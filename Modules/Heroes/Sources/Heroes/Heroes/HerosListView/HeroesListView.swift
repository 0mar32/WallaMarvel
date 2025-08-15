import SwiftUI
import HeroesCore

struct HeroesListView: View {
    @StateObject private var viewModel: HeroesListViewModel

    init(viewModel: HeroesListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Heroes")
                .task {
                    viewModel.loadInitialHeroes()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("Welcome!").foregroundColor(.gray)
        case .loadingInitial:
            ProgressView("Loading Heroes...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(heroes, isLoadingMore):
            heroList(heroes, showFooter: isLoadingMore)
        case let .error(message, heroes):
            VStack {
                if !heroes.isEmpty {
                    heroList(heroes, showFooter: false)
                }
                Text("Error: \(message)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    @ViewBuilder
    private func heroList(_ heroes: [Hero], showFooter: Bool) -> some View {
        List {
            ForEach(heroes, id: \.id) { hero in
                HeroRowView(hero: hero)
                    .onAppear {
                        viewModel.loadMoreHeroesIfNeeded(currentHero: hero)
                    }
            }

            if showFooter {
                HStack {
                    Spacer()
                    ProgressView()
                        .frame(height: 44)
                    Spacer()
                }
                .id(UUID())
            }
        }
    }
}

