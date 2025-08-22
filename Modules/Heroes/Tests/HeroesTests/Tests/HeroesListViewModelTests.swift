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
    private var mapper: HeroesListMapperMock!
    private var sut: HeroesListViewModel!

    override func setUp() async throws {
        try await super.setUp()
        interactor = PaginationInteractorMock()
        mapper = HeroesListMapperMock()
        sut = await MainActor.run { [interactor, mapper] in
            HeroesListViewModel(interactor: interactor!, heroesListMapper: mapper!)
        }
    }

    override func tearDown() async throws {
        sut = nil
        mapper = nil
        interactor = nil
        try await super.tearDown()
    }

    // MARK: - Initial load (no waiting helpers needed)

    @MainActor
    func test_loadInitialHeroes_success_setsLoaded() async throws {
        // given
        interactor.mockRefresh(.success(.sample(
            count: 2, limit: 2, offset: 0, total: 10,
            characters: [.sample(id: 1, name: "A"), .sample(id: 2, name: "B")]
        )))

        // when
        await sut.loadInitialHeroes()

        // then
        guard case let .loaded(heroes, isLoadingMore, paginationError) = sut.state else {
            return XCTFail("Expected .loaded")
        }
        XCTAssertEqual(heroes.map(\.name), ["A","B"])
        XCTAssertFalse(isLoadingMore)
        XCTAssertFalse(paginationError)
    }

    @MainActor
    func test_loadInitialHeroes_offlineEmptyCache_setsLoadedWithPaginationErrorTrue() async {
        interactor.mockRefresh(.failure(HeroesError.offline))

        await sut.loadInitialHeroes()

        guard case let .loaded(heroes, isLoadingMore, paginationError) = sut.state else {
            return XCTFail("Expected .loaded with paginationError")
        }
        XCTAssertTrue(heroes.isEmpty)
        XCTAssertFalse(isLoadingMore)
        XCTAssertTrue(paginationError)
    }

    // MARK: - Pagination (async VM methods; just await them)

    @MainActor
    func test_loadMoreHeroesIfNeeded_mergesNewItems() async {
        // seed cache by emitting + awaiting next state (only place we await the publisher)
        interactor.emitCache(.sample(
            count: 10, limit: 10, offset: 0, total: 30,
            characters: (1...10).map { .sample(id: $0, name: "H\($0)") }
        ))
        _ = await waitForState { state in
            if case let .loaded(heroes, _, _) = state {
                return heroes.count == 10
            }
            return false
        }

        interactor.mockFetchNext(.success(.sample(
            count: 5, limit: 5, offset: 10, total: 30,
            characters: (11...15).map { .sample(id: $0, name: "N\($0)") }
        )))

        await sut.loadMoreHeroesIfNeeded(currentHero: .sample(id: 8, name: "H8"))

        guard case let .loaded(heroes, isLoadingMore, paginationError) = sut.state else {
            return XCTFail("Expected .loaded after pagination")
        }
        XCTAssertEqual(heroes.map(\.name),
                       (1...10).map { "H\($0)" } + (11...15).map { "N\($0)" })
        XCTAssertFalse(isLoadingMore)
        XCTAssertFalse(paginationError)
    }

    @MainActor
    func test_loadMoreHeroesIfNeeded_noMorePages_stopsSpinnerKeepsList() async {
        interactor.emitCache(.sample(
            count: 5, limit: 5, offset: 0, total: 5,
            characters: (1...5).map { .sample(id: $0, name: "H\($0)") }
        ))
        _ = await waitForState { state in
            if case let .loaded(heroes, _, _) = state { return heroes.count == 5 }
            return false
        }

        interactor.mockFetchNext(.failure(PaginationError.noMorePages))

        await sut.loadMoreHeroesIfNeeded(currentHero: .sample(id: 4, name: "H4"))

        guard case let .loaded(heroes, isLoadingMore, paginationError) = sut.state else {
            return XCTFail("Expected .loaded")
        }
        XCTAssertEqual(heroes.map(\.name), (1...5).map { "H\($0)" })
        XCTAssertFalse(isLoadingMore)
        XCTAssertFalse(paginationError)
    }

    @MainActor
    func test_loadMoreHeroesIfNeeded_offline_setsPaginationErrorTrue() async {
        interactor.emitCache(.sample(
            count: 5, limit: 5, offset: 0, total: 100,
            characters: (1...5).map { .sample(id: $0, name: "H\($0)") }
        ))
        _ = await waitForState { state in
            if case let .loaded(heroes, _, _) = state { return heroes.count == 5 }
            return false
        }

        interactor.mockFetchNext(.failure(HeroesError.offline))

        await sut.loadMoreHeroesIfNeeded(currentHero: .sample(id: 4, name: "H4"))

        guard case let .loaded(_, isLoadingMore, paginationError) = sut.state else {
            return XCTFail("Expected .loaded")
        }
        XCTAssertFalse(isLoadingMore)
        XCTAssertTrue(paginationError)
    }

    @MainActor
    func test_retryPagination_success_appendsAndClearsErrorFlag() async {
        interactor.emitCache(.sample(
            count: 2, limit: 2, offset: 0, total: 100,
            characters: [.sample(id: 1, name: "H1"), .sample(id: 2, name: "H2")]
        ))
        _ = await waitForState { state in
            if case let .loaded(heroes, _, _) = state { return heroes.count == 2 }
            return false
        }

        // put VM into paginationError=true
        interactor.mockFetchNext(.failure(HeroesError.offline))
        await sut.loadMoreHeroesIfNeeded(currentHero: .sample(id: 2, name: "H2"))
        _ = await waitForState { state in
            if case let .loaded(_, _, paginationError) = state { return paginationError }
            return false
        }

        // retry succeeds
        interactor.mockFetchNext(.success(.sample(
            count: 2, limit: 2, offset: 2, total: 100,
            characters: [.sample(id: 3, name: "N3"), .sample(id: 4, name: "N4")]
        )))

        await sut.retryPagination()

        guard case let .loaded(heroes, isLoadingMore, paginationError) = sut.state else {
            return XCTFail("Expected .loaded after retry")
        }
        XCTAssertEqual(heroes.map(\.name), ["H1","H2","N3","N4"])
        XCTAssertFalse(isLoadingMore)
        XCTAssertFalse(paginationError)
    }

    // MARK: - Await next state from @Published

    @MainActor
    func waitForState(
        timeout: TimeInterval = 1.0,
        where predicate: @escaping (HeroesListViewModel.ViewState) -> Bool
    ) async -> HeroesListViewModel.ViewState {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let current = sut.state
            if predicate(current) { return current }
            await Task.yield() // let the VM's internal tasks run
        }
        XCTFail("Timed out waiting for expected state. Last: \(sut.state)")
        return sut.state
    }
}

