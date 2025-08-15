import Foundation

public enum PaginationError: Error {
    case noMorePages
}

public protocol HeroesPaginationInteractorProtocol: Sendable {
    var hasMorePages: Bool { get async }
    func reset() async
    func fetchNextPage() async throws -> HeroesContainer
}

public actor HeroesPaginationInteractor: HeroesPaginationInteractorProtocol {
    private let repository: HeroesRepositoryProtocol
    private var offset: Int = 0
    private let limit: Int
    private var total: Int? = nil

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

    public func fetchNextPage() async throws -> HeroesContainer {
        guard hasMorePages else {
            throw PaginationError.noMorePages
        }

        let result = try await repository.fetchHeroes(limit: limit, offset: offset)

        offset += result.count
        total = result.total

        return result
    }
}

