//
//  PhysioAuthView.swift
//  Physio_Connect
//
//  Created by Codex on 08/01/26.
//

import UIKit

final class PhysioAuthView: UIView {

    enum Mode {
        case login
        case signup
    }

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let headerLabel = UILabel()
    private let subtitleLabel = UILabel()
    let modeControl = UISegmentedControl(items: ["Log In", "Sign Up"])

    let nameField = UITextField()
    let emailField = UITextField()
    let passwordField = UITextField()
    let actionButton = UIButton(type: .system)
    let activity = UIActivityIndicatorView(style: .medium)
    let statusLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E3F0FF")
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 14
        scrollView.addSubview(contentStack)

        headerLabel.text = "Physio Login"
        headerLabel.font = .systemFont(ofSize: 28, weight: .bold)
        headerLabel.textColor = UIColor(hex: "102A43")

        subtitleLabel.text = "Access your dashboard to manage sessions."
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.55)
        subtitleLabel.numberOfLines = 0

        modeControl.selectedSegmentIndex = 0
        modeControl.selectedSegmentTintColor = UIColor(hex: "1E6EF7")
        modeControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
        modeControl.setTitleTextAttributes([.foregroundColor: UIColor.black.withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)

        [headerLabel, subtitleLabel, modeControl, nameField, emailField, passwordField, actionButton, activity, statusLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview($0)
        }

        configureField(nameField, placeholder: "Full name (for signup)")
        configureField(emailField, placeholder: "Email")
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        configureField(passwordField, placeholder: "Password")
        passwordField.isSecureTextEntry = true

        actionButton.setTitle("Log In", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        actionButton.backgroundColor = UIColor(hex: "1E6EF7")
        actionButton.layer.cornerRadius = 14
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        actionButton.layer.shadowColor = UIColor.black.cgColor
        actionButton.layer.shadowOpacity = 0.1
        actionButton.layer.shadowRadius = 8
        actionButton.layer.shadowOffset = CGSize(width: 0, height: 4)

        activity.hidesWhenStopped = true

        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textColor = UIColor.red.withAlphaComponent(0.8)
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            actionButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func configureField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.backgroundColor = .white
        field.layer.cornerRadius = 12
        field.layer.masksToBounds = true
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
        field.font = .systemFont(ofSize: 15, weight: .regular)
    }

    func setMode(_ mode: Mode) {
        switch mode {
        case .login:
            headerLabel.text = "Physio Login"
            subtitleLabel.text = "Access your dashboard to manage sessions."
            nameField.isHidden = true
            actionButton.setTitle("Log In", for: .normal)
        case .signup:
            headerLabel.text = "Physio Sign Up"
            subtitleLabel.text = "Create your account to start seeing patients."
            nameField.isHidden = false
            actionButton.setTitle("Sign Up", for: .normal)
        }
    }

    func setLoading(_ loading: Bool) {
        actionButton.isEnabled = !loading
        loading ? activity.startAnimating() : activity.stopAnimating()
    }

    func showError(_ message: String?) {
        statusLabel.text = message
        statusLabel.isHidden = (message == nil || message?.isEmpty == true)
    }
}
