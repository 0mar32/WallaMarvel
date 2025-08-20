//
//  AvatarRowView.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//

import SwiftUI
import Kingfisher
import HeroesCore

public struct AvatarRowView: View {
    public enum Style {
        case normal
        case highlighted(borderColor: UIColor)
    }

    let title: String
    let imageURL: URL?
    let style: Style

    public init(title: String, imageURL: URL?, style: Style = .normal) {
        self.title = title
        self.imageURL = imageURL
        self.style = style
    }

    public var body: some View {
        HStack(spacing: Padding.medium) {

            KFImage(imageURL)
                .placeholder {
                    ProgressView()
                        .frame(width: Sizes.Avatar.medium, height: Sizes.Avatar.medium)
                }
                .onFailureView {
                    Image(systemName: SFIcon.noPersonImage.systemName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Sizes.Avatar.medium, height: Sizes.Avatar.medium)
                        .foregroundColor(Color(Colors.Text.placeholder))
                }
                .cancelOnDisappear(true)
                .fade(duration: AnimationDuration.fast)
                .resizable()
                .scaledToFill()
                .frame(width: Sizes.Avatar.medium, height: Sizes.Avatar.medium)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: borderWidth)
                )

            Text(title)
                .font(TextStyles.heading3)
                .foregroundColor(Color(Colors.Text.primary))

            Spacer()
        }
        .padding(.vertical, Padding.small)
    }

    // MARK: - Helpers
    private var borderColor: Color {
        switch style {
        case .highlighted(let uiColor):
            return Color(uiColor)
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .highlighted:
            return BorderWidth.thick
        default:
            return 0
        }
    }
}
