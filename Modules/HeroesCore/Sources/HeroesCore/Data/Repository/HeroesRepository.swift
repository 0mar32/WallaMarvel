import Foundation
import CoreData
import NetworkClient
import AppConfig

// MARK: - Repository Protocol
public protocol HeroesRepositoryProtocol: Sendable {
    func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer
    func fetchHeroesStream(limit: Int, offset: Int) -> AsyncThrowingStream<HeroesContainer, Error>
}

public class HeroesRepository: HeroesRepositoryProtocol, @unchecked Sendable {
    // MARK: - Dependancies

    private let apiService: HeroesAPIServiceProtocol
    private let storageService: HeroesStorageServiceProtocol

    // MARK: - init

    public init(
        apiService: HeroesAPIServiceProtocol,
        storageService: HeroesStorageServiceProtocol
    ) {
        self.apiService = apiService
        self.storageService = storageService
    }

    convenience public init() {
        self.init(
            apiService: HeroesAPIService(),
            storageService: HeroesStorageService()
        )
    }

    // MARK: - Public APIs

    /// User this function if you want to receive a stream that emits 1-2 events. The first event is the cached data, while the second one the remote data
    /// - Parameters:
    ///   - limit: how many hero you want to fetch per page
    ///   - offset: the starting index where the data should retuned from
    /// - Returns: An AsyncStream that always gives 1-2 events and completes.
    public func fetchHeroesStream(limit: Int, offset: Int = 0) -> AsyncThrowingStream<HeroesContainer, Error> {
        AsyncThrowingStream(bufferingPolicy: .unbounded) { continuation in
            let task = Task {
                do {
                    // 1) Emit cached snapshot if any
                    let cached = try storageService.fetchAllHeroes()
                    if !cached.isEmpty {
                        continuation.yield(HeroesContainer(
                            count: cached.count,
                            limit: cached.count,
                            offset: 0,
                            total: nil, // must be nil here as we do not know how many object in the remote at this moment
                            characters: cached
                        ))
                    }

                    // 2) Refresh from remote
                    let cachedCount = cached.count
                    let refreshTarget = max(cachedCount, limit)
                    var all: [Hero] = []
                    var currentOffset = offset
                    var newTotal: Int? = nil
                    let maxPageSize = 100 // hard coded but better to come from configuration for backward compatibility

                    // here we fetch the equivalent remote data in chunks, because the API does not support fetching more than 100
                    // object per one call
                    while currentOffset < refreshTarget {
                        let fetchLimit = min(maxPageSize, refreshTarget - currentOffset)
                        let page = try await fetchRemotePage(limit: fetchLimit, offset: currentOffset)
                        all.append(contentsOf: page.characters)
                        newTotal = page.total
                        try storageService.storeHeroes(page.characters, offset: currentOffset)
                        currentOffset += fetchLimit
                    }

                    continuation.yield(HeroesContainer(
                        count: all.count,
                        limit: all.count,
                        offset: offset,
                        total: newTotal,
                        characters: all
                    ))
                    continuation.finish()

                } catch {
                    continuation.finish(throwing: error) // already mapped in fetchRemotePage
                }
            }

            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Get a fresh page from remote with the passed limit and offset
    /// after the page retrieved successfully it is automatically cached
    /// - Parameters:
    ///   - limit: the amount for object that we need to receive (make sure it is less than 100, other wise api is not supporting this request)
    ///   - offset: the start position from which we should start chucking the page
    /// - Returns: a fresh remote page ``HeroesContainer``
    public func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer {
        // we can here put guard to make sure that the limit is less than 100, as the APIs enforces this.
        // but this is not good for backward compatiljblity, if we want the page size later on to be back end driven
        let remoteContainer = try await fetchRemotePage(limit: limit, offset: offset)
        try storageService.storeHeroes(remoteContainer.characters, offset: offset)
        return remoteContainer
    }
}

// MARK: Helpers

extension HeroesRepository {
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
