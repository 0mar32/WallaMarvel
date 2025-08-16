import SwiftUI
import HeroesCore

struct HeroesListView: View {
    @StateObject private var viewModel: HeroesListViewModel
    let onHeroSelected: (Hero) -> Void

    init(viewModel: HeroesListViewModel,
         onHeroSelected: @escaping (Hero) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onHeroSelected = onHeroSelected
    }

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Heroes")
                .onAppear {
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
                Button {
                    onHeroSelected(hero)
                } label: {
                    HeroRowView(hero: hero)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onAppear {
                    viewModel.loadMoreHeroesIfNeeded(currentHero: hero)
                }
            }

            if showFooter {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .id(UUID()) // ensure spinner re-renders/animates
            }
        }
    }
}

