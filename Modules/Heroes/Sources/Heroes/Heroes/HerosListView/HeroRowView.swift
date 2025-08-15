//
//  HeroRowView.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import SwiftUI
import HeroesCore

struct HeroRowView: View {
    let hero: Hero

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: hero.thumbnail.url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .resizable()
                        .frame(width: 60, height: 60)
                @unknown default:
                    EmptyView()
                }
            }

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
