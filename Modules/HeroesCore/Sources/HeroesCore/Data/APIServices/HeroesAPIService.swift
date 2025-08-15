import Foundation

import NetworkClient
import NetworkClientConfig

public protocol HeroesAPIServiceProtocol {
    func fetchHeroes(paginationInfo: PaginationDto?) async throws -> HeroesResponseDto
}

class HeroesAPIService: HeroesAPIServiceProtocol {

    private let networkClient: NetworkClientProtocol

    init(
        networkClient: NetworkClientProtocol = DefaultNetworkClient.shared
    ) {
        self.networkClient = networkClient
    }

    func fetchHeroes(paginationInfo: PaginationDto?) async throws -> HeroesResponseDto {
        var payLoad: Payload = .empty
        if let paginationInfo = paginationInfo {
            payLoad = .parameters(paginationInfo)
        }

        let request = NetworkRequest(
            path: "/v1/public/characters",
            method: .get,
            payload: payLoad
        )
        let data = try await networkClient.send(
            request,
            responseType: HeroesResponseDto.self
        )

        return data
    }
}
