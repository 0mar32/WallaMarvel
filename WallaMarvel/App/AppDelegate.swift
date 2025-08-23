import SwiftUI
import UIKit

import Heroes
import HeroesCore
import HeroDetails

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        AppConfiguration.configureOnLaunch()

        // TODO: Change this to Coordinator pattern
        setRootViewController()

        return true
    }

    func setRootViewController() {
        let window = UIWindow(frame: UIScreen.main.bounds)

        // in UITests we want to store in Memory, instead of disk
        let repository = HeroesRepository()
        let interactor = HeroesPaginationInteractor(repository: repository)
        let factory = HeroesListFactory(dependencies: .init(interactor: interactor))

        let rootNavigationController = UINavigationController()
        let rootVC = factory.makeViewController { hero in
            let HeroesDetailsFactory = HeroesDetailsFactory()
            rootNavigationController.pushViewController(
                HeroesDetailsFactory.makeViewController(hero: hero),
                animated: true
            )
        }
        rootNavigationController.viewControllers = [rootVC]
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}
