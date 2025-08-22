//
//  HeroesListFactory.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
//

import SwiftUI
import UIKit
import HeroesCore

//
final public class HeroesListFactory {

    public struct Dependencies {
        let interactor: HeroesPaginationInteractorProtocol

        public init(interactor: HeroesPaginationInteractorProtocol) {
            self.interactor = interactor
        }
    }

    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    /// Create a UIViewController wrapping the SwiftUI HeroesListView
    @MainActor
    public func makeViewController(onHeroSelected: @escaping (Hero) -> Void) -> UIViewController {
        let viewModel = HeroesListViewModel(
            interactor: dependencies.interactor,
            heroesListMapper: HeroesListUIModelMapper()
        )
        let view = HeroesListView(viewModel: viewModel, onHeroSelected: onHeroSelected)
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}
