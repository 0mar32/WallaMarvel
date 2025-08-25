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
                .onChange(of: viewModel.alert) { error in
                    errorAlert = error
                }
                .alert(item: $errorAlert) { error in
                    Alert(title: Text(error.title),
                          message: Text(error.message),
                          dismissButton: .default(Text(error.actionTitle)))
                }
        }
        // this need to be on the NavigationView to avoid auto cancelling the stream when the screen state changes from loading to loaded
        // loadInitialHeroesStream is AsyncStream that return cached data -> remote data
        // when cached is returned the view caches from ProgressView to the List which makes the the as cancel before getting the remote data.
        // so we need to keep the stream live on the level of NavigationView
        // other wise we can move this to onAppear and make the VM own the task to control the cancellation, but for now this one works well
        .task {
            await viewModel.loadInitialHeroesStream()
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

        case let .loaded(model):
            heroList(
                model.heroes,
                isLoadingMore: model.isLoadingMore,
                error: model.listError
            )

        case let .error(error, heroes):
            if !heroes.isEmpty {
                heroList(heroes, error: error)
            }
        }
    }

    // MARK: - Hero List
    @ViewBuilder
    private func heroList(
        _ heroes: [HeroListItemUIModel],
        isLoadingMore: Bool? = nil,
        error: ErrorMessageUIModel? = nil
    ) -> some View {

        if let error, heroes.isEmpty {
            offlineRetryColumn(errorModel: error)
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
                    .accessibilityIdentifier(AccessibilityID.heroCell(hero.name))
                    .fadeSlideIn(index: index)
                    .task {
                        await viewModel.loadMoreHeroesIfNeeded(currentHero: hero)
                    }
                }

                // this VStack is important for the loading spinner to work
                // without it SwiftUI sees the subtree view inside the if body has the same id all the time which makes
                // a problem with cell reusability that makes the spinner appears only the first time
                // but now swiftUI is able to identify that is a different subtree view
                // an other solution would be use .id(UUID) so swiftUI can no it is a new view each time we displays it.
                // it is not gonna have performance problem in that case, but it is not a good practice in general
                VStack {
                    if isLoadingMore == true {
                        HStack {
                            Spacer()
                            ProgressView()
                                .accessibilityIdentifier(AccessibilityID.paginationSpinner)
                            Spacer()
                        }
                    } else if let error, !heroes.isEmpty {
                        offlineRetryRow(errorModel: error)
                            .accessibilityIdentifier(AccessibilityID.retryRow)
                    }
                }
            }
            .accessibilityIdentifier(AccessibilityID.table)
        }
    }

    // MARK: - Retry Views
    @ViewBuilder
    private func offlineRetryRow(errorModel: ErrorMessageUIModel) -> some View {
        HorizontalTitleWithAction(
            title: errorModel.title,
            icon: .noConnection,
            buttonTitle: errorModel.actionTitle
        ) {
            Task { await viewModel.retryPagination() }
        }
        .accessibilityHint("Tap to retry loading more heroes")
    }

    @ViewBuilder
    private func offlineRetryColumn(errorModel: ErrorMessageUIModel) -> some View {
        VerticalTitleWithAction(
            title: errorModel.title,
            icon: .noConnection,
            buttonTitle: errorModel.actionTitle
        ) {
            Task { await viewModel.loadInitialHeroesStream() }
        }
        .accessibilityHint("Tap to retry loading heroes")
    }
}
