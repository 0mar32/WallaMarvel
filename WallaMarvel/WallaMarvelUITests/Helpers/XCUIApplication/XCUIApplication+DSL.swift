//
//  Untitled.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import XCTest

// MARK: - Match
public enum Match {
    case idEquals(String)
    case idBegins(with: String)
    case idContains(String)
    case labelEquals(String)
    case labelBegins(with: String)
    case labelContains(String)
    case any
}

public extension XCUIApplication {

    // MARK: - Buttons
    func button(_ match: Match) -> XCUIElement {
        query(.button, match: match).firstMatch
    }

    func tapButton(_ match: Match, timeout: TimeInterval = 5) {
        let buttonElement = button(match)
        XCTAssertTrue(
            buttonElement.waitForExistence(timeout: timeout),
            "Button not found: \(match)"
        )
        buttonElement.tap()
    }

    // MARK: - Static texts
    func text(_ match: Match) -> XCUIElement {
        query(.staticText, match: match).firstMatch
    }

    // MARK: - Text fields
    func textField(_ match: Match) -> XCUIElement {
        query(.textField, match: match).firstMatch
    }

    func type(_ text: String, into match: Match, timeout: TimeInterval = 5) {
        let textFieldElement = textField(match)
        XCTAssertTrue(
            textFieldElement.waitForExistence(timeout: timeout),
            "Text field not found: \(match)"
        )
        textFieldElement.tap()
        textFieldElement.typeText(text)
    }

    // MARK: - Cells (tables/collections)
    func cell(idBeginsWith prefix: String, at index: Int = 0) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", prefix)
        let matchedCells = descendants(matching: .cell).matching(predicate)
        return matchedCells.element(boundBy: index)
    }

    func element(idBeginsWith prefix: String) -> XCUIElement {
        return query(.any, match: .idBegins(with: prefix)).firstMatch
    }

    // MARK: - Generic query entry point
    func query(_ type: XCUIElement.ElementType, match: Match) -> XCUIElementQuery {
        let allElements = descendants(matching: type)
        switch match {
        case .any:
            return allElements
        case .idEquals(let value):
            return allElements.matching(NSPredicate(format: "identifier == %@", value))
        case .idBegins(let prefix):
            return allElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
        case .idContains(let substring):
            return allElements.matching(NSPredicate(format: "identifier CONTAINS %@", substring))
        case .labelEquals(let value):
            return allElements.matching(NSPredicate(format: "label == %@", value))
        case .labelBegins(let prefix):
            return allElements.matching(NSPredicate(format: "label BEGINSWITH %@", prefix))
        case .labelContains(let substring):
            return allElements.matching(NSPredicate(format: "label CONTAINS %@", substring))
        }
    }
}
