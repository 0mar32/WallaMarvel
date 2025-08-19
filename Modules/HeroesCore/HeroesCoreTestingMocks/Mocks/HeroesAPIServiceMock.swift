//
//  MockHeroesAPIService.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//
@testable import HeroesCore

final class HeroesAPIServiceMock: HeroesAPIServiceProtocol {
    struct Request: Equatable {
        let limit: Int
        let offset: Int
    }

    private var queue: [Result<HeroesResponseDto, Error>] = []
    private(set) var queueIndex = 0
    private(set) var _recordedRequests: [Request] = []

    var recordedRequests: [Request] { _recordedRequests }

    func enqueue(_ result: Result<HeroesResponseDto, Error>) {
        queue.append(result)
    }

    func fetchHeroes(paginationInfo: PaginationDto?) async throws -> HeroesResponseDto {
        let limit = paginationInfo?.limit ?? -1
        let offset = paginationInfo?.offset ?? -1
        _recordedRequests.append(.init(limit: limit, offset: offset))

        guard queueIndex < queue.count else {
            fatalError("No enqueued result for MockHeroesAPIService")
        }
        defer { queueIndex += 1 }
        return try queue[queueIndex].get()
    }
}
