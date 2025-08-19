//
//  Story.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import Foundation
import CoreData

public struct Story: Equatable, Sendable {
    public let name: String
    public let type: String
}

extension StoryItemDto {
    func toDomainModel() -> Story {
        return Story(name: name, type: type)
    }
}

extension StoryEntity {
    static func fromDomain(_ story: Story, context: NSManagedObjectContext) -> StoryEntity {
        let entity = StoryEntity(context: context)
        entity.name = story.name
        entity.type = story.type
        return entity
    }
    func toDomainModel() -> Story { Story(name: name ?? "", type: type ?? "") }
}
