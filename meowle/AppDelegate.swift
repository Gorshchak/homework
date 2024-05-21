//
//  AppDelegate.swift
//  meowle
//
//  Created by a.gorshchak on 20.01.2024.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var isAuthorized: Bool {
        return UserDefaults.standard.string(forKey: "username") != nil
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if ProcessInfo.processInfo.environment["UITests"] != nil {
            UserDefaults.standard.removeObject(forKey: "username")
        }
        let window = UIWindow()
        self.window = window
        let rootVC = UITabBarController()
        let urlSession = URLSession.shared
        let networkService = NetworkService(session: urlSession)
        let imageResolversFactory = ImageResolversFactory(session: urlSession)
        let settingsVC = SettingsViewController()
        settingsVC.output = self
        rootVC.viewControllers = [
            SearchViewController(
                networkService: networkService,
                imageResolversFactory: imageResolversFactory
            ).wrappedInNavigationController(),
            RatingViewController(
                networkService: networkService,
                imageResolversFactory: imageResolversFactory
            ).wrappedInNavigationController(),
            AddCatViewController(
                networkService: networkService,
                imageResolversFactory: imageResolversFactory
            ).wrappedInNavigationController(),
            SearchResultsViewController(
                networkService: networkService,
                imageResolversFactory: imageResolversFactory,
                data: [],
                isFavorite: true
            ).wrappedInNavigationController(),
            settingsVC.wrappedInNavigationController()
        ]
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        if !isAuthorized {
            let authVC = AuthViewController()
            authVC.output = self
            rootVC.present(authVC, animated: false)
        }
        return true
    }
}

// MARK: - AuthOutput

extension AppDelegate: AuthOutput {
    
    func didAuth(as username: String) {
        UserDefaults.standard.set(username, forKey: "username")
    }
}

// MARK: - SettingsOutput

extension AppDelegate: SettingsOutput {
    
    func didLogout() {
        UserDefaults.standard.removeObject(forKey: "username")
        let authVC = AuthViewController()
        authVC.output = self
        window?.rootViewController?.present(authVC, animated: true) { [weak window] in
            (window?.rootViewController as? UITabBarController)?.selectedIndex = .zero
        }
    }
}

// MARK: - Private

private extension UIViewController {
    
    func wrappedInNavigationController() -> UIViewController {
        return UINavigationController(rootViewController: self)
    }
}
