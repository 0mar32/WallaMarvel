//
//  Sanpshot+Helpers.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import SwiftUI
import SnapshotTesting
import XCTest

enum SnapshotConfig {
    static let defaultLocale: Locale = .init(identifier: "en_US")
    @MainActor static let defaultSizeCategory: ContentSizeCategory = .medium
    static let defaultWidth: CGFloat = 320
    static let defaultHeight: CGFloat = 80
    static let defaultInsets: EdgeInsets = EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
    static let defaultWaitForAppear: TimeInterval = 0.03
}

/// A single, unified snapshot assertion helper for SwiftUI views (fixed-size canvas).
@MainActor
func assertSnapshot(
    view: some View,
    named name: String? = nil,
    isRecording: Bool = false,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    width: CGFloat = SnapshotConfig.defaultWidth,
    height: CGFloat = SnapshotConfig.defaultHeight,
    locale: Locale = SnapshotConfig.defaultLocale,
    sizeCategory: ContentSizeCategory = SnapshotConfig.defaultSizeCategory,
    insets: EdgeInsets = SnapshotConfig.defaultInsets
) {
    // Apply deterministic environment and size with optional insets
    let configured = view
        .padding(insets)
        .frame(width: width, height: height)
        .environment(\.locale, locale)
        .environment(\.sizeCategory, sizeCategory)

    // Build traits (light mode only for now)
    let traits = UITraitCollection(traitsFrom: [
        UITraitCollection(userInterfaceStyle: .light),
        UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(from: sizeCategory))
    ])

    SnapshotTesting.assertSnapshot(
        of: configured,
        as: .image(
            layout: .fixed(width: width, height: height),
            traits: traits
        ),
        named: name,
        record: isRecording,
        file: file,
        testName: testName,
        line: line
    )
}

// MARK: - Helpers

// Tiny bridge to convert SwiftUI ContentSizeCategory to UIKit’s
private extension UIContentSizeCategory {
    init(from swiftUICategory: ContentSizeCategory) {
        self = UIContentSizeCategory(rawValue: swiftUICategory.swiftUICategoryRawValue)
    }
}

private extension ContentSizeCategory {
    var swiftUICategoryRawValue: String {
        switch self {
        case .extraSmall: return UIContentSizeCategory.extraSmall.rawValue
        case .small: return UIContentSizeCategory.small.rawValue
        case .medium: return UIContentSizeCategory.medium.rawValue
        case .large: return UIContentSizeCategory.large.rawValue
        case .extraLarge: return UIContentSizeCategory.extraLarge.rawValue
        case .extraExtraLarge: return UIContentSizeCategory.extraExtraLarge.rawValue
        case .extraExtraExtraLarge: return UIContentSizeCategory.extraExtraExtraLarge.rawValue
        case .accessibilityMedium: return UIContentSizeCategory.accessibilityMedium.rawValue
        case .accessibilityLarge: return UIContentSizeCategory.accessibilityLarge.rawValue
        case .accessibilityExtraLarge: return UIContentSizeCategory.accessibilityExtraLarge.rawValue
        case .accessibilityExtraExtraLarge: return UIContentSizeCategory.accessibilityExtraExtraLarge.rawValue
        case .accessibilityExtraExtraExtraLarge: return UIContentSizeCategory.accessibilityExtraExtraExtraLarge.rawValue
        @unknown default: return UIContentSizeCategory.medium.rawValue
        }
    }
}
