//
//  AppointmentsViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//

import UIKit

final class AppointmentsViewController: UIViewController {

    private let apptView = AppointmentsView()
    private let model = AppointmentsModel()
    private let profileModel = ProfileModel()

    private var lastUpcoming: [UpcomingAppointment] = []
    private var lastPast: [PastAppointment] = []
    private var physioImages: [String: UIImage] = [:]
    private var isCancelling = false
    private var isRefreshing = false
    private var upcomingTimer: Timer?

    override func loadView() { view = apptView }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        bind()
        Task { await refreshAll() }
        Task { await refreshProfileAvatar() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await refreshAll() }
        Task { await refreshProfileAvatar() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        upcomingTimer?.invalidate()
        upcomingTimer = nil
    }

    private func bind() {
        apptView.onProfileTapped = { [weak self] in
            guard let self else { return }
            let vc = ProfileViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

        apptView.onCancelTapped = { [weak self] vm in
            guard let self else { return }
            guard !self.isCancelling else { return }
            self.isCancelling = true
            self.apptView.setCancelEnabled(false, appointmentID: vm.appointmentID)
            Task {
                do {
                    try await self.model.cancelAppointment(appointmentID: vm.appointmentID)
                    await self.refreshAll()
                } catch {
                    print("❌ Cancel failed:", error)
                    await MainActor.run {
                        self.isCancelling = false
                        self.apptView.setCancelEnabled(true, appointmentID: vm.appointmentID)
                    }
                }
                await MainActor.run {
                    self.isCancelling = false
                    self.apptView.setCancelEnabled(true, appointmentID: vm.appointmentID)
                }
            }
        }

        apptView.onRescheduleTapped = { [weak self] vm in
            guard let self else { return }
            let vc = PhysiotherapistProfileViewController(physioID: vm.physioID, preloadCard: nil, isReschedule: true)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

        apptView.onBookTapped = { [weak self] in
            guard let self else { return }
            let vc = PhysiotherapistListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }

        // ✅ Completed list actions (per-row)
        apptView.onCompletedRebookTapped = { [weak self] vm in
            guard let self else { return }
            let vc = PhysiotherapistProfileViewController(physioID: vm.physioID, preloadCard: nil)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

        apptView.onCompletedReportTapped = { vm in
            print("View report tapped for:", vm.physioName)
        }

        apptView.onCompletedReviewTapped = { [weak self] vm in
            self?.presentReviewPrompt(for: vm)
        }
    }

    private func refreshAll() async {
        if isRefreshing { return }
        isRefreshing = true
        defer {
            Task { @MainActor in
                self.isRefreshing = false
            }
        }
        do {
            async let upcoming = model.fetchUpcomingAppointments()
            async let past = model.fetchPastAppointments()

            let upcomingResult = try await upcoming
            let pastResult = try await past

            await MainActor.run {
                self.lastUpcoming = upcomingResult
                self.lastPast = pastResult
                self.applyUpcoming(upcomingResult)
                self.applyPast(pastResult)
            }
        } catch {
            print("❌ Appointments fetch error:", error)
            await MainActor.run {
                self.lastUpcoming = []
                self.apptView.setUpcoming([])
                self.apptView.setCompleted([])
            }
        }
    }

    private func refreshProfileAvatar() async {
        await MainActor.run {
            PatientNavAvatarStyle.updateProfileButton(
                self.apptView.profileButton,
                urlString: ProfileModel.cachedAvatarURL()
            )
        }
        guard let profile = try? await profileModel.fetchCurrentProfile() else { return }
        await MainActor.run {
            PatientNavAvatarStyle.updateProfileButton(self.apptView.profileButton, urlString: profile.avatarURL)
        }
    }

    // MARK: - Mapping to your View VMs

    private func applyUpcoming(_ appts: [UpcomingAppointment]) {
        upcomingTimer?.invalidate()
        upcomingTimer = nil

        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy - h:mm a"

        let vms: [AppointmentsView.UpcomingCardVM] = appts.compactMap { appt in
            guard appt.startTime > Date() else { return nil }
            if appt.physioName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return nil
            }

            let ratingText: String = {
                let r = appt.rating ?? 0
                let c = appt.reviewsCount ?? 0
                return "⭐️ \(String(format: "%.1f", r))   ·   \(c) reviews"
            }()

            let distanceText = appt.locationText != nil
            ? "📍 \(appt.locationText!)"
            : "📍 Nearby"

            let feeText: String = {
                if let fee = appt.fee {
                    return "₹\(Int(fee)) / hr"
                }
                return "₹ -- / hr"
            }()

            let cacheKey = physioImageKey(id: appt.physioID, version: appt.profileImageVersion)
            return AppointmentsView.UpcomingCardVM(
                appointmentID: appt.appointmentID,
                physioID: appt.physioID,
                dateTimeText: df.string(from: appt.startTime),
                physioName: appt.physioName,
                ratingText: ratingText,
                distanceText: distanceText,
                specializationText: appt.specialization,
                feeText: feeText,
                image: physioImages[cacheKey]
            )
        }

        apptView.setUpcoming(vms)

        for appt in appts {
            let cacheKey = physioImageKey(id: appt.physioID, version: appt.profileImageVersion)
            if physioImages[cacheKey] != nil { continue }
            guard let path = appt.profileImagePath,
                  let url = PhysioService.shared.profileImageURL(pathOrUrl: path, version: appt.profileImageVersion) else { continue }
            ImageLoader.shared.load(url) { [weak self] image in
                guard let self, let image else { return }
                self.physioImages[cacheKey] = image
                self.applyUpcoming(self.lastUpcoming)
            }
        }

        if let nextDate = appts.map(\.startTime).min() {
            let interval = nextDate.timeIntervalSinceNow
            if interval > 0 {
                upcomingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                    Task { await self?.refreshAll() }
                }
            }
        }
    }


    private func applyPast(_ past: [PastAppointment]) {
        let vms: [CompletedAppointmentVM] = past.map { item in
            let status: CompletedAppointmentVM.Status
            switch item.status.lowercased() {
            case "cancelled_by_physio":
                status = .cancelledByPhysio
            case "cancelled", "canceled":
                status = .cancelled
            default:
                status = .completed
            }

            let ratingText: String = {
                let r = item.rating ?? 0
                let c = item.reviewsCount ?? 0
                return "⭐️ \(String(format: "%.1f", r))   ·   \(c) reviews"
            }()

            let distanceText = item.locationText != nil
            ? "📍 \(item.locationText!)"
            : "📍 Nearby"

            let feeText: String = {
                if let fee = item.fee {
                    return "₹\(Int(fee)) / hr"
                }
                return "₹ -- / hr"
            }()

            let cacheKey = physioImageKey(id: item.physioID, version: item.profileImageVersion)
            return CompletedAppointmentVM(
                appointmentID: item.appointmentID,
                physioID: item.physioID,
                status: status,
                physioName: item.physioName,
                ratingText: ratingText,
                distanceText: distanceText,
                specializationText: item.specialization,
                feeText: feeText,
                image: physioImages[cacheKey]
            )
        }
        var unique: [UUID: CompletedAppointmentVM] = [:]
        for vm in vms {
            if unique[vm.appointmentID] == nil {
                unique[vm.appointmentID] = vm
            }
        }
        apptView.setCompleted(Array(unique.values))

        for item in past {
            let cacheKey = physioImageKey(id: item.physioID, version: item.profileImageVersion)
            if physioImages[cacheKey] != nil { continue }
            guard let path = item.profileImagePath,
                  let url = PhysioService.shared.profileImageURL(pathOrUrl: path, version: item.profileImageVersion) else { continue }
            ImageLoader.shared.load(url) { [weak self] image in
                guard let self, let image else { return }
                self.physioImages[cacheKey] = image
                self.applyPast(self.lastPast)
            }
        }
    }

    private func physioImageKey(id: UUID, version: String?) -> String {
        "\(id.uuidString)|\(version ?? "")"
    }

    private func presentReviewPrompt(for vm: CompletedAppointmentVM) {
        guard vm.status == .completed else { return }

        let alert = UIAlertController(
            title: "Rate \(vm.physioName)",
            message: "Add a rating (1-5) and an optional review.",
            preferredStyle: .alert
        )
        alert.addTextField { field in
            field.placeholder = "Rating (1-5)"
            field.keyboardType = .numberPad
        }
        alert.addTextField { field in
            field.placeholder = "Write your review (optional)"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            let ratingRaw = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let reviewText = alert.textFields?.dropFirst().first?.text

            guard let rating = Int(ratingRaw), (1...5).contains(rating) else {
                self.presentSimpleAlert(title: "Invalid Rating", message: "Please enter a number between 1 and 5.")
                return
            }
            self.saveReview(for: vm, rating: rating, reviewText: reviewText)
        }))

        present(alert, animated: true)
    }

    private func saveReview(for vm: CompletedAppointmentVM, rating: Int, reviewText: String?) {
        Task {
            do {
                try await model.submitReview(
                    appointmentID: vm.appointmentID,
                    physioID: vm.physioID,
                    rating: rating,
                    reviewText: reviewText
                )
                await refreshAll()
                await MainActor.run {
                    self.presentSimpleAlert(title: "Thanks!", message: "Your rating and review were saved.")
                }
            } catch {
                await MainActor.run {
                    self.presentSimpleAlert(title: "Review Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func presentSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
