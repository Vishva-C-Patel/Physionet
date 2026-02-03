//
//  RootRouter.swift
//  Physio_Connect
//
//  Created by user@8 on 07/01/26.
//
import UIKit

enum RootRouter {

    static func setRoot(_ vc: UIViewController, window: UIWindow?, animated: Bool = true) {
        guard let window else { return }

        if animated {
            UIView.transition(with: window,
                              duration: 0.25,
                              options: [.transitionCrossDissolve, .allowAnimatedContent],
                              animations: {
                window.rootViewController = vc
            }, completion: nil)
        } else {
            window.rootViewController = vc
        }

        window.makeKeyAndVisible()
    }
}

