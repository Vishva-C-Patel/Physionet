//
//  PhysioSignupView.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
//

import UIKit

struct PhysioSignupInput {
    let name: String
    let email: String
    let phone: String
    let password: String
    let confirmPassword: String
    let acceptedTerms: Bool
    let idProofData: Data?
    let idProofFilename: String?
    let licenseProofData: Data?
    let licenseProofFilename: String?
}

final class PhysioSignupView: UIView, UITextFieldDelegate {

    // MARK: - Callbacks
    var onBack: (() -> Void)?
    var onCreateAccount: ((PhysioSignupInput) -> Void)?
    var onLoginLink: (() -> Void)?
    var onPickIdProof: (() -> Void)?
    var onPickLicenseProof: (() -> Void)?

    private let primaryBlue = UITheme.Colors.accent

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    // MARK: - Form
    private let sectionTitle = UILabel()

    let fullNameField = PhysioIconTextField(iconSystemName: "person")
    let emailField = PhysioIconTextField(iconSystemName: "envelope")
    let phoneField = PhysioIconTextField(iconSystemName: "phone")
    let passwordField = PhysioIconTextField(iconSystemName: "lock")
    let confirmPasswordField = PhysioIconTextField(iconSystemName: "lock")

    let passwordEyeButton = UIButton(type: .system)
    let confirmPasswordEyeButton = UIButton(type: .system)

    private let passwordHint = UILabel()

    // MARK: - Proof uploads
    private let proofTitle = UILabel()
    private let idProofRow = ProofUploadRow(title: "ID Proof *", subtitle: "Upload government-issued ID")
    private let licenseProofRow = ProofUploadRow(title: "Physio Proof *", subtitle: "Upload license or registration")
    private var idProofData: Data?
    private var idProofFilename: String?
    private var licenseProofData: Data?
    private var licenseProofFilename: String?

    // MARK: - Terms
    private let termsCard = UIView()
    let termsCheckButton = UIButton(type: .system)
    private let termsLabel = UILabel()
    private let statusLabel = UILabel()

    // MARK: - CTA
    let createAccountButton = UIButton(type: .system)

    // MARK: - Divider
    private let orDivider = OrDividerView()

    // MARK: - Social
    let googleButton = UIButton(type: .custom)
    let appleButton = UIButton(type: .custom)

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

    private var isPasswordVisible = false
    private var isConfirmVisible = false
    private let phonePrefix = "+91 "
    private let maxPhoneDigits = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UITheme.Colors.background
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
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
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        // Section title
        sectionTitle.text = "Sign up with email"
        sectionTitle.font = .systemFont(ofSize: 18, weight: .bold)
        sectionTitle.textColor = UITheme.Colors.textPrimary
        sectionTitle.textAlignment = .center
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
        phoneField.textField.delegate = self
        if phoneField.textField.text == nil || phoneField.textField.text?.isEmpty == true {
            phoneField.textField.text = phonePrefix
        }

        passwordField.placeholder = "Password"
        passwordField.textField.isSecureTextEntry = true
        passwordField.textField.autocapitalizationType = .none
        passwordField.textField.autocorrectionType = .no
        passwordField.textField.spellCheckingType = .no
        passwordField.textField.keyboardType = .asciiCapable
        passwordField.textField.textContentType = UITextContentType(rawValue: "")
        passwordField.textField.clearsOnBeginEditing = false

        confirmPasswordField.placeholder = "Confirm Password"
        confirmPasswordField.textField.isSecureTextEntry = true
        confirmPasswordField.textField.autocapitalizationType = .none
        confirmPasswordField.textField.autocorrectionType = .no
        confirmPasswordField.textField.spellCheckingType = .no
        confirmPasswordField.textField.keyboardType = .asciiCapable
        confirmPasswordField.textField.textContentType = UITextContentType(rawValue: "")
        confirmPasswordField.textField.clearsOnBeginEditing = false

        configureEyeButton(passwordEyeButton, selector: #selector(togglePassword))
        configureEyeButton(confirmPasswordEyeButton, selector: #selector(toggleConfirmPassword))

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
        passwordHint.textColor = UITheme.Colors.textSecondary
        stack.addArrangedSubview(passwordHint)

        stack.addArrangedSubview(confirmPasswordField)

        proofTitle.text = "Verification documents"
        proofTitle.font = .systemFont(ofSize: 18, weight: .bold)
        proofTitle.textColor = UITheme.Colors.textPrimary
        stack.addArrangedSubview(proofTitle)

        idProofRow.onTap = { [weak self] in self?.onPickIdProof?() }
        licenseProofRow.onTap = { [weak self] in self?.onPickLicenseProof?() }
        stack.addArrangedSubview(idProofRow)
        stack.addArrangedSubview(licenseProofRow)

        // Terms card
        styleCard(termsCard)
        termsCard.backgroundColor = UITheme.Colors.surface
        termsCard.layer.shadowOpacity = 0

        termsCheckButton.translatesAutoresizingMaskIntoConstraints = false
        termsCheckButton.tintColor = primaryBlue
        termsCheckButton.contentHorizontalAlignment = .left
        termsCheckButton.addTarget(self, action: #selector(toggleTerms), for: .touchUpInside)

        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.numberOfLines = 0
        termsLabel.font = .systemFont(ofSize: 14)
        termsLabel.textColor = UITheme.Colors.textSecondary
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

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textColor = .systemRed
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true
        stack.addArrangedSubview(statusLabel)

        // CTA
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        createAccountButton.backgroundColor = primaryBlue
        createAccountButton.layer.cornerRadius = 28
        createAccountButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        createAccountButton.layer.shadowColor = UIColor.black.cgColor
        createAccountButton.layer.shadowOpacity = 0.12
        createAccountButton.layer.shadowRadius = 12
        createAccountButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        createAccountButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        stack.addArrangedSubview(createAccountButton)

        // Or divider
        stack.addArrangedSubview(orDivider)

        // Social buttons row
        let socialRow = UIStackView(arrangedSubviews: [googleButton, appleButton])
        socialRow.axis = .horizontal
        socialRow.spacing = 12
        socialRow.distribution = .fillEqually
        socialRow.translatesAutoresizingMaskIntoConstraints = false

        styleOutlineSocialButton(googleButton, title: "Google", icon: drawGoogleLogo(size: 20))
        styleOutlineSocialButton(appleButton, title: "Apple", icon: UIImage(systemName: "apple.logo")?.withRenderingMode(.alwaysTemplate))

        stack.addArrangedSubview(socialRow)

        // Login link
        loginButton.setTitle("Already have an account? Log in", for: .normal)
        loginButton.setTitleColor(primaryBlue, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        loginButton.contentHorizontalAlignment = .center
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
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
        securityText.textColor = UITheme.Colors.textSecondary
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
    private func configureEyeButton(_ b: UIButton, selector: Selector) {
        b.tintColor = UITheme.Colors.textSecondary
        b.setImage(UIImage(systemName: "eye"), for: .normal)
        b.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        b.contentMode = .center
        b.isUserInteractionEnabled = true
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        b.addTarget(self, action: selector, for: .touchUpInside)
    }

    @objc private func togglePassword() {
        isPasswordVisible.toggle()
        passwordField.textField.isSecureTextEntry = !isPasswordVisible
        let name = isPasswordVisible ? "eye.slash" : "eye"
        passwordEyeButton.setImage(UIImage(systemName: name), for: .normal)
        let text = passwordField.textField.text
        passwordField.textField.text = nil
        passwordField.textField.text = text
    }

    @objc private func toggleConfirmPassword() {
        isConfirmVisible.toggle()
        confirmPasswordField.textField.isSecureTextEntry = !isConfirmVisible
        let name = isConfirmVisible ? "eye.slash" : "eye"
        confirmPasswordEyeButton.setImage(UIImage(systemName: name), for: .normal)
        let text = confirmPasswordField.textField.text
        confirmPasswordField.textField.text = nil
        confirmPasswordField.textField.text = text
    }

    @objc private func toggleTerms() {
        isTermsChecked.toggle()
    }

    private func updateTermsUI() {
        let imageName = isTermsChecked ? "checkmark.square.fill" : "square"
        termsCheckButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func styleCard(_ v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UITheme.Colors.surface
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
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
            b.tintColor = nil // Keep original colors (gray for monochrome logos)
        }
    }

    // MARK: - Actions
    @objc private func loginTapped() { onLoginLink?() }

    @objc private func createTapped() {
        phoneField.textField.text = formatPhoneInput(phoneField.textField.text ?? "")
        let input = PhysioSignupInput(
            name: (fullNameField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            email: (emailField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            phone: (phoneField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            password: passwordField.textField.text ?? "",
            confirmPassword: confirmPasswordField.textField.text ?? "",
            acceptedTerms: isTermsChecked,
            idProofData: idProofData,
            idProofFilename: idProofFilename,
            licenseProofData: licenseProofData,
            licenseProofFilename: licenseProofFilename
        )
        onCreateAccount?(input)
    }

    func setLoading(_ loading: Bool) {
        createAccountButton.isEnabled = !loading
        createAccountButton.alpha = loading ? 0.6 : 1
    }

    func showError(_ message: String?) {
        statusLabel.text = message
        statusLabel.isHidden = (message == nil || message?.isEmpty == true)
    }

    func setIdProof(data: Data, filename: String) {
        idProofData = data
        idProofFilename = filename
        idProofRow.setSelected(filename: filename)
    }

    func setLicenseProof(data: Data, filename: String) {
        licenseProofData = data
        licenseProofFilename = filename
        licenseProofRow.setSelected(filename: filename)
    }

    // MARK: - Phone formatting
    private func formatPhoneInput(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawDigits = trimmed.filter { $0.isNumber }
        let hasCountryPrefix = trimmed.hasPrefix("+91")
        let digitsAfterPrefix: String
        if hasCountryPrefix, rawDigits.hasPrefix("91") {
            digitsAfterPrefix = String(rawDigits.dropFirst(2))
        } else {
            digitsAfterPrefix = rawDigits
        }
        let digits: String
        if digitsAfterPrefix.count > maxPhoneDigits {
            digits = String(digitsAfterPrefix.prefix(maxPhoneDigits))
        } else {
            digits = digitsAfterPrefix
        }

        guard !digits.isEmpty else { return phonePrefix }

        let first = digits.prefix(5)
        let second = digits.dropFirst(5)
        if second.isEmpty {
            return "\(phonePrefix)\(first)"
        }
        return "\(phonePrefix)\(first) \(second)"
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === phoneField.textField else { return true }
        let current = textField.text ?? phonePrefix
        guard let range = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: range, with: string)
        let formatted = formatPhoneInput(updated)
        textField.text = formatted
        let end = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: end, to: end)
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField === phoneField.textField else { return }
        if (textField.text ?? "").isEmpty {
            textField.text = phonePrefix
        }
    }

    private func drawGoogleLogo(size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size * 0.45
            let thickness = size * 0.18
            let offset: CGFloat = 0.05 // Increased gap to prevent zoom overlap

            // Clip to perfect circle to prevent middle bar corners from sticking out
            let clipPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            clipPath.addClip()

            // Top (Red)
            let redPath = UIBezierPath(arcCenter: center, radius: radius - thickness/2, startAngle: -.pi * 0.8 + offset, endAngle: -.pi * 0.1 - offset, clockwise: true)
            redPath.lineWidth = thickness
            redPath.lineCapStyle = .butt
            UIColor(hex: "#EA4335").setStroke()
            redPath.stroke()
            
            // Left (Yellow)
            let yellowPath = UIBezierPath(arcCenter: center, radius: radius - thickness/2, startAngle: .pi * 0.9 + offset, endAngle: .pi * 1.2 - offset, clockwise: true)
            yellowPath.lineWidth = thickness
            yellowPath.lineCapStyle = .butt
            UIColor(hex: "#FBBC05").setStroke()
            yellowPath.stroke()
            
            // Bottom (Green)
            let greenPath = UIBezierPath(arcCenter: center, radius: radius - thickness/2, startAngle: .pi * 0.35 + offset, endAngle: .pi * 0.9 - offset, clockwise: true)
            greenPath.lineWidth = thickness
            greenPath.lineCapStyle = .butt
            UIColor(hex: "#34A853").setStroke()
            greenPath.stroke()
            
            // Right (Blue)
            let bluePath = UIBezierPath(arcCenter: center, radius: radius - thickness/2, startAngle: -.pi * 0.1 + offset, endAngle: .pi * 0.35 - offset, clockwise: true)
            bluePath.lineWidth = thickness
            bluePath.lineCapStyle = .butt
            UIColor(hex: "#4285F4").setStroke()
            bluePath.stroke()
            
            // Middle Bar (Blue)
            let blue = UIColor(hex: "#4285F4")
            blue.setFill()
            // Make bar slightly thinner to fit visually within stroke boundaries without bleeding
            let barRect = CGRect(x: center.x - 1, y: center.y - (thickness * 0.85)/2, width: radius + 1, height: thickness * 0.85)
            UIBezierPath(rect: barRect).fill()
        }
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
        line1.backgroundColor = UITheme.Colors.border
        line2.backgroundColor = UITheme.Colors.border

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "or continue with"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .placeholderText

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

private final class ProofUploadRow: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    var onTap: (() -> Void)?

    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    func setSelected(filename: String) {
        statusLabel.text = filename
        statusLabel.textColor = UITheme.Colors.textPrimary
        actionButton.setTitle("Change", for: .normal)
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 18
        backgroundColor = UITheme.Colors.surface
        layer.borderWidth = 1
        layer.borderColor = UITheme.Colors.border.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UITheme.Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = UITheme.Colors.textSecondary
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor = UITheme.Colors.textMuted
        statusLabel.text = "No file selected"
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        actionButton.setTitle("Upload", for: .normal)
        actionButton.setTitleColor(UITheme.Colors.accent, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        actionButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(statusLabel)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            statusLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    @objc private func tapped() { onTap?() }
}
