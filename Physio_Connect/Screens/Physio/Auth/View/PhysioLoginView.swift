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
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
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
        passwordField.textField.textContentType = UITextContentType(rawValue: "")

        configureEyeButton(passwordEyeButton)
        passwordEyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        passwordField.textField.rightView = passwordEyeButton
        passwordField.textField.rightViewMode = .always

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
        stack.setCustomSpacing(22, after: loginButton)

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
        updatePlaceholder()

        addSubview(container)
        container.addSubview(icon)
        container.addSubview(textField)

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
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    private func updatePlaceholder() {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.placeholderText,
            .font: textField.font ?? UIFont.systemFont(ofSize: 15, weight: .medium)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
}
