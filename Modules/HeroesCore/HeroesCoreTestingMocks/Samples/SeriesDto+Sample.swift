//
//  SeriesDto+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension SeriesDto {
    static func sample(
        available: Int = 1,
        items: [SeriesItemDto] = [.sample()]
    ) -> SeriesDto {
        SeriesDto(available: available, items: items)
    }
}
