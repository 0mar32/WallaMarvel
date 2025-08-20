import Foundation

public enum PaginationError: Error {
    case noMorePages
    case refreshInProgress
}

public protocol HeroesPaginationInteractorProtocol: Sendable {
    var hasMorePages: Bool { get async }
    var heroesCachePublisher: AsyncStream<HeroesContainer> { get async }
    func refresh() async throws -> HeroesContainer
    func reset() async
    func fetchNextPage() async throws -> HeroesContainer
}

public actor HeroesPaginationInteractor: HeroesPaginationInteractorProtocol {
    private let repository: HeroesRepositoryProtocol
    private var offset: Int = 0
    private let limit: Int
    private var total: Int? = nil

    private var isRefreshing = false
    private var pendingPagination: CheckedContinuation<HeroesContainer, Error>?

    private var cacheSubscriptionTask: Task<Void, Never>?
    private var didStartSubscription = false

    public var heroesCachePublisher: AsyncStream<HeroesContainer> {
        repository.heroesPublisher
    }

    public init(repository: HeroesRepositoryProtocol, limit: Int = 20) {
        self.repository = repository
        self.limit = limit
    }

    deinit {
        cacheSubscriptionTask?.cancel()
    }

    private func ensureCacheSubscriptionStarted() {
        guard !didStartSubscription else { return }
        didStartSubscription = true
        cacheSubscriptionTask = Task { [weak self] in
            guard let self else { return }
            for await container in repository.heroesPublisher {
                await self.applyCacheSnapshot(container)
            }
        }
    }

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

    public func refresh() async throws -> HeroesContainer {
        ensureCacheSubscriptionStarted()

        guard !isRefreshing else {
            throw PaginationError.refreshInProgress
        }

        isRefreshing = true
        defer { isRefreshing = false }

        let result = try await repository.fetchHeroes(limit: limit, offset: 0)

        offset = result.count
        total = result.total

        // to handle the case when user open the app -> cached data displayed -> user scroll down to paginate
        // we should pend the pagination request until the first refresh for the initial data happens
        if let continuation = pendingPagination {
            pendingPagination = nil
            Task {
                do {
                    let page = try await fetchNextPage()
                    continuation.resume(returning: page)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        return result
    }

    public func fetchNextPage() async throws -> HeroesContainer {
        ensureCacheSubscriptionStarted()

        guard hasMorePages else {
            throw PaginationError.noMorePages
        }

        if isRefreshing {
            return try await withCheckedThrowingContinuation { continuation in
                pendingPagination = continuation
            }
        }

        let result = try await repository.fetchHeroes(limit: limit, offset: offset)

        offset += result.count
        total = result.total

        return result
    }

    private func applyCacheSnapshot(_ container: HeroesContainer) {
        guard !isRefreshing else { return }
        if container.count > offset {
            offset = container.count
        }
        if total == nil {
            total = container.total
        }
    }
}
