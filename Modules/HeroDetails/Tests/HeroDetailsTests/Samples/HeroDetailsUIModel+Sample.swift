//
//  HeroDetailsUIModel+Sample.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import XCTest
import HeroesCore
import DesignSystem

@testable import HeroDetails

extension HeroDetailsUIModel {
    static func sample(
        id: Int = 1,
        title: String = "Sample Hero",
        imageURL: URL? = URL(string: "https://example.com/hero.jpg"),
        description: String = "A sample hero description.",
        storiesSection: SectionUIModel? = .sample(title: "Stories", names: ["Story 1", "Story 2"]),
        seriesSection: SectionUIModel? = .sample(title: "Series", names: ["Series A", "Series B"])
    ) -> HeroDetailsUIModel {
        HeroDetailsUIModel(
            id: id,
            title: title,
            imageURL: imageURL,
            description: description,
            storiesSection: storiesSection,
            seriesSection: seriesSection
        )
    }
}
