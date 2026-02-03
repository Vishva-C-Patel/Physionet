//
//  PhysioReportsViewController.swift
//  Physio_Connect
//
//  Created by Codex on 21/01/26.
//

import UIKit

final class PhysioReportsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private let reportsView = PhysioReportsView()
    private let model = PhysioReportsModel()
    private let profileModel = PhysioProfileModel()
    private let profileButton = UIButton(type: .system)

    private var physioID: String?
    private var allPatients: [PhysioReportsView.PatientVM] = []
    private var filteredPatients: [PhysioReportsView.PatientVM] = []
    private var isLoading = false

    override func loadView() {
        view = reportsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        PhysioNavBarStyle.apply(
            to: self,
            title: "Reports",
            profileButton: profileButton,
            profileAction: #selector(profileTapped)
        )
        loadProfileAvatar()

        reportsView.tableView.dataSource = self
        reportsView.tableView.delegate = self
        reportsView.searchBar.delegate = self
        reportsView.refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)

        Task { await loadReports() }
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

    @objc private func refreshPulled() {
        Task { await loadReports() }
    }

    private func loadReports() async {
        if isLoading { return }
        isLoading = true
        await MainActor.run { self.reportsView.refreshControl.beginRefreshing() }
        defer {
            Task { @MainActor in
                self.isLoading = false
                self.reportsView.refreshControl.endRefreshing()
            }
        }

        do {
            let id = try await resolvePhysioID()
            physioID = id
            let snapshot = try await model.fetchReport(physioID: id)

            let patientVMs = snapshot.patients.map { row -> PhysioReportsView.PatientVM in
                return PhysioReportsView.PatientVM(
                    id: row.id,
                    name: row.name,
                    age: row.ageText,
                    location: row.location,
                    programText: programText(from: row.programTitles),
                    adherencePercent: row.adherencePercent
                )
            }

            await MainActor.run {
                self.allPatients = patientVMs
                self.applyFilter()
                self.reportsView.showEmptyState(patientVMs.isEmpty)
            }
        } catch {
            await MainActor.run {
                self.presentError(message: error.localizedDescription)
            }
        }
    }

    private func resolvePhysioID() async throws -> String {
        if let physioID { return physioID }
        return try await model.resolvePhysioID()
    }

    private func presentError(message: String) {
        let ac = UIAlertController(title: "Reports Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }

    private func programText(from programs: [String]) -> String {
        guard let first = programs.first else { return "—" }
        if programs.count > 1 {
            return "\(first) +\(programs.count - 1)"
        }
        return first
    }

    // MARK: - Table data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPatients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportPatientCell.reuseID, for: indexPath) as? ReportPatientCell else {
            return UITableViewCell()
        }
        cell.apply(filteredPatients[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let patient = filteredPatients[indexPath.row]
        let vc = PhysioPatientReportViewController(patientID: patient.id)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        applyFilter()
    }

    private func applyFilter() {
        let query = reportsView.searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !query.isEmpty else {
            filteredPatients = allPatients
            reportsView.tableView.reloadData()
            return
        }

        filteredPatients = allPatients.filter { vm in
            let haystack = "\(vm.name) \(vm.programText) \(vm.location)".lowercased()
            return haystack.contains(query)
        }
        reportsView.tableView.reloadData()
    }
}
