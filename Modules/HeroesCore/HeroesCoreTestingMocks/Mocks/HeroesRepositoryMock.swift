//
//  MockHeroesRepository.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

import XCTest
@testable import HeroesCore

/// Mock for:
/// public protocol HeroesRepositoryProtocol: Sendable {
///   func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer
///   func fetchHeroesStream(limit: Int, offset: Int) -> AsyncThrowingStream<HeroesContainer, Error>
/// }
final class HeroesRepositoryMock: HeroesRepositoryProtocol, @unchecked Sendable {
    struct Request: Equatable { let limit: Int; let offset: Int }

    // ---- pagination scripting (fetchHeroes) ----
    var pageResultsQueue: [Result<HeroesContainer, Error>] = []
    private(set) var recordedRequests: [Request] = []

    func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer {
        recordedRequests.append(.init(limit: limit, offset: offset))
        guard !pageResultsQueue.isEmpty else { fatalError("No pageResultsQueue scripted") }
        return try pageResultsQueue.removeFirst().get()
    }

    // ---- initial stream scripting (cache → fresh / error) ----
    enum StreamPlan {
        case none
        case cacheOnly(cache: HeroesContainer)
        case freshOnly(fresh: HeroesContainer)
        case cacheThenFresh(cache: HeroesContainer, fresh: HeroesContainer)
        case cacheThenError(cache: HeroesContainer, error: Error)
        case cacheThenFreshGated(cache: HeroesContainer, fresh: HeroesContainer, gate: CallGate) // ← gate
    }
    var streamPlan: StreamPlan = .none

    func fetchHeroesStream(limit: Int, offset: Int) -> AsyncThrowingStream<HeroesContainer, Error> {
        AsyncThrowingStream(bufferingPolicy: .unbounded) { continuation in
            let task = Task {
                switch streamPlan {
                case .none:
                    continuation.finish()

                case let .cacheOnly(cache):
                    continuation.yield(cache)
                    continuation.finish()

                case let .freshOnly(fresh):
                    continuation.yield(fresh)
                    continuation.finish()

                case let .cacheThenFresh(cache, fresh):
                    continuation.yield(cache)
                    await Task.yield()
                    continuation.yield(fresh)
                    continuation.finish()

                case let .cacheThenError(cache, error):
                    continuation.yield(cache)
                    await Task.yield()
                    continuation.finish(throwing: error)

                case let .cacheThenFreshGated(cache, fresh, gate):
                    continuation.yield(cache) // cached first
                    await gate.waitIfClosed() // hold here deterministically
                    continuation.yield(fresh) // fresh after gate opens
                    continuation.finish()
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

/// Simple async gate for deterministic blocking in tests.
actor CallGate {
    private var isOpen = true
    private var waiters: [CheckedContinuation<Void, Never>] = []
    private var blockedObservers: [CheckedContinuation<Void, Never>] = []

    func close() {
        isOpen = false
    }

    func openGate() {
        isOpen = true
        let toResume = waiters
        waiters.removeAll()
        for waiter in toResume {
            waiter.resume()
        }
    }

    func waitIfClosed() async {
        guard !isOpen else { return }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            waiters.append(c)
            let obs = blockedObservers
            blockedObservers.removeAll()

            for observer in obs {
                observer.resume()
            }
        }
    }

    /// Completes once at least one waiter is blocked on this gate.
    func waitUntilBlocked() async {
        if !waiters.isEmpty { return }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            blockedObservers.append(c)
        }
    }
}
