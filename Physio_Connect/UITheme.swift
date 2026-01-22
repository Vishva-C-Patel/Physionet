import UIKit

enum UITheme {
    enum Colors {
        static let accent = UIColor(hex: "1E6EF7")
        static let background = UIColor(hex: "EAF2FF")
        static let surface = UIColor.white
        static let textPrimary = UIColor(hex: "1E2A44")
        static let textSecondary = UIColor(hex: "5C6B80")
        static let textMuted = UIColor.black.withAlphaComponent(0.5)
        static let border = UIColor(hex: "D9E6FF")
        static let neutralFill = UIColor(hex: "F5F7FB")
    }

    enum Fonts {
        static func title(_ size: CGFloat) -> UIFont {
            UIFont(name: "AvenirNext-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
        }

        static func subtitle(_ size: CGFloat) -> UIFont {
            UIFont(name: "AvenirNext-DemiBold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
        }

        static func body(_ size: CGFloat) -> UIFont {
            UIFont(name: "AvenirNext-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
        }
    }

    enum Metrics {
        static let cardCornerRadius: CGFloat = 16
        static let chipCornerRadius: CGFloat = 12
        static let cardShadowOpacity: Float = 0.08
        static let cardShadowRadius: CGFloat = 10
        static let cardShadowOffset = CGSize(width: 0, height: 6)
    }

    static func applyCardStyle(_ view: UIView) {
        view.backgroundColor = Colors.surface
        view.layer.cornerRadius = Metrics.cardCornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = Metrics.cardShadowOpacity
        view.layer.shadowRadius = Metrics.cardShadowRadius
        view.layer.shadowOffset = Metrics.cardShadowOffset
    }

    static func applySecondaryCardStyle(_ view: UIView) {
        view.backgroundColor = Colors.surface
        view.layer.cornerRadius = Metrics.cardCornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.border.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}

final class PillLabel: UILabel {
    var contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + contentInsets.left + contentInsets.right,
            height: size.height + contentInsets.top + contentInsets.bottom
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
}
