//
//  HeroListItemUIModel+Sample.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import Foundation
@testable import Heroes

extension HeroListItemUIModel {
    static func sample(
        id: Int = 1,
        name: String = "Sample Hero",
        imageURL: URL? = URL(string: "https://example.com/image.jpg")
    ) -> HeroListItemUIModel {
        HeroListItemUIModel(id: id, imageURL: imageURL, name: name)
    }
}
