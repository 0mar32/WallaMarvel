//
//  FadeSlideIn.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import SwiftUI

private struct FadeSlideIn: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 20)
            .onAppear {
                guard !shown else { return }
                if reduceMotion {
                    shown = true
                } else {
                    withAnimation(
                        .easeOut(duration: AnimationDuration.spark).delay(delay)
                    ) {
                        shown = true
                    }
                }
            }
    }
}

public extension View {
    /// Subtle, fast fade+slide for list rows. Adds a tiny stagger by index.
    func fadeSlideIn(index: Int, baseDelay: Double = 0.01, maxSteps: Int = 8) -> some View {
        let step = min(index, maxSteps)
        return modifier(FadeSlideIn(delay: Double(step) * baseDelay))
    }
}
