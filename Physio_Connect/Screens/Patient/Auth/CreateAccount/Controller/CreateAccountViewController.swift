//
//  CreateAccountViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//

import UIKit
import Supabase

final class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Callbacks (MVC friendly)
    var onSignupComplete: (() -> Void)?
    var onLoginTapped: (() -> Void)?

    private let createView = CreateAccountView()
    private let model: CreateAccountModel

    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false

    // MARK: - Init
    init(model: CreateAccountModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Load View
    override func loadView() {
        view = createView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        bind()
        applyAppointmentBanner()
        addKeyboardDismissTap()
    }

    private func bind() {
        createView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        createView.termsCheckButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)

        createView.passwordEyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        createView.confirmPasswordEyeButton.addTarget(self, action: #selector(toggleConfirmPassword), for: .touchUpInside)

        createView.createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)

        createView.googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        createView.appleButton.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)

        createView.loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        // Phone field behavior: delegate handles formatting, limiting and keeps +91 prefix
        createView.phoneField.textField.delegate = self
        // Ensure prefix is present once (and only once)
        let prefix = "+91 "
        if (createView.phoneField.textField.text ?? "").isEmpty {
            createView.phoneField.textField.text = prefix
        } else if createView.phoneField.textField.text?.hasPrefix(prefix) == false {
            createView.phoneField.textField.text = prefix
        }
    }

    private func applyAppointmentBanner() {
        let appt = model.appointment
        createView.savedLine1.text = "\(appt.dateText) at \(appt.timeText)"
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func termsTapped() {
        createView.setTermsChecked(!createView.isTermsChecked)
    }

    @objc private func togglePassword() {
        isPasswordVisible.toggle()
        createView.passwordField.textField.isSecureTextEntry = !isPasswordVisible
        let name = isPasswordVisible ? "eye.slash" : "eye"
        createView.passwordEyeButton.setImage(UIImage(systemName: name), for: .normal)

        // keep cursor position stable
        let text = createView.passwordField.textField.text
        createView.passwordField.textField.text = nil
        createView.passwordField.textField.text = text
        // keep cursor at end
        if let end = createView.passwordField.textField.endOfDocument as UITextPosition? {
            createView.passwordField.textField.selectedTextRange = createView.passwordField.textField.textRange(from: end, to: end)
        }
    }

    @objc private func toggleConfirmPassword() {
        isConfirmPasswordVisible.toggle()
        createView.confirmPasswordField.textField.isSecureTextEntry = !isConfirmPasswordVisible
        let name = isConfirmPasswordVisible ? "eye.slash" : "eye"
        createView.confirmPasswordEyeButton.setImage(UIImage(systemName: name), for: .normal)

        let text = createView.confirmPasswordField.textField.text
        createView.confirmPasswordField.textField.text = nil
        createView.confirmPasswordField.textField.text = text
        // keep cursor at end
        if let end = createView.confirmPasswordField.textField.endOfDocument as UITextPosition? {
            createView.confirmPasswordField.textField.selectedTextRange = createView.confirmPasswordField.textField.textRange(from: end, to: end)
        }
    }

    @objc private func createAccountTapped() {
        // 0) Terms check
        guard createView.isTermsChecked else {
            showAlert(title: "Terms Required", message: "Please agree to the terms and conditions.")
            return
        }

        // 1) Read fields
        let fullName = (createView.fullNameField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (createView.emailField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let rawPhoneText = (createView.phoneField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = createView.passwordField.textField.text ?? ""
        let confirm = createView.confirmPasswordField.textField.text ?? ""

        // normalize phone digits (extract digits only)
        let digitsOnly = rawPhoneText.compactMap { $0.isWholeNumber ? $0 : nil }
        let digits = String(digitsOnly)

        // 2) Validation
        if fullName.isEmpty || email.isEmpty || digits.isEmpty || password.isEmpty || confirm.isEmpty {
            showAlert(title: "Missing Details", message: "Please fill in all required fields.")
            return
        }

        // require exactly 10 digits (excluding +91)
        if digits.count < 10 {
            showAlert(title: "Invalid Phone", message: "Please enter a 10-digit phone number (without country code).")
            return
        }

        // use last 10 digits in case user pasted country code or extra
        let last10 = String(digits.suffix(10))
        let normalizedPhone = "+91" + last10

        if password.count < 8 {
            showAlert(title: "Weak Password", message: "Password must be at least 8 characters.")
            return
        }

        if password != confirm {
            showAlert(title: "Password Mismatch", message: "Passwords do not match.")
            return
        }

        // 3) Supabase signup + save customer + SIGN IN (this is what fixes redirect)
        Task {
            do {
                await MainActor.run {
                    self.createView.createAccountButton.isEnabled = false
                }

                // A) Create user
                let data: [String: AnyJSON] = [
                    "full_name": .string(fullName),
                    "phone": .string(normalizedPhone)
                ]

                let authResponse = try await SupabaseManager.shared.client.auth.signUp(
                    email: email,
                    password: password,
                    data: data
                )
                // Ensure the user is signed in with the normalized phone
                _ = try await SupabaseManager.shared.client.auth.signIn(
                    email: email,
                    password: password
                )
                // B) Save customer row
                let userId = authResponse.user.id

                struct CustomerInsert: Encodable {
                    let id: UUID
                    let full_name: String
                    let email: String
                    let phone: String
                }

                let payload = CustomerInsert(
                    id: userId,
                    full_name: fullName,
                    email: email,
                    phone: normalizedPhone
                )

                _ = try await SupabaseManager.shared.client
                    .from("customers")
                    .upsert(payload)
                    .execute()

                let isValid = await RoleAccessGate.isSessionValid(for: .patient)
                if !isValid {
                    try? await SupabaseManager.shared.client.auth.signOut()
                    throw SignupError(message: "This account is registered for physiotherapists. Please sign up on the physio side.")
                }


                await MainActor.run {
                    self.onSignupComplete?() // Payment screen will NOT redirect anymore
                }

            } catch {
                await MainActor.run {
                    self.showAlert(title: "Signup failed", message: error.localizedDescription)
                    self.createView.createAccountButton.isEnabled = true
                }
            }
        }
    }

    @objc private func googleTapped() {
        showAlert(title: "Google Sign-In", message: "Hook Google Sign-In here.")
    }

    // MARK: - UITextFieldDelegate (phone formatting)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == createView.phoneField.textField else { return true }

        let prefix = "+91 "
        let currentText = textField.text ?? prefix

        // Always keep the +91 prefix permanently
        if !currentText.hasPrefix(prefix) {
            textField.text = prefix
        }

        // If user tries to edit within the prefix area, block it
        if range.location < prefix.count {
            // Allow only if they are deleting after the prefix (i.e., nothing to delete in prefix)
            return false
        }

        // Build candidate text after the user's change
        guard let textRange = Range(range, in: currentText) else { return false }
        var updated = currentText.replacingCharacters(in: textRange, with: string)

        // Extract ONLY the user-entered digits (exclude the fixed prefix)
        if updated.hasPrefix(prefix) {
            updated = String(updated.dropFirst(prefix.count))
        }

        var digits = updated.compactMap { $0.isWholeNumber ? $0 : nil }
        // Max 10 digits (excluding +91)
        if digits.count > 10 { digits = Array(digits.prefix(10)) }

        // Format as: +91 XXXXX XXXXX
        let d = String(digits)
        var formatted = prefix
        if d.count <= 5 {
            formatted += d
        } else {
            let first = String(d.prefix(5))
            let rest = String(d.dropFirst(5))
            formatted += first
            if !rest.isEmpty { formatted += " " + rest }
        }

        textField.text = formatted

        // Keep cursor at end to prevent jumping into the prefix
        if let end = textField.endOfDocument as UITextPosition? {
            textField.selectedTextRange = textField.textRange(from: end, to: end)
        }

        // Prevent system from applying its own change (we already set text)
        return false
    }

    @objc private func appleTapped() {
        showAlert(title: "Apple Sign-In", message: "Hook Sign in with Apple here.")
    }

    @objc private func loginTapped() {
        onLoginTapped?()
    }

    // MARK: - Helpers
    private func addKeyboardDismissTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingNow))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditingNow() {
        view.endEditing(true)
    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

private struct SignupError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
