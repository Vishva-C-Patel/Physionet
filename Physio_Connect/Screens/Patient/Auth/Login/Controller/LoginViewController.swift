//
//  LoginViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 06/01/26.
//

import UIKit

final class LoginViewController: UIViewController {

    var onLoginSuccess: (() -> Void)?
    var onSignupTapped: (() -> Void)?

    private let loginView = LoginView()
    private let model = LoginModel()
    private var isPasswordVisible = false

    override func loadView() { view = loginView }

    override func viewDidLoad() {
        super.viewDidLoad()
        UITheme.applyNativeNavBar(to: self, title: "Log In")
        // Custom back action — goes to role selection, not pop
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        bind()
        enableTapToDismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetLoginButtonState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Double-safety to keep button active after role switches/navigation
        resetLoginButtonState()
    }

    private func bind() {
        loginView.passwordEyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        loginView.loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginView.signUpButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        loginView.googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
    }

    @objc private func backTapped() {
        AppLogout.backToRoleSelection(from: view)
    }

    @objc private func togglePassword() {
        isPasswordVisible.toggle()
        loginView.passwordField.textField.isSecureTextEntry = !isPasswordVisible
        let name = isPasswordVisible ? "eye.slash" : "eye"
        loginView.passwordEyeButton.setImage(UIImage(systemName: name), for: .normal)

        let text = loginView.passwordField.textField.text
        loginView.passwordField.textField.text = nil
        loginView.passwordField.textField.text = text
    }

    @objc private func loginTapped() {
        let email = (loginView.emailField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = loginView.passwordField.textField.text ?? ""

        if email.isEmpty || password.isEmpty {
            showAlert(title: "Missing Details", message: "Please enter your email and password.")
            resetLoginButtonState()
            return
        }

        // Timeout safety: never leave the button disabled if network hangs
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 12 * 1_000_000_000) // 12s
            await MainActor.run { self?.resetLoginButtonState() }
        }

        Task {
            do {
                await MainActor.run {
                    self.loginView.loginButton.isEnabled = false
                    self.loginView.loginButton.alpha = 0.8
                }
                try await model.signIn(email: email, password: password)
                await MainActor.run {
                    self.onLoginSuccess?()
                    if self.onLoginSuccess == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Login failed", message: error.localizedDescription)
                    self.resetLoginButtonState()
                }
            }
        }
    }

    @objc private func signupTapped() {
        if let onSignupTapped {
            onSignupTapped()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func googleTapped() {
        Task {
            do {
                try await GoogleOAuthHandler.shared.signIn(from: self)
                let session = try await SupabaseManager.shared.client.auth.session
                let userId = session.user.id.uuidString
                let email = session.user.email ?? ""
                let fullName = session.user.userMetadata["full_name"]?.stringValue ?? "Google User"

                let isValidPatient = await RoleAccessGate.isSessionValid(for: .patient)
                if isValidPatient {
                    await MainActor.run {
                        self.onLoginSuccess?()
                        if self.onLoginSuccess == nil {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    return
                }

                // If not valid, check if they are a physio
                struct PhysioRow: Decodable { let id: UUID }
                
                let physioRows: [PhysioRow] = (try? await SupabaseManager.shared.client.from("physiotherapists").select("id").eq("id", value: userId).limit(1).execute().value) ?? []
                let isPhysio = !physioRows.isEmpty

                if isPhysio {
                    try? await SupabaseManager.shared.client.auth.signOut()
                    await MainActor.run {
                        self.showAlert(title: "Unauthorized", message: "This account is registered for physiotherapists. Please log in on the physio side.")
                        self.resetLoginButtonState()
                    }
                    return
                }

                // Treat as new customer
                struct CustomerInsert: Encodable {
                    let id: UUID
                    let full_name: String
                    let email: String
                    let phone: String
                }
                let payload = CustomerInsert(id: session.user.id, full_name: fullName, email: email, phone: "")
                _ = try await SupabaseManager.shared.client.from("customers").upsert(payload).execute()

                await MainActor.run {
                    self.onLoginSuccess?()
                    if self.onLoginSuccess == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Google Sign-In Failed", message: error.localizedDescription)
                    self.resetLoginButtonState()
                }
            }
        }
    }

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

    @MainActor
    private func resetLoginButtonState() {
        loginView.loginButton.isEnabled = true
        loginView.loginButton.alpha = 1.0
    }
}
