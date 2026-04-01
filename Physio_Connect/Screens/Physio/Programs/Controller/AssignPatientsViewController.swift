//
//  AssignPatientsViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import UIKit

final class AssignPatientsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    var onAssigned: ((String) -> Void)?

    private let program: PhysioProgramRow
    private let model = PhysioProgramsModel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let footerView = UIView()
    private let cancelButton = UIButton(type: .system)
    private let assignButton = UIButton(type: .system)
    private let searchController = UISearchController(searchResultsController: nil)

    private var physioID: String?
    private var patients: [ProgramsCustomerRow] = []
    private var filteredPatients: [ProgramsCustomerRow] = []
    private var selectedIDs = Set<UUID>()
    private var isLoading = false

    init(program: PhysioProgramRow) {
        self.program = program
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Assign Patients"
        view.backgroundColor = UITheme.Colors.background
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTapped))
        setupSearch()

        setupFooter()
        setupTableView()
        Task { await loadPatients() }
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search patients"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56
        tableView.backgroundColor = .clear
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])
    }

    private func setupFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .secondarySystemGroupedBackground
        view.addSubview(footerView)

        var cancelConfig = UIButton.Configuration.tinted()
        cancelConfig.title = "Cancel"
        cancelConfig.baseForegroundColor = .label
        cancelConfig.baseBackgroundColor = .secondarySystemFill
        cancelConfig.cornerStyle = .capsule
        cancelButton.configuration = cancelConfig
        cancelButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        var assignConfig = UIButton.Configuration.filled()
        assignConfig.title = "Assign"
        assignConfig.baseBackgroundColor = UITheme.Colors.accent
        assignConfig.baseForegroundColor = .white
        assignConfig.cornerStyle = .capsule
        assignButton.configuration = assignConfig
        assignButton.addTarget(self, action: #selector(assignTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [cancelButton, assignButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        footerView.addSubview(stack)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -12),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            assignButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func loadPatients() async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let id = try await model.resolvePhysioID()
            physioID = id
            let allPatients = try await model.fetchPatientsForPhysio(physioID: id)
            let redemptions = try await model.fetchRedemptions(programIDs: [program.id])
            let assigned = Set(redemptions.map(\.customer_id))

            let unique = Dictionary(grouping: allPatients, by: \.id)
                .compactMapValues { $0.first }
                .values
                .sorted { $0.full_name < $1.full_name }

            let filtered = unique.filter { !assigned.contains($0.id) }

            await MainActor.run {
                self.patients = filtered
                self.applyFilter(query: self.searchController.searchBar.text)
            }
        } catch {
            await MainActor.run { self.showError("Patients Error", error.localizedDescription) }
        }
    }

    private func applyFilter(query: String?) {
        let trimmed = query?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            filteredPatients = patients
        } else {
            let lowercased = trimmed.lowercased()
            filteredPatients = patients.filter { patient in
                let name = patient.full_name.lowercased()
                let email = patient.email?.lowercased() ?? ""
                let location = patient.location?.lowercased() ?? ""
                return name.contains(lowercased)
                    || email.contains(lowercased)
                    || location.contains(lowercased)
            }
        }
        tableView.reloadData()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func assignTapped() {
        guard let physioID else { return }
        let ids = Array(selectedIDs)
        if ids.isEmpty {
            showError("Select Patients", "Pick at least one patient to assign.")
            return
        }

        Task {
            do {
                let code = try await model.createAccessCode(
                    programID: program.id,
                    physioID: physioID,
                    maxRedemptions: ids.count
                )
                try await model.createRedemptions(
                    programID: program.id,
                    codeID: code.id,
                    customerIDs: ids
                )
                await MainActor.run {
                    self.onAssigned?(code.code)
                    self.dismiss(animated: true)
                }
            } catch {
                await MainActor.run { self.showError("Assign Error", error.localizedDescription) }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPatients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "patientCell")
        let patient = filteredPatients[indexPath.row]
        cell.textLabel?.text = patient.full_name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.detailTextLabel?.text = patient.location ?? patient.email ?? ""
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.backgroundColor = .clear
        cell.accessoryType = selectedIDs.contains(patient.id) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let patient = filteredPatients[indexPath.row]
        if selectedIDs.contains(patient.id) {
            selectedIDs.remove(patient.id)
        } else {
            selectedIDs.insert(patient.id)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func updateSearchResults(for searchController: UISearchController) {
        applyFilter(query: searchController.searchBar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        applyFilter(query: nil)
    }

    private func showError(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
}
