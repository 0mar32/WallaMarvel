import SwiftUI
import HeroesCore
import DesignSystem

struct HeroesListView: View {
    @StateObject private var viewModel: HeroesListViewModel
    @State private var errorAlert: ErrorMessageUIModel?
    let onHeroSelected: (Hero) -> Void

    // MARK: - Init
    init(
        viewModel: HeroesListViewModel,
        onHeroSelected: @escaping (Hero) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onHeroSelected = onHeroSelected
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            content
                .navigationTitle(viewModel.state.viewTitle)
                .onAppear {
                    Task { await viewModel.loadInitialHeroes() }
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
        .accessibilityIdentifier(AccessibilityID.screen)
    }

    // MARK: - Content States
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear

        case let .loadingInitial(message):
            ProgressView(message)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(AccessibilityID.loading)

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

    // MARK: - Hero List
    @ViewBuilder
    private func heroList(
        _ heroes: [HeroListItemUIModel],
        showFooter: Bool,
        showOfflineRetry: Bool
    ) -> some View {
        if showOfflineRetry, heroes.isEmpty {
            offlineRetryColumn()
                .padding()
                .fixedSize()
                .accessibilityIdentifier(AccessibilityID.retryColumn)
        } else {
            List {
                ForEach(Array(heroes.enumerated()), id: \.element.id) { index, hero in
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
                    .accessibilityIdentifier(AccessibilityID.heroCell(hero.id))
                    .fadeSlideIn(index: index)
                    .onAppear {
                        Task { await viewModel.loadMoreHeroesIfNeeded(currentHero: hero) }
                    }
                }

                if showFooter {
                    HStack {
                        Spacer()
                        ProgressView()
                            .accessibilityIdentifier(AccessibilityID.paginationSpinner)
                        Spacer()
                    }
                    .id(UUID())
                } else if showOfflineRetry, !heroes.isEmpty {
                    offlineRetryRow()
                        .accessibilityIdentifier(AccessibilityID.retryRow)
                }
            }
            .accessibilityIdentifier(AccessibilityID.table)
        }
    }

    @ViewBuilder
    private func heroList(
        _ heroes: [HeroListItemUIModel],
        showFooter: Bool
    ) -> some View {
        heroList(heroes, showFooter: showFooter, showOfflineRetry: false)
    }

    // MARK: - Retry Views
    @ViewBuilder
    private func offlineRetryRow() -> some View {
        HorizontalTitleWithAction(
            title: "No internet connection.",
            icon: .noConnection,
            buttonTitle: "Retry"
        ) {
            Task { await viewModel.retryPagination() }
        }
        .accessibilityHint("Tap to retry loading more heroes")
    }

    @ViewBuilder
    private func offlineRetryColumn() -> some View {
        VerticalTitleWithAction(
            title: "No internet connection.",
            icon: .noConnection,
            buttonTitle: "Retry"
        ) {
            Task { await viewModel.loadInitialHeroes() }
        }
        .accessibilityHint("Tap to retry loading heroes")
    }
}
