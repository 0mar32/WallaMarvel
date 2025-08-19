//
//  HeroesContainer+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension HeroesContainer {
    static func sample(
        count: Int = 1,
        limit: Int = 1,
        offset: Int = 0,
        total: Int? = 1,
        characters: [Hero] = [.sample()]
    ) -> HeroesContainer {
        HeroesContainer(count: count, limit: limit, offset: offset, total: total, characters: characters)
    }
}
