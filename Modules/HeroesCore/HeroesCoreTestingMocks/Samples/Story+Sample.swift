//
//  Story+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension Story {
    static func sample(
        name: String = "Sample Story",
        type: String = "comic"
    ) -> Story {
        Story(name: name, type: type)
    }
}
