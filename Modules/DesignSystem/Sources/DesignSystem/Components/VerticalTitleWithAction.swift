//
//  VerticalTitleWithAction.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

import SwiftUI

public struct VerticalTitleWithAction: View {
    private let title: String
    private let icon: SFIcon?
    private let buttonTitle: String
    private let action: () -> Void

    public init(
        title: String,
        icon: SFIcon? = nil,
        buttonTitle: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.buttonTitle = buttonTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: Padding.medium) {
            if let icon {
                Image(systemName: icon.systemName)
            }
            Text(title)
                .lineLimit(2)
                .truncationMode(.tail)
            Spacer()
            Button(buttonTitle, action: action)
                .buttonStyle(.bordered)
        }
        .font(.callout)
        .foregroundColor(.secondary)
        .padding(.vertical, Padding.medium)
    }
}
