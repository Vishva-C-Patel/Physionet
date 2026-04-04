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
        enableTapToDismissKeyboard()
        UITheme.applyNativeNavBar(to: self, title: "Edit Profile")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveProfile)
        )
        editView.apply(profile)
    }

    @objc private func saveProfile() {
        if isSaving { return }
        isSaving = true
        navigationItem.rightBarButtonItem?.isEnabled = false
        let input = editView.currentInput()
        Task {
            do {
                try await model.updateProfile(input)
                await MainActor.run {
                    self.isSaving = false
                    self.onSave?()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
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
