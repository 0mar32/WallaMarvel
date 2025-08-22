//
//  HeroDetailsView.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//

import SwiftUI
import HeroesCore
import Kingfisher
import DesignSystem

// MARK: - Detail View
struct HeroDetailView: View {
    @StateObject private var viewModel: HeroDetailsViewModel

    init(viewModel: HeroDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 16) {
                    switch viewModel.state {
                    case .idle:
                        ProgressView()
                            .accessibilityIdentifier(AccessibilityID.loading)

                    case let .loaded(heroDetailsUIModel):
                        heroImage(
                            url: heroDetailsUIModel.imageURL,
                            geo: geo
                        )
                        heroInfo(
                            name: heroDetailsUIModel.title,
                            description: heroDetailsUIModel.description
                        )
                        if let stories = heroDetailsUIModel.storiesSection {
                            InfoSectionView(
                                title: stories.title,
                                items: stories.names,
                                icon: stories.icon
                            )
                            .accessibilityIdentifier(AccessibilityID.storiesSection)
                        }
                        if let series = heroDetailsUIModel.seriesSection {
                            InfoSectionView(
                                title: series.title,
                                items: series.names,
                                icon: series.icon
                            )
                            .accessibilityIdentifier(AccessibilityID.seriesSection)
                        }
                        Spacer(minLength: 32)
                    }
                }
            }
        }
        .navigationTitle(viewModel.state.heroName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.refreshHeroDetails() }
        .accessibilityIdentifier(AccessibilityID.screen)
    }

    // MARK: - Hero Image
    @ViewBuilder
    private func heroImage(url: URL?, geo: GeometryProxy) -> some View {
        KFImage(url)
            .placeholder {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .accessibilityIdentifier(AccessibilityID.imagePlaceholder)
            }
            .cancelOnDisappear(true)
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .background(
                Image(systemName: SFIcon.photo.systemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .opacity(url == nil ? 1 : 0)
            )
            .accessibilityIdentifier(AccessibilityID.image)
    }

    // MARK: - Hero Info
    @ViewBuilder
    private func heroInfo(name: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityIdentifier(AccessibilityID.title)

            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .transition(.opacity)
                .accessibilityIdentifier(AccessibilityID.description)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: description)
        .accessibilityIdentifier(AccessibilityID.infoContainer)
    }
}
