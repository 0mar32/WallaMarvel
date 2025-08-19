//
//  HeroDto+sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//
@testable import HeroesCore

// MARK: - HeroDto
extension HeroDto {
    static func sample(
        id: Int = 1,
        name: String = "Sample Hero",
        description: String = "A hero description",
        thumbnail: ThumbnailDto = .sample(),
        series: SeriesDto = .sample(),
        stories: StoriesDto = .sample()
    ) -> HeroDto {
        HeroDto(id: id, name: name, description: description, thumbnail: thumbnail, series: series, stories: stories)
    }
}
