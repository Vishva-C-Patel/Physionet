//
//  UIViewController+DismissKeyboard.swift
//  Physio_Connect
//
//  Global keyboard dismissal — tapping anywhere outside a text input
//  will resign the first responder.
//

import UIKit

extension UIViewController {

    /// Call this in `viewDidLoad()` to install a tap gesture that dismisses the keyboard
    /// when the user taps anywhere outside the active text field / text view / search bar.
    func enableTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(_dismissKeyboard))
        tap.cancelsTouchesInView = false          // allow buttons & table cells to still receive taps
        view.addGestureRecognizer(tap)
    }

    @objc private func _dismissKeyboard() {
        view.endEditing(true)
    }
}
