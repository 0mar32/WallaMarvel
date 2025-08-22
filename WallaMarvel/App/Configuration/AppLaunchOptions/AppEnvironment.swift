//
//  LaunchArguments.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import Foundation

enum LaunchArguments {
    static let uiTest = "UITEST"
    static let useStubs = "USE_STUBS"
}

enum EnvironmentArguments {
    static let stubsConfig = "STUBS_CONFIG"
}

enum AppEnvironment {
    static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var isRunningUITests: Bool {
        ProcessInfo.processInfo.arguments.contains(LaunchArguments.uiTest)
    }

    static var shouldUseStubs: Bool {
        ProcessInfo.processInfo.arguments.contains(LaunchArguments.useStubs)
    }
}
