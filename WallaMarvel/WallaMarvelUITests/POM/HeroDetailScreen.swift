//
//  HeroDetailScreen.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import XCTest

enum HeroDetailIDs {
    static let screen = "HeroDetail_Screen"
    static let title  = "HeroDetail_Title"
}

struct HeroDetailScreen {
    let app: XCUIApplication

    private var screen: XCUIElement {
        app.query(.any, match: .idEquals(HeroDetailIDs.screen)).firstMatch
    }
    private var titleLabel: XCUIElement {
        app.text(.idEquals(HeroDetailIDs.title))
    }

    @discardableResult
    func waitLoaded(timeout: TimeInterval = 8, expectedName: String? = nil) -> Self {
        // prefer explicit ids
        if !screen.waitForExistence(timeout: 1) {
            _ = titleLabel.waitForExistence(timeout: timeout)
        }

        if let name = expectedName {
            // assert via id if present, otherwise via nav title text
            if titleLabel.exists {
                XCTAssertEqual(titleLabel.label, name, "Details title mismatch")
            } else {
                let navTitle = app.staticTexts[name]
                XCTAssertTrue(navTitle.waitForExistence(timeout: 2),
                              "Expected navigation title '\(name)' to appear")
            }
        }
        return self
    }
}
