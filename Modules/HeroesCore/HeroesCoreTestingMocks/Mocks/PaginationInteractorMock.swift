//
//  MockPaginationInteractor.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import XCTest

@testable import HeroesCore

final class PaginationInteractorMock: HeroesPaginationInteractorProtocol, @unchecked Sendable {

    // MARK: - Scripting initial stream
    enum StreamPlan {
        case none
        case error(Error)
        case cacheOnly(HeroesContainer)
        case freshOnly(HeroesContainer)
        case cacheThenFresh(HeroesContainer, HeroesContainer)
        case cacheThenError(HeroesContainer, Error)
        case cacheThenFreshGated(HeroesContainer, HeroesContainer, CallGate) // yield cache, then wait, then fresh
    }

    var streamPlan: StreamPlan = .none

    var pageGate: CallGate?

    // MARK: - Scripting pagination
    var pageResultsQueue: [Result<HeroesContainer, Error>] = []
    private(set) var fetchNextPageCalls = 0

    // MARK: - hasMorePages
    var _hasMorePages: Bool = true
    var hasMorePages: Bool { get async { _hasMorePages } }

    // MARK: - Protocol
    func initialStream() async -> AsyncThrowingStream<HeroesContainer, Error> {
        AsyncThrowingStream(bufferingPolicy: .unbounded) { cont in
            let t = Task {
                switch streamPlan {
                case .none:
                    cont.finish()

                case let .error(e):
                    cont.finish(throwing: e)

                case let .cacheOnly(c):
                    cont.yield(c); cont.finish()

                case let .freshOnly(f):
                    cont.yield(f); cont.finish()

                case let .cacheThenFresh(c, f):
                    cont.yield(c)
                    await Task.yield()
                    cont.yield(f)
                    cont.finish()

                case let .cacheThenError(c, e):
                    cont.yield(c)
                    await Task.yield()
                    cont.finish(throwing: e)

                case let .cacheThenFreshGated(c, f, gate):
                    cont.yield(c)
                    await gate.waitIfClosed() // block until test opens
                    cont.yield(f)
                    cont.finish()
                }
            }
            cont.onTermination = { _ in t.cancel() }
        }
    }

    func reset() async { /* no-op */ }

    func fetchNextPage() async throws -> HeroesContainer {
        fetchNextPageCalls += 1
        if let gate = pageGate { await gate.waitIfClosed() }  // block here until test opens
        guard !pageResultsQueue.isEmpty else { fatalError("No pageResultsQueue scripted") }
        return try pageResultsQueue.removeFirst().get()
    }
}
