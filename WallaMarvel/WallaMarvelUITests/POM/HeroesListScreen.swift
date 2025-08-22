//
//  HeroesListScreen.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import XCTest

enum HeroesListIDs {
    static let screen = "HeroesList_Screen"
    static let table = "HeroesList_Table"
    static let retryColumn = "HeroesList_RetryColumn"
    static let retryRow = "HeroesList_RetryRow"
    static let retryButton = "HeroesList_RetryButton"
    static let heroCell = "HeroCell_"
    static let paginationSpinner = "HeroesList_Loading"
    static func heroCell(_ id: Int) -> String { "\(heroCell)\(id)" }
}

struct HeroesListScreen {
    let app: XCUIApplication

    private var heroesContainer: XCUIElement {
        let byId = app.query(.any, match: .idEquals(HeroesListIDs.table)).firstMatch
        if byId.exists { return byId }
        if app.tables.count > 0 { return app.tables.firstMatch }
        if app.collectionViews.count > 0 { return app.collectionViews.firstMatch }
        if app.scrollViews.count > 0 { return app.scrollViews.firstMatch }
        return app.descendants(matching: .any).firstMatch
    }

    @discardableResult
    func waitLoaded(timeout: TimeInterval = 8) -> Self {
        let firstRow = app.element(idBeginsWith: HeroesListIDs.heroCell)
        XCTAssertTrue(firstRow.waitForExistence(timeout: timeout), "Heroes list didn't appear")
        return self
    }


    func visibleCellCount() -> Int {
        let rows = app.query(.any, match: .idBegins(with: HeroesListIDs.heroCell))
        return rows.count
    }

    func tapFirstHeroCell() {
        let firstHeroRow = app.element(idBeginsWith: HeroesListIDs.heroCell)
        XCTAssertTrue(firstHeroRow.exists, "First hero row not found")
        firstHeroRow.tap()
    }

    var isRetryColumnVisible: Bool {
        retryRowElement.firstMatch.exists
    }

    func scrollToBottom(times: Int = 2) {
        let container = heroesContainer
        for _ in 0..<max(1, times) { container.swipeUp() }
    }

    func scrollUntilTextVisible(text: String, maxSwipes: Int) {
        let label = app.text(.labelEquals(text))
        var swipes = 0
        while !label.exists && swipes < maxSwipes {
            heroesContainer.swipeUp()
            RunLoop.current.run(until: Date().addingTimeInterval(0.08))
            swipes += 1
        }
    }

    var retryRowElement: XCUIElement {
        app.query(.any, match: .idEquals(HeroesListIDs.retryRow)).firstMatch
    }
    var retryColumnElement: XCUIElement {
        app.query(.any, match: .idEquals(HeroesListIDs.retryColumn)).firstMatch
    }

    // MARK: - Waiters
    @discardableResult
    func waitForRetryRow(timeout: TimeInterval = 8) -> XCUIElement {
        let el = retryRowElement
        XCTAssertTrue(el.waitForExistence(timeout: timeout), "Retry row didn’t appear")
        return el
    }

    @discardableResult
    func waitForRetryColumn(timeout: TimeInterval = 8) -> XCUIElement {
        let el = retryColumnElement
        XCTAssertTrue(el.waitForExistence(timeout: timeout), "Retry column didn’t appear")
        return el
    }

    // MARK: - Actions
    @discardableResult
    func tapRetryRow() -> Bool {
        tapRetry(in: retryRowElement)
    }

    @discardableResult
    func tapRetryColumn() -> Bool {
        tapRetry(in: retryColumnElement)
    }

    // MARK: - Internals
    @discardableResult
    private func tapRetry(in container: XCUIElement) -> Bool {
        // Prefer explicit button id if you add one in the view
        let byId = app.button(.idEquals(HeroesListIDs.retryButton))
        if byId.exists { byId.tap(); return true }

        // Otherwise, tap the first button within the container
        guard container.exists else { return false }
        let button = container.descendants(matching: .button).firstMatch
        if button.exists { button.tap(); return true }

        // Last resort: label (works unless localized)
        let byLabel = app.button(.labelEquals("Retry"))
        if byLabel.exists { byLabel.tap(); return true }

        return false
    }
}
