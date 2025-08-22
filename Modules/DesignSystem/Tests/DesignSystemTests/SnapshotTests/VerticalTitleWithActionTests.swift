//
//  VerticalTitleWithActionTests.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import XCTest
import SwiftUI
@testable import DesignSystem


final class VerticalTitleWithActionTests: XCTestCase {

    // Tweak if your tokens differ
    private let width: CGFloat = 320
    private let height: CGFloat = 140

    // MARK: - Basic

    @MainActor
    func test_default_noIcon() {
        let view = VerticalTitleWithAction(
            title: "No internet connection.",
            buttonTitle: "Retry",
            action: {}
        )
        assertSnapshot(view: view, named: "default-noIcon", width: width, height: height)
    }

    @MainActor
    func test_withIcon() {
        let view = VerticalTitleWithAction(
            title: "No internet connection.",
            icon: .noConnection,
            buttonTitle: "Retry",
            action: {}
        )
        assertSnapshot(view: view, named: "withIcon", width: width, height: height)
    }

    // MARK: - Text behaviors

    @MainActor
    func test_longTitle_truncatesTail() {
        let view = VerticalTitleWithAction(
            title: "Your connection appears to be offline. Please check your network settings and try again.",
            icon: .noConnection,
            buttonTitle: "Retry",
            action: {}
        )
        assertSnapshot(view: view, named: "longTitle-truncate", width: width, height: height)
    }

    // MARK: - RTL layout

    @MainActor
    func test_rtl() {
        let view = VerticalTitleWithAction(
            title: "انقطع الاتصال بالإنترنت.",
            icon: .noConnection,
            buttonTitle: "إعادة المحاولة",
            action: {}
        )
        assertSnapshot(
            view: view.environment(\.layoutDirection, .rightToLeft),
            named: "rtl",
            width: width,
            height: height
        )
    }
}
