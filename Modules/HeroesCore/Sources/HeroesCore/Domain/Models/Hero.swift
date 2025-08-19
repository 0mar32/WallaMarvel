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

extension HeroEntity {
    func update(with hero: Hero, context: NSManagedObjectContext) {
        self.id = Int64(hero.id)
        self.name = hero.name
        self.heroDescription = hero.description
        self.thumbnailPath = hero.thumbnail.path
        self.thumbnailExtension = hero.thumbnail.extension

        // Remove existing relationships safely
        (self.series as? Set<SeriesEntity>)?.forEach { self.removeFromSeries($0) }
        (self.stories as? Set<StoryEntity>)?.forEach { self.removeFromStories($0) }

        // Add new relationships
        let seriesEntities = hero.series.compactMap { SeriesEntity.fromDomain($0, context: context) }
        self.addToSeries(NSSet(array: seriesEntities))

        let storyEntities = hero.stories.compactMap { StoryEntity.fromDomain($0, context: context) }
        self.addToStories(NSSet(array: storyEntities))
    }

    func toDomainModel() -> Hero {
        let seriesModels = (series?.allObjects as? [SeriesEntity] ?? []).map { $0.toDomainModel() }
        let storiesModels = (stories?.allObjects as? [StoryEntity] ?? []).map { $0.toDomainModel() }

        return Hero(
            id: Int(id),
            name: name ?? "",
            description: heroDescription ?? "",
            thumbnail: Thumbnail(path: thumbnailPath ?? "", extension: thumbnailExtension ?? ""),
            stories: storiesModels,
            series: seriesModels
        )
    }
}
