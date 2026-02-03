//
//  EditProfileViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class EditProfileViewController: UIViewController {

    private let editView = EditProfileView()
    private let model = ProfileModel()
    private let profile: ProfileViewData
    private var isSaving = false

    var onSave: (() -> Void)?

    init(profile: ProfileViewData) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() { view = editView }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        editView.apply(profile)

        editView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        editView.onSave = { [weak self] in
            self?.saveProfile()
        }
    }

    private func saveProfile() {
        if isSaving { return }
        isSaving = true
        editView.setSaving(true)
        let input = editView.currentInput()
        Task {
            do {
                try await model.updateProfile(input)
                await MainActor.run {
                    self.isSaving = false
                    self.editView.setSaving(false)
                    self.onSave?()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    self.editView.setSaving(false)
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
