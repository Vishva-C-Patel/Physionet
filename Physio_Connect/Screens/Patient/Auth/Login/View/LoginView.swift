//
//  LoginView.swift
//  Physio_Connect
//
//  Created by user@8 on 06/01/26.
//

import UIKit

final class LoginView: UIView {

    private let bg = UITheme.Colors.background
    private let primaryBlue = UITheme.Colors.accent

    // MARK: - Social
    let googleButton = UIButton(type: .custom)
    let appleButton = UIButton(type: .custom)

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    let emailField = IconTextField(iconSystemName: "envelope")
    let passwordField = IconTextField(iconSystemName: "lock")
    let passwordEyeButton = UIButton(type: .system)

    let loginButton = UIButton(type: .system)
    let signUpButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = bg
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

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
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        // Native navigation bar is used for heading now.
        emailField.placeholder = "Email Address"
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none

        passwordField.placeholder = "Password"
        passwordField.textField.isSecureTextEntry = true
        passwordField.textField.autocapitalizationType = .none
        passwordField.textField.autocorrectionType = .no
        passwordField.textField.keyboardType = .asciiCapable
        passwordField.textField.textContentType = UITextContentType(rawValue: "")

        configureEyeButton(passwordEyeButton)
        passwordField.textField.rightView = passwordEyeButton
        passwordField.textField.rightViewMode = .always

        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(passwordField)

        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        loginButton.backgroundColor = primaryBlue
        loginButton.layer.cornerRadius = 27
        loginButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        stack.addArrangedSubview(loginButton)

        // Or divider
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

        signUpButton.setTitle("Don't have an account? Sign up", for: .normal)
        signUpButton.setTitleColor(primaryBlue, for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        signUpButton.contentHorizontalAlignment = .center
        stack.addArrangedSubview(signUpButton)
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
