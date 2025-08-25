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

    var screen: XCUIElement {
        app.query(.any, match: .idEquals(HeroDetailIDs.screen)).firstMatch
    }

    var titleLabel: XCUIElement {
        app.text(.idEquals(HeroDetailIDs.title))
    }
}
