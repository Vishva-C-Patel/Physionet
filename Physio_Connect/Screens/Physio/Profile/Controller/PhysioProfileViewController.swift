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
