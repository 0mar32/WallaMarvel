import SwiftUI
import Combine

import HeroesCore

@MainActor
class HeroesListViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loadingInitial
        case loaded(heroes: [Hero], isLoadingMore: Bool)
        case error(String, [Hero])
    }

    @Published private(set) var state: ViewState = .idle

    private let interactor: HeroesPaginationInteractorProtocol

    init(interactor: HeroesPaginationInteractorProtocol) {
        self.interactor = interactor
    }

    func loadInitialHeroes() {
        guard case .idle = state else { return }

        state = .loadingInitial
        Task {
            await interactor.reset()
            do {
                let container = try await interactor.fetchNextPage()
                state = .loaded(heroes: container.characters, isLoadingMore: false)
            } catch {
                state = .error(error.localizedDescription, [])
            }
        }
    }

    func loadMoreHeroesIfNeeded(currentHero hero: Hero) {
        guard case let .loaded(heroes, isLoadingMore) = state else { return }
        guard !heroes.isEmpty && !isLoadingMore else { return }

        if heroes.suffix(5).contains(where: { $0.id == hero.id }) {
            state = .loaded(heroes: heroes, isLoadingMore: true)
            Task {
                do {
                    let container = try await interactor.fetchNextPage()
                    let updatedHeroes = heroes + container.characters
                    state = .loaded(heroes: updatedHeroes, isLoadingMore: false)
                } catch PaginationError.noMorePages {
                    state = .loaded(heroes: heroes, isLoadingMore: false)
                } catch {
                    state = .error(error.localizedDescription, heroes)
                }
            }
        }
    }
}
