//
//  HeroesRepositoryTests.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 18/8/25.
//
import XCTest
import NetworkClient
import UnitTestingUtils

@testable import HeroesCoreTestingMocks
@testable import HeroesCore

final class HeroesRepositoryTests: XCTestCase {

    private var api: HeroesAPIServiceMock!
    private var store: HeroesStorageServiceMock!
    private var sut: HeroesRepository!

    override func setUp() {
        super.setUp()
        api = HeroesAPIServiceMock()
        store = HeroesStorageServiceMock()
        sut = HeroesRepository(apiService: api, storageService: store)
    }

    override func tearDown() {
        sut = nil
        store = nil
        api = nil
        super.tearDown()
    }

    // MARK: - Empty cache → first-time remote fetch, store, return

    func test_fetchHeroes_whenCacheEmpty_fetchesRemoteStoresAndReturns() async throws {
        // given
        store.stubbedAllHeroes = [] // empty cache

        let remoteContainerDto = HeroesContainerDto.sample(
            count: 2, limit: 2, offset: 0, total: 10,
            results: [
                .sample(id: 1, name: "A"),
                .sample(id: 2, name: "B")
            ]
        )
        api.enqueue(.success(.sample(data: remoteContainerDto)))

        // when
        let result = try await sut.fetchHeroes(limit: 2, offset: 0)

        // then
        XCTAssertEqual(api.recordedRequests, [.init(limit: 2, offset: 0)])
        XCTAssertEqual(store.recordedStores.count, 1)
        XCTAssertEqual(store.recordedStores.first?.offset, 0)
        XCTAssertEqual(store.recordedStores.first?.heroes.count, 2)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.characters.map(\.name), ["A", "B"])

        // No cached-yield on first-time fetch
        let noYield = await AsyncStreamCollector(sut.heroesPublisher).first(timeout: 0.1)
        XCTAssertNil(noYield)
    }

    func test_offsetZero_yieldsCachedSnapshot() async throws {
        givenCachedHeroes(250)
        enqueueRefreshPages(total: 250)
        let collector = AsyncStreamCollector(sut.heroesPublisher)

        let _ = try await sut.fetchHeroes(limit: 10, offset: 0)

        let yielded = await collector.first(timeout: 1.0)
        XCTAssertNotNil(yielded)
        XCTAssertEqual(yielded?.count, 250)
        XCTAssertEqual(yielded?.characters.first?.name, "H1")
        XCTAssertEqual(yielded?.characters.last?.name,  "H250")
    }

    func test_offsetZero_storesEachPageAtCorrectOffset() async throws {
        givenCachedHeroes(250)
        enqueueRefreshPages(total: 250)

        _ = try await sut.fetchHeroes(limit: 10, offset: 0)

        XCTAssertEqual(store.recordedStores.count, 3)
        XCTAssertEqual(store.recordedStores.map(\.offset), [0, 100, 200])
        XCTAssertEqual(store.recordedStores.map { $0.heroes.count }, [100, 100, 50])
    }

    func test_offsetZero_returnsFullyRefreshedContainer() async throws {
        givenCachedHeroes(250)
        enqueueRefreshPages(total: 250)

        let refreshed = try await sut.fetchHeroes(limit: 10, offset: 0)

        XCTAssertEqual(refreshed.count, 250)
        XCTAssertEqual(refreshed.characters.first?.name, "R1")
        XCTAssertEqual(refreshed.characters.last?.name,  "R250")
        XCTAssertEqual(refreshed.total, 250)
    }

    func test_offsetZero_refreshesInPagesOfMax100WithCorrectOffsets() async throws {
        givenCachedHeroes(250)
        enqueueRefreshPages(total: 250)

        _ = try await sut.fetchHeroes(limit: 10, offset: 0)

        XCTAssertEqual(api.recordedRequests, [
            .init(limit: 100, offset: 0),
            .init(limit: 100, offset: 100),
            .init(limit: 50,  offset: 200)
        ])
    }

    // MARK: - Offset > 0 → fetch one page and store

    func test_fetchHeroes_whenOffsetGreaterThanZero_fetchesThatPageAndStores() async throws {
        // given
        store.stubbedAllHeroes = (1...20).map { .sample(id: $0, name: "C\($0)") } // existing cache shouldn't matter

        let pageDto = HeroesContainerDto.sample(
            count: 5,
            limit: 5,
            offset: 15,
            total: 100,
            results: (16...20).map {
                .sample(id: $0, name: "P\($0)")
            }
        )
        api.enqueue(.success(.sample(data: pageDto)))

        // when
        let page = try await sut.fetchHeroes(limit: 5, offset: 15)

        // then
        XCTAssertEqual(api.recordedRequests, [.init(limit: 5, offset: 15)])
        XCTAssertEqual(store.recordedStores.count, 1)
        XCTAssertEqual(store.recordedStores.first?.offset, 15)
        XCTAssertEqual(store.recordedStores.first?.heroes.map(\.name), ["P16","P17","P18","P19","P20"])

        XCTAssertEqual(page.count, 5)
        XCTAssertEqual(page.characters.map(\.name), ["P16","P17","P18","P19","P20"])

        // No cached-yield for non-zero offset path
        let noYield = await AsyncStreamCollector(sut.heroesPublisher).first(timeout: 0.1)
        XCTAssertNil(noYield)
    }

    // MARK: - Cached data & offset == 0 → yield cached, refresh in pages of up to 100, store each page, return refreshed

    func test_fetchHeroes_whenOffsetZeroWithCache_yieldsCachedThenRefreshesPagedAndStoresAllPages() async throws {
        // given: cached 250 heroes, sorted
        store.stubbedAllHeroes = (1...250).map {
            Hero.sample(id: $0, name: "H\($0)")
        }

        // will refresh in pages of 100,100,50 with offsets 0,100,200
        func pageDto(startID: Int, count: Int, total: Int = 250) -> HeroesContainerDto {
            let results = (startID..<(startID+count)).map {
                HeroDto.sample(id: $0, name: "R\($0)")
            }
            return HeroesContainerDto.sample(
                count: count,
                limit: count,
                offset: startID - 1,
                total: total,
                results: results
            )
        }

        api.enqueue(.success(.sample(data: pageDto(startID: 1,   count: 100))))
        api.enqueue(.success(.sample(data: pageDto(startID: 101, count: 100))))
        api.enqueue(.success(.sample(data: pageDto(startID: 201, count: 50))))

        // collect the first yield from the AsyncStream (should be cached)
        let collector = AsyncStreamCollector(sut.heroesPublisher)

        // when
        let refreshed = try await sut.fetchHeroes(limit: 10, offset: 0) // limit ignored during refresh loop

        // then: first yield is cached snapshot
        if let yieldedCached = await collector.first(timeout: 1.0) {
            XCTAssertEqual(yieldedCached.count, 250)
            XCTAssertEqual(yieldedCached.characters.first?.name, "H1")
            XCTAssertEqual(yieldedCached.characters.last?.name, "H250")
        } else {
            XCTFail("Expected cached container to be yielded before refresh.")
        }

        // API called in 3 pages (100/100/50) with offsets 0/100/200
        XCTAssertEqual(api.recordedRequests, [
            .init(limit: 100, offset: 0),
            .init(limit: 100, offset: 100),
            .init(limit: 50,  offset: 200)
        ])

        // Each page stored at its page offset
        XCTAssertEqual(store.recordedStores.count, 3)
        XCTAssertEqual(store.recordedStores.map(\.offset), [0, 100, 200])
        XCTAssertEqual(store.recordedStores.map { $0.heroes.count }, [100, 100, 50])

        // Returned container is the fully refreshed remote list
        XCTAssertEqual(refreshed.count, 250)
        XCTAssertEqual(refreshed.characters.first?.name, "R1")
        XCTAssertEqual(refreshed.characters.last?.name, "R250")
        XCTAssertEqual(refreshed.total, 250)
    }

    // MARK: - Error mapping

    func test_fetchHeroes_mapsGenericErrorsToGeneric() async {
        enum DummyError: Error {
            case error
        }
        // given
        store.stubbedAllHeroes = [] // triggers first-time remote fetch

        api.enqueue(.failure(DummyError.error))

        // when/then
        await XCTAssertThrowsErrorAsync(
            try await sut.fetchHeroes(limit: 5, offset: 0)
        ) { error in
            guard let heroesError = error as? HeroesError else {
                return XCTFail("Expected HeroesError, got \(error)")
            }
            guard case .generic = heroesError else {
                return XCTFail("Expected .generic, got \(heroesError)")
            }
        }
    }

    /// If your app exposes `NetworkError.noInternet`, this test checks `.offline` mapping.
    /// If it conflicts with an existing type, delete this local enum and import the real one.
    func test_fetchHeroes_mapsNoInternetToOffline() async {
        store.stubbedAllHeroes = []
        api.enqueue(.failure(NetworkError.noInternet))

        await XCTAssertThrowsErrorAsync(try await sut.fetchHeroes(limit: 5, offset: 0)) { error in
            guard let heroesError = error as? HeroesError else {
                return XCTFail("Expected HeroesError, got \(error)")
            }
            guard case .offline = heroesError else {
                return XCTFail("Expected .offline, got \(heroesError)")
            }
        }
    }
}

private extension HeroesRepositoryTests {
    func givenCachedHeroes(_ count: Int) {
        store.stubbedAllHeroes = (1...count).map { .sample(id: $0, name: "H\($0)") }
    }

    func enqueueRefreshPages(total: Int) {
        // pages of 100
        var remaining = total
        var start = 1
        while remaining > 0 {
            let pageCount = min(100, remaining)
            let results = (start..<(start + pageCount)).map { HeroDto.sample(id: $0, name: "R\($0)") }
            let dto = HeroesContainerDto.sample(count: pageCount, limit: pageCount, offset: start - 1, total: total, results: results)
            api.enqueue(.success(.sample(data: dto)))
            start += pageCount
            remaining -= pageCount
        }
    }
}
