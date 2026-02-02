//
//  PhysioProgramsViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import UIKit

final class PhysioProgramsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let programsView = PhysioProgramsView()
    private let model = PhysioProgramsModel()
    private let profileModel = PhysioProfileModel()
    private let profileButton = UIButton(type: .system)
    private var items: [ProgramListItem] = []
    private var isLoading = false

    override func loadView() {
        view = programsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        PhysioNavBarStyle.apply(
            to: self,
            title: "Programs",
            profileButton: profileButton,
            profileAction: #selector(profileTapped)
        )
        loadProfileAvatar()

        programsView.tableView.dataSource = self
        programsView.tableView.delegate = self
        programsView.tableView.register(ProgramCardCell.self, forCellReuseIdentifier: ProgramCardCell.reuseID)
        programsView.setRefreshTarget(self, action: #selector(refreshPulled))
        programsView.createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        Task { await reload() }
    }

    private func loadProfileAvatar() {
        Task {
            do {
                let data = try await profileModel.fetchProfile()
                await MainActor.run {
                    PhysioNavBarStyle.updateProfileButton(self.profileButton, urlString: data.avatarURL)
                }
            } catch {
                // ignore avatar load errors
            }
        }
    }

    @objc private func profileTapped() {
        let vc = PhysioProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func refreshPulled() {
        Task { await reload() }
    }

    @objc private func createTapped() {
        let vc = CreateProgramViewController()
        vc.onProgramCreated = { [weak self] _ in
            guard let self else { return }
            Task { await self.reload() }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func showCodeAlert(code: String) {
        let ac = UIAlertController(
            title: "Program Code Created",
            message: "Share this code with your patient to redeem the program:\n\n\(code)",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Copy", style: .default, handler: { _ in
            UIPasteboard.general.string = code
        }))
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }

    private func reload() async {
        if isLoading { return }
        isLoading = true
        await MainActor.run { self.programsView.setRefreshing(true) }
        defer {
            Task { @MainActor in
                self.isLoading = false
                self.programsView.setRefreshing(false)
            }
        }

        do {
            let physioID = try await model.resolvePhysioID()
            let programs = try await model.fetchPrograms(physioID: physioID)
            let programIDs = programs.map(\.id)

            async let exercisesRows = model.fetchProgramExercises(programIDs: programIDs)
            async let redemptionRows = model.fetchRedemptions(programIDs: programIDs)
            async let codeRows = model.fetchProgramCodes(programIDs: programIDs)

            let exercises = try await exercisesRows
            let redemptions = try await redemptionRows
            let codes = try await codeRows

            let exerciseCountByProgram = Dictionary(grouping: exercises, by: \.program_id)
                .mapValues { $0.count }

            let redemptionByProgram = Dictionary(grouping: redemptions, by: \.program_id)
            let customerIDs = Set(redemptions.map(\.customer_id))
            let customers = try await model.fetchCustomers(ids: Array(customerIDs))
            let customerByID = Dictionary(uniqueKeysWithValues: customers.map { ($0.id, $0) })

            let codeByProgram = Dictionary(grouping: codes, by: \.program_id)
                .compactMapValues { rows in
                    rows.max(by: { codeDate($0.created_at) < codeDate($1.created_at) })
                }

            let listItems = programs.map { program in
                let meta = model.parseDescription(program.description)
                let exerciseCount = exerciseCountByProgram[program.id] ?? 0
                let assigned = Array(
                    Dictionary(
                        grouping: redemptionByProgram[program.id, default: []]
                            .compactMap { customerByID[$0.customer_id] },
                        by: \.id
                    )
                    .compactMap(\.value.first)
                )
                .sorted { $0.full_name.localizedCaseInsensitiveCompare($1.full_name) == .orderedAscending }
                let duration = meta.durationDays ?? max(1, exerciseCount)
                let perDay = meta.exercisesPerDay ?? 1
                return ProgramListItem(
                    program: program,
                    meta: meta,
                    durationDays: duration,
                    exercisesPerDay: perDay,
                    exerciseCount: exerciseCount,
                    assignedPatients: assigned,
                    accessCode: codeByProgram[program.id]?.code
                )
            }

            await MainActor.run {
                self.items = listItems
                self.programsView.showEmptyState(listItems.isEmpty)
                self.programsView.tableView.reloadData()
            }
        } catch {
            await MainActor.run {
                self.programsView.showEmptyState(true)
                self.showError("Programs Error", error.localizedDescription)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgramCardCell.reuseID, for: indexPath) as? ProgramCardCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.apply(makeVM(item))
        cell.selectionStyle = .none
        cell.onDetails = { [weak self] in
            self?.showDetails(for: item)
        }
        cell.onAssign = { [weak self] in
            self?.showAssign(for: item)
        }
        cell.onDelete = { [weak self] in
            self?.confirmDelete(for: item)
        }
        return cell
    }

    private func showDetails(for item: ProgramListItem) {
        let codeText = item.accessCode ?? "No code yet"
        let patientNames = item.assignedPatients.map(\.full_name).joined(separator: ", ")
        let assignedText = patientNames.isEmpty ? "No patients assigned." : patientNames
        let ac = UIAlertController(
            title: item.program.title,
            message: "Access code: \(codeText)\n\nAssigned: \(assignedText)",
            preferredStyle: .alert
        )
        if let code = item.accessCode {
            ac.addAction(UIAlertAction(title: "Copy Code", style: .default, handler: { _ in
                UIPasteboard.general.string = code
            }))
        }
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }

    private func showAssign(for item: ProgramListItem) {
        let vc = AssignPatientsViewController(program: item.program)
        vc.onAssigned = { [weak self] code in
            guard let self else { return }
            self.showCodeAlert(code: code)
            Task { await self.reload() }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func confirmDelete(for item: ProgramListItem) {
        let ac = UIAlertController(
            title: "Delete Program",
            message: "This will remove the program and all assignments. This cannot be undone.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteProgram(item.program.id)
        }))
        present(ac, animated: true)
    }

    private func deleteProgram(_ programID: UUID) {
        Task {
            do {
                try await model.deleteProgram(programID: programID)
                await MainActor.run { Task { await self.reload() } }
            } catch {
                await MainActor.run { self.showError("Delete Error", error.localizedDescription) }
            }
        }
    }

    private func makeVM(_ item: ProgramListItem) -> ProgramCardVM {
        let isActive = item.program.is_active
        let statusText = isActive ? "Active" : "Inactive"
        let statusColor = isActive ? UIColor(hex: "DFF7E8") : UIColor(hex: "F3F4F6")
        let statusTextColor = isActive ? UIColor(hex: "1E8E3E") : UIColor.black.withAlphaComponent(0.6)

        let patientCount = item.assignedPatients.count
        let durationText = "\(item.durationDays) days program"
        let exercisesText = "\(item.exerciseCount) exercises"
        let createdText = formattedDate(item.program.created_at)

        let metrics = [
            ProgramCardVM.Metric(icon: "person", text: "\(patientCount) patients assigned"),
            ProgramCardVM.Metric(icon: "calendar", text: durationText),
            ProgramCardVM.Metric(icon: "video", text: exercisesText),
            ProgramCardVM.Metric(icon: "clock", text: "Created: \(createdText)")
        ]

        let chipNames = item.assignedPatients.prefix(2).map(\.full_name)
        let overflow = max(0, item.assignedPatients.count - chipNames.count)

        return ProgramCardVM(
            title: item.program.title,
            statusText: statusText,
            statusColor: statusColor,
            statusTextColor: statusTextColor,
            metrics: metrics,
            assignedChips: chipNames,
            assignedOverflow: overflow
        )
    }

    private func formattedDate(_ raw: String) -> String {
        let iso = ISO8601DateFormatter()
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        if let date = iso.date(from: raw) {
            return df.string(from: date)
        }
        return raw
    }

    private func codeDate(_ raw: String) -> Date {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: raw) {
            return date
        }

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSXXXXX"
        if let date = df.date(from: raw) {
            return date
        }
        df.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
        return df.date(from: raw) ?? .distantPast
    }

    private func showError(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
}

private struct ProgramListItem {
    let program: PhysioProgramRow
    let meta: ProgramMeta
    let durationDays: Int
    let exercisesPerDay: Int
    let exerciseCount: Int
    let assignedPatients: [ProgramsCustomerRow]
    let accessCode: String?
}
