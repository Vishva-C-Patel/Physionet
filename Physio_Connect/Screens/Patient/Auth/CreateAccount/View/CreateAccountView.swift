//
//  CreateAccountView.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//


import UIKit

final class CreateAccountView: UIView {

    // MARK: - Theme (match project)
    private let bg = UITheme.Colors.background
    private let primaryBlue = UITheme.Colors.accent
    private let cardBg = UITheme.Colors.cardBackground

    // MARK: - Scroll
    let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    // MARK: - Appointment saved banner
    private let savedCard = UIView()
    private let savedIconCircle = UIView()
    private let savedIcon = UIImageView()
    private let savedTitle = UILabel()
    let savedLine1 = UILabel() // set by VC (date/time)
    private let savedLine2 = UILabel()

    // MARK: - Benefits
    private let benefitsGrid = UIStackView()
    private let benefit1 = BenefitTileView()
    private let benefit2 = BenefitTileView()
    private let benefit3 = BenefitTileView()

    // MARK: - Form
    private let sectionTitle = UILabel()

    let fullNameField = IconTextField(iconSystemName: "person")
    let emailField = IconTextField(iconSystemName: "envelope")
    let phoneField = IconTextField(iconSystemName: "phone")
    let passwordField = IconTextField(iconSystemName: "lock")
    let confirmPasswordField = IconTextField(iconSystemName: "lock")

    let passwordEyeButton = UIButton(type: .system)
    let confirmPasswordEyeButton = UIButton(type: .system)

    private let passwordHint = UILabel()

    // MARK: - Terms
    private let termsCard = UIView()
    let termsCheckButton = UIButton(type: .system)
    private let termsLabel = UILabel()

    // MARK: - CTA
    let createAccountButton = UIButton(type: .system)

    // MARK: - Divider
    private let orDivider = OrDividerView()

    // MARK: - Social
    let googleButton = UIButton(type: .system)
    let appleButton = UIButton(type: .system)

    // MARK: - Login
    let loginButton = UIButton(type: .system)

    // MARK: - Security notice
    private let securityCard = UIView()
    private let securityIcon = UIImageView()
    private let securityText = UILabel()

    // MARK: - State
    private(set) var isTermsChecked: Bool = false {
        didSet { updateTermsUI() }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = bg
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public
    func setTermsChecked(_ checked: Bool) {
        isTermsChecked = checked
    }

    // MARK: - UI
    private func build() {
        // Scroll
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

        // Main stack
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        ])

        // Header removed, using native navigation bar.
        
        // Appointment saved banner
        styleCard(savedCard)
        savedCard.backgroundColor = UITheme.Colors.cardBackground
        savedCard.layer.borderWidth = 1.2
        savedCard.layer.borderColor = primaryBlue.withAlphaComponent(0.18).cgColor

        savedIconCircle.translatesAutoresizingMaskIntoConstraints = false
        savedIconCircle.backgroundColor = primaryBlue
        savedIconCircle.layer.cornerRadius = 18

        savedIcon.translatesAutoresizingMaskIntoConstraints = false
        savedIcon.image = UIImage(systemName: "checkmark")
        savedIcon.tintColor = .white
        savedIcon.contentMode = .scaleAspectFit

        savedTitle.translatesAutoresizingMaskIntoConstraints = false
        savedTitle.text = "Appointment Saved!"
        savedTitle.font = .systemFont(ofSize: 14, weight: .bold)
        savedTitle.textColor = UITheme.Colors.accent

        savedLine1.translatesAutoresizingMaskIntoConstraints = false
        savedLine1.text = "--"
        savedLine1.font = .systemFont(ofSize: 13, weight: .semibold)
        savedLine1.textColor = .label

        savedLine2.translatesAutoresizingMaskIntoConstraints = false
        savedLine2.text = "Create an account to confirm your booking"
        savedLine2.font = .systemFont(ofSize: 13, weight: .medium)
        savedLine2.textColor = .secondaryLabel
        savedLine2.numberOfLines = 2

        let savedTextStack = UIStackView(arrangedSubviews: [savedTitle, savedLine1, savedLine2])
        savedTextStack.axis = .vertical
        savedTextStack.spacing = 4
        savedTextStack.translatesAutoresizingMaskIntoConstraints = false

        savedCard.addSubview(savedIconCircle)
        savedIconCircle.addSubview(savedIcon)
        savedCard.addSubview(savedTextStack)

        NSLayoutConstraint.activate([
            savedIconCircle.leadingAnchor.constraint(equalTo: savedCard.leadingAnchor, constant: 14),
            savedIconCircle.topAnchor.constraint(equalTo: savedCard.topAnchor, constant: 14),
            savedIconCircle.widthAnchor.constraint(equalToConstant: 36),
            savedIconCircle.heightAnchor.constraint(equalToConstant: 36),

            savedIcon.centerXAnchor.constraint(equalTo: savedIconCircle.centerXAnchor),
            savedIcon.centerYAnchor.constraint(equalTo: savedIconCircle.centerYAnchor),
            savedIcon.widthAnchor.constraint(equalToConstant: 18),
            savedIcon.heightAnchor.constraint(equalToConstant: 18),

            savedTextStack.leadingAnchor.constraint(equalTo: savedIconCircle.trailingAnchor, constant: 12),
            savedTextStack.trailingAnchor.constraint(equalTo: savedCard.trailingAnchor, constant: -14),
            savedTextStack.topAnchor.constraint(equalTo: savedCard.topAnchor, constant: 14),
            savedTextStack.bottomAnchor.constraint(equalTo: savedCard.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(savedCard)

        // Benefits (3 tiles)
        benefitsGrid.axis = .horizontal
        benefitsGrid.spacing = 10
        benefitsGrid.distribution = .fillEqually
        benefitsGrid.translatesAutoresizingMaskIntoConstraints = false

        benefit1.configure(title: "Easy\nBooking", iconName: "checkmark.circle.fill", tint: primaryBlue)
        benefit2.configure(title: "Secure &\nSafe", iconName: "shield.fill", tint: UIColor(hex: "4F46E5"))
        benefit3.configure(title: "Track\nHistory", iconName: "person.fill", tint: UIColor(hex: "7C3AED"))

        benefitsGrid.addArrangedSubview(benefit1)
        benefitsGrid.addArrangedSubview(benefit2)
        benefitsGrid.addArrangedSubview(benefit3)

        stack.addArrangedSubview(benefitsGrid)

        // Section title
        sectionTitle.text = "Sign up with email"
        sectionTitle.font = .systemFont(ofSize: 18, weight: .bold)
        sectionTitle.textColor = .label
        stack.addArrangedSubview(sectionTitle)

        // Fields
        fullNameField.placeholder = "Full Name"

        emailField.placeholder = "Email Address"
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none

        phoneField.placeholder = "Phone Number"
        phoneField.textField.keyboardType = .numberPad
        phoneField.textField.autocorrectionType = .no
        phoneField.textField.autocapitalizationType = .none
        // Start with country prefix visible
        if phoneField.textField.text == nil || phoneField.textField.text?.isEmpty == true {
            phoneField.textField.text = "+91 "
        }

        passwordField.placeholder = "Password"
        passwordField.textField.isSecureTextEntry = true
        passwordField.textField.autocapitalizationType = .none
        passwordField.textField.autocorrectionType = .no
        passwordField.textField.spellCheckingType = .no
        passwordField.textField.keyboardType = .asciiCapable
        passwordField.textField.textContentType = UITextContentType(rawValue: "")
        passwordField.textField.inputAssistantItem.leadingBarButtonGroups = []
        passwordField.textField.inputAssistantItem.trailingBarButtonGroups = []
        passwordField.textField.clearsOnBeginEditing = false

        confirmPasswordField.placeholder = "Confirm Password"
        confirmPasswordField.textField.isSecureTextEntry = true
        confirmPasswordField.textField.autocapitalizationType = .none
        confirmPasswordField.textField.autocorrectionType = .no
        confirmPasswordField.textField.spellCheckingType = .no
        confirmPasswordField.textField.keyboardType = .asciiCapable
        confirmPasswordField.textField.textContentType = UITextContentType(rawValue: "")
        confirmPasswordField.textField.inputAssistantItem.leadingBarButtonGroups = []
        confirmPasswordField.textField.inputAssistantItem.trailingBarButtonGroups = []
        confirmPasswordField.textField.clearsOnBeginEditing = false

        // Eye buttons inside password fields (right view)
        configureEyeButton(passwordEyeButton)
        configureEyeButton(confirmPasswordEyeButton)

        passwordField.textField.rightView = passwordEyeButton
        passwordField.textField.rightViewMode = .always

        confirmPasswordField.textField.rightView = confirmPasswordEyeButton
        confirmPasswordField.textField.rightViewMode = .always

        stack.addArrangedSubview(fullNameField)
        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(phoneField)
        stack.addArrangedSubview(passwordField)

        passwordHint.text = "Must be at least 8 characters"
        passwordHint.font = .systemFont(ofSize: 12, weight: .medium)
        passwordHint.textColor = .gray
        stack.addArrangedSubview(passwordHint)

        stack.addArrangedSubview(confirmPasswordField)

        // Terms card
        styleCard(termsCard)
        termsCard.backgroundColor = UIColor.tertiarySystemFill
        termsCard.layer.shadowOpacity = 0 // looks like light panel (as in SS)

        termsCheckButton.translatesAutoresizingMaskIntoConstraints = false
        termsCheckButton.tintColor = primaryBlue
        termsCheckButton.contentHorizontalAlignment = .left

        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.numberOfLines = 0
        termsLabel.font = .systemFont(ofSize: 13, weight: .medium)
        termsLabel.textColor = .secondaryLabel
        termsLabel.text = "I agree to the Terms of Service and Privacy Policy"

        termsCard.addSubview(termsCheckButton)
        termsCard.addSubview(termsLabel)

        NSLayoutConstraint.activate([
            termsCheckButton.leadingAnchor.constraint(equalTo: termsCard.leadingAnchor, constant: 14),
            termsCheckButton.topAnchor.constraint(equalTo: termsCard.topAnchor, constant: 14),
            termsCheckButton.widthAnchor.constraint(equalToConstant: 26),
            termsCheckButton.heightAnchor.constraint(equalToConstant: 26),

            termsLabel.leadingAnchor.constraint(equalTo: termsCheckButton.trailingAnchor, constant: 10),
            termsLabel.trailingAnchor.constraint(equalTo: termsCard.trailingAnchor, constant: -14),
            termsLabel.centerYAnchor.constraint(equalTo: termsCheckButton.centerYAnchor),

            termsCard.bottomAnchor.constraint(equalTo: termsCheckButton.bottomAnchor, constant: 14)
        ])

        updateTermsUI()
        stack.addArrangedSubview(termsCard)

        // CTA
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.setTitle("Create Account & Confirm Booking", for: .normal)
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        createAccountButton.backgroundColor = primaryBlue
        createAccountButton.layer.cornerRadius = UITheme.Metrics.buttonCornerRadius
        createAccountButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        createAccountButton.layer.shadowColor = UIColor.black.cgColor
        createAccountButton.layer.shadowOpacity = 0.12
        createAccountButton.layer.shadowRadius = 12
        createAccountButton.layer.shadowOffset = CGSize(width: 0, height: 8)

        stack.addArrangedSubview(createAccountButton)

        // Or divider
        stack.addArrangedSubview(orDivider)

        // Social buttons row
        let socialRow = UIStackView(arrangedSubviews: [googleButton, appleButton])
        socialRow.axis = .horizontal
        socialRow.spacing = 12
        socialRow.distribution = .fillEqually
        socialRow.translatesAutoresizingMaskIntoConstraints = false

        styleOutlineSocialButton(googleButton, title: "Google", iconSystemName: "g.circle")
        styleOutlineSocialButton(appleButton, title: "Apple", iconSystemName: "apple.logo")

        stack.addArrangedSubview(socialRow)

        // Login link
        loginButton.setTitle("Already have an account? Log in", for: .normal)
        loginButton.setTitleColor(primaryBlue, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        loginButton.contentHorizontalAlignment = .center
        stack.addArrangedSubview(loginButton)

        // Security notice
        styleCard(securityCard)
        securityCard.backgroundColor = primaryBlue.withAlphaComponent(0.08)
        securityCard.layer.borderWidth = 1
        securityCard.layer.borderColor = primaryBlue.withAlphaComponent(0.18).cgColor
        securityCard.layer.shadowOpacity = 0

        securityIcon.translatesAutoresizingMaskIntoConstraints = false
        securityIcon.image = UIImage(systemName: "shield.fill")
        securityIcon.tintColor = primaryBlue

        securityText.translatesAutoresizingMaskIntoConstraints = false
        securityText.numberOfLines = 0
        securityText.font = .systemFont(ofSize: 12, weight: .medium)
        securityText.textColor = .secondaryLabel
        securityText.text = "Your information is encrypted and secure. We never share your data with third parties."

        securityCard.addSubview(securityIcon)
        securityCard.addSubview(securityText)

        NSLayoutConstraint.activate([
            securityIcon.leadingAnchor.constraint(equalTo: securityCard.leadingAnchor, constant: 14),
            securityIcon.topAnchor.constraint(equalTo: securityCard.topAnchor, constant: 14),
            securityIcon.widthAnchor.constraint(equalToConstant: 18),
            securityIcon.heightAnchor.constraint(equalToConstant: 18),

            securityText.leadingAnchor.constraint(equalTo: securityIcon.trailingAnchor, constant: 10),
            securityText.trailingAnchor.constraint(equalTo: securityCard.trailingAnchor, constant: -14),
            securityText.topAnchor.constraint(equalTo: securityCard.topAnchor, constant: 12),
            securityText.bottomAnchor.constraint(equalTo: securityCard.bottomAnchor, constant: -12)
        ])

        stack.addArrangedSubview(securityCard)
    }

    // MARK: - Helpers
    private func configureEyeButton(_ b: UIButton) {
        b.tintColor = .tertiaryLabel
        b.setImage(UIImage(systemName: "eye"), for: .normal)
        b.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        b.contentMode = .center
        b.isUserInteractionEnabled = true
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }

    private func updateTermsUI() {
        let imageName = isTermsChecked ? "checkmark.square.fill" : "square"
        termsCheckButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func styleCard(_ v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = cardBg
        v.layer.cornerRadius = UITheme.Metrics.cardCornerRadius
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    private func styleOutlineSocialButton(_ b: UIButton, title: String, iconSystemName: String) {
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("  \(title)", for: .normal)
        b.setTitleColor(.label, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.layer.cornerRadius = UITheme.Metrics.chipCornerRadius
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.backgroundColor = .secondarySystemGroupedBackground
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        b.setImage(UIImage(systemName: iconSystemName), for: .normal)
        b.tintColor = .secondaryLabel
    }
}

// MARK: - Benefit tile
private final class BenefitTileView: UIView {

    private let iconCircle = UIView()
    private let icon = UIImageView()
    private let title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, iconName: String, tint: UIColor) {
        self.title.text = title
        icon.image = UIImage(systemName: iconName)
        icon.tintColor = tint
        iconCircle.backgroundColor = tint.withAlphaComponent(0.12)
    }

    private func build() {
        backgroundColor = UIColor.tertiarySystemFill
        layer.cornerRadius = UITheme.Metrics.chipCornerRadius

        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.layer.cornerRadius = 18

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 12, weight: .semibold)
        title.textColor = .secondaryLabel
        title.textAlignment = .center
        title.numberOfLines = 2

        addSubview(iconCircle)
        iconCircle.addSubview(icon)
        addSubview(title)

        NSLayoutConstraint.activate([
            iconCircle.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 36),
            iconCircle.heightAnchor.constraint(equalToConstant: 36),

            icon.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            title.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 8),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}

// MARK: - Divider view
private final class OrDividerView: UIView {
    private let line1 = UIView()
    private let line2 = UIView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 24).isActive = true

        line1.translatesAutoresizingMaskIntoConstraints = false
        line2.translatesAutoresizingMaskIntoConstraints = false
        line1.backgroundColor = UIColor.separator
        line2.backgroundColor = UIColor.separator

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "or continue with"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel

        addSubview(line1)
        addSubview(line2)
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),

            line1.leadingAnchor.constraint(equalTo: leadingAnchor),
            line1.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            line1.centerYAnchor.constraint(equalTo: centerYAnchor),
            line1.heightAnchor.constraint(equalToConstant: 1),

            line2.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            line2.trailingAnchor.constraint(equalTo: trailingAnchor),
            line2.centerYAnchor.constraint(equalTo: centerYAnchor),
            line2.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

// MARK: - IconTextField (title + rounded textfield with left icon)
final class IconTextField: UIView {

    private let primaryBlue = UITheme.Colors.accent

    var placeholder: String = "" { 
        didSet { 
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.placeholderText])
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
        container.backgroundColor = UIColor.tertiarySystemFill
        container.layer.cornerRadius = 18
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.separator.cgColor

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .tertiaryLabel
        icon.contentMode = .scaleAspectFit

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 15, weight: .medium)
        textField.textColor = .label
        textField.autocorrectionType = .no

        addSubview(container)
        container.addSubview(icon)
        container.addSubview(textField)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 54),
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
}

