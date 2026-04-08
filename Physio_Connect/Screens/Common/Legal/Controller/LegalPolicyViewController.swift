//
//  LegalPolicyViewController.swift
//  Physio_Connect
//

import UIKit

final class LegalPolicyViewController: UIViewController {

    enum PolicyType {
        case privacy
        case terms

        var title: String {
            switch self {
            case .privacy: return "Privacy Policy"
            case .terms: return "Terms of Service"
            }
        }

        var content: String {
            switch self {
            case .privacy:
                return """
                Privacy Policy
                
                Last updated: April 2026

                1. Introduction
                Welcome to Physio Connect. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

                2. Information We Collect
                We may collect personal information that you provide to us, such as your name, email address, phone number, and professional credentials.

                3. How We Use Your Information
                We use the information we collect to provide, maintain, and improve our services, communicate with you, and personalize your experience.

                4. Sharing of Information
                We do not sell, trade, or rent your personal identification information to others. We may share generic aggregated demographic information not linked to any personal identification information with our business partners.

                5. Data Security
                We use administrative, technical, and physical security measures to help protect your personal information. However, no method of transmission over the Internet is 100% secure.

                6. Contact Us
                If you have questions or comments about this Privacy Policy, please contact us at support@physioconnect.com.
                """
            case .terms:
                return """
                Terms of Service
                
                Last updated: April 2026

                1. Acceptance of Terms
                By accessing and using Physio Connect, you accept and agree to be bound by the terms and provision of this agreement.

                2. Provision of Services
                Physio Connect provides a platform for physiotherapists and patients to connect. We are constantly innovating in order to provide the best possible experience for our users.

                3. User Responsibilities
                You are responsible for your use of the service and for any content you provide, including compliance with applicable laws, rules, and regulations.

                4. Professional Credentials
                Physiotherapists must provide accurate and verifiable professional credentials. False information may result in immediate account termination.

                5. Limitation of Liability
                In no event shall Physio Connect be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.

                6. Changes to Terms
                We reserve the right to modify these terms from time to time at our sole discretion. Therefore, you should review these pages periodically.
                """
            }
        }
    }

    private let type: PolicyType
    
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let doneButton = UIButton(type: .system)
    private let containerView = UIView()

    init(type: PolicyType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UITheme.Colors.background

        titleLabel.text = type.title
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        textView.text = type.content
        textView.font = .systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .secondaryLabel
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.showsVerticalScrollIndicator = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            doneButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func didTapDone() {
        dismiss(animated: true)
    }
}
