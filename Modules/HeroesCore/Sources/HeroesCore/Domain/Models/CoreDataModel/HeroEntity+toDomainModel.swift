//
//  HeroEntity+toDomainModel.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 25/8/25.
//

extension HeroEntity {
    func toDomainModel() -> Hero {
        let seriesModels: [Series] = (series?.allObjects as? [SeriesEntity] ?? []).compactMap {
            guard let name = $0.name else { return nil }
            return Series(name: name)
        }

        let storiesModels: [Story] = (stories?.allObjects as? [StoryEntity] ?? []).compactMap {
            guard let name = $0.name, let type = $0.type else { return nil }
            return Story(name: name, type: type)
        }

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
