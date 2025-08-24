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
import AppConfig

public enum NetworkStubs {
    public static func install() {
        guard ProcessInfo.processInfo.arguments.contains(LaunchArguments.uiTest)
        else { return }

        // Read a JSON blob from env (set by the UI test target)
        let env = ProcessInfo.processInfo.environment

        // Default case
        var HeroesAPIUseCase: HeroesAPIServiceStubFactory.UseCase = .twoPages

        // Pick passed UseCases
        if let json = env[EnvironmentArguments.stubsConfig],
           let data = json.data(using: .utf8),
           let stubConfig = try? JSONDecoder().decode(StubsConfiguration.self, from: data) {

            HeroesAPIUseCase = stubConfig.heroesAPIServiceUseCase
        }

        // Stub APIs
        HeroesAPIServiceStubFactory.makeStubs(for: HeroesAPIUseCase)
    }
}
#endif
