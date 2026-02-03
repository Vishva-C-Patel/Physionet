//
//  RoleSelectionViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 07/01/26.
//
import UIKit

final class RoleSelectionViewController: UIViewController {

    private let roleView = RoleSelectionView()
    private let model = RoleStore.shared

    override func loadView() { view = roleView }

    override func viewDidLoad() {
        super.viewDidLoad()

        // If you have an asset, put it in Assets.xcassets as "welcome_hero"
        roleView.setHeroImage(UIImage(named: "welcome_hero"))

        roleView.patientButton.addTarget(self, action: #selector(patientTapped), for: .touchUpInside)
        roleView.physioButton.addTarget(self, action: #selector(physioTapped), for: .touchUpInside)
    }

    @objc private func patientTapped() {
        model.currentRole = .patient
        Task { await switchToPatientApp() }
    }

    @objc private func physioTapped() {
        model.currentRole = .physiotherapist
        switchToPhysioApp()
    }

    private func switchToPatientApp() async {
        let window = await MainActor.run { self.currentWindow() }

        await MainActor.run {
            guard let window else { return }
            RootRouter.setRoot(MainTabBarController(), window: window)
        }

        let isPatient = await RoleAccessGate.isSessionValid(for: .patient)
        if !isPatient {
            try? await SupabaseManager.shared.client.auth.signOut()
        }
    }

    private func switchToPhysioApp() {
        let window = currentWindow()
        Task {
            let hasSession = await RoleAccessGate.isSessionValid(for: .physiotherapist)
            await MainActor.run {
                guard let window else { return }
                if hasSession {
                    // Keep existing physio session
                    let tab = PhysioTabBarController()
                    RootRouter.setRoot(tab, window: window)
                } else {
                    let choice = PhysioRoleChoiceViewController()
                    let nav = UINavigationController(rootViewController: choice)
                    RootRouter.setRoot(nav, window: window)
                }
            }
        }
    }

    private func currentWindow() -> UIWindow? {
        // Scene-based safe window access
        return (view.window ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow })
    }
}
