//
//  HeroEntity+update.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 25/8/25.
//
import Foundation
import CoreData

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
        let seriesEntities = hero.series.compactMap {
            let series = SeriesEntity(context: context)
            series.name = $0.name
            return series
        }
        self.addToSeries(NSSet(array: seriesEntities))

        let storyEntities = hero.stories.compactMap {
            let story = StoryEntity(context: context)
            story.name = $0.name
            story.type = $0.type
            return story
        }
        self.addToStories(NSSet(array: storyEntities))
    }
}
