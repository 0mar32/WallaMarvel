//
//  SectionUIModel+Sample.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import XCTest
import HeroesCore
import DesignSystem

@testable import HeroDetails

extension SectionUIModel {
    static func sample(
        icon: SFIcon? = nil,
        title: String = "Sample Section",
        names: [String] = ["Item 1", "Item 2", "Item 3"]
    ) -> SectionUIModel {
        SectionUIModel(icon: icon, title: title, names: names)
    }
}
