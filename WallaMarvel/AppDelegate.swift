import SwiftUI
import UIKit

import Heroes
import HeroesCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // Create UIWindow manually
        let window = UIWindow(frame: UIScreen.main.bounds)

        // Setup dependencies for the HeroesListFactory
        let repository = HeroesRepository()
        let interactor = HeroesPaginationInteractor(repository: repository)
        let factory = HeroesListFactory(dependencies: .init(interactor: interactor))

        // Create root VC
        let rootVC = factory.makeViewController()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        self.window = window

        return true
    }
}

