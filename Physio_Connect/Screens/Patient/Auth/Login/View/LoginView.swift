//
//  LoginView.swift
//  Physio_Connect
//
//  Created by user@8 on 06/01/26.
//

import UIKit

final class LoginView: UIView {

    private let bg = UIColor(hex: "E3F0FF")
    private let primaryBlue = UIColor(hex: "1E6EF7")

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

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

        let headerRow = UIView()
        headerRow.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = primaryBlue
        backButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Welcome Back"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Log in to continue"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.textAlignment = .center

        headerRow.addSubview(backButton)
        headerRow.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerRow.heightAnchor.constraint(equalToConstant: 40),
            backButton.leadingAnchor.constraint(equalTo: headerRow.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerRow.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor)
        ])

        stack.addArrangedSubview(headerRow)
        stack.addArrangedSubview(subtitleLabel)

        emailField.titleText = "Email Address"
        emailField.placeholder = "your.email@example.com"
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none

        passwordField.titleText = "Password"
        passwordField.placeholder = "Enter your password"
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
        loginButton.layer.cornerRadius = 16
        loginButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        stack.addArrangedSubview(loginButton)

        signUpButton.setTitle("Don't have an account? Sign up", for: .normal)
        signUpButton.setTitleColor(primaryBlue, for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        signUpButton.contentHorizontalAlignment = .center
        stack.addArrangedSubview(signUpButton)
    }

    private func configureEyeButton(_ button: UIButton) {
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = UIColor.black.withAlphaComponent(0.45)
        button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
    }
}
