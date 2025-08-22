//
//  MockHeroesRepository.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

import XCTest
@testable import HeroesCore

final class HeroesRepositoryMock: HeroesRepositoryProtocol, @unchecked Sendable {
    struct Request: Equatable {
        let limit: Int
        let offset: Int
    }

    var results: [Result<HeroesContainer, Error>] = []
    private(set) var recordedRequests: [Request] = []

    // Optional gate: when set and closed, calls to fetchHeroes will suspend until opened
    var gate: CallGate?

    private let stream: AsyncStream<HeroesContainer>
    private let continuation: AsyncStream<HeroesContainer>.Continuation

    init() {
        var asyncContinuation: AsyncStream<HeroesContainer>.Continuation!
        self.stream = AsyncStream {
            cont in asyncContinuation = cont
        }
        self.continuation = asyncContinuation
    }

    var heroesPublisher: AsyncStream<HeroesContainer> { stream }

    func emitCache(_ container: HeroesContainer) {
        continuation.yield(container)
    }

    func finishStream() {
        continuation.finish()
    }

    func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer {
        recordedRequests.append(.init(limit: limit, offset: offset))

        if let gate { await gate.waitIfClosed() }

        guard !results.isEmpty else { fatalError("No result enqueued for HeroesRepositoryMock") }
        let next = results.removeFirst()
        return try next.get()
    }
}

// Tiny async gate used only when a test needs a call to stay “in flight”
actor CallGate {
    private var isOpen = true
    private var waiters: [CheckedContinuation<Void, Never>] = []

    // NEW: observers that want to know when the first waiter arrives
    private var blockedObservers: [CheckedContinuation<Void, Never>] = []

    func close() { isOpen = false }

    func openGate() {
        isOpen = true
        let toResume = waiters
        waiters.removeAll()
        for c in toResume { c.resume() }
    }

    func waitIfClosed() async {
        guard !isOpen else { return }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            waiters.append(c)
            // notify any observers that we now have at least one blocked waiter
            let obs = blockedObservers
            blockedObservers.removeAll()
            for o in obs { o.resume() }
        }
    }

    // completes once a waiter is actually blocked on this gate
    func waitUntilBlocked() async {
        if !waiters.isEmpty { return }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            blockedObservers.append(c)
        }
    }
}
