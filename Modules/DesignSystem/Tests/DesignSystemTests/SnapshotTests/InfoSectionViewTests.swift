//
//  InfoSectionViewTests.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import XCTest
@testable import DesignSystem
import SwiftUI

final class InfoSectionViewTests: XCTestCase {

    private let width: CGFloat = 320
    private let height: CGFloat = 220

    // MARK: - Basic

    @MainActor
    func test_default_withIcon() {
        let view = InfoSectionView(
            title: "Stories",
            items: ["A New Dawn", "Into the Multiverse", "The Last Stand"],
            icon: .series,
        )
        // Disable animations so `appear` applies instantly
        assertSnapshot(
            view: view.transaction { $0.disablesAnimations = true },
            named: "default-withIcon",
            width: width,
            height: height
        )
    }

    @MainActor
    func test_default_noIcon() {
        let view = InfoSectionView(
            title: "Series",
            items: ["Infinity War", "Endgame", "Secret Invasion"],
            icon: nil
        )
        assertSnapshot(
            view: view.transaction { $0.disablesAnimations = true },
            named: "default-noIcon",
            width: width,
            height: height
        )
    }

    // MARK: - Long content

    @MainActor
    func test_longItems_wrapsNicely() {
        let view = InfoSectionView(
            title: "Featured",
            items: [
                "Doctor Stephen Strange, Master of the Mystic Arts",
                "Peter Parker’s Friendly Neighborhood Adventures",
                "Wanda Maximoff and the Scarlet Witch Chronicles"
            ],
            icon: .stories
        )
        assertSnapshot(
            view: view.transaction { $0.disablesAnimations = true },
            named: "longItems",
            width: width,
            height: 260
        )
    }

    // MARK: - Accessibility & RTL

    @MainActor
    func test_accessibilityExtraLarge() {
        let view = InfoSectionView(
            title: "Stories",
            items: ["A New Dawn", "Into the Multiverse", "The Last Stand"],
            icon: .series
        )
        assertSnapshot(
            view: view
                .transaction { $0.disablesAnimations = true },
            named: "a11y-extraLarge",
            width: width,
            height: 260,
            sizeCategory: .accessibilityExtraLarge
        )
    }

    @MainActor
    func test_rtl() {
        let view = InfoSectionView(
            title: "قصص",
            items: ["فجر جديد", "في عالم متعدد", "المعركة الأخيرة"],
            icon: .stories
        )
        assertSnapshot(
            view: view
                .environment(\.layoutDirection, .rightToLeft)
                .transaction { $0.disablesAnimations = true },
            named: "rtl",
            width: width,
            height: height
        )
    }
}
