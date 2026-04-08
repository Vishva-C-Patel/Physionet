//
//  PhysioAuthViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
//

import UIKit
import PhotosUI

final class PhysioAuthViewController: UIViewController {

    private enum Mode {
        case login
        case signup
    }

    private let loginView = PhysioLoginView()
    private let signupView = PhysioSignupView()
    private let model = PhysioAuthModel()
    private var mode: Mode = .login
    private let preferredMode: Mode?
    private let onboardingKey = "physioconnect.physio_onboarded"
    private var activeProof: ProofType?

    private let backButton = UIButton(type: .system)
    private let backButtonBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

    private enum ProofType {
        case idProof
        case licenseProof
    }

    init(startOnSignup: Bool) {
        self.preferredMode = startOnSignup ? .signup : .login
        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.preferredMode = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UITheme.Colors.background
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableTapToDismissKeyboard()
        UITheme.applyNativeNavBar(to: self, title: "Physio Access")

        layoutViews()
        bind()
        Task {
            let hasSession = await RoleAccessGate.isSessionValid(for: .physiotherapist)
            await MainActor.run {
                if hasSession {
                    self.routeToHome()
                    return
                }
                if let preferred = self.preferredMode {
                    self.show(mode: preferred, animated: false)
                } else {
                    let hasOnboarded = UserDefaults.standard.bool(forKey: self.onboardingKey)
                    self.show(mode: hasOnboarded ? .login : .signup, animated: false)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Ensure buttons are re-enabled after any previous attempts
        loginView.setLoading(false)
        loginView.showError(nil)
    }

    private func layoutViews() {
        [loginView, signupView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        signupView.isHidden = true
    }

    private func bind() {
        // iOS 26 Floating Back Button Style
        backButtonBlur.isUserInteractionEnabled = false
        backButtonBlur.layer.cornerRadius = 18
        backButtonBlur.clipsToBounds = true
        backButtonBlur.layer.borderWidth = 0.5
        backButtonBlur.layer.borderColor = UITheme.Colors.glassBorder.cgColor

        let backConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = .label

        view.addSubview(backButtonBlur)
        view.addSubview(backButton)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButtonBlur.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            backButtonBlur.centerXAnchor.constraint(equalTo: backButton.centerXAnchor),
            backButtonBlur.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            backButtonBlur.widthAnchor.constraint(equalTo: backButton.widthAnchor),
            backButtonBlur.heightAnchor.constraint(equalTo: backButton.heightAnchor)
        ])

        backButton.addTarget(self, action: #selector(handleBackNavigation), for: .touchUpInside)

        loginView.onSignupTapped = { [weak self] in self?.show(mode: .signup, animated: true) }
        loginView.onLogin = { [weak self] email, password in
            self?.handleLogin(email: email, password: password)
        }

        signupView.onLoginLink = { [weak self] in self?.show(mode: .login, animated: true) }
        signupView.onCreateAccount = { [weak self] input in
            self?.handleSignup(input: input)
        }
        signupView.onPickIdProof = { [weak self] in self?.presentPicker(for: .idProof) }
        signupView.onPickLicenseProof = { [weak self] in self?.presentPicker(for: .licenseProof) }

        loginView.googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        signupView.googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
    }

    private func show(mode: Mode, animated: Bool) {
        self.mode = mode
        let showLogin = (mode == .login)
        self.title = showLogin ? "Log In" : "Create Account"
        let duration: TimeInterval = animated ? 0.2 : 0.0
        loginView.showError(nil)
        signupView.showError(nil)
        UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve, animations: {
            self.loginView.isHidden = !showLogin
            self.signupView.isHidden = showLogin
        })
    }

    private func handleLogin(email: String, password: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            loginView.setLoading(false)
            presentInlineAlert(title: "Missing Details", message: "Please enter your email and password.")
            return
        }
        loginView.showError(nil)
        loginView.setLoading(true)

        Task {
            do {
                _ = try await model.login(email: trimmedEmail, password: password)
                await MainActor.run {
                    self.loginView.setLoading(false)
                    UserDefaults.standard.set(true, forKey: self.onboardingKey)
                    self.routeToHome()
                }
            } catch {
                await MainActor.run {
                    self.loginView.setLoading(false)
                    self.presentInlineAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func handleSignup(input: PhysioSignupInput) {
        let email = input.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = input.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = input.phone.filter { $0.isNumber }
        let normalizedDigits: String
        if digits.count > 10, digits.hasPrefix("91") {
            normalizedDigits = String(digits.suffix(10))
        } else {
            normalizedDigits = digits
        }
        guard !name.isEmpty else {
            signupView.setLoading(false)
            showInlineError("Please enter your full name.")
            return
        }
        guard !email.isEmpty else {
            signupView.setLoading(false)
            showInlineError("Please enter your email.")
            return
        }
        guard normalizedDigits.count == 10 else {
            signupView.setLoading(false)
            showInlineError("Phone number must be 10 digits (India).")
            return
        }
        guard !input.password.isEmpty, input.password.count >= 8 else {
            signupView.setLoading(false)
            showInlineError("Password must be at least 8 characters.")
            return
        }
        guard input.password == input.confirmPassword else {
            signupView.setLoading(false)
            showInlineError("Passwords do not match.")
            return
        }
        guard input.acceptedTerms else {
            signupView.setLoading(false)
            showInlineError("Please accept the Terms to continue.")
            return
        }
        guard input.idProofData != nil else {
            signupView.setLoading(false)
            showInlineError("Please upload your ID proof.")
            return
        }
        guard input.licenseProofData != nil else {
            signupView.setLoading(false)
            showInlineError("Please upload your physio proof.")
            return
        }

        showInlineError(nil)
        signupView.setLoading(true)

        Task {
            do {
                let signupInput = PhysioAuthModel.PhysioSignupInput(
                    name: name,
                    email: email,
                    password: input.password,
                    idProofData: input.idProofData,
                    idProofFilename: input.idProofFilename,
                    licenseProofData: input.licenseProofData,
                    licenseProofFilename: input.licenseProofFilename
                )
                _ = try await model.signup(input: signupInput)
                await MainActor.run {
                    self.signupView.setLoading(false)
                    UserDefaults.standard.set(true, forKey: self.onboardingKey)
                    self.routeToHome()
                }
            } catch {
                await MainActor.run {
                    self.signupView.setLoading(false)
                    self.presentInlineAlert(title: "Signup Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func showInlineError(_ message: String?) {
        if mode == .login {
            loginView.showError(message)
        } else {
            signupView.showError(message)
        }
    }

    private func presentInlineAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func routeToHome() {
        let tab = PhysioTabBarController()
        if let nav = navigationController {
            nav.setViewControllers([tab], animated: true)
        } else {
            RootRouter.setRoot(tab, window: view.window)
        }
    }

    @objc private func googleTapped() {
        Task {
            do {
                try await GoogleOAuthHandler.shared.signIn(from: self)
                let isValid = await RoleAccessGate.isSessionValid(for: .physiotherapist)
                if isValid {
                    await MainActor.run {
                        UserDefaults.standard.set(true, forKey: self.onboardingKey)
                        self.routeToHome()
                    }
                } else {
                    try? await SupabaseManager.shared.client.auth.signOut()
                    await MainActor.run {
                        self.presentInlineAlert(title: "Unauthorized", message: "No physiotherapist account found. Please sign up using email and provide the required documents.")
                    }
                }
            } catch {
                await MainActor.run {
                    self.presentInlineAlert(title: "Google Sign-In Failed", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func handleBackNavigation() {
        AppLogout.backToRoleSelection(from: view, signOut: false)
    }

    private func popOrDismiss() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func presentPicker(for type: ProofType) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        activeProof = type
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension PhysioAuthViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider else { return }
        guard itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            guard let data = image.jpegData(compressionQuality: 0.85) else { return }
            let filename = (self.activeProof == .licenseProof) ? "physio_proof.jpg" : "id_proof.jpg"
            DispatchQueue.main.async {
                switch self.activeProof {
                case .idProof:
                    self.signupView.setIdProof(data: data, filename: filename)
                case .licenseProof:
                    self.signupView.setLicenseProof(data: data, filename: filename)
                case .none:
                    break
                }
            }
        }
    }
}
