//
//  HeroDetailsView.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import SwiftUI
import HeroesCore
import SwiftUI
import HeroesCore
import Kingfisher

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
                            AnimatedSectionView(title: stories.title, items: stories.names)
                        }
                        if let series = heroDetailsUIModel.seriesSection {
                            AnimatedSectionView(title: series.title, items: series.names)
                        }
                        Spacer(minLength: 32)
                    }
                }
            }
        }
        .navigationTitle(viewModel.state.heroName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.refreshHeroDetails()
        }
    }

    @ViewBuilder
    private func heroImage(url: URL?, geo: GeometryProxy) -> some View {
        KFImage(url)
            .placeholder {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: 200) // temporary height while loading
            }
            .cancelOnDisappear(true)
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fit) // keep ratio, width defines height
            .frame(maxWidth: .infinity)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .background(
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .opacity(url == nil ? 1 : 0) // fallback when no URL
            )
    }

    // MARK: - Hero Info
    @ViewBuilder
    private func heroInfo(name: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .transition(.move(edge: .top).combined(with: .opacity))

            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .transition(.opacity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: description)
    }
}
