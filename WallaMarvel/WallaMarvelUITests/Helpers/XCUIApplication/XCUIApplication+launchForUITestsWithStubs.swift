//
//  XCUIApplication+launchForUITestsWithStubs.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import XCTest
import AppConfig
import NetworkStubsUITestUtils

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
            launchEnvironment[EnvironmentArguments.stubsConfig] = json
        }

        launch()
        return self
    }
}
