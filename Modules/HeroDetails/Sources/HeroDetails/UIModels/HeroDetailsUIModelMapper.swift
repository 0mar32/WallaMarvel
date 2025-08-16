//
//  HeroDetailsUIModelMapper.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//
import Foundation
import HeroesCore

protocol HeroDetailsUIModelMapperProtocol {
    func map(hero: Hero) -> HeroDetailsUIModel
}

struct HeroDetailsUIModelMapper: HeroDetailsUIModelMapperProtocol {
    func map(hero: Hero) -> HeroDetailsUIModel {
        // chance to set localization also here
        let title = hero.name.isEmpty ? "Unknown" : hero.name

        let imageURL = url(
            thumbnail: hero.thumbnail,
            size: .standardFantastic
        )

        let description = hero.description.isEmpty ? "No description available" : hero.description

        let stories: SectionUIModel? = hero.stories.isEmpty
        ? nil
        : .init(
            icon: .stories,
            title: "Stories",
            names: hero.stories.map {"• \($0.name)"
            }
        )

        let series: SectionUIModel? = hero.series.isEmpty
        ? nil
        : .init(
            icon: .series,
            title: "Series",
            names: hero.series.map {"• \($0.name)"
            }
        )
        return HeroDetailsUIModel(
            id: hero.id,
            title: title,
            imageURL: imageURL,
            description: description,
            storiesSection: stories,
            seriesSection: series
        )
    }

    func url(thumbnail: Thumbnail, size: Thumbnail.ImageSize) -> URL? {
        let httpsPath = thumbnail.path.replacingOccurrences(of: "http://", with: "https://")
        return URL(string: "\(httpsPath)/\(size.rawValue).\(thumbnail.extension)")
    }
}

// MARK: - Thumbnail helper
extension Thumbnail {
    enum ImageSize: String {
        case portraitXLarge = "portrait_xlarge"
        case landscapeIncredible = "landscape_incredible"
        case standardFantastic = "standard_fantastic"
    }
}
