//
//  UIImageView+Initials.swift
//  Physio_Connect
//

import UIKit

extension UIImage {
    static func generatedInitials(name: String?, size: CGSize = CGSize(width: 40, height: 40), backgroundColor: UIColor? = nil, textColor: UIColor? = nil) -> UIImage? {
        let displayName = name ?? "User"
        let initials = UITheme.getInitials(from: displayName)

        let targetSize = size

        let defaultBg = UITheme.Colors.accent.withAlphaComponent(0.15)
        let defaultText = UITheme.Colors.accent

        let bg = backgroundColor ?? defaultBg
        let textCol = textColor ?? defaultText

        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: targetSize))
        context.setFillColor(bg.cgColor)
        path.fill()

        let fontSize = targetSize.height * 0.45
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textCol
        ]

        let textSize = initials.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (targetSize.width - textSize.width) / 2.0,
            y: (targetSize.height - textSize.height) / 2.0,
            width: textSize.width,
            height: textSize.height
        )

        initials.draw(in: textRect, withAttributes: attributes)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImageView {
    func setInitials(from name: String?,
                     size: CGSize? = nil,
                     backgroundColor: UIColor? = nil,
                     textColor: UIColor? = nil) {
        
        let targetSize = size ?? (bounds.size != .zero ? bounds.size : CGSize(width: 40, height: 40))
        self.image = UIImage.generatedInitials(name: name, size: targetSize, backgroundColor: backgroundColor, textColor: textColor)

        self.contentMode = .center
        self.layer.cornerRadius = targetSize.height / 2.0
        self.layer.masksToBounds = true
    }
}
