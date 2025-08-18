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
    private var subscriptionTask: Task<Void, Never>? = nil

    init(
        interactor: HeroesPaginationInteractorProtocol,
        heroesListMapper: HeroesListUIModelMapperProtocol
    ) {
        self.interactor = interactor
        self.heroesListMapper = heroesListMapper

        subscribeToHeroesCache()
    }

    private func subscribeToHeroesCache() {
        subscriptionTask = Task { [weak self] in
            guard let self = self else { return }
            for await container in await self.interactor.heroesCachePublisher {
                let heroesUIModel = self.heroesListMapper.map(heroes: container.characters)
                self.allHeroes = container.characters
                if self.allHeroes.isEmpty {
                    self.state = .idle
                } else {
                    self.state = .loaded(heroes: heroesUIModel, isLoadingMore: false)
                }
            }
        }
    }

    func loadInitialHeroes() {
        guard case .idle = state else { return }

        state = .loadingInitial(message: "Loading Heroes...")
        Task {
            await interactor.reset()
            do {
                let container = try await interactor.refresh()
                allHeroes = container.characters
                let heroesListUIModel = self.heroesListMapper.map(
                    heroes: container.characters
                )
                // Animate insertion of new items
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        state = .loaded(heroes: heroesListUIModel, isLoadingMore: false)
                    }
                }
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
                    await MainActor.run {
                        withAnimation(.easeInOut) {
                            state = .loaded(heroes: updatedHeroesListUIModel, isLoadingMore: false)
                        }
                    }
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
