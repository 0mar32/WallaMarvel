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

        // Create UIWindow manually
        let window = UIWindow(frame: UIScreen.main.bounds)

        // Setup dependencies for the HeroesListFactory
        let repository = HeroesRepository(
            apiService: HeroesAPIService(),
            storageService: HeroesStorageService(
                persistence: PersistenceController(
                    inMemory: AppEnvironment.isRunningUITests
                )
            )
        )
        let interactor = HeroesPaginationInteractor(
            repository: repository
        )
        let factory = HeroesListFactory(dependencies: .init(interactor: interactor))

        // Create root VC
        let rootNavigationController = UINavigationController()
        let rootVC = factory.makeViewController { hero in
            rootNavigationController
                .pushViewController(
                    HeroesDetailsFactory().makeViewController(hero: hero),
                    animated: true
                )
        }
        rootNavigationController.viewControllers = [rootVC]
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()

        self.window = window

        return true
    }
}

