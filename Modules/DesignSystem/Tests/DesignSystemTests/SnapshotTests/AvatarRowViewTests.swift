//
//  AvatarRowViewTests.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import XCTest
import SwiftUI
import Kingfisher
@testable import DesignSystem

final class AvatarRowViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        KFTestCache.clearAll()
    }

    override func tearDown() {
        KFTestCache.clearAll()
        super.tearDown()
    }

    // MARK: - Placeholder path (no URL)

    @MainActor
    func test_avatarRow_placeholder_normal() {
        let view = AvatarRowView(
            title: "Spider-Man",
            imageURL: mockedImageURL(),
            style: .normal
        )
        assertSnapshot(view: view, named: "normal-placeholder", width: 320, height: 72)
    }

    @MainActor
    func test_avatarRow_placeholder_highlighted() {
        let view = AvatarRowView(
            title: "Captain Marvel",
            imageURL: nil,
            style: .highlighted(borderColor: .systemBlue)
        )
        assertSnapshot(view: view, named: "highlighted-placeholder", width: 320, height: 72)
    }

    // MARK: - Loaded image path (preloaded into KF memory cache)

    @MainActor
    func test_avatarRow_loadedImage_normal() {
        let view = AvatarRowView(
            title: "Black Widow",
            imageURL: mockedImageURL(),
            style: .normal
        )
        assertSnapshot(view: view, named: "normal-loaded", width: 320, height: 72)
    }

    @MainActor
    func test_avatarRow_loadedImage_highlighted() {
        let view = AvatarRowView(
            title: "Nick Fury",
            imageURL: mockedImageURL(),
            style: .highlighted(borderColor: .systemBlue)
        )
        assertSnapshot(view: view, named: "highlighted-loaded", width: 320, height: 72)
    }

    // MARK: - Layout variants (optional)

    @MainActor
    func test_avatarRow_longTitle_a11yXXXL() {
        let view = AvatarRowView(
            title: "Doctor Stephen Strange, Master of the Mystic Arts",
            imageURL: mockedImageURL(),
            style: .normal
        )

        assertSnapshot(
            view: view,
            named: "longTitle-a11yXXXL",
            width: 320,
            height: 100,
            sizeCategory: .accessibilityExtraExtraExtraLarge
        )
    }

    @MainActor
    func test_avatarRow_rtl() {
        let view = AvatarRowView(
            title: "Loki",
            imageURL: nil,
            style: .normal
        )

        assertSnapshot(
            view: view.environment(\.layoutDirection, .rightToLeft),
            named: "rtl",
            width: 320,
            height: 72
        )
    }
}

extension AvatarRowViewTests {
    func mockedImageURL() -> URL {
        let url = URL(string: "https://tests.example/avatar-loaded-highlighted")!
        KFTestCache.preloadMemory(image: TestImages.solid(.systemIndigo), for: url)
        return url
    }
}


enum KFTestCache {
    static func clearAll() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache() // shouldn’t be needed if you store in memory-only
    }

    static func preloadMemory(image: UIImage, for url: URL) {
        ImageCache.default.store(image, forKey: url.absoluteString, toDisk: false)
    }
}

enum TestImages {
    /// A tiny, deterministic test image (solid color)
    static func solid(_ color: UIColor = .systemRed, size: CGSize = .init(width: 40, height: 40)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
