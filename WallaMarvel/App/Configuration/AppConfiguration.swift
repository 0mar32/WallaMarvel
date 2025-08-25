//
//  AppConfiguration.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import UIKit
import AppConfig
import NetworkStubsUITestUtils

enum AppConfiguration {
    static func configureOnLaunch() {
        #if DEBUG
        // Only enable network stubs for UITests
        if AppEnvironment.isRunningUITests && AppEnvironment.shouldUseStubs {
            NetworkStubs.install()
        }
        #endif
    }
}
