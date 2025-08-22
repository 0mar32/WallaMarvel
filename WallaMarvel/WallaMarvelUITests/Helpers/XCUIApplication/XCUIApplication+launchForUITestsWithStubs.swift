//
//  XCUIApplication+launchForUITestsWithStubs.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import XCTest

enum LaunchArguments {
    static let uiTest = "UITEST"
    static let useStubs = "USE_STUBS"
}

enum EnvironmentArguments {
    static let stubConfig = "STUBS_CONFIG"
}

// Mirror the app-side config just for encoding
struct StubsConfiguration: Codable {
    var heroesAPIServiceCase: HeroesAPIStubUseCase

    init(
        heroesAPIServiceCase: HeroesAPIStubUseCase = .twoPages
    ) {
        self.heroesAPIServiceCase = heroesAPIServiceCase
    }
}

enum HeroesAPIStubUseCase: String, Codable {
    case twoPages
    case secondPageOffline
    case offline
}

extension XCUIApplication {
    @discardableResult
    func launchForUITestsWithStubs(
        args: [String] = [],
        stubs: StubsConfiguration = StubsConfiguration()
    ) -> XCUIApplication {

        launchArguments += args
        launchArguments += [LaunchArguments.uiTest, LaunchArguments.useStubs]

        if let data = try? JSONEncoder().encode(stubs),
           let json = String(data: data, encoding: .utf8) {
            launchEnvironment[EnvironmentArguments.stubConfig] = json
        }

        launch()
        return self
    }
}
