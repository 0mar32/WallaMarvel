//
//  SeriesDto.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import Foundation

struct SeriesDto: Decodable {
    let available: Int
    let items: [SeriesItemDto]
}

struct SeriesItemDto: Decodable {
    let name: String
}
