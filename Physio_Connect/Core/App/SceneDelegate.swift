import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        window.rootViewController = SplashViewController { [weak self] in
            self?.startAppFlow()
        }
        window.makeKeyAndVisible()
    }

    private func startAppFlow() {
        window?.rootViewController = RoleSelectionViewController()

        Task { @MainActor [weak self] in
            guard let self else { return }
            let session = try? await SupabaseManager.shared.client.auth.session
            guard session != nil else {
                RoleStore.shared.clear()
                self.window?.rootViewController = RoleSelectionViewController()
                return
            }

            if let role = RoleStore.shared.currentRole {
                let isValid = await RoleAccessGate.isSessionValid(for: role)
                if !isValid {
                    try? await SupabaseManager.shared.client.auth.signOut()
                    switch role {
                    case .patient:
                        self.window?.rootViewController = MainTabBarController()
                    case .physiotherapist:
                        let nav = UINavigationController(rootViewController: PhysioAuthViewController())
                        self.window?.rootViewController = nav
                    }
                    return
                }

                switch role {
                case .patient:
                    self.window?.rootViewController = MainTabBarController()
                case .physiotherapist:
                    let tab = PhysioTabBarController()
                    self.window?.rootViewController = tab
                }
            } else {
                self.window?.rootViewController = RoleSelectionViewController()
            }
        }
    }
}
