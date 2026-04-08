//
//  ProfileViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit
import PhotosUI

final class ProfileViewController: UIViewController, PHPickerViewControllerDelegate {

    private let profileView = ProfileView()
    private let model = ProfileModel()
    private var isRefreshing = false
    private var isUploadingAvatar = false
    private var currentProfile: ProfileViewData?

    override func loadView() { view = profileView }

    override func viewDidLoad() {
        super.viewDidLoad()
        UITheme.applyNativeNavBar(to: self, title: "Profile")
        profileView.setProfessionalProfileFieldsVisible(false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        
        bind()
        profileView.preloadAvatar(urlString: ProfileModel.cachedAvatarURL())
        Task { await refreshProfile() }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await refreshProfile() }
    }

    private func bind() {
        profileView.onPrivacyTapped = { [weak self] in
            self?.showAlert(title: "Privacy Policy", message: "Add your privacy policy URL here.")
        }

        profileView.onTermsTapped = { [weak self] in
            self?.showAlert(title: "Terms of Service", message: "Add your terms of service URL here.")
        }

        profileView.onSignOut = { [weak self] in
            self?.signOut()
        }

        profileView.onLogin = { [weak self] in
            self?.showLogin()
        }

        profileView.onSignup = { [weak self] in
            self?.showSignup()
        }

        profileView.onNotificationsChanged = { [weak self] isOn in
            Task { await self?.model.updateNotifications(enabled: isOn) }
        }

        profileView.onRefresh = { [weak self] in
            Task { await self?.refreshProfile() }
        }

        profileView.onAvatarTapped = { [weak self] in
            self?.presentAvatarPicker()
        }
        
        profileView.onSwitchRole = { [weak self] in
            self?.switchRoleTapped()
        }

    }

    @objc private func appWillEnterForeground() {
        Task { await refreshProfile() }
    }
    
    
    @objc private func switchRoleTapped() {
        let alert = UIAlertController(
            title: "Switch role?",
            message: "You’ll return to the role selection screen.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Switch", style: .destructive, handler: { _ in
            AppLogout.backToRoleSelection(from: self.view)
        }))
        present(alert, animated: true)
    }


    private func refreshProfile() async {
        if isRefreshing { return }
        isRefreshing = true
        await MainActor.run { self.profileView.setRefreshing(true) }
        defer {
            Task { @MainActor in
                self.isRefreshing = false
                self.profileView.setRefreshing(false)
            }
        }

        let hasSession = await model.hasActiveSession()
        guard hasSession else {
            await MainActor.run {
                self.profileView.applyLoggedOut()
            }
            return
        }

        do {
            let data = try await model.fetchCurrentProfile()
            await MainActor.run {
                self.currentProfile = data
                self.profileView.apply(data)
                self.updateEditButtonVisibility(true)
            }
        } catch {
            await MainActor.run {
                self.showAlert(title: "Profile Error", message: error.localizedDescription)
                self.updateEditButtonVisibility(false)
            }
        }
    }

    private func updateEditButtonVisibility(_ isVisible: Bool) {
        navigationItem.rightBarButtonItem?.isHidden = !isVisible
    }

    private func signOut() {
        Task {
            do {
                try await model.signOut()
                ProfileModel.clearCachedAvatarURL()
                await MainActor.run {
                    self.profileView.applyLoggedOut()
                    self.updateEditButtonVisibility(false)
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Sign Out Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func showLogin() {
        let vc = LoginViewController()
        vc.onLoginSuccess = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            Task { await self?.refreshProfile() }
        }
        vc.onSignupTapped = { [weak self] in
            self?.showSignup()
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showSignup() {
        let model = CreateAccountModel(context: .standard)
        let vc = CreateAccountViewController(model: model)
        vc.onSignupComplete = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            Task { await self?.refreshProfile() }
        }
        vc.onLoginTapped = { [weak self] in
            self?.showLogin()
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func editTapped() {
        openEditProfile()
    }

    private func openEditProfile() {
        guard let currentProfile else {
            showAlert(title: "Edit Profile", message: "Profile data is still loading.")
            return
        }
        let vc = EditProfileViewController(profile: currentProfile)
        vc.onSave = { [weak self] in
            Task { await self?.refreshProfile() }
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func presentAvatarPicker() {
        guard !isUploadingAvatar else { return }
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { return }
        guard provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            guard let data = image.jpegData(compressionQuality: 0.85) else { return }
            Task { await self.uploadAvatar(image: image, data: data) }
        }
    }

    @MainActor
    private func setAvatarUploadState(_ uploading: Bool) {
        isUploadingAvatar = uploading
        profileView.setRefreshing(uploading)
    }

    private func uploadAvatar(image: UIImage, data: Data) async {
        await MainActor.run {
            self.profileView.setAvatarPreview(image)
            self.setAvatarUploadState(true)
        }
        defer { Task { @MainActor in self.setAvatarUploadState(false) } }

        do {
            try await model.uploadAvatarImage(data)
            await refreshProfile()
        } catch {
            await MainActor.run {
                self.showAlert(title: "Upload Failed", message: error.localizedDescription)
            }
        }
    }
}
