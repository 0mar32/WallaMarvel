//
//  Untitled.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

import XCTest
import UnitTestingUtils

@testable import HeroesCoreTestingMocks
@testable import HeroesCore

final class HeroesPaginationInteractorTests: XCTestCase {
    private var repo: HeroesRepositoryMock!
    private var sut: HeroesPaginationInteractor!

    override func setUp() async throws {
        try await super.setUp()
        repo = HeroesRepositoryMock()
        sut  = HeroesPaginationInteractor(repository: repo, limit: 20)
    }

    override func tearDown() async throws {
        sut = nil
        repo = nil
        try await super.tearDown()
    }

    // MARK: - initialStream

    func test_initialStream_emitsCacheThenFresh_andPrimesPagination() async throws {
        // given
        let cache = HeroesContainer.sample(
            count: 20, limit: 20, offset: 0, total: 100,
            characters: (1...20).map { .sample(id: $0, name: "C\($0)") }
        )
        let fresh = HeroesContainer.sample(
            count: 20, limit: 20, offset: 0, total: 100,
            characters: (1...20).map { .sample(id: $0, name: "R\($0)") }
        )
        repo.streamPlan = .cacheThenFresh(cache: cache, fresh: fresh)

        // when
        let stream = await sut.initialStream()
        let result = await collectFromAsyncStream(stream)

        // then
        XCTAssertEqual(result.items.map(\.characters.first?.name), ["C1", "R1"])
        XCTAssertNil(result.error)

        // pagination now starts at offset 20
        repo.pageResultsQueue = [
            .success(.sample(
                count: 20, limit: 20, offset: 20, total: 100,
                characters: (21...40).map { .sample(id: $0) }
            ))
        ]
        let page = try await sut.fetchNextPage()
        XCTAssertEqual(repo.recordedRequests, [.init(limit: 20, offset: 20)])
        XCTAssertEqual(page.count, 20)
    }

    func test_initialStream_emitsCache_thenOfflineError() async throws {
        // given
        let cache = HeroesContainer.sample(
            count: 5, limit: 5, offset: 0, total: 100,
            characters: (1...5).map { .sample(id: $0) }
        )
        repo.streamPlan = .cacheThenError(cache: cache, error: HeroesError.offline)

        // when
        let stream = await sut.initialStream()
        let result = await collectFromAsyncStream(stream)

        // then (2 asserts)
        XCTAssertEqual(result.items.count, 1) // cached only
        XCTAssertTrue((result.error as? HeroesError) == .offline)
    }

    func test_initialStream_calledTwice_concurrently_rejectsSecond() async {
        // given
        let gate = CallGate(); await gate.close()

        let cache = HeroesContainer.sample(count: 1, limit: 1, offset: 0, total: 10,
                                           characters: [.sample(id: 1)])
        let fresh = HeroesContainer.sample(count: 1, limit: 1, offset: 0, total: 10,
                                           characters: [.sample(id: 1)])

        // when
        repo.streamPlan = .cacheThenFreshGated(cache: cache, fresh: fresh, gate: gate)

        // act: start first stream and actively consume so interactor installs its gate
        let first = await sut.initialStream()
        let firstCollector = Task { await collectFromAsyncStream(first) }

        // ensure producer is actually blocked (first is in-flight)
        await gate.waitUntilBlocked()

        // second call must be rejected while first is running
        let second = await sut.initialStream()
        let secondResult = await collectFromAsyncStream(second)

        // Then
        // assert
        XCTAssertEqual(secondResult.error as? PaginationError, .refreshInProgress)

        // cleanup: let first finish and assert it produced 2 items (cache+fresh)
        await gate.openGate()
        let firstResult = await firstCollector.value
        XCTAssertEqual(firstResult.items.count, 2)
    }

    // MARK: - fetchNextPage

    func test_fetchNextPage_waitsUntil_initialStream_finishes() async throws {
        // given
        // First stream stays running (cache first, then wait on gate before fresh)
        let gate = CallGate()
        await gate.close()
        let cache = HeroesContainer.sample(count: 20, limit: 20, offset: 0, total: 40,
                                           characters: (1...20).map { .sample(id: $0) })
        let fresh = HeroesContainer.sample(count: 20, limit: 20, offset: 0, total: 40,
                                           characters: (1...20).map { .sample(id: $0) })

        // when
        repo.streamPlan = .cacheThenFreshGated(cache: cache, fresh: fresh, gate: gate)

        let stream = await sut.initialStream()

        // Schedule pagination; it should WAIT until gate opens (initial finishes)
        repo.pageResultsQueue = [
            .success(.sample(
                count: 20, limit: 20, offset: 20, total: 40,
                characters: (21...40).map { .sample(id: $0) }
            ))
        ]
        let nextTask = Task { [sut] in
            try await sut?.fetchNextPage()
        }

        // ensure initial is running (optional)
        await gate.waitUntilBlocked()

        // now let initial finish
        await gate.openGate()

        // then
        // collect stream to completion (cache + fresh)
        let result = await collectFromAsyncStream(stream)
        XCTAssertEqual(result.items.count, 2) // cache, fresh

        // pagination should now succeed at offset 20
        let page = try await nextTask.value
        XCTAssertEqual(page?.count, 20)
    }

    func test_fetchNextPage_noMorePages_afterFresh_throws() async throws {
        // given
        // fresh == total → no more pages
        let fresh = HeroesContainer.sample(
            count: 20, limit: 20, offset: 0, total: 20,
            characters: (1...20).map { .sample(id: $0) }
        )

        // when
        repo.streamPlan = .freshOnly(fresh: fresh)

        _ = await collectFromAsyncStream(await sut.initialStream())

        // then
        do {
            _ = try await sut.fetchNextPage()
            XCTFail("Expected noMorePages")
        } catch let e as PaginationError {
            XCTAssertEqual(e, .noMorePages)
        } catch {
            XCTFail("Expected PaginationError.noMorePages, got \(error)")
        }
    }

    func test_initialStream_cacheThenError_allowsRetry() async {
        // given
        let cache = HeroesContainer.sample(count: 1, limit: 1, offset: 0, total: 10,
                                           characters: [.sample(id: 1)])

        // when
        repo.streamPlan = .cacheThenError(cache: cache, error: HeroesError.offline)

        let first = await sut.initialStream()
        let r1 = await collectFromAsyncStream(first)
        // then
        XCTAssertEqual(r1.items.count, 1)
        XCTAssertEqual(r1.error as? HeroesError, .offline)

        // After failure, gate must be cleared → can start again
        repo.streamPlan = .freshOnly(fresh: cache) // reuse cache as a “fresh” for simplicity
        let second = await sut.initialStream()
        let r2 = await collectFromAsyncStream(second)
        // then
        XCTAssertEqual(r2.items.count, 1)
        XCTAssertNil(r2.error)
    }

    func test_hasMorePages_cacheOnly_true_then_fresh_exhausted_false() async {
        // given
        // 1) cache only (total nil) → true
        let cacheOnly = HeroesContainer.sample(count: 10, limit: 10, offset: 0, total: nil,
                                               characters: (1...10).map { .sample(id: $0) })
        // when
        repo.streamPlan = .cacheOnly(cache: cacheOnly)
        _ = await collectFromAsyncStream(await sut.initialStream())
        var more = await sut.hasMorePages

        // then
        XCTAssertTrue(more)

        // 2) fresh says total == count → false
        let fresh = HeroesContainer.sample(count: 10, limit: 10, offset: 0, total: 10,
                                           characters: (1...10).map { .sample(id: $0) })
        repo.streamPlan = .freshOnly(fresh: fresh)
        _ = await collectFromAsyncStream(await sut.initialStream())
        more = await sut.hasMorePages

        // then
        XCTAssertFalse(more)
    }

    func test_fetchNextPage_withoutInitial_startsFromZero() async throws {
        // given
        repo.pageResultsQueue = [
            .success(.sample(count: 20, limit: 20, offset: 0, total: 40,
                             characters: (1...20).map { .sample(id: $0) }))
        ]

        // when
        let page = try await sut.fetchNextPage()

        // then
        XCTAssertEqual(page.count, 20)
        XCTAssertEqual(repo.recordedRequests, [.init(limit: 20, offset: 0)])
    }

    func test_reset_clearsCounters_allowsNewInitial() async {
        // given
        // prime with a fresh (sets offset=20, total=40)
        let fresh = HeroesContainer.sample(count: 20, limit: 20, offset: 0, total: 40,
                                           characters: (1...20).map { .sample(id: $0) })
        // when
        repo.streamPlan = .freshOnly(fresh: fresh)
        _ = await collectFromAsyncStream(await sut.initialStream())

        await sut.reset()

        // new initial should run cleanly again
        repo.streamPlan = .freshOnly(fresh: fresh)
        // then
        let r = await collectFromAsyncStream(await sut.initialStream())
        XCTAssertEqual(r.items.count, 1)
        XCTAssertNil(r.error)
    }

}
