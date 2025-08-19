import Foundation
import CoreData
import NetworkClient

// MARK: - Repository Protocol
public protocol HeroesRepositoryProtocol: Sendable {
    func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer
    var heroesPublisher: AsyncStream<HeroesContainer> { get }
}

public class HeroesRepository: HeroesRepositoryProtocol, @unchecked Sendable {
    private let apiService: HeroesAPIServiceProtocol
    private let storageService: HeroesStorageServiceProtocol

    private let updateContinuation: AsyncStream<HeroesContainer>.Continuation
    public let heroesPublisher: AsyncStream<HeroesContainer>

    public init(
        apiService: HeroesAPIServiceProtocol,
        storageService: HeroesStorageServiceProtocol
    ) {
        self.apiService = apiService
        self.storageService = storageService

        var continuation: AsyncStream<HeroesContainer>.Continuation!
        self.heroesPublisher = AsyncStream { cont in
            continuation = cont
        }
        self.updateContinuation = continuation
    }

    convenience public init() {
        self.init(
            apiService: HeroesAPIService(),
            storageService: HeroesStorageService()
        )
    }

    public func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer {
        // Fetch all data from cache
        let cachedHeroes = try storageService.fetchAllHeroes()

        if cachedHeroes.isEmpty {
            // First-time fetch
            let remoteContainer = try await fetchRemotePage(limit: limit, offset: offset)
            try storageService.storeHeroes(remoteContainer.characters, offset: offset)
            return remoteContainer
    
        } else if offset == 0 {
            // Step 1: yield cached
            let cachedContainer = HeroesContainer(
                count: cachedHeroes.count,
                limit: cachedHeroes.count,
                offset: 0,
                total: nil,
                characters: cachedHeroes
            )
            updateContinuation.yield(cachedContainer)

            // Step 2: refresh from remote in pages (max 100 per call)
            var allCharacters: [Hero] = []
            var currentOffset = 0
            let maxPageSize = 100
            var newTotal: Int? = nil

            while currentOffset < cachedHeroes.count {
                let fetchLimit = min(maxPageSize, cachedHeroes.count - currentOffset)
                let page = try await fetchRemotePage(limit: fetchLimit, offset: currentOffset)
                allCharacters.append(contentsOf: page.characters)
                newTotal = page.total
                // Store each page incrementally
                try storageService.storeHeroes(page.characters, offset: currentOffset)

                currentOffset += fetchLimit
            }

            let refreshedRemoteContainer = HeroesContainer(
                count: allCharacters.count,
                limit: allCharacters.count,
                offset: 0,
                total: newTotal,
                characters: allCharacters
            )

            return refreshedRemoteContainer

        } else {
            // Pagination (just fetch one page)
            let remoteContainer = try await fetchRemotePage(limit: limit, offset: offset)
            try storageService.storeHeroes(remoteContainer.characters, offset: offset)

            return remoteContainer
        }
    }

    private func fetchRemotePage(limit: Int, offset: Int) async throws -> HeroesContainer {
        do {
            return try await apiService
                .fetchHeroes(paginationInfo: .init(limit: limit, offset: offset))
                .data
                .toDomainModel()
        } catch {
            throw HeroesError.map(error)
        }
    }
}

// MARK: - HeroesError
public enum HeroesError: Error {
    case offline
    case generic
}

extension HeroesError {
    static func map(_ error: Error) -> HeroesError {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet:
                return .offline
            default:
                return .generic
            }
        } else {
            return .generic
        }
    }
}
