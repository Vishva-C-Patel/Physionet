//
//  AppLogout.swift
//  Physio_Connect
//
//  Created by user@8 on 07/01/26.
//
import UIKit

enum AppLogout {

    static func backToRoleSelection(from view: UIView?, signOut: Bool = true) {
        let window = findWindow(from: view)

        // Clear stored role
        RoleStore.shared.clear()

        // Immediately route back to role selection so UI never hangs on sign-out
        let roleVC = RoleSelectionViewController()
        RootRouter.setRoot(roleVC, window: window)

        // Optionally sign out (used when leaving patient side; physio may keep session)
        if signOut {
            Task { try? await SupabaseManager.shared.client.auth.signOut() }
        }

    }

    private static func findWindow(from view: UIView?) -> UIWindow? {
        if let w = view?.window { return w }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
