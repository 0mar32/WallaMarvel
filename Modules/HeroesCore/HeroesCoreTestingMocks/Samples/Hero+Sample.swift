//
//  Hero+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension Hero {
    static func sample(
        id: Int = 1,
        name: String = "Sample Hero",
        description: String = "A hero description",
        thumbnail: Thumbnail = .sample(),
        stories: [Story] = [.sample()],
        series: [Series] = [.sample()]
    ) -> Hero {
        Hero(id: id, name: name, description: description, thumbnail: thumbnail, stories: stories, series: series)
    }
}
