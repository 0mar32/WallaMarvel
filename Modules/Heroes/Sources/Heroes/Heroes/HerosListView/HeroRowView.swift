//
//  HeroRowView.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import SwiftUI
import HeroesCore
import Kingfisher

struct HeroRowView: View {
    let hero: Hero

    var body: some View {
        HStack(spacing: 16) {
            KFImage(hero.thumbnail.url)
                .placeholder {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
                .cancelOnDisappear(true)
                .fade(duration: 0.25)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .background(
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .opacity(hero.thumbnail.url == nil ? 1 : 0) // fallback if no URL
                )

            Text(hero.name)
                .font(.headline)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

extension Thumbnail {
    var url: URL? {
        URL(string: "\(path).\(self.extension)")
    }
}
