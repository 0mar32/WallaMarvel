//
//  HeroDetailViewModel.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//

import SwiftUI
import HeroesCore

@MainActor
final class HeroDetailsViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loaded(HeroDetailsUIModel)
    }

    @Published private(set) var state: ViewState = .idle

    private let hero: Hero
    private let HeroDetailsUIModelMapper: HeroDetailsUIModelMapperProtocol

    init(hero: Hero, HeroDetailsUIModelMapper: HeroDetailsUIModelMapperProtocol) {
        self.hero = hero
        self.HeroDetailsUIModelMapper = HeroDetailsUIModelMapper
    }

    func refreshHeroDetails() {
        self.state = .loaded(HeroDetailsUIModelMapper.map(hero: hero))
    }
}

extension HeroDetailsViewModel.ViewState {
    var heroName: String {
        switch self {
        case .idle:
            return ""
        case let .loaded(heroDetailsUIModel):
            return heroDetailsUIModel.title
        }
    }
}
