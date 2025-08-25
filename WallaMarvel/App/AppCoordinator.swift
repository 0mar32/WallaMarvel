//
//  AppCoordinator.swift
//  WallaMarvel
//
//  Created by Omar Tarek Mansour Omar on 25/8/25.
//

import UIKit
import Heroes
import HeroesCore
import HeroDetails

protocol Coordinator {
    var navigationController: UINavigationController { get }
    func start() async
}

final class AppCoordinator: Coordinator {

    // Keep a strong ref to the window.
    private let window: UIWindow

    // Expose the nav if other coordinators need it.
    let navigationController = UINavigationController()

    init(window: UIWindow) {
        self.window = window
    }

    @MainActor
    func start() {
        // Root wiring
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let repository = HeroesRepository()
        let interactor = HeroesPaginationInteractor(repository: repository)
        let listFactory = HeroesListFactory(dependencies: .init(interactor: interactor))

        let listVC = listFactory.makeViewController { [weak self] hero in
            self?.showDetails(for: hero)
        }
        navigationController.setViewControllers([listVC], animated: false)
    }

    @MainActor
    private func showDetails(for hero: Hero) {
        let detailsFactory = HeroesDetailsFactory()
        let detailsVC = detailsFactory.makeViewController(hero: hero)
        navigationController.pushViewController(detailsVC, animated: true)
    }
}
