//
//  HeroesListViewModel+ViewState.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 24/8/25.
//

extension HeroesListViewModel {
    enum ViewState: Equatable {
        struct LoadedStateModel: Equatable {
            let heroes: [HeroListItemUIModel]
            let isLoadingMore: Bool
            let listError: ErrorMessageUIModel?

            public init(
                heroes: [HeroListItemUIModel],
                isLoadingMore: Bool = false,
                listError: ErrorMessageUIModel? = nil
            ) {
                self.heroes = heroes
                self.isLoadingMore = isLoadingMore
                self.listError = listError
            }
        }

        case idle
        case loadingInitial(message: String)
        case loaded(LoadedStateModel)
        case error(ErrorMessageUIModel, heroes: [HeroListItemUIModel])

        var viewTitle: String {
            return "Heroes"
        }

        var heroes: [HeroListItemUIModel] {
            switch self {
            case let .loaded(model):
                return model.heroes
            case .error, .idle, .loadingInitial:
                return []
            }
        }
    }
}
