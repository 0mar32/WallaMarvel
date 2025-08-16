import SwiftUI
import HeroesCore
import DesignSystem

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
                .navigationTitle(viewModel.state.viewTitle)
                .onAppear {
                    viewModel.loadInitialHeroes()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case let .loadingInitial(message):
            ProgressView(message)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(heroes, isLoadingMore):
            heroList(heroes, showFooter: isLoadingMore)
        case let .error(message, heroes):
            VStack {
                if !heroes.isEmpty {
                    heroList(heroes, showFooter: false)
                }
                Text(message)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    @ViewBuilder
    private func heroList(_ heroes: [HeroListItemUIModel], showFooter: Bool) -> some View {
        List {
            ForEach(heroes, id: \.id) { hero in
                Button {
                    guard let hero = viewModel.model(for: hero) else { return }
                    onHeroSelected(hero)
                } label: {
                    AvatarRowView(
                        title: hero.name,
                        imageURL: hero.imageURL,
                        style: .highlighted(borderColor: Colors.Primary.lightBlue)
                    )
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

