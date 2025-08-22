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

enum HeroesAPIServiceStubFactory: APIServiceStub {
    enum UseCase: String {
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
            return jsonFixture("heroes_page_0.json").responseTime(0.25)
        }

        // Page 1
        stub(condition:
             isMethodGET() &&
             isHost("gateway.marvel.com") &&
             isPath("/v1/public/characters") &&
             containsQueryParams(["offset": "20"])
        ) { _ in
            return jsonFixture("heroes_page_1.json").responseTime(0.25)
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
            jsonFixture("heroes_page_0.json").responseTime(0.25)
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

    private static func jsonFixture(_ name: String, status: Int32 = 200) -> HTTPStubsResponse {
        let url = Bundle.main.url(forResource: name, withExtension: nil)!
        return HTTPStubsResponse(fileURL: url, statusCode: status, headers: ["Content-Type": "application/json"])
    }
}
#endif
