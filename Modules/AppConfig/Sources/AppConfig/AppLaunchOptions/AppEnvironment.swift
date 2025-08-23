//
//  LaunchArguments.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import Foundation

public enum LaunchArguments {
    public static let uiTest = "UITEST"
    public static let useStubs = "USE_STUBS"
}

public enum EnvironmentArguments {
    public static let stubsConfig = "STUBS_CONFIG"
}

public enum AppEnvironment {
    public static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    public static var isRunningUITests: Bool {
        ProcessInfo.processInfo.arguments.contains(LaunchArguments.uiTest)
    }

    public static var shouldUseStubs: Bool {
        ProcessInfo.processInfo.arguments.contains(LaunchArguments.useStubs)
    }
}
