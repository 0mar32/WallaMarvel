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

    public var heroesCachePublisher: AsyncStream<HeroesContainer> {
        repository.heroesPublisher
    }

    public init(repository: HeroesRepositoryProtocol, limit: Int = 20) {
        self.repository = repository
        self.limit = limit
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

    /// First call to update cache + start fresh
    public func refresh() async throws -> HeroesContainer {
        guard !isRefreshing else {
            throw PaginationError.refreshInProgress
        }

        isRefreshing = true
        defer { isRefreshing = false }

        let result = try await repository.fetchHeroes(limit: limit, offset: 0)

        offset = result.count
        total = result.total

        // If a pagination request was queued during refresh, run it now
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
        guard hasMorePages else {
            throw PaginationError.noMorePages
        }

        // If refresh is still in progress, queue this pagination request
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
}
