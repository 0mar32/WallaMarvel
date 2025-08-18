//
//  series.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import Foundation
import CoreData

public struct Series: Sendable {
    public let name: String
}

extension SeriesItemDto {
    func toDomainModel() -> Series {
        return Series(name: name)
    }
}

extension SeriesEntity {
    static func fromDomain(_ series: Series, context: NSManagedObjectContext) -> SeriesEntity {
        let entity = SeriesEntity(context: context)
        entity.name = series.name
        return entity
    }
    func toDomainModel() -> Series { Series(name: name ?? "") }
}

