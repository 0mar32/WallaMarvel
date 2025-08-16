//
//  AnimatedSectionView.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//
import SwiftUI

public struct AnimatedSectionView: View {
    let title: String
    let items: [String]
    let icon: SFIcon?

    @State private var appear = false

    public init(title: String, items: [String], icon: SFIcon? = nil) {
        self.title = title
        self.items = items
        self.icon = icon
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Padding.small) {
            HStack(spacing: Padding.small) {
                if let icon {
                    Image(systemName: icon.systemName)
                        .font(.system(size: Sizes.Icon.medium))
                        .foregroundColor(Color(Colors.Foreground.primary))
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(.easeOut(duration: AnimationDuration.normal), value: appear)
                }

                Text(title)
                    .font(TextStyles.heading2)
                    .foregroundColor(Color(Colors.Text.primary))
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.easeOut(duration: AnimationDuration.normal), value: appear)
            }

            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Text(item)
                    .font(TextStyles.body)
                    .foregroundColor(Color(Colors.Text.secondary))
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.easeOut.delay(Double(index) * 0.05), value: appear)
            }
        }
        .padding(Padding.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(Color(Colors.Background.section))
                .shadow(color: Color.black.opacity(0.1),
                        radius: Shadow.light.radius,
                        x: Shadow.light.offsetX,
                        y: Shadow.light.offsetY)
        )
        .padding(.horizontal, Padding.large)
        .onAppear {
            withAnimation(.easeOut(duration: AnimationDuration.normal)) {
                appear = true
            }
        }
    }
}
