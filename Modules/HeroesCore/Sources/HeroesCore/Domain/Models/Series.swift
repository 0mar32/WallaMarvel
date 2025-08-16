//
//  series.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import Foundation

public struct Series: Sendable {
    public let name: String
}

extension SeriesItemDto {
    func toDomainModel() -> Series {
        return Series(name: name)
    }
}
