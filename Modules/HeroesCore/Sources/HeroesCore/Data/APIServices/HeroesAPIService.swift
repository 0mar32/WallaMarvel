import Foundation

import NetworkClient
import AppConfig

public protocol HeroesAPIServiceProtocol {
    func fetchHeroes(paginationInfo: PaginationDto?) async throws -> HeroesResponseDto
}

public class HeroesAPIService: HeroesAPIServiceProtocol {

    private let networkClient: NetworkClientProtocol

    public init(
        networkClient: NetworkClientProtocol = DefaultNetworkClient.shared
    ) {
        self.networkClient = networkClient
    }

    public func fetchHeroes(paginationInfo: PaginationDto?) async throws -> HeroesResponseDto {
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
