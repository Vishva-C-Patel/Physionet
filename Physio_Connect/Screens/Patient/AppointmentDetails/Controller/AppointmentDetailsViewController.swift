//
//  AppointmentDetailsViewController.swift
//  Physio_Connect
//

import UIKit

final class AppointmentDetailsViewController: UIViewController, UITextViewDelegate {

    // MARK: - Model
    private var appointment: Appointment

    // MARK: - View
    private let detailsView = AppointmentDetailsView()

    // MARK: - Init
    init(appointment: Appointment) {
        self.appointment = appointment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func loadView() {
        view = detailsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableTapToDismissKeyboard()
        UITheme.applyNativeNavBar(to: self, title: "Appointment Details")
        // Custom back — pops to root
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        view.backgroundColor = UITheme.Colors.background

        // ✅ Pass MODEL to VIEW
        detailsView.configure(with: makeDetailsModel(from: appointment))
        loadAvatarImage(path: appointment.profileImagePath, version: appointment.profileImageVersion)
        detailsView.updateNotesHeight()

        detailsView.notesTextView.delegate = self
        detailsView.callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        detailsView.messageButton.addTarget(self, action: #selector(messageTapped), for: .touchUpInside)
    }

    private func loadAvatarImage(path: String?, version: String?) {
        guard let path else {
            detailsView.setAvatarImage(nil)
            return
        }
        PhysioService.shared.loadProfileImage(pathOrUrl: path, version: version) { [weak self] image in
            self?.detailsView.setAvatarImage(image)
        }
    }

    // MARK: - Actions
    @objc private func callTapped() {
        guard let number = appointment.phoneNumber, !number.isEmpty else {
            showAlert("Phone not available", "Add phone number later from DB.")
            return
        }
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }

    @objc private func messageTapped() {
        guard let number = appointment.phoneNumber, !number.isEmpty else {
            showAlert("Number not available", "Add number later from DB.")
            return
        }
        if let url = URL(string: "sms:\(number)") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        appointment.sessionNotes = textView.text
        detailsView.updateNotesHeight()
        // Later you can sync this to Supabase
    }

    private func makeDetailsModel(from appointment: Appointment) -> AppointmentDetailsModel {
        let statusText: String
        switch appointment.status {
        case .upcoming:
            statusText = "Upcoming"
        case .completed:
            statusText = "Completed"
        case .cancelled:
            statusText = "Cancelled"
        case .cancelledByPhysio:
            statusText = "Cancelled by Physio"
        }

        return AppointmentDetailsModel(
            physioName: appointment.doctorName,
            ratingText: appointment.ratingText,
            specializationText: appointment.specialization,
            feeText: appointment.feeText,
            dateTimeText: "\(appointment.dateText) \(appointment.timeText)",
            locationText: appointment.locationText.isEmpty ? "TBD" : appointment.locationText,
            statusText: statusText,
            sessionNotes: appointment.sessionNotes,
            phoneNumber: appointment.phoneNumber
        )
    }

    // MARK: - Helpers
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
