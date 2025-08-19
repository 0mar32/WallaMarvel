//
//  SeriesItemDto+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension SeriesItemDto {
    static func sample(
        name: String = "Sample Series"
    ) -> SeriesItemDto {
        SeriesItemDto(name: name)
    }
}
