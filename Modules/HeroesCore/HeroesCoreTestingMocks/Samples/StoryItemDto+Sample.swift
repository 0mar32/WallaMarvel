//
//  StoryItemDto+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension StoryItemDto {
    static func sample(
        name: String = "Sample Story",
        type: String = "comic"
    ) -> StoryItemDto {
        StoryItemDto(name: name, type: type)
    }
}
