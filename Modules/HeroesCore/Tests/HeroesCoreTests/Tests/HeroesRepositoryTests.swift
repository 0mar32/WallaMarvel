//
//  HeroesRepositoryTests.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 18/8/25.
//
//
//  HeroesRepositoryTests.swift
//  HeroesCore
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
        sut  = HeroesRepository(apiService: api, storageService: store)
    }

    override func tearDown() {
        sut = nil; store = nil; api = nil
        super.tearDown()
    }

    // MARK: - Non-stream path (pagination / direct page)

    func test_fetchHeroes_whenOffsetGreaterThanZero_fetchesThatPageAndStores() async throws {
        // given
        store.stubbedAllHeroes = (1...20).map { .sample(id: $0, name: "C\($0)") }

        let pageDto = HeroesContainerDto.sample(
            count: 5, limit: 5, offset: 15, total: 100,
            results: (16...20).map { .sample(id: $0, name: "P\($0)") }
        )
        api.enqueue(.success(.sample(data: pageDto)))

        // when
        let page = try await sut.fetchHeroes(limit: 5, offset: 15)

        // then
        XCTAssertEqual(store.recordedStores.first?.offset, 15)
        XCTAssertEqual(page.characters.map(\.name), ["P16","P17","P18","P19","P20"])
    }

    func test_fetchHeroes_mapsErrors() async {
        enum DummyError: Error { case boom }
        store.stubbedAllHeroes = []            // no cache → direct remote
        api.enqueue(.failure(DummyError.boom)) // then fail

        await XCTAssertThrowsErrorAsync(try await sut.fetchHeroes(limit: 5, offset: 0)) { error in
            XCTAssertTrue((error as? HeroesError) == .generic) // 1 assert
        }

        store.stubbedAllHeroes = []
        api.enqueue(.failure(NetworkError.noInternet))

        await XCTAssertThrowsErrorAsync(try await sut.fetchHeroes(limit: 5, offset: 0)) { error in
            XCTAssertTrue((error as? HeroesError) == .offline) // 1 assert
        }
    }

    // MARK: - Stream path (offset 0): cache → fresh

    func test_stream_withCache_emitsCachedThenFresh() async throws {
        // given
        givenCachedHeroes(250)
        enqueueRefreshPages(total: 250)

        // when
        let stream = sut.fetchHeroesStream(limit: 10, offset: 0)
        let result = await collectFromAsyncStream(stream)

        // then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.count, 250)
        XCTAssertEqual(result.items.last?.total, 250)
    }

    func test_stream_largeCache_paginatesHundreds_andReturnsFullFresh() async {
        // given
        givenCachedHeroes(250)
        enqueueRefreshPages(total: 250)

        // when
        let result = await collectFromAsyncStream(sut.fetchHeroesStream(limit: 10, offset: 0))

        // then
        XCTAssertEqual(api.recordedRequests.map(\.offset), [0,100,200])
        XCTAssertEqual(store.recordedStores.map(\.offset), [0,100,200])
        XCTAssertEqual(result.items.last?.count, 250)
    }

    func test_stream_withCache_refreshIsPagedAndStored() async throws {
        // given
        givenCachedHeroes(250)
        enqueueRefreshPages(total: 250)

        // when
        _ = await collectFromAsyncStream(sut.fetchHeroesStream(limit: 10, offset: 0))

        // then
        XCTAssertEqual(api.recordedRequests, [
            .init(limit: 100, offset: 0),
            .init(limit: 100, offset: 100),
            .init(limit: 50,  offset: 200)
        ])
        XCTAssertEqual(store.recordedStores.map(\.offset), [0, 100, 200])
    }

    func test_stream_noCache_emitsFreshOnly() async throws {
        // given
        store.stubbedAllHeroes = []
        let dto = HeroesContainerDto.sample(
            count: 3, limit: 3, offset: 0, total: 3,
            results: [.sample(id: 1, name: "A"), .sample(id: 2, name: "B"), .sample(id: 3, name: "C")]
        )
        api.enqueue(.success(.sample(data: dto)))

        // when
        let stream = sut.fetchHeroesStream(limit: 3, offset: 0)
        let result = await collectFromAsyncStream(stream)

        // then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.characters.map(\.name), ["A","B","C"])
    }

    func test_stream_withCache_offlineDuringRefresh_emitsCachedThenThrowsOffline() async throws {
        // given
        givenCachedHeroes(10)
        api.enqueue(.failure(NetworkError.noInternet))

        // when
        let stream = sut.fetchHeroesStream(limit: 10, offset: 0)
        let result = await collectFromAsyncStream(stream)

        // then
        XCTAssertEqual(result.items.count, 1) // cached only
        XCTAssertTrue((result.error as? HeroesError) == .offline)
    }

    func test_stream_cache50_limit80_refreshesTo80() async {
        // given
        givenCachedHeroes(50)
        // one network call of 80 (<= 100)
        let dto = HeroesContainerDto.sample(
            count: 80, limit: 80, offset: 0, total: 200,
            results: (1...80).map { .sample(id: $0, name: "R\($0)") }
        )
        api.enqueue(.success(.sample(data: dto)))

        // when
        let result = await collectFromAsyncStream(sut.fetchHeroesStream(limit: 80, offset: 0))

        // then (2 asserts)
        XCTAssertEqual(api.recordedRequests, [.init(limit: 80, offset: 0)])
        XCTAssertEqual(result.items.last?.count, 80)
    }
}

// MARK: - Helpers

private extension HeroesRepositoryTests {
    func givenCachedHeroes(_ count: Int) {
        store.stubbedAllHeroes = (1...count).map { .sample(id: $0, name: "H\($0)") }
    }

    func enqueueRefreshPages(total: Int) {
        var remaining = total
        var start = 1
        while remaining > 0 {
            let pageCount = min(100, remaining)
            let results = (start..<(start + pageCount))
                .map { HeroDto.sample(id: $0, name: "R\($0)") }
            let dto = HeroesContainerDto.sample(
                count: pageCount, limit: pageCount, offset: start - 1, total: total, results: results
            )
            api.enqueue(.success(.sample(data: dto)))
            start += pageCount
            remaining -= pageCount
        }
    }
}
