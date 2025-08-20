//
//  HeroesListMapperMock.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//
import Foundation
import HeroesCore
@testable import Heroes

final class HeroesListMapperMock: HeroesListUIModelMapperProtocol, Sendable {
    func map(heroes: [Hero]) -> [HeroListItemUIModel] {
        heroes.map {
            HeroListItemUIModel(
                id: $0.id,
                imageURL: URL(
                    string: $0.thumbnail.path + "." + $0.thumbnail.extension
                ),
                name: $0.name
            )
        }
    }
}
