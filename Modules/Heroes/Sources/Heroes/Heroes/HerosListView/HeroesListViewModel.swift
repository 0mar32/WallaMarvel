import SwiftUI
import HeroesCore

@MainActor
class HeroesListViewModel: ObservableObject {
    // MARK: - Types

    enum Constants {
        static let paginationTriggerIndex = 5
    }

    // MARK: - Published State

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var alert: ErrorMessageUIModel? = nil

    // MARK: - Dependancies

    private let interactor: HeroesPaginationInteractorProtocol
    private let heroesListMapper: HeroesListUIModelMapperProtocol

    // MARK: - Local variables

    private var allHeroes: [Hero] = []

    // MARK: - init

    init(
        interactor: HeroesPaginationInteractorProtocol,
        heroesListMapper: HeroesListUIModelMapperProtocol
    ) {
        self.interactor = interactor
        self.heroesListMapper = heroesListMapper
    }

    // MARK: - APIs

    /// Fetch the the data to display in the view
    func loadInitialHeroesStream() async {
        guard state.heroes.isEmpty else { return }
        state = .loadingInitial(message: "Loading Heroes...")

        await interactor.reset()

        // initialStream: emits 1–2 values (cache first if any, then fresh), then finishes or throws
        let stream = await interactor.initialStream()

        do {
            for try await container in stream {
                allHeroes = container.characters
                let ui = heroesListMapper.map(heroes: container.characters)
                // animate to smoothly change the list if the remote data is different from the cache.
                // so the user does not feel blinks
                withAnimation(.easeInOut) {
                    state = .loaded(.init(heroes: ui))
                }
            }
            // Finished normally (after fresh)
        } catch {
            handleLoadInitialHeroesError(error)
        }
    }

    /// fetch next page and merge it with current displayed list if the scrolling is near to the end
    /// - Parameter heroItem: hero item that will appear
    func loadMoreHeroesIfNeeded(currentHero heroItem: HeroListItemUIModel) async {
        guard case let .loaded(model) = state else { return }
        guard !model.heroes.isEmpty && !model.isLoadingMore else { return }

        if model.heroes.suffix(Constants.paginationTriggerIndex).contains(where: { $0.id == heroItem.id }) {
            state = .loaded(.init(heroes: model.heroes, isLoadingMore: true))
            await requestNextPageAndMerge(using: model.heroes)
        }
    }

    /// try to re-fetch the last page agin, should be used to recover from pagination errors
    func retryPagination() async {
        guard case let .loaded(model) = state else { return }
        state = .loaded(.init(heroes: model.heroes, isLoadingMore: true))
        await requestNextPageAndMerge(using: model.heroes)
    }
}

// MARK: Helpers

extension HeroesListViewModel {
    private func requestNextPageAndMerge(using currentHeroes: [HeroListItemUIModel]) async {
        do {
            let container = try await interactor.fetchNextPage()
            allHeroes.append(contentsOf: container.characters)

            let newHeroesListUIModel = heroesListMapper.map(heroes: container.characters)
            let updatedHeroesListUIModel = currentHeroes + newHeroesListUIModel

            withAnimation(.easeInOut) {
                state = .loaded(.init(heroes: updatedHeroesListUIModel))
            }
        } catch {
            handlePaginationError(error)
        }
    }

    func model(for heroItem: HeroListItemUIModel) -> Hero? {
        allHeroes.first(where: { $0.id == heroItem.id })
    }
}

// MARK: Error Handling

extension HeroesListViewModel {
    private func handlePaginationError(_ error: Error) {
        if let error = error as? PaginationError {
            if error == .noMorePages {
                state = .loaded(.init(heroes: state.heroes))
            } else {
                state = .loaded(
                    .init(
                        heroes: state.heroes,
                        listError: .init(
                            title: error.localizedDescription,
                            actionTitle: "Retry"
                        )
                    )
                )
            }
        } else if let error = error as? HeroesError {
            state = .loaded(
                .init(
                    heroes: state.heroes,
                    listError: .init(
                        title: error.localizedDescription,
                        actionTitle: "Retry"
                    )
                )
            )
        } else {
            alert = .init(
                title: "Error",
                message: error.localizedDescription,
                actionTitle: "OK"
            )
        }
    }

    private func handleLoadInitialHeroesError(_ error: Error) {
        if let error = error as? HeroesError {
            if state.heroes.isEmpty {
                state = .loaded(
                    .init(
                        heroes: [],
                        listError: .init(
                            title: error.localizedDescription,
                            actionTitle: "Retry"
                        )
                    )
                )
            } else {
                alert = .init(
                    title: "Error",
                    message: error.localizedDescription,
                    actionTitle: "OK"
                )
            }
        }
    }
}

extension HeroesError {
    var localizedDescription: String {
        switch self {
        case .offline:
            return "No internet connection"
        case .generic:
            return "Something went wrong"
        }
    }
}
