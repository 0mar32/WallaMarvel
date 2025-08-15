import Foundation
import NetworkClient

public protocol HeroesRepositoryProtocol: Sendable {
    func fetchHeroes() async throws -> HeroesContainer
    func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer
}

public class HeroesRepository: HeroesRepositoryProtocol, @unchecked Sendable {
    let apiService: HeroesAPIServiceProtocol

    public init(apiService: HeroesAPIServiceProtocol) {
        self.apiService = apiService
    }

    public convenience init() {
        self.init(apiService: HeroesAPIService())
    }

    public func fetchHeroes() async throws -> HeroesContainer {
        do {
            return try await apiService
                .fetchHeroes(paginationInfo: nil)
                .data
                .toDomainModel()
        } catch {
            throw HeroesError.map(error)
        }
    }

    public func fetchHeroes(limit: Int, offset: Int) async throws -> HeroesContainer {
        do {
            return try await apiService
                .fetchHeroes(
                    paginationInfo: .init(limit: limit, offset: offset)
                )
                .data
                .toDomainModel()
        } catch {
            throw HeroesError.map(error)
        }
    }
}

enum HeroesError: Error {
    case offline
    case generic
}

extension HeroesError {
    static func map(_ error: Error) -> HeroesError {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet: return .offline
            default: return .generic
            }
        } else {
            return .generic
        }
    }
}

struct Heroes {
    let id: String
    let name: String
}
