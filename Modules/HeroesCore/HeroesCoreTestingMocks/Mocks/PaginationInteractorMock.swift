//
//  MockPaginationInteractor.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

@testable import HeroesCore

final class PaginationInteractorMock: HeroesPaginationInteractorProtocol, @unchecked Sendable {

    // Publisher plumbing
    private let stream: AsyncStream<HeroesContainer>
    private let continuation: AsyncStream<HeroesContainer>.Continuation

    init() {
        var c: AsyncStream<HeroesContainer>.Continuation!
        self.stream = AsyncStream { cont in c = cont }
        self.continuation = c
    }

    var hasMorePages: Bool { true } // VM doesn’t consult this directly
    var heroesCachePublisher: AsyncStream<HeroesContainer> { stream }

    func emitCache(_ container: HeroesContainer) {
        continuation.yield(container)
    }

    // Scripted responses
    private var mockedRefresh: Result<HeroesContainer, Error>?
    private var mockedNextQueue: [Result<HeroesContainer, Error>] = []

    func mockRefresh(_ result: Result<HeroesContainer, Error>) {
        mockedRefresh = result
    }

    func mockFetchNext(_ result: Result<HeroesContainer, Error>) {
        mockedNextQueue.append(result)
    }

    // Protocol
    func refresh() async throws -> HeroesContainer {
        guard let r = mockedRefresh else {
            fatalError("MockPaginationInteractor.refresh not scripted")
        }
        return try r.get()
    }

    func reset() async {}

    func fetchNextPage() async throws -> HeroesContainer {
        guard !mockedNextQueue.isEmpty else {
            fatalError("MockPaginationInteractor.fetchNextPage not scripted")
        }
        return try mockedNextQueue.removeFirst().get()
    }
}
