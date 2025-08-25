import Foundation

public protocol HeroesPaginationInteractorProtocol: Sendable {
    var hasMorePages: Bool { get async }
    func initialStream() async -> AsyncThrowingStream<HeroesContainer, Error>
    func reset() async
    func fetchNextPage() async throws -> HeroesContainer
}

public actor HeroesPaginationInteractor: HeroesPaginationInteractorProtocol {
    // MARK: - Dependancies

    private let repository: HeroesRepositoryProtocol
    private let limit: Int

    // MARK: - Local mutable states

    private var offset: Int = 0
    private var total: Int? = nil // as we do not know the total amount of data on remote initially
    // This task to hold the initial load of the data.
    // as long as the initial load is in-flight we need to park any pagination request
    // until the initial load finishes then we let the pagination continue
    private var initialLoadTask: Task<Void, Error>?

    // MARK: - init

    public init(repository: HeroesRepositoryProtocol, limit: Int = 20) {
        self.repository = repository
        self.limit = limit
    }

    // MARK: - public APIs

    public func reset() {
        offset = 0
        total = nil
    }

    public var hasMorePages: Bool {
        if let total = total {
            return offset < total
        }
        return true
    }

    /// user this function is used for getting all the cached pages(if any) then its corresponding fresh from remote.
    /// ideally should be used for getting first page
    /// - Returns: an AsyncStream that gives 1-2 events cache(if any) ->  remote
    public func initialStream() -> AsyncThrowingStream<HeroesContainer, Error> {
        AsyncThrowingStream<HeroesContainer, Error>(bufferingPolicy: .unbounded) { continuation in
            Task { [weak self] in
                guard let self else { return }

                // If an initial load is already running, fail fast
                if await self.initialLoadTask != nil {
                    continuation.finish(throwing: PaginationError.refreshInProgress)
                    return
                }

                // Build a task that *represents* the entire cache→fresh work
                let job = Task<Void, Error> { [weak self] in
                    guard let self else { throw HeroesError.generic }
                    defer {
                        // always clear gate & refreshing at the very end
                        Task { await self.finishInitialLoad() }
                    }

                    do {
                        // Forward repo stream (cache → fresh), align counters, emit to caller
                        for try await container in self.repository.fetchHeroesStream(
                            limit: self.limit,
                            offset: 0
                        ) {
                            await self.align(with: container)
                            continuation.yield(container)
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                        throw error
                    }
                }

                // Store the gate so others (pagination) can await it
                await self.setInitialLoadTask(job)

                // Cancel the job if the stream consumer goes away
                continuation.onTermination = { _ in job.cancel() }
            }
        }
    }

    /// This function get the next page of data from the remote
    /// if any view model used this function only and not use ``HeroesPaginationInteractor/initialStream()`` at all, it will be only receiving data from remote
    /// - Returns: fresh remote page
    public func fetchNextPage() async throws -> HeroesContainer {
        // If initial load is in-flight, just await it.
        if let gate = initialLoadTask {
            _ = try await gate.value
        }

        guard hasMorePages else {
            throw PaginationError.noMorePages
        }

        let result = try await repository.fetchHeroes(limit: limit, offset: offset)
        offset += result.count
        total = result.total
        return result
    }
}

// MARK: - actor helpers

private extension HeroesPaginationInteractor {
    //(actor-isolated)
    func setInitialLoadTask(_ task: Task<Void, Error>?) {
        initialLoadTask = task
    }

    func finishInitialLoad() {
        initialLoadTask = nil
    }

    func align(with container: HeroesContainer) {
        if container.count > offset {
            offset = container.count
        }
        if total == nil, let newTotal = container.total {
            total = newTotal
        }
    }
}
