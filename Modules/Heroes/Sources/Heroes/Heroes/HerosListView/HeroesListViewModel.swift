import SwiftUI
import Combine

import HeroesCore

@MainActor
class HeroesListViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loadingInitial(message: String)
        case loaded(heroes: [HeroListItemUIModel], isLoadingMore: Bool, paginationError: Bool = false)
        case error(ErrorMessageUIModel, heroes: [HeroListItemUIModel])

        var viewTitle: String {
            return "Heroes"
        }

        var heroes: [HeroListItemUIModel] {
            switch self {
            case let .loaded(heroes, _ , _):
                return heroes
            case .error, .idle, .loadingInitial:
                return []
            }
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
                    self.state = .loaded(heroes: heroesUIModel, isLoadingMore: false, paginationError: false)
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
                        state = .loaded(heroes: heroesListUIModel, isLoadingMore: false, paginationError: false)
                    }
                }
            } catch HeroesError.offline {
                if state.heroes.isEmpty {
                    state = .loaded(heroes: [], isLoadingMore: false, paginationError: true)
                }
            } catch {
                state = .error(
                    .init(
                        title: "Error",
                        text: "\(error.localizedDescription)"),
                    heroes: state.heroes
                )
            }
        }
    }

    func loadMoreHeroesIfNeeded(currentHero heroItem: HeroListItemUIModel) {
        guard case let .loaded(heroes, isLoadingMore, _) = state else { return }
        guard !heroes.isEmpty && !isLoadingMore else { return }

        if heroes.suffix(5).contains(where: { $0.id == heroItem.id }) {
            state = .loaded(heroes: heroes, isLoadingMore: true, paginationError: false)
            requestNextPageAndMerge(using: heroes)
        }
    }

    func retryPagination() {
        guard case let .loaded(heroes, _, _) = state else { return }
        state = .loaded(heroes: heroes, isLoadingMore: true, paginationError: false)
        requestNextPageAndMerge(using: heroes)
    }

    private func requestNextPageAndMerge(using currentHeroes: [HeroListItemUIModel]) {
        Task {
            do {
                let container = try await interactor.fetchNextPage()
                allHeroes.append(contentsOf: container.characters)

                let newHeroesListUIModel = self.heroesListMapper.map(
                    heroes: container.characters
                )
                let updatedHeroesListUIModel = currentHeroes + newHeroesListUIModel

                await MainActor.run {
                    withAnimation(.easeInOut) {
                        state = .loaded(
                            heroes: updatedHeroesListUIModel,
                            isLoadingMore: false,
                            paginationError: false
                        )
                    }
                }
            } catch PaginationError.noMorePages {
                state = .loaded(heroes: currentHeroes, isLoadingMore: false, paginationError: false)
            } catch HeroesError.offline {
                state = .loaded(heroes: currentHeroes, isLoadingMore: false, paginationError: true)
            } catch {
                state = .error(
                    .init(title: "Error", text: "\(error.localizedDescription)"),
                    heroes: state.heroes
                )
            }
        }
    }

    func model(for heroItem: HeroListItemUIModel) -> Hero? {
        allHeroes.first(where: { $0.id == heroItem.id })
    }
}
