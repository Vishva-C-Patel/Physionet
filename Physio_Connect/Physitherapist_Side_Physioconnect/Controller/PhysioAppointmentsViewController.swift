//
//  PhysioAppointmentsViewController.swift
//  Physio_Connect
//
//  Created by Codex on 11/01/26.
//

import UIKit

final class PhysioAppointmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    private let contentView = PhysioAppointmentsView()
    private let model = PhysioAppointmentsModel()
    private let profileModel = PhysioProfileModel()
    private let profileButton = UIButton(type: .system)
    private var allAppointments: [PhysioAppointmentsView.AppointmentVM] = []
    private var filteredAppointments: [PhysioAppointmentsView.AppointmentVM] = []
    private var physioID: String?
    private var isLoading = false

    override func loadView() { view = contentView }

    override func viewDidLoad() {
        super.viewDidLoad()
        PhysioNavBarStyle.apply(
            to: self,
            title: "Appointments",
            profileButton: profileButton,
            profileAction: #selector(profileTapped)
        )
        loadProfileAvatar()

        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.rowHeight = UITableView.automaticDimension
        contentView.tableView.estimatedRowHeight = 220
        contentView.searchBar.delegate = self
        contentView.segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        Task { await loadAppointments() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileAvatar()
    }

    private func loadProfileAvatar() {
        Task {
            do {
                let data = try await profileModel.fetchProfile()
                await MainActor.run {
                    PhysioNavBarStyle.updateProfileButton(self.profileButton, urlString: data.avatarURL)
                }
            } catch {
                let fallback = PhysioProfileModel.cachedAvatarURL()
                await MainActor.run {
                    PhysioNavBarStyle.updateProfileButton(self.profileButton, urlString: fallback)
                }
            }
        }
    }

    @objc private func profileTapped() {
        let vc = PhysioProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func segmentChanged() {
        applyFilters()
    }

    private func applyFilters() {
        let searchText = contentView.searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let selectedIndex = contentView.segmentControl.selectedSegmentIndex

        filteredAppointments = allAppointments.filter { vm in
            let matchesSegment: Bool
            switch selectedIndex {
            case 1:
                matchesSegment = vm.status == .upcoming
            case 2:
                matchesSegment = vm.status != .upcoming
            default:
                matchesSegment = true
            }

            if !matchesSegment { return false }
            if searchText.isEmpty { return true }
            let haystack = "\(vm.title) \(vm.patientName) \(vm.locationText)".lowercased()
            return haystack.contains(searchText)
        }

        contentView.tableView.reloadData()
    }

    private func loadAppointments() async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let id = session.user.id.uuidString
            physioID = id

            let rows = try await model.fetchAppointments(physioID: id)
            let vms = rows.compactMap { makeViewModel(from: $0) }
            await MainActor.run {
                self.allAppointments = vms
                self.applyFilters()
            }
        } catch {
            await MainActor.run {
                self.allAppointments = []
                self.applyFilters()
            }
        }
    }

    private func makeViewModel(from row: PhysioAppointment) -> PhysioAppointmentsView.AppointmentVM? {
        let status = row.status.lowercased()
        let statusVM: PhysioAppointmentsView.Status
        if status == "completed" {
            statusVM = .completed
        } else if status == "cancelled_by_physio" {
            statusVM = .cancelledByPhysio
        } else if status == "cancelled" {
            statusVM = .cancelled
        } else {
            statusVM = .upcoming
        }

        let start = row.slot?.startTime
        let end = row.slot?.endTime
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE • h:mm a"
        let timeText = start.map { formatter.string(from: $0) } ?? "Time TBD"

        let durationText: String = {
            guard let start, let end else { return "Duration TBD" }
            let minutes = max(1, Int(end.timeIntervalSince(start) / 60))
            return "\(minutes) mins"
        }()

        let patientName = row.customer?.fullName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let patient = patientName?.isEmpty == false ? patientName! : "Patient"

        let location = row.addressText?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? row.customer?.location
            ?? "Location TBD"

        let mode = row.serviceMode.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = "\(mode.capitalized) Session"

        return PhysioAppointmentsView.AppointmentVM(
            id: row.id,
            status: statusVM,
            title: title,
            patientName: patient,
            timeText: timeText,
            durationText: durationText,
            locationText: location,
            isActionable: statusVM == .upcoming
        )
    }

    private func updateStatus(id: UUID, status: String) {
        Task {
            do {
                try await model.updateStatus(appointmentID: id, status: status)
                await loadAppointments()
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(title: "Update Failed", message: "Try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredAppointments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhysioAppointmentCell", for: indexPath) as? PhysioAppointmentCell else {
            return UITableViewCell()
        }
        let vm = filteredAppointments[indexPath.row]
        cell.apply(vm)
        cell.onCancelTapped = { [weak self] in
            self?.updateStatus(id: vm.id, status: "cancelled_by_physio")
        }
        cell.onCompleteTapped = { [weak self] in
            self?.updateStatus(id: vm.id, status: "completed")
        }
        return cell
    }

    // MARK: - UISearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters()
    }
}
