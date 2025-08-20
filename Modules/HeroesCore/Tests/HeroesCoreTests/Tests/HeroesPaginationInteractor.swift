//
//  Untitled.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

import XCTest
@testable import HeroesCoreTestingMocks
@testable import HeroesCore

final class HeroesPaginationInteractorTests: XCTestCase {

    private var repo: HeroesRepositoryMock!
    private var sut: HeroesPaginationInteractor!

    override func setUp() async throws {
        try await super.setUp()
        repo = HeroesRepositoryMock()
        sut = HeroesPaginationInteractor(repository: repo, limit: 20)
    }

    override func tearDown() async throws {
        sut = nil
        repo = nil
        try await super.tearDown()
    }

    // MARK: - refresh()

    func test_refresh_startsSubscription_setsOffsetAndTotal_andReturnsFirstPage() async throws {
        // given
        let firstPage = HeroesContainer.sample(
            count: 20, limit: 20, offset: 0, total: 100,
            characters: (1...20).map { .sample(id: $0, name: "R\($0)") }
        )
        repo.results = [.success(firstPage)]

        // when
        let result = try await sut.refresh()

        // then
        XCTAssertEqual(result.count, 20)
        XCTAssertEqual(result.total, 100)
        XCTAssertEqual(repo.recordedRequests, [.init(limit: 20, offset: 0)])
        let more = await sut.hasMorePages
        XCTAssertTrue(more)
    }

    func test_refresh_rejectsWhileAlreadyRefreshing() async {
        let gate = CallGate()
        await gate.close()
        repo.gate = gate
        repo.results = [.success(.sample(
            count: 20, limit: 20, offset: 0, total: 40,
            characters: (1...20).map { .sample(id: $0) }
        ))]

        let firstTask = Task { [sut] in try await sut?.refresh() }

        // Wait until the first refresh is actually blocked at the gate
        await gate.waitUntilBlocked()

        // Now the actor is in "refreshing" state — second refresh should throw
        do {
            _ = try await sut.refresh()
            XCTFail("Expected refreshInProgress")
        } catch let e as PaginationError {
            XCTAssertEqual(e, .refreshInProgress)
        } catch {
            XCTFail("Expected PaginationError.refreshInProgress, got \(error)")
        }

        await gate.openGate()
        _ = try? await firstTask.value
    }

    // MARK: - hasMorePages flag

    func test_hasMorePages_thereAreMorePagesToLoad_shouldReturnTrue() async throws {
        repo.results = [.success(.sample(
            count: 20, limit: 20, offset: 0, total: 100,
            characters: (1...20).map { .sample(id: $0) }
        ))]

        _ = try await sut.refresh()
        let more = await sut.hasMorePages
        XCTAssertTrue(more)
    }

    func test_hasMorePages_thereAreNoMorePagesToLoad_shouldReturnFalse() async throws {
        repo.results = [.success(.sample(
            count: 20, limit: 20, offset: 0, total: 20,
            characters: (1...20).map { .sample(id: $0) }
        ))]

        _ = try await sut.refresh()
        let more = await sut.hasMorePages
        XCTAssertFalse(more)
    }

    // MARK: - Cache snapshot primes offset automatically

    func test_cacheSnapshot_primesOffset_beforeFirstPagination() async throws {
        // given: repository publish cached snapshot of 40/100
        repo.emitCache(.sample(
            count: 40, limit: 40, offset: 0, total: 100,
            characters: (1...40).map { .sample(id: $0, name: "C\($0)") }
        ))

        // refresh returns the first 40 items (this is what the interactor will trust)
        repo.results = [.success(.sample(
            count: 40, limit: 40, offset: 0, total: 100,
            characters: (1...40).map { .sample(id: $0, name: "R\($0)") }
        ))]

        // when: run the real initial load
        _ = try await sut.refresh() // sets offset = 40, total = 100

        // and now fetch the next page (offset 40)
        repo.results.append(.success(.sample(
            count: 20, limit: 20, offset: 40, total: 100,
            characters: (41...60).map { .sample(id: $0, name: "R\($0)") }
        )))

        let result = try await sut.fetchNextPage()

        // then: first call was refresh at offset 0, second is pagination at offset 40
        XCTAssertEqual(repo.recordedRequests, [
            .init(limit: 20, offset: 0),
            .init(limit: 20, offset: 40)
        ])
        XCTAssertEqual(result.count, 20)
    }

    // MARK: - fetchNextPage()

    func test_fetchNextPage_incrementsOffset_andUpdatesTotal() async throws {
        // first page via refresh
        repo.results = [.success(.sample(
            count: 20, limit: 20, offset: 0, total: 60,
            characters: (1...20).map { .sample(id: $0) }
        ))]
        _ = try await sut.refresh()

        // second page
        repo.results.append(.success(.sample(
            count: 20, limit: 20, offset: 20, total: 60,
            characters: (21...40).map { .sample(id: $0) }
        )))
        let second = try await sut.fetchNextPage()

        XCTAssertEqual(second.count, 20)
        XCTAssertEqual(repo.recordedRequests, [
            .init(limit: 20, offset: 0),
            .init(limit: 20, offset: 20)
        ])
        let more = await sut.hasMorePages
        XCTAssertTrue(more)
    }

    func test_fetchNextPage_whileRefreshing_waitsAndThenContinues() async throws {
        let gate = CallGate()
        await gate.close()
        repo.gate = gate

        repo.results = [
            .success(.sample(
                count: 20, limit: 20, offset: 0, total: 40,
                characters: (1...20).map { .sample(id: $0) }
            )),
            .success(.sample(
                count: 20, limit: 20, offset: 20, total: 40,
                characters: (21...40).map { .sample(id: $0) }
            ))
        ]

        guard let interactor = sut else {
            return XCTFail("sut is nil")
        }

        let refreshTask = Task { try await interactor.refresh() }

        // deterministically wait until refresh() is actually blocked on the gate
        await gate.waitUntilBlocked()

        let nextTask = Task { try await interactor.fetchNextPage() }

        await gate.openGate()

        let refreshed = try await refreshTask.value
        let page = try await nextTask.value

        XCTAssertEqual(refreshed.count, 20)
        XCTAssertEqual(page.count, 20)
        XCTAssertEqual(repo.recordedRequests, [
            .init(limit: 20, offset: 0),
            .init(limit: 20, offset: 20)
        ])
    }


    func test_fetchNextPage_propagatesOfflineError() async {
        // cache primes total so pagination allowed
        repo.emitCache(.sample(count: 0, limit: 0, offset: 0, total: 100, characters: []))

        // next page fails with offline
        repo.results = [.failure(HeroesError.offline)]

        do {
            _ = try await sut.fetchNextPage()
            XCTFail("Expected HeroesError.offline")
        } catch let e as HeroesError {
            XCTAssertEqual(e, .offline)
        } catch {
            XCTFail("Expected HeroesError.offline, got \(error)")
        }
    }
}
