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
