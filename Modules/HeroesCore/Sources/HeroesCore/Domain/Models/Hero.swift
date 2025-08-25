//
//  Hero.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//

import Foundation
import CoreData

public struct Hero: Equatable, Sendable {
    public let id: Int
    public let name: String
    public let description: String
    public let thumbnail: Thumbnail
    public let stories: [Story]
    public let series: [Series]

    public init(
        id: Int,
        name: String,
        description: String,
        thumbnail: Thumbnail,
        stories: [Story],
        series: [Series]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.stories = stories
        self.series = series
    }
}

extension HeroDto {
    func toDomainModel() -> Hero {
        .init(
            id: id,
            name: name,
            description: description,
            thumbnail: thumbnail.toDomainModel(),
            stories: stories.items.map { $0.toDomainModel() },
            series: series.items.map { $0.toDomainModel() }
        )
    }
}
