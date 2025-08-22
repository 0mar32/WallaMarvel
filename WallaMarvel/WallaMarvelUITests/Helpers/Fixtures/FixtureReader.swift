//
//  FixtureReader.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//
import Foundation
import XCTest

enum HeroesFixture {
    enum Page: String {
        case first = "heroes_page_0"
        case second = "heroes_page_1"

        var name: String { rawValue }
    }

    /// Loads the last hero's name from a fixture JSON in the UITest bundle.
    static func loadHeroFromFixture(page: Page = .first, index: Int = 0) throws -> String {
        guard let url = Bundle(for: HeroesList_Smoke_UITests.self).url(
            forResource: page.name,
            withExtension: "json"
        ) else {
            XCTFail("Missing fixture \(page.name).json in UITest bundle")
            throw NSError(domain: "fixture", code: 1)
        }

        let data = try Data(contentsOf: url)

        struct Response: Decodable { let data: DataContainer }
        struct DataContainer: Decodable { let results: [Hero] }
        struct Hero: Decodable { let name: String }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        guard let hero = decoded.data.results[safe: index] else {
            XCTFail("Fixture \(page.name).json has no results")
            throw NSError(domain: "fixture", code: 2)
        }
        return hero.name
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
