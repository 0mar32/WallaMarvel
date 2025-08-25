//
//  NetworkStubs.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

#if DEBUG
import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift

struct StubsConfiguration: Decodable {
    var heroesAPIServiceCase = HeroesAPIServiceStubFactory.UseCase.twoPages.rawValue
}

enum NetworkStubs {
    static func install() {
        guard ProcessInfo.processInfo.arguments.contains(LaunchArguments.uiTest)
        else { return }

        // Read a JSON blob from env (set by the UI test target)
        let env = ProcessInfo.processInfo.environment

        // Default case
        var useCase: HeroesAPIServiceStubFactory.UseCase = .twoPages

        // Pick passed UseCases
        if let json = env[EnvironmentArguments.stubsConfig],
           let data = json.data(using: .utf8),
           // no hurt here from initializing JSONDecoder() on the fly, because this function is going to be called once per lunch
           // so we are not in case of creating it in each use unnecessary
           let stubConfig = try? JSONDecoder().decode(StubsConfiguration.self, from: data) {

            if let parsed = HeroesAPIServiceStubFactory.UseCase(rawValue: stubConfig.heroesAPIServiceCase) {
                useCase = parsed
            }
        }

        // Stub APIs
        HeroesAPIServiceStubFactory.makeStubs(for: useCase)

    }
}

#endif
