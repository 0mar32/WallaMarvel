//
//  StoriesDto.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import Foundation

struct StoriesDto: Decodable {
    let available: Int
    let items: [StoryItemDto]
}

struct StoryItemDto: Decodable {
    let name: String
    let type: String
}
