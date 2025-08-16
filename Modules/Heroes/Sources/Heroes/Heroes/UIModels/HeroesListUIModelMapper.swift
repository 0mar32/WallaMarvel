//
//  HeroesListUIModelMapper.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//
import Foundation
import HeroesCore

protocol HeroesListUIModelMapperProtocol {
    func map(heroes: [Hero]) -> [HeroListItemUIModel]
}

struct HeroesListUIModelMapper: HeroesListUIModelMapperProtocol {
    func map(heroes: [Hero]) -> [HeroListItemUIModel] {
        return heroes.map { hero in
            let url = URL(
                string: "\(hero.thumbnail.path).\(hero.thumbnail.extension)"
            )
            return .init(id: hero.id, imageURL: url, name: hero.name)
        }
    }
}
