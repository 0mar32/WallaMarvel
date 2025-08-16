//
//  AnimatedSectionView.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//
import SwiftUI

struct AnimatedSectionView: View {
    let title: String
    let items: [String]

    @State private var appear = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.easeOut.delay(Double(items.firstIndex(of: item) ?? 0) * 0.05), value: appear)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading) // <- full width
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16) // consistent outer margin
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appear = true }
        }
    }
}
