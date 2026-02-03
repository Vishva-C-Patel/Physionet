//
//  UIColor+Hex.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//
import UIKit

extension UIColor {

    /// Supports both: UIColor(hex: "E3F0FF") and UIColor("E3F0FF")
    convenience init(hex: String) {
        self.init(_hex: hex)
    }

    convenience init(_ hex: String) {
        self.init(_hex: hex)
    }

    private convenience init(_hex: String) {
        var hex = _hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}


