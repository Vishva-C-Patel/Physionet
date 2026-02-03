//
//  PhysiotherapistListViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//

import UIKit
import CoreLocation

final class PhysiotherapistListViewController: UIViewController {

    private let listView = PhysiotherapistListView()

    private var items: [PhysiotherapistCardModel] = []
    private var availableItems: [PhysiotherapistCardModel] = []
    private var filtered: [PhysiotherapistCardModel] = []
    private var availablePhysioIDs: Set<UUID>?
    private var searchQuery = ""
    private var selectedDate = Date()

    var activeFilters = Filters()

    override func loadView() { view = listView }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listView.layoutHeaderIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        listView.tableView.dataSource = self
        listView.tableView.delegate = self
        listView.searchBar.delegate = self

        listView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        listView.datePill.addTarget(self, action: #selector(datePillTapped), for: .touchUpInside)
        listView.timePill.addTarget(self, action: #selector(timePillTapped), for: .touchUpInside)
        listView.filterButton.addTarget(self, action: #selector(openFilters), for: .touchUpInside)

        setupLocationUpdates()
        setInitialDatePills()
        fetchPhysios()
    }

    private func setInitialDatePills() {
        let now = selectedDate
        let d = DateFormatter()
        d.dateFormat = "dd MMM yyyy"
        listView.setDateText(d.string(from: now))

        let t = DateFormatter()
        t.dateFormat = "h:mm a"
        listView.setTimeText(t.string(from: now))
    }

    // MARK: - Fetch from Supabase (NEW TABLE)
    private func fetchPhysios() {
        Task {
            do {
                let rows = try await PhysioService.shared.fetchPhysiotherapistsForList()
                var cards = rows.map { self.mapToCard($0) }

                if let loc = LocationService.shared.lastLocation {
                    for i in cards.indices { cards[i].updateDistance(from: loc) }
                }

                await MainActor.run {
                    self.items = cards
                    self.applyAvailabilityFilter()
                    self.applyFilters()
                }
                await refreshAvailability()
            } catch {
                print("❌ fetchPhysios error:", error)
            }
        }
    }

    // MARK: - Map DB model → UI model (IMPORTANT)
    private func mapToCard(_ p: PhysioListRow) -> PhysiotherapistCardModel
{

        // feeText must be STRING
        let fee = Int(p.consultation_fee ?? 0)
        let feeText = "₹\(fee)/hr"

        // TEMP: until specialization join, keep this line same style
        let spec =
        p.physio_specializations?
            .compactMap { $0.specializations?.name }
            .first
        ?? "Physiotherapy specialist"


        return PhysiotherapistCardModel(
            id: p.id,
            name: p.name,
            gender: p.gender,
            rating: p.avg_rating ?? 0,
            reviewsCount: p.reviews_count ?? 0,
            specializationText: spec,
            feeText: feeText,
            profileImagePath: p.profile_image_path,
            profileImageVersion: p.updated_at,
            latitude: p.latitude,
            longitude: p.longitude,
            distanceText: "Calculating..."
        )
    }

    // MARK: - Location
    private func setupLocationUpdates() {
        LocationService.shared.onLocationUpdate = { [weak self] city, location in
            guard let self else { return }
            self.listView.cityLabel.text = city

            guard let loc = location else { return }

            for i in self.items.indices { self.items[i].updateDistance(from: loc) }
            self.applyAvailabilityFilter()
            self.applyFilters()
        }
        LocationService.shared.requestLocation()
    }

    // MARK: - Actions
    @objc private func goBack() { navigationController?.popViewController(animated: true) }

    @objc private func datePillTapped() {
        presentDatePicker(mode: .date)
    }

    @objc private func timePillTapped() {
        presentDatePicker(mode: .time)
    }

    @objc private func openFilters() {
        tabBarController?.tabBar.isHidden = true

        let vc = FiltersOverlayViewController()
        vc.selectedFilters = activeFilters

        vc.onApply = { [weak self] newFilters in
            guard let self else { return }
            self.activeFilters = newFilters
            self.applyFilters()
            self.tabBarController?.tabBar.isHidden = false
        }

        vc.onDismiss = { [weak self] in
            self?.tabBarController?.tabBar.isHidden = false
        }

        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: false)
    }

    private func applyAvailabilityFilter() {
        if let ids = availablePhysioIDs {
            availableItems = items.filter { ids.contains($0.id) }
        } else {
            availableItems = items
        }
    }

    private func applyFilters() {
        var list = availableItems

        // NOTE: Your Filters struct might be "specialities" or "specialties"
        // Use whichever exists in YOUR project.
        if !activeFilters.specialities.isEmpty {
            let specials = activeFilters.specialities.map { $0.lowercased() }
            list = list.filter { model in
                let specialization = model.specializationText.lowercased()
                return specials.contains { specialization.contains($0) }
            }
        }

        list = list.filter { model in
            guard let km = extractKm(from: model.distanceText) else { return true }
            return km <= activeFilters.maxDistance
        }

        if activeFilters.minRating > 0 {
            list = list.filter { Int($0.rating) >= activeFilters.minRating }
        }

        if let gender = activeFilters.gender, gender != "Prefer not to say" {
            let target = gender.lowercased()
            list = list.filter { $0.gender?.lowercased() == target }
        }

        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedQuery.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(trimmedQuery) ||
                $0.specializationText.lowercased().contains(trimmedQuery) ||
                $0.distanceText.lowercased().contains(trimmedQuery)
            }
        }

        filtered = list
        listView.tableView.reloadData()
    }

    private func presentDatePicker(mode: UIDatePicker.Mode) {
        let picker = UIDatePicker()
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.datePickerMode = mode
        picker.date = selectedDate
        if mode == .date {
            picker.minimumDate = Date()
        }

        let title = mode == .date ? "Select Date" : "Select Time"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        let contentView = UIViewController()
        contentView.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: contentView.view.topAnchor),
            picker.leadingAnchor.constraint(equalTo: contentView.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: contentView.view.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: contentView.view.bottomAnchor),
            contentView.view.heightAnchor.constraint(equalToConstant: 216)
        ])

        alert.setValue(contentView, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            self?.updateSelectedDate(with: picker.date, mode: mode)
        }))
        present(alert, animated: true)
    }

    private func updateSelectedDate(with value: Date, mode: UIDatePicker.Mode) {
        let calendar = Calendar.current
        switch mode {
        case .date:
            let newDate = calendar.startOfDay(for: value)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedDate)
            selectedDate = calendar.date(
                bySettingHour: timeComponents.hour ?? 0,
                minute: timeComponents.minute ?? 0,
                second: 0,
                of: newDate
            ) ?? newDate
        case .time:
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: value)
            selectedDate = calendar.date(
                bySettingHour: timeComponents.hour ?? 0,
                minute: timeComponents.minute ?? 0,
                second: 0,
                of: calendar.date(from: dateComponents) ?? selectedDate
            ) ?? selectedDate
        default:
            selectedDate = value
        }

        let d = DateFormatter()
        d.dateFormat = "dd MMM yyyy"
        listView.setDateText(d.string(from: selectedDate))

        let t = DateFormatter()
        t.dateFormat = "h:mm a"
        listView.setTimeText(t.string(from: selectedDate))

        Task { await refreshAvailability() }
    }

    private func refreshAvailability() async {
        do {
            let ids = try await PhysioService.shared.fetchAvailablePhysioIDs(at: selectedDate)
            await MainActor.run {
                self.availablePhysioIDs = ids.isEmpty ? nil : ids
                self.applyAvailabilityFilter()
                self.applyFilters()
            }
        } catch {
            print("❌ availability fetch error:", error)
        }
    }

    private func extractKm(from text: String) -> Double? {
        let digits = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Double(digits)
    }
}

// MARK: - Table
extension PhysiotherapistListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: PhysiotherapistCardCell.reuseID,
            for: indexPath
        ) as! PhysiotherapistCardCell

        let model = filtered[indexPath.row]
        cell.configure(with: model)
        cell.avatarPath = model.profileImagePath
        cell.setAvatarImage(nil)
        loadAvatar(path: model.profileImagePath, version: model.profileImageVersion, into: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = filtered[indexPath.row]

        let vc = PhysiotherapistProfileViewController(physioID: model.id, preloadCard: model)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func loadAvatar(path: String?, version: String?, into cell: PhysiotherapistCardCell) {
        guard let path else { return }
        PhysioService.shared.loadProfileImage(pathOrUrl: path, version: version) { [weak cell] image in
            guard let cell else { return }
            if cell.avatarPath == path {
                cell.setAvatarImage(image)
            }
        }
    }
}


// MARK: - Search
extension PhysiotherapistListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        applyFilters()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchQuery = ""
        searchBar.text = ""
        applyFilters()
    }
}
