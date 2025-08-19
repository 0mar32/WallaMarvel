import SwiftUI
import HeroesCore
import DesignSystem

struct HeroesListView: View {
    @StateObject private var viewModel: HeroesListViewModel
    @State private var errorAlert: ErrorMessageUIModel?
    let onHeroSelected: (Hero) -> Void

    init(
        viewModel: HeroesListViewModel,
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
                .onChange(of: viewModel.state) { newState in
                    if case let .error(message, _) = newState { errorAlert = message }
                }
                .alert(item: $errorAlert) { error in
                    Alert(title: Text(error.title),
                          message: Text(error.text),
                          dismissButton: .default(Text("OK")))
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
        case let .loaded(heroes, isLoadingMore, paginationError):
            heroList(heroes, showFooter: isLoadingMore, showOfflineRetry: paginationError)
        case let .error(_, heroes):
            VStack {
                if !heroes.isEmpty {
                    heroList(heroes, showFooter: false, showOfflineRetry: false)
                }
            }
        }
    }

    @ViewBuilder
    private func heroList(_ heroes: [HeroListItemUIModel], showFooter: Bool, showOfflineRetry: Bool) -> some View {
        if showOfflineRetry, heroes.isEmpty {
            offlineRetryColumn()
                .padding()
                .fixedSize()
        } else {
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
                    .id(UUID())
                } else if showOfflineRetry, !heroes.isEmpty {
                    offlineRetryRow()
                }
            }
        }
    }

    @ViewBuilder
    private func heroList(_ heroes: [HeroListItemUIModel], showFooter: Bool) -> some View {
        heroList(heroes, showFooter: showFooter, showOfflineRetry: false)
    }

    @ViewBuilder
    private func offlineRetryRow() -> some View {
        HorizontalTitleWithAction(
            title: "No internet connection.",
            icon: .noConnection,
            buttonTitle: "Retry"
        ) {
            viewModel.retryPagination()
        }
    }

    @ViewBuilder
    private func offlineRetryColumn() -> some View {
        VerticalTitleWithAction(
            title: "No internet connection.",
            icon: .noConnection,
            buttonTitle: "Retry"
        ) {
            viewModel.loadInitialHeroes()
        }
    }
}
