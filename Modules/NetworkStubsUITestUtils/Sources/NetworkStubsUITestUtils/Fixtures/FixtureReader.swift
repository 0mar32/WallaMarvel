//
//  FixtureReader.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//
import Foundation

public enum HeroesFixture {
    public enum Page: String {
        case first = "heroes_page_0"
        case second = "heroes_page_1"

        var name: String { rawValue }
    }

    /// Loads the last hero's name from a fixture JSON in the UITest bundle.
    public static func heroNameFromFixture(page: Page = .first, index: Int = 0) throws -> String {
        let url = fixtureUrl(for: page.name)
        let data = try Data(contentsOf: url)

        // those types are just internal helpers to decode the name of the hero from fixture.
        // they should not be living outside
        struct Response: Decodable { let data: DataContainer }
        struct DataContainer: Decodable { let results: [Hero] }
        struct Hero: Decodable { let name: String }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        guard let hero = decoded.data.results[safe: index] else {
            fatalError("Fixture \(page.name).json has no results")
        }
        return hero.name
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
