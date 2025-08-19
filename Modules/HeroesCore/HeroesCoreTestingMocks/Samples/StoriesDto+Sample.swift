//
//  StoriesDto+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension StoriesDto {
    static func sample(
        available: Int = 1,
        items: [StoryItemDto] = [.sample()]
    ) -> StoriesDto {
        StoriesDto(available: available, items: items)
    }
}
