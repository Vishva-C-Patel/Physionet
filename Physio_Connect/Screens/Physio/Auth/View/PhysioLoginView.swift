//
//  PhysioLoginView.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
//

import UIKit

final class PhysioLoginView: UIView {

    // MARK: - Callbacks
    var onBack: (() -> Void)?
    var onLogin: ((String, String) -> Void)?
    var onSignupTapped: (() -> Void)?

    // MARK: - UI
    private let primaryBlue = UIColor(hex: "1E6EF7")

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    private let subtitleLabel = UILabel()
    private let statusLabel = UILabel()

    let emailField = PhysioIconTextField(iconSystemName: "envelope")
    let passwordField = PhysioIconTextField(iconSystemName: "lock")
    private let passwordEyeButton = UIButton(type: .system)

    let loginButton = UIButton(type: .system)
    let signUpButton = UIButton(type: .system)

    // MARK: - Social
    let googleButton = UIButton(type: .custom)
    let appleButton = UIButton(type: .custom)

    private var isPasswordVisible = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UITheme.Colors.background
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])

        // removed headerRow

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Log in to continue"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center

        stack.addArrangedSubview(subtitleLabel)
        stack.setCustomSpacing(28, after: subtitleLabel)

        emailField.placeholder = "Email Address"
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none

        passwordField.placeholder = "Password"
        passwordField.textField.isSecureTextEntry = true
        passwordField.textField.autocapitalizationType = .none
        passwordField.textField.autocorrectionType = .no
        passwordField.textField.keyboardType = .asciiCapable
        passwordField.textField.textContentType = .password

        configureEyeButton(passwordEyeButton)
        passwordEyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        passwordField.setTrailingAccessory(passwordEyeButton)

        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(passwordField)
        stack.setCustomSpacing(28, after: passwordField)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textColor = UIColor.red.withAlphaComponent(0.85)
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true
        stack.addArrangedSubview(statusLabel)

        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        loginButton.backgroundColor = primaryBlue
        loginButton.layer.cornerRadius = 28
        loginButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        stack.addArrangedSubview(loginButton)

        let orDivider = UIView()
        orDivider.translatesAutoresizingMaskIntoConstraints = false
        orDivider.heightAnchor.constraint(equalToConstant: 24).isActive = true
        let line1 = UIView()
        let line2 = UIView()
        let label = UILabel()
        line1.translatesAutoresizingMaskIntoConstraints = false
        line2.translatesAutoresizingMaskIntoConstraints = false
        line1.backgroundColor = UITheme.Colors.border
        line2.backgroundColor = UITheme.Colors.border
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "or continue with"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .placeholderText
        orDivider.addSubview(line1)
        orDivider.addSubview(line2)
        orDivider.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: orDivider.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: orDivider.centerYAnchor),
            line1.leadingAnchor.constraint(equalTo: orDivider.leadingAnchor),
            line1.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            line1.centerYAnchor.constraint(equalTo: orDivider.centerYAnchor),
            line1.heightAnchor.constraint(equalToConstant: 1),
            line2.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            line2.trailingAnchor.constraint(equalTo: orDivider.trailingAnchor),
            line2.centerYAnchor.constraint(equalTo: orDivider.centerYAnchor),
            line2.heightAnchor.constraint(equalToConstant: 1)
        ])
        stack.addArrangedSubview(orDivider)

        let socialRow = UIStackView(arrangedSubviews: [googleButton, appleButton])
        socialRow.axis = .horizontal
        socialRow.spacing = 12
        socialRow.distribution = .fillEqually
        socialRow.translatesAutoresizingMaskIntoConstraints = false
        styleOutlineSocialButton(googleButton, title: "Google", icon: drawGoogleLogo(size: 20))
        styleOutlineSocialButton(appleButton, title: "Apple", icon: UIImage(systemName: "apple.logo")?.withRenderingMode(.alwaysTemplate))
        stack.addArrangedSubview(socialRow)
        stack.setCustomSpacing(22, after: socialRow)

        signUpButton.setTitle("Don't have an account? Sign up", for: .normal)
        signUpButton.setTitleColor(primaryBlue, for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        signUpButton.contentHorizontalAlignment = .center
        signUpButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        stack.addArrangedSubview(signUpButton)
    }

    // MARK: - Actions

    @objc private func signupTapped() { onSignupTapped?() }

    @objc private func loginTapped() {
        let email = (emailField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.textField.text ?? ""
        onLogin?(email, password)
    }

    @objc private func togglePassword() {
        isPasswordVisible.toggle()
        passwordField.textField.isSecureTextEntry = !isPasswordVisible
        let name = isPasswordVisible ? "eye.slash" : "eye"
        passwordEyeButton.setImage(UIImage(systemName: name), for: .normal)

        // fix caret jump
        let text = passwordField.textField.text
        passwordField.textField.text = nil
        passwordField.textField.text = text
        if let end = passwordField.textField.endOfDocument as UITextPosition? {
            passwordField.textField.selectedTextRange = passwordField.textField.textRange(from: end, to: end)
        }
    }

    func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loginButton.alpha = loading ? 0.6 : 1
    }

    func showError(_ message: String?) {
        statusLabel.text = message
        statusLabel.isHidden = (message == nil || message?.isEmpty == true)
    }

    private func configureEyeButton(_ button: UIButton) {
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .tertiaryLabel
        button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
    }

    private func styleOutlineSocialButton(_ b: UIButton, title: String, icon: UIImage?) {
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("  \(title)", for: .normal)
        b.setTitleColor(UITheme.Colors.textPrimary, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.layer.cornerRadius = 14
        b.layer.borderWidth = 0.5
        b.layer.borderColor = UITheme.Colors.border.cgColor
        b.backgroundColor = UITheme.Colors.surface
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        b.setImage(icon, for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        if icon?.isSymbolImage == true {
            b.tintColor = UITheme.Colors.textSecondary
        } else {
            b.tintColor = nil
        }
    }

    private func drawGoogleLogo(size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size * 0.45
            let thickness = size * 0.18
            let offset: CGFloat = 0.05
            let clipPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            clipPath.addClip()
            let redPath = UIBezierPath(arcCenter: center, radius: radius - thickness/2, startAngle: -.pi * 0.8 + offset, endAngle: -.pi * 0.1 - offset, clockwise: true)
            redPath.lineWidth = thickness
            redPath.lineCapStyle = .butt
            UIColor(hex: "#EA4335").setStroke()
            redPath.stroke()
            let yellowPath = UIBezierPath(arcCenter: center, radius: radius - thickness/2, startAngle: .pi * 0.9 + offset, endAngle: .pi * 1.2 - offset, clockwise: true)
            yellowPath.lineWidth = thickness
            yellowPath.lineCapStyle = .butt
            UIColor(hex: "#FBBC05").setStroke()
            yellowPath.stroke()
            let greenPath = UIBezierPath(arcCenter: center, radius: radius - thickness/2, startAngle: .pi * 0.35 + offset, endAngle: .pi * 0.9 - offset, clockwise: true)
            greenPath.lineWidth = thickness
            greenPath.lineCapStyle = .butt
            UIColor(hex: "#34A853").setStroke()
            greenPath.stroke()
            let bluePath = UIBezierPath(arcCenter: center, radius: radius - thickness/2, startAngle: -.pi * 0.1 + offset, endAngle: .pi * 0.35 - offset, clockwise: true)
            bluePath.lineWidth = thickness
            bluePath.lineCapStyle = .butt
            UIColor(hex: "#4285F4").setStroke()
            bluePath.stroke()
            let blue = UIColor(hex: "#4285F4")
            blue.setFill()
            let barRect = CGRect(x: center.x - 1, y: center.y - (thickness * 0.85)/2, width: radius + 1, height: thickness * 0.85)
            UIBezierPath(rect: barRect).fill()
        }
    }
}

// MARK: - Shared field
final class PhysioIconTextField: UIView {

    private let primaryBlue = UIColor(hex: "1E6EF7")

    var placeholder: String = "" { 
        didSet { 
            updatePlaceholder()
        } 
    }

    let textField = UITextField()

    private let container = UIView()
    private let icon = UIImageView()
    private let trailingAccessoryContainer = UIView()
    private var trailingAccessoryWidthConstraint: NSLayoutConstraint!

    init(iconSystemName: String) {
        super.init(frame: .zero)
        icon.image = UIImage(systemName: iconSystemName)
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UITheme.Colors.surface
        container.layer.cornerRadius = 18
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UITheme.Colors.border.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.03
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 4)

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .tertiaryLabel
        icon.contentMode = .scaleAspectFit

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 15, weight: .medium)
        textField.textColor = .label
        textField.tintColor = primaryBlue
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        updatePlaceholder()

        trailingAccessoryContainer.translatesAutoresizingMaskIntoConstraints = false
        trailingAccessoryContainer.isUserInteractionEnabled = true

        addSubview(container)
        container.addSubview(icon)
        container.addSubview(textField)
        container.addSubview(trailingAccessoryContainer)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 56),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            textField.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: trailingAccessoryContainer.leadingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            trailingAccessoryContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            trailingAccessoryContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            trailingAccessoryContainer.heightAnchor.constraint(equalToConstant: 34)
        ])

        trailingAccessoryWidthConstraint = trailingAccessoryContainer.widthAnchor.constraint(equalToConstant: 0)
        trailingAccessoryWidthConstraint.isActive = true
    }

    private func updatePlaceholder() {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.placeholderText,
            .font: textField.font ?? UIFont.systemFont(ofSize: 15, weight: .medium)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }

    func setTrailingAccessory(_ view: UIView?) {
        trailingAccessoryContainer.subviews.forEach { $0.removeFromSuperview() }
        guard let view else {
            trailingAccessoryWidthConstraint.constant = 0
            return
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        trailingAccessoryContainer.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: trailingAccessoryContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: trailingAccessoryContainer.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: trailingAccessoryContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAccessoryContainer.trailingAnchor)
        ])

        trailingAccessoryWidthConstraint.constant = max(34, view.intrinsicContentSize.width)
    }
}
