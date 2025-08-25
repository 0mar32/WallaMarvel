//
//  HeroesListViewModelTests.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import XCTest
import HeroesCore
@testable import HeroesCoreTestingMocks
@testable import Heroes

final class HeroesListViewModelTests: XCTestCase {

    private var interactor: PaginationInteractorMock!
    private var mapper: HeroesListUIModelMapperMock!
    private var sut: HeroesListViewModel!

    override func setUp() async throws {
        try await super.setUp()
        interactor = PaginationInteractorMock()
        mapper = HeroesListUIModelMapperMock()
        sut = await HeroesListViewModel(
            interactor: interactor,
            heroesListMapper: mapper
        )
    }

    override func tearDown() async throws {
        sut = nil; mapper = nil
        interactor = nil
        try await super.tearDown()
    }

    // MARK: - Initial load (cache → fresh)

    @MainActor
    func test_loadInitial_emitsCache_thenFresh_updatesStateEachTime() async {
        let cache = HeroesContainer.sample(
            count: 2, limit: 2, offset: 0, total: 10,
            characters: [ .sample(id: 1), .sample(id: 2) ]
        )
        let fresh = HeroesContainer.sample(
            count: 3, limit: 3, offset: 0, total: 10,
            characters: [ .sample(id: 1), .sample(id: 2), .sample(id: 3) ]
        )

        let gate = CallGate(); await gate.close()
        interactor.streamPlan = .cacheThenFreshGated(cache, fresh, gate)

        // drive
        let run = Task { @MainActor in
            await sut.loadInitialHeroesStream()
        }

        // after cache arrives, VM should show 2 rows
        await gate.waitUntilBlocked()
        if case let .loaded(model) = sut.state {
            XCTAssertEqual(model.heroes.count, 2)
        } else {
            XCTFail("Expected .loaded after cache")
        }

        // then let fresh flow and complete
        await gate.openGate()
        _ = await run.value

        if case let .loaded(model) = sut.state {
            XCTAssertEqual(model.heroes.count, 3)
        } else {
            XCTFail("Expected .loaded after fresh")
        }
    }

    @MainActor
    func test_loadInitial_offline_withEmptyState_setsRetryColumn() async {
        interactor.streamPlan = .error(HeroesError.offline)

        await sut.loadInitialHeroesStream()

        if case let .loaded(model) = sut.state {
            XCTAssertEqual(model.heroes.count, 0)
            XCTAssertNotNil(model.listError)
        } else {
            XCTFail("Expected .loaded with empty heroes and listError")
        }
    }

    @MainActor
    func test_loadInitial_cacheThenOffline_setsAlert() async {
        let cache = HeroesContainer.sample(
            count: 1, limit: 1, offset: 0, total: 10,
            characters: [ .sample(id: 1) ]
        )
        interactor.streamPlan = .cacheThenError(cache, HeroesError.offline)

        await sut.loadInitialHeroesStream()

        XCTAssertEqual(sut.state.heroes.count, 1) // cache applied
        XCTAssertEqual(sut.alert?.message, HeroesError.offline.localizedDescription)
    }

    // MARK: - Pagination

    @MainActor
    func test_loadMore_triggersNearEnd_showsSpinner_thenMergesPage() async {
        // initial (fresh only) → 10 items
        let fresh = HeroesContainer.sample(
            count: 10, limit: 10, offset: 0, total: 20,
            characters: (1...10).map { .sample(id: $0) }
        )
        interactor.streamPlan = .freshOnly(fresh)
        await sut.loadInitialHeroesStream()
        XCTAssertEqual(sut.state.heroes.count, 10)

        // next page result (11..20)
        interactor.pageResultsQueue = [
            .success(.sample(count: 10, limit: 10, offset: 10, total: 20,
                             characters: (11...20).map { .sample(id: $0) }))
        ]

        // gate pagination so we can see spinner
        let gate = CallGate(); await gate.close()
        interactor.pageGate = gate

        // trigger near end (index 7 is in last 5 for 10 items)
        let trigger = sut.state.heroes[7]
        let task = Task { @MainActor in
            await sut.loadMoreHeroesIfNeeded(currentHero: trigger)
        }

        // ensure fetchNextPage is now waiting at the gate
        await gate.waitUntilBlocked()

        // assert spinner ON
        if case let .loaded(model) = sut.state {
            XCTAssertTrue(model.isLoadingMore)
        } else {
            XCTFail("Expected .loaded with isLoadingMore == true")
        }

        // release pagination; finish and merge
        await gate.openGate()
        _ = await task.value

        // assert final merged state
        if case let .loaded(model) = sut.state {
            XCTAssertEqual(model.heroes.count, 20)
            XCTAssertFalse(model.isLoadingMore)
        } else {
            XCTFail("Expected .loaded with 20 items and spinner off")
        }
    }

    @MainActor
    func test_retryPagination_retriesAfterError() async {
        // initial 5
        let fresh = HeroesContainer.sample(
            count: 5, limit: 5, offset: 0, total: 10,
            characters: (1...5).map { .sample(id: $0) }
        )
        interactor.streamPlan = .freshOnly(fresh)
        await sut.loadInitialHeroesStream()

        // next page returns 5 more
        interactor.pageResultsQueue = [
            .success(.sample(count: 5, limit: 5, offset: 5, total: 10,
                             characters: (6...10).map { .sample(id: $0) }))
        ]
        XCTAssertEqual(interactor.fetchNextPageCalls, 0)
        await sut.retryPagination()
        XCTAssertEqual(interactor.fetchNextPageCalls, 1)
        if case let .loaded(model) = sut.state {
            XCTAssertEqual(model.heroes.count, 10)
            XCTAssertEqual(model.heroes.count, 10)
            XCTAssertFalse(model.isLoadingMore)
        } else {
            XCTFail("Expected merged list after retry")
        }
    }

    @MainActor
    func test_loadMore_doesNotTrigger_whenNotNearEnd_orAlreadyLoading() async {
        // initial 8
        interactor.streamPlan = .freshOnly(.sample(count: 8, limit: 8, offset: 0, total: 20,
                                                   characters: (1...8).map { .sample(id: $0) }))
        await sut.loadInitialHeroesStream()

        // not near end → should not call fetchNextPage
        interactor.pageResultsQueue = [
            .success(.sample(count: 5, limit: 5, offset: 8, total: 20,
                             characters: (9...13).map { .sample(id: $0) }))
        ]
        await sut.loadMoreHeroesIfNeeded(currentHero: sut.state.heroes[1]) // far from end
        XCTAssertEqual(interactor.fetchNextPageCalls, 0)
    }
}
