//
//  HeroDto.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//

import Foundation

struct HeroDto: Decodable {
    let id: Int // TODO: change this to string, Int will overflow
    let name: String
    let description: String
    let thumbnail: ThumbnailDto
    let series: SeriesDto
    let stories: StoriesDto
}
