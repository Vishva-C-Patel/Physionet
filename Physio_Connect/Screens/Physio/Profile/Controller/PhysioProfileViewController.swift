//
//  PhysioProfileViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
//

import UIKit
import PhotosUI

final class PhysioProfileViewController: UIViewController, PHPickerViewControllerDelegate {

    private let profileView = ProfileView()
    private let model = PhysioProfileModel()
    private let availabilityModel = PhysioAvailabilityModel()
    private var isLoading = false
    private var isUploadingAvatar = false
    private var isDeletingAccount = false
    private let deleteOverlay = UIView()
    private let deleteIndicator = UIActivityIndicatorView(style: .large)
    private let deleteLabel = UILabel()

    override func loadView() { view = profileView }

    override func viewDidLoad() {
        super.viewDidLoad()
        UITheme.applyNativeNavBar(to: self, title: "Profile")
        profileView.setProfessionalProfileFieldsVisible(true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )

        profileView.onSignOut = { [weak self] in self?.signOut() }
        profileView.onDeleteAccount = { [weak self] in self?.handleDeleteAccountTap() }
        profileView.onSwitchRole = { [weak self] in self?.confirmSwitchRole() }
        profileView.onRefresh = { [weak self] in Task { await self?.loadProfile() } }
        profileView.onAvatarTapped = { [weak self] in self?.presentAvatarPicker() }
        profileView.setAvailabilityVisible(true)
        profileView.onAvailabilitySave = { [weak self] day, ranges in
            guard !ranges.isEmpty else { return }
            self?.presentRepeatPicker(for: day, ranges: ranges)
        }
        profileView.onPrivacyTapped = { [weak self] in
            let vc = LegalPolicyViewController(type: .privacy)
            self?.present(vc, animated: true)
        }
        
        profileView.onTermsTapped = { [weak self] in
            let vc = LegalPolicyViewController(type: .terms)
            self?.present(vc, animated: true)
        }

        buildDeleteOverlay()
        profileView.setLoggedIn(true)
        loadInitial()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @objc private func editTapped() {
        showEdit()
    }

    private func loadInitial() {
        Task { await loadProfile() }
    }

    private func showEdit() {
        let vc = PhysioEditProfileViewController()
        vc.onProfileUpdated = { [weak self] in
            Task { await self?.loadProfile() }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func signOut() {
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signOut()
            } catch {
                // ignore
            }
            await MainActor.run {
                AppLogout.backToRoleSelection(from: self.view, signOut: false)
            }
        }
    }

    private func confirmSwitchRole() {
        let alert = UIAlertController(
            title: "Switch role?",
            message: "You’ll return to the role selection screen.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Switch", style: .destructive, handler: { _ in
            AppLogout.backToRoleSelection(from: self.view, signOut: false)
        }))
        present(alert, animated: true)
    }

    private func confirmDeleteAccount() {
        let alert = UIAlertController(
            title: "Delete Account?",
            message: "This permanently deletes your account and data. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteAccount()
        }))
        present(alert, animated: true)
    }

    private func handleDeleteAccountTap() {
        if isDeletingAccount { return }
        Task {
            do {
                let hasBooked = try await model.hasBookedAppointments()
                await MainActor.run {
                    if hasBooked {
                        let ac = UIAlertController(
                            title: "Cannot Delete Account",
                            message: "You have booked appointments. Please cancel or complete them first.",
                            preferredStyle: .alert
                        )
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    } else {
                        self.confirmDeleteAccount()
                    }
                }
            } catch {
                await MainActor.run {
                    let ac = UIAlertController(title: "Delete Account Failed", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }

    private func deleteAccount() {
        if isDeletingAccount { return }
        isDeletingAccount = true
        setDeleteLoading(true)
        Task {
            do {
                try await model.deleteAccount()
                ProfileModel.clearCachedAvatarURL()
                PhysioProfileModel.clearCachedAvatarURL()
                await MainActor.run {
                    self.setDeleteLoading(false)
                    self.isDeletingAccount = false
                    AppLogout.backToRoleSelection(from: self.view, signOut: false)
                }
            } catch {
                await MainActor.run {
                    self.setDeleteLoading(false)
                    self.isDeletingAccount = false
                    let ac = UIAlertController(title: "Delete Account Failed", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }

    private func buildDeleteOverlay() {
        deleteOverlay.translatesAutoresizingMaskIntoConstraints = false
        deleteOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.26)
        deleteOverlay.isHidden = true

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 18
        blur.layer.masksToBounds = true

        deleteIndicator.translatesAutoresizingMaskIntoConstraints = false
        deleteIndicator.color = .white
        deleteIndicator.hidesWhenStopped = true

        deleteLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteLabel.text = "Deleting account..."
        deleteLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        deleteLabel.textColor = .white
        deleteLabel.textAlignment = .center

        view.addSubview(deleteOverlay)
        deleteOverlay.addSubview(blur)
        blur.contentView.addSubview(deleteIndicator)
        blur.contentView.addSubview(deleteLabel)

        NSLayoutConstraint.activate([
            deleteOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            deleteOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            deleteOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            deleteOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blur.centerXAnchor.constraint(equalTo: deleteOverlay.centerXAnchor),
            blur.centerYAnchor.constraint(equalTo: deleteOverlay.centerYAnchor),
            blur.widthAnchor.constraint(equalToConstant: 220),
            blur.heightAnchor.constraint(equalToConstant: 140),

            deleteIndicator.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
            deleteIndicator.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 26),

            deleteLabel.topAnchor.constraint(equalTo: deleteIndicator.bottomAnchor, constant: 14),
            deleteLabel.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 12),
            deleteLabel.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -12)
        ])
    }

    private func setDeleteLoading(_ loading: Bool) {
        deleteOverlay.isHidden = !loading
        navigationItem.rightBarButtonItem?.isEnabled = !loading
        if loading {
            view.bringSubviewToFront(deleteOverlay)
            deleteIndicator.startAnimating()
        } else {
            deleteIndicator.stopAnimating()
        }
    }

    private func setLoading(_ loading: Bool) {
        isLoading = loading
        profileView.setRefreshing(loading)
    }

    private func loadProfile() async {
        if isLoading { return }
        setLoading(true)
        defer { Task { @MainActor in self.setLoading(false) } }
        do {
            let data = try await model.fetchProfile()
            await MainActor.run {
                self.profileView.apply(data)
            }
        } catch {
            await MainActor.run {
                self.profileView.applyLoggedOut()
            }
        }
    }

    private func presentRepeatPicker(for day: Date, ranges: [TimeSlotRange]) {
        let weekday = Calendar.current.component(.weekday, from: day) - 1
        let controller = RepeatSelectionViewController(
            selectedDate: day,
            initialWeekdays: [weekday]
        )
        controller.onSave = { [weak self] repeatWeekdays, isSingleDate in
            self?.saveAvailability(day: day, ranges: ranges, repeatWeekdays: repeatWeekdays, isSingleDate: isSingleDate)
        }
        controller.onCancel = { [weak self] in
            self?.profileView.setAvailabilitySaving(false)
        }
        present(controller, animated: true)
    }

    private func saveAvailability(day: Date, ranges: [TimeSlotRange], repeatWeekdays: [Int], isSingleDate: Bool) {
        profileView.setAvailabilitySaving(true)
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let physioID = session.user.id
                let result = try await availabilityModel.saveMultiSlotAvailability(
                    physioID: physioID,
                    day: day,
                    ranges: ranges,
                    repeatWeekdays: isSingleDate ? [] : repeatWeekdays
                )
                await MainActor.run {
                    self.profileView.setAvailabilitySaving(false)
                    let ac = UIAlertController(
                        title: "Availability Saved",
                        message: "Added \(result.createdSlots) hourly slots.",
                        preferredStyle: .alert
                    )
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.profileView.setAvailabilitySaving(false)
                    let ac = UIAlertController(
                        title: "Save Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
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
            await loadProfile()
        } catch {
            await MainActor.run {
                let ac = UIAlertController(title: "Upload Failed", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
    }
}
