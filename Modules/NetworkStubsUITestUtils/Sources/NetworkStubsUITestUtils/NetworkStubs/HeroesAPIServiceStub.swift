//
//  HeroesAPIServiceStub.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 22/8/25.
//

#if DEBUG
import OHHTTPStubs
import OHHTTPStubsSwift

protocol APIServiceStub {
    associatedtype UseCase
    static func makeStubs(for useCase: UseCase)
}

public enum HeroesAPIServiceStubFactory: APIServiceStub {
    public enum UseCase: String, Codable {
        case twoPages
        case secondPageOffline
        case offline
    }

    static func makeStubs(for useCase: UseCase) {
        switch useCase {
        case .twoPages:
            stubForTwoPages()
        case .offline:
            stubOffline()
        case .secondPageOffline:
            stubForSecondPageOffline()
        }
    }

    private static func stubForTwoPages() {
        // Page 0
        stub(condition:
             isMethodGET() &&
             isHost("gateway.marvel.com") &&
             isPath("/v1/public/characters") &&
             containsQueryParams(["offset": "0"])
        ) { _ in
            return httpStubsResponse(for: "heroes_page_0.json").responseTime(0.25)
        }

        // Page 1
        stub(condition:
             isMethodGET() &&
             isHost("gateway.marvel.com") &&
             isPath("/v1/public/characters") &&
             containsQueryParams(["offset": "20"])
        ) { _ in
            return httpStubsResponse(for: "heroes_page_1.json").responseTime(0.25)
        }
    }

    private static func stubForSecondPageOffline() {
        // Page 0
        stub(condition:
                isMethodGET() &&
             isHost("gateway.marvel.com") &&
             isPath("/v1/public/characters") &&
             containsQueryParams(["offset": "0"])
        ) { _ in
            httpStubsResponse(for: "heroes_page_0.json").responseTime(0.25)
        }

        // Page 1 - offline
        stub(condition:
             isMethodGET() &&
             isHost("gateway.marvel.com") &&
             isPath("/v1/public/characters") &&
             containsQueryParams(["offset": "20"])
        ) { _ in
            HTTPStubsResponse(error: URLError(.notConnectedToInternet))
                .responseTime(0.25)
        }
    }

    private static func stubOffline() {
        // all pages offline
        stub(condition:
             isMethodGET() &&
             isHost("gateway.marvel.com") &&
             isPath("/v1/public/characters")
        ) { _ in
            HTTPStubsResponse(error: URLError(.notConnectedToInternet))
                .responseTime(0.25)
        }
    }

    private static func httpStubsResponse(
        for fileName: String,
        status: Int32 = 200
    ) -> HTTPStubsResponse {
        let name = fileName.hasSuffix(".json") ? String(fileName.dropLast(5)) : fileName
        let url = fixtureUrl(for: name)
        return HTTPStubsResponse(fileURL: url, statusCode: status, headers: ["Content-Type": "application/json"])
    }
}
#endif
