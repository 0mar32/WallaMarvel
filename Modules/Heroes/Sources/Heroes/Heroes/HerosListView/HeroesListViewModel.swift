import SwiftUI
import Combine

import HeroesCore

@MainActor
class HeroesListViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loadingInitial(message: String)
        case loaded(heroes: [HeroListItemUIModel], isLoadingMore: Bool)
        case error(String, [HeroListItemUIModel])

        var viewTitle: String {
            return "Heroes"
        }
    }

    @Published private(set) var state: ViewState = .idle

    private let interactor: HeroesPaginationInteractorProtocol
    private let heroesListMapper: HeroesListUIModelMapperProtocol

    private var allHeroes: [Hero] = []

    init(
        interactor: HeroesPaginationInteractorProtocol,
        heroesListMapper: HeroesListUIModelMapperProtocol
    ) {
        self.interactor = interactor
        self.heroesListMapper = heroesListMapper
    }

    func loadInitialHeroes() {
        guard case .idle = state else { return }

        state = .loadingInitial(message: "Loading Heroes...")
        Task {
            await interactor.reset()
            do {
                let container = try await interactor.fetchNextPage()
                allHeroes.append(contentsOf: container.characters)
                let heroesListUIModel = self.heroesListMapper.map(
                    heroes: container.characters
                )
                state = .loaded(heroes: heroesListUIModel, isLoadingMore: false)
            } catch {
                state = .error("Error: \(error.localizedDescription)", [])
            }
        }
    }

    func loadMoreHeroesIfNeeded(currentHero heroItem: HeroListItemUIModel) {
        guard case let .loaded(heroes, isLoadingMore) = state else { return }
        guard !heroes.isEmpty && !isLoadingMore else { return }

        if heroes.suffix(5).contains(where: { $0.id == heroItem.id }) {
            state = .loaded(heroes: heroes, isLoadingMore: true)
            Task {
                do {
                    let container = try await interactor.fetchNextPage()
                    allHeroes.append(contentsOf: container.characters)
                    let newHeroesListUIModel = self.heroesListMapper.map(
                        heroes: container.characters
                    )
                    let updatedHeroesListUIModel = heroes + newHeroesListUIModel
                    state = .loaded(heroes: updatedHeroesListUIModel, isLoadingMore: false)
                } catch PaginationError.noMorePages {
                    state = .loaded(heroes: heroes, isLoadingMore: false)
                } catch {
                    state = .error(error.localizedDescription, heroes)
                }
            }
        }
    }

    func model(for heroItem: HeroListItemUIModel) -> Hero? {
        allHeroes.first(where: { $0.id == heroItem.id })
    }
}
