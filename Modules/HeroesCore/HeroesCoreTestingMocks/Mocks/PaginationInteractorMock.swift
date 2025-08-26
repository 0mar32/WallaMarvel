//
//  MockPaginationInteractor.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import XCTest

import Foundation
import HeroesCore

final class PaginationInteractorMock: HeroesPaginationInteractorProtocol, @unchecked Sendable {

    // MARK: - Stream planning for initial load
    enum StreamPlan {
        case none
        case freshOnly(HeroesContainer)
        case error(Error)
        case cacheThenError(HeroesContainer, Error)
        case manual // tests drive emissions
    }

    var streamPlan: StreamPlan = .none

    // MARK: - Manual initial stream plumbing
    private var manualCont: AsyncThrowingStream<HeroesContainer, Error>.Continuation?
    private var subscribedWaiter: CheckedContinuation<Void, Never>?

    func waitUntilSubscribed() async {
        if manualCont != nil { return }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            subscribedWaiter = c
        }
    }

    func emit(_ container: HeroesContainer) {
        manualCont?.yield(container)
    }

    func finishStream() {
        manualCont?.finish()
        manualCont = nil
    }

    func fail(_ error: Error) {
        manualCont?.finish(throwing: error)
        manualCont = nil
    }

    // MARK: - Pagination scripting
    var pageResultsQueue: [Result<HeroesContainer, Error>] = []
    private(set) var fetchNextPageCalls: Int = 0

    // MARK: - Manual pagination
    private var manualNextPageMode = false
    private var nextPageContinuation: CheckedContinuation<HeroesContainer, Error>?
    private var nextPageBlockedWaiters: [CheckedContinuation<Void, Never>] = []

    /// Tell the mock to suspend `fetchNextPage()` and let the test resume it manually.
    func beginManualNextPage() { manualNextPageMode = true }

    /// Wait until `fetchNextPage()` has actually suspended.
    func waitUntilManualNextPageIsBlocked() async {
        if nextPageContinuation != nil { return }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            nextPageBlockedWaiters.append(c)
        }
    }

    /// Resume the suspended `fetchNextPage()` with a result (success or failure).
    func resolveManualNextPage(_ result: Result<HeroesContainer, Error>) {
        guard let cont = nextPageContinuation else {
            fatalError("resolveManualNextPage called but no fetchNextPage is blocked.")
        }
        nextPageContinuation = nil
        manualNextPageMode = false
        switch result {
        case .success(let page): cont.resume(returning: page)
        case .failure(let error): cont.resume(throwing: error)
        }
    }

    // MARK: - Protocol conformance

    var hasMorePages: Bool { get async { _hasMorePages } }
    var _hasMorePages: Bool = true

    func reset() async {
        pageResultsQueue.removeAll()
        fetchNextPageCalls = 0
        // Keep streamPlan as set by each test
    }

    func initialStream() async -> AsyncThrowingStream<HeroesContainer, Error> {
        switch streamPlan {
        case .none:
            return AsyncThrowingStream { $0.finish() }

        case .freshOnly(let fresh):
            return AsyncThrowingStream { cont in
                cont.yield(fresh)
                cont.finish()
            }

        case .error(let error):
            return AsyncThrowingStream { cont in
                cont.finish(throwing: error)
            }

        case .cacheThenError(let cache, let error):
            return AsyncThrowingStream { cont in
                cont.yield(cache)
                cont.finish(throwing: error)
            }

        case .manual:
            return AsyncThrowingStream(bufferingPolicy: .unbounded) { cont in
                self.manualCont = cont
                self.subscribedWaiter?.resume()
                self.subscribedWaiter = nil
            }
        }
    }

    func fetchNextPage() async throws -> HeroesContainer {
        // Manual pause path
        if manualNextPageMode {
            fetchNextPageCalls += 1
            return try await withCheckedThrowingContinuation { (c: CheckedContinuation<HeroesContainer, Error>) in
                nextPageContinuation = c
                // notify waiters that we are now blocked
                let waiters = nextPageBlockedWaiters
                nextPageBlockedWaiters.removeAll()
                for waiter in waiters { waiter.resume() }
            }
        }

        // Normal queued path
        fetchNextPageCalls += 1
        guard !pageResultsQueue.isEmpty else {
            fatalError("PaginationInteractorMock.fetchNextPage() called with empty pageResultsQueue")
        }
        let next = pageResultsQueue.removeFirst()
        return try next.get()
    }
}
