//
//  HeroDetailsUIModelMapperMock.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import HeroesCore

@testable import HeroDetails

final class HeroDetailsUIModelMapperMock: HeroDetailsUIModelMapperProtocol {
    private(set) var receivedHeroes: [Hero] = []
    var stubbed: HeroDetailsUIModel = .sample()

    func map(hero: Hero) -> HeroDetailsUIModel {
        receivedHeroes.append(hero)
        return stubbed
    }
}
