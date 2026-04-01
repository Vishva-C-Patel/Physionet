import UIKit

enum UITheme {
    enum Colors {
        // iOS 26 system-adaptive colors for Liquid Glass design
        static let accent = UIColor(hex: "1E6EF7")
        static let background = UIColor.systemGroupedBackground
        static let surface = UIColor.secondarySystemGroupedBackground
        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let textMuted = UIColor.tertiaryLabel
        static let border = UIColor.separator
        static let neutralFill = UIColor.tertiarySystemFill

        // Glass-specific
        static let glassBackground = UIColor.systemBackground.withAlphaComponent(0.7)
        static let glassBorder = UIColor.separator.withAlphaComponent(0.3)

        // Card backgrounds (system-adaptive)
        static let cardBackground = UIColor.secondarySystemGroupedBackground
    }

    enum Fonts {
        static func title(_ size: CGFloat) -> UIFont {
            .systemFont(ofSize: size, weight: .bold)
        }

        static func subtitle(_ size: CGFloat) -> UIFont {
            .systemFont(ofSize: size, weight: .semibold)
        }

        static func body(_ size: CGFloat) -> UIFont {
            .systemFont(ofSize: size, weight: .regular)
        }
    }

    // Standardized typography scale used across patient + physio flows.
    enum Typography {
        static let screenTitle = UIFont.systemFont(ofSize: 20, weight: .bold)
        static let sectionTitle = UIFont.systemFont(ofSize: 18, weight: .bold)
        static let cardTitle = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let cardTitleRegular = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let body = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let bodySmall = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let bodySmallMedium = UIFont.systemFont(ofSize: 14, weight: .medium)
        static let meta = UIFont.systemFont(ofSize: 13, weight: .medium)
        static let caption = UIFont.systemFont(ofSize: 12, weight: .semibold)
        static let button = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let buttonSmall = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }

    enum Metrics {
        static let cardCornerRadius: CGFloat = 22
        static let chipCornerRadius: CGFloat = 14
        static let buttonCornerRadius: CGFloat = 27
        static let cardShadowOpacity: Float = 0.04
        static let cardShadowRadius: CGFloat = 16
        static let cardShadowOffset = CGSize(width: 0, height: 4)
    }

    // MARK: - Glass Card Style (iOS 26 Liquid Glass)

    /// Applies a translucent glass card style using UIVisualEffectView.
    /// Returns the content view where subviews should be added.
    @discardableResult
    static func applyGlassCardStyle(_ view: UIView) -> UIVisualEffectView {
        view.backgroundColor = .clear
        view.layer.cornerRadius = Metrics.cardCornerRadius
        view.clipsToBounds = true

        // Create blur effect
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = Metrics.cardCornerRadius
        blurView.clipsToBounds = true
        view.insertSubview(blurView, at: 0)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Subtle border for glass definition
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Colors.glassBorder.cgColor

        // Softer shadow
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        blurView.layer.cornerRadius = Metrics.cardCornerRadius
        blurView.clipsToBounds = true

        return blurView
    }

    /// Classic card style — updated for iOS 26 with larger corner radius, softer shadows and subtle border.
    static func applyCardStyle(_ view: UIView) {
        view.backgroundColor = Colors.surface
        view.layer.cornerRadius = Metrics.cardCornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Colors.glassBorder.cgColor
    }

    static func applySecondaryCardStyle(_ view: UIView) {
        view.backgroundColor = Colors.surface
        view.layer.cornerRadius = Metrics.cardCornerRadius
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Colors.border.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.03
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    // MARK: - Glass Tab/Nav Bar Appearance

    static func makeGlassTabBarAppearance() -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        // iOS 26: use default background for native Liquid Glass capsule rendering
        appearance.configureWithDefaultBackground()

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = UIColor.secondaryLabel
        normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = Colors.accent
        selected.titleTextAttributes = [.foregroundColor: Colors.accent]

        return appearance
    };    static func makeGlassNavBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        // iOS 26: Use system ultra thin material for a premium glass feel
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)
        appearance.shadowColor = Colors.glassBorder
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        appearance.titleTextAttributes = titleAttrs
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        return appearance
    }

    /// Applies the refined native iOS navigation bar — transparent on scroll edge, glass when scrolled.
    static func applyNativeNavBar(to vc: UIViewController, title: String) {
        let navBar = vc.navigationController?.navigationBar
        navBar?.prefersLargeTitles = false
        navBar?.tintColor = Colors.accent

        let standard = makeGlassNavBarAppearance()
        
        let scrollEdge = UINavigationBarAppearance()
        scrollEdge.configureWithTransparentBackground()
        scrollEdge.shadowColor = .clear
        scrollEdge.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]

        navBar?.standardAppearance = standard
        navBar?.scrollEdgeAppearance = scrollEdge
        navBar?.compactAppearance = standard

        vc.navigationItem.title = title
        vc.navigationItem.backButtonDisplayMode = .minimal
        
        // Remove custom title views that might glitch the native hovering behavior
        vc.navigationItem.titleView = nil
    }

    /// Applies standardized iOS 26 Liquid Glass styling to a segmented control.
    static func applySegmentedStyle(_ segmented: UISegmentedControl) {
        // High contrast selection for immediate visibility
        segmented.selectedSegmentTintColor = Colors.accent
        segmented.backgroundColor = UIColor.tertiarySystemFill
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: Typography.buttonSmall
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ]
        
        segmented.setTitleTextAttributes(normalAttrs, for: .normal)
        segmented.setTitleTextAttributes(selectedAttrs, for: .selected)
        
        // Fix for selection not showing at first: force an update
        let current = segmented.selectedSegmentIndex
        segmented.selectedSegmentIndex = -1
        segmented.selectedSegmentIndex = current
    }

    /// Generates initials from a name (e.g. "John Doe" -> "JD")
    static func getInitials(from name: String) -> String {
        let words = name.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let initials = words.prefix(2).compactMap { $0.first.map(String.init) }
        return initials.joined().uppercased()
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

// MARK: - App Background Top Glow View

final class AppBackgroundTopGlowView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Primary neutral background
        self.backgroundColor = .systemGroupedBackground
        
        gradientLayer.type = .radial
        layer.addSublayer(gradientLayer)
        updateColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Create a large square centered at the top-left (0,0)
        let size = max(bounds.width, bounds.height) * 1.5
        gradientLayer.frame = CGRect(x: -size / 2, y: -size / 2, width: size, height: size)
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5) // Center of the square
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)   // Expand outward
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }
    
    private func updateColors() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        
        // Light Mode: E3F0FF glowing gently
        let lightColors = [
            UIColor(hex: "E3F0FF").withAlphaComponent(1.0).cgColor,
            UIColor(hex: "E3F0FF").withAlphaComponent(0.0).cgColor
        ]
        
        // Dark Mode: Navy blue glowing gently against dark background
        let darkColors = [
            UIColor(hex: "1F4275").withAlphaComponent(0.35).cgColor,
            UIColor(hex: "060B14").withAlphaComponent(0.0).cgColor
        ]
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.colors = isDark ? darkColors : lightColors
        CATransaction.commit()
    }
}

