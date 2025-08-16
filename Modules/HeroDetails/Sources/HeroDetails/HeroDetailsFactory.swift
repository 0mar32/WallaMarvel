//
//  Untitled.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//
import UIKit
import SwiftUI
import HeroesCore

// Factory for creating HeroesDetails screen
final public class HeroesDetailsFactory {

    public init(){}

    /// Create a UIViewController wrapping the SwiftUI HeroesDetailsView
    @MainActor
    public func makeViewController(hero: Hero) -> UIViewController {
        let viewModel = HeroDetailsViewModel(
            hero: hero,
            HeroDetailsUIModelMapper: HeroDetailsUIModelMapper()
        )
        let view = HeroDetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}
