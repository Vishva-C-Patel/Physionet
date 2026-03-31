//
//  VideosViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//

import UIKit

final class VideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let videosView = VideosView()
    private let model = VideosModel()
    private let profileModel = ProfileModel()

    private var freeExercises: [ExerciseVideoRow] = []
    private var programExercises: [MyProgramExerciseRow] = []
    private var isRefreshing = false
    private let filterOptions = ["All", "Neck", "Back", "Shoulders", "Knees"]
    private var selectedFilterIndex = 0
    private let daySubtitles = [
        "Foundation & Assessment",
        "Building Stability",
        "Progressive Strengthening",
        "Mobility & Flow",
        "Control & Balance"
    ]
    private let itemsPerDay = 2

    private var programSections: [ProgramDaySection] = []
    private var completedRowKeys: Set<String> = []
    private var programTitle: String?
    private var programStartDate: Date?
    private var preferredProgramID: UUID?
    private var shouldPreferProgramOnce = false
    private var programHeaderView: UIView?
    private var programFooterView: UIView?
    private var animatedProgramRows = Set<IndexPath>()

    private var isProgramTab: Bool { videosView.segmented.selectedSegmentIndex == 1 }
    private var filteredFreeExercises: [ExerciseVideoRow] {
        guard selectedFilterIndex > 0 else { return freeExercises }
        let filter = filterOptions[selectedFilterIndex].lowercased()
        return freeExercises.filter { row in
            let area = row.target_area?.lowercased() ?? ""
            return area.contains(filter)
        }
    }

    override func loadView() { view = videosView }

    override func viewDidLoad() {
        super.viewDidLoad()
        UITheme.applyNativeNavBar(to: self, title: "Exercises")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: videosView.profileButton)

        videosView.tableView.dataSource = self
        videosView.tableView.delegate = self
        videosView.searchBar.delegate = self
        videosView.tableView.register(ExerciseCell.self, forCellReuseIdentifier: ExerciseCell.reuseID)
        videosView.tableView.register(ProgramExerciseCell.self, forCellReuseIdentifier: ProgramExerciseCell.reuseID)
        videosView.tableView.rowHeight = UITableView.automaticDimension
        videosView.tableView.estimatedRowHeight = 300
        videosView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        videosView.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        videosView.filterCollectionView.dataSource = self
        videosView.filterCollectionView.delegate = self
        videosView.filterCollectionView.register(ExerciseFilterChipCell.self, forCellWithReuseIdentifier: ExerciseFilterChipCell.reuseID)
        videosView.filterCollectionView.allowsMultipleSelection = false
        videosView.filterCollectionView.selectItem(at: IndexPath(item: selectedFilterIndex, section: 0), animated: false, scrollPosition: [])

        videosView.segmented.addTarget(self, action: #selector(tabChanged), for: .valueChanged)
        videosView.redeemButton.addTarget(self, action: #selector(redeemTapped), for: .touchUpInside)
        videosView.redeemInlineButton.addTarget(self, action: #selector(redeemInlineTapped), for: .touchUpInside)
        videosView.setRefreshTarget(self, action: #selector(refreshPulled))
        videosView.profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProgressUpdate(_:)),
            name: ExerciseDetailViewController.progressUpdatedNotification,
            object: nil
        )

        Task { await reload() }
        Task { await refreshProfileAvatar() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await reload() }
        Task { await refreshProfileAvatar() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderLayout()
        updateFooterLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateHeaderLayout()
        updateFooterLayout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func tabChanged() {
        Task { await reload() }
    }

    @objc private func refreshPulled() {
        Task { await reload() }
    }

    @objc private func profileTapped() {
        let vc = ProfileViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleProgressUpdate(_ notification: Notification) {
        let exerciseID = notification.userInfo?["exerciseID"] as? UUID
        let programID = notification.userInfo?["programID"] as? UUID
        let rowKeyValue = notification.userInfo?["rowKey"] as? String
        Task { @MainActor in
            let today = dateString(from: Date())
            if let rowKeyValue {
                completedRowKeys.insert(rowKeyValue)
                if let programID {
                    ProgramRowCompletionStore.add(
                        rowKey: rowKeyValue,
                        programID: programID,
                        completionDate: today
                    )
                }
            } else if let exerciseID,
                      let first = programSections
                        .flatMap({ $0.items })
                        .first(where: { $0.exercise_id == exerciseID && !completedRowKeys.contains(rowKey(for: $0)) }) {
                let key = rowKey(for: first)
                completedRowKeys.insert(key)
                if let programID {
                    ProgramRowCompletionStore.add(
                        rowKey: key,
                        programID: programID,
                        completionDate: today
                    )
                }
            }
            animatedProgramRows.removeAll()
            videosView.tableView.reloadData()
            if isProgramTab {
                let completedDays = programSections.filter { isDayComplete($0) }.count
                applyProgramFooter(completedDays: completedDays, totalDays: programSections.count)
                updateFooterLayout()
            }
        }
    }

    private func reload() async {
        if isRefreshing { return }
        isRefreshing = true
        await MainActor.run { self.videosView.setRefreshing(true) }
        defer {
            Task { @MainActor in
                self.isRefreshing = false
                self.videosView.setRefreshing(false)
            }
        }

        do {
            if isProgramTab {
                videosView.setProgramMode(true)
                var programCompleted = false
                let forcedProgramID = shouldPreferProgramOnce ? preferredProgramID : nil
                let rows = try await model.fetchMyProgramExercises(preferredProgramID: forcedProgramID)
                shouldPreferProgramOnce = false
                if let loadedProgramID = rows.first?.program_id {
                    preferredProgramID = loadedProgramID
                }
                programExercises = rows
                programTitle = rows.first?.program_title
                programStartDate = nil
                programSections = []
                if rows.isEmpty {
                    completedRowKeys = []
                    await MainActor.run {
                        self.programHeaderView = nil
                        self.programFooterView = nil
                        self.videosView.tableView.tableHeaderView = nil
                        self.videosView.tableView.tableFooterView = nil
                    }
                } else if let programID = rows.first?.program_id {
                    let fetchedStartDate = try? await model.fetchProgramStartDate(programID: programID)
                    let progressRows = try await model.fetchProgress(programID: programID)
                    let resolvedStartDate = fetchedStartDate ?? earliestProgressDate(from: progressRows) ?? Date()
                    programStartDate = resolvedStartDate
                    programSections = buildProgramSections(rows)
                    completedRowKeys = buildCompletedRowKeys(
                        rows: rows,
                        progressRows: progressRows,
                        programID: programID
                    )
                    let totalCount = rows.count
                    let completedCount = rows.filter { completedRowKeys.contains(rowKey(for: $0)) }.count
                    let weeklyMinutes = computeWeeklyMinutes(from: progressRows)
                    let adherencePercent = totalCount == 0 ? 0 : Int(Double(completedCount) / Double(totalCount) * 100.0)
                    let expectedByDay = Dictionary(uniqueKeysWithValues: self.programSections.map { ($0.day - 1, $0.items.count) })
                    let series = buildSeries(from: progressRows,
                                             totalDays: programSections.count,
                                             programStartDate: resolvedStartDate,
                                             expectedByDay: expectedByDay)
                    let completedDays = programSections.filter { isDayComplete($0) }.count
                    programCompleted = programSections.count > 0 && completedDays == programSections.count
                    await MainActor.run {
                        if programCompleted {
                            self.programHeaderView = nil
                            self.programFooterView = nil
                            self.videosView.tableView.tableHeaderView = nil
                            self.videosView.tableView.tableFooterView = nil
                        } else {
                            self.applyProgramHeader(
                                programTitle: self.programTitle ?? "Your Recovery Program",
                                adherencePercent: adherencePercent,
                                completedCount: completedCount,
                                totalCount: totalCount,
                                weeklyMinutes: weeklyMinutes,
                                painSeries: series.pain,
                                adherenceSeries: series.adherence
                            )
                            self.applyProgramFooter(completedDays: completedDays, totalDays: self.programSections.count)
                        }
                    }
                } else {
                    await MainActor.run {
                        self.programHeaderView = nil
                        self.programFooterView = nil
                        self.videosView.tableView.tableHeaderView = nil
                        self.videosView.tableView.tableFooterView = nil
                    }
                }
                await MainActor.run {
                    self.videosView.setProgramRedeemVisible(rows.isEmpty)
                    if programCompleted {
                        self.videosView.configureEmptyState(
                            title: "Program Completed",
                            message: "Great work! Your program is completed. Ask your physiotherapist for a new plan.",
                            showRedeem: false
                        )
                        self.videosView.showEmptyState(true)
                    } else {
                        self.videosView.configureEmptyState(
                            title: "No Program Yet",
                            message: "Redeem your physiotherapist's code to unlock your personalized program.",
                            showRedeem: true
                        )
                        self.videosView.showEmptyState(rows.isEmpty)
                    }
                    self.animatedProgramRows.removeAll()
                    self.videosView.tableView.reloadData()
                    self.updateHeaderLayout()
                }
            } else {
                videosView.setProgramMode(false)
                await MainActor.run {
                    self.videosView.setProgramRedeemVisible(false)
                    self.programHeaderView = nil
                    self.programFooterView = nil
                    self.videosView.tableView.tableHeaderView = nil
                    self.videosView.tableView.tableFooterView = nil
                }
                programStartDate = nil
                let rows = try await model.fetchFreeExercises(search: videosView.searchBar.text)
                freeExercises = rows
                await MainActor.run {
                    self.videosView.showEmptyState(false)
                    self.videosView.filterCollectionView.reloadData()
                    self.videosView.filterCollectionView.selectItem(
                        at: IndexPath(item: self.selectedFilterIndex, section: 0),
                        animated: false,
                        scrollPosition: []
                    )
                    self.videosView.tableView.reloadData()
                    self.updateHeaderLayout()
                }
            }
        } catch {
            await MainActor.run {
                if self.isProgramTab { self.videosView.showEmptyState(true) }
                self.showError("Videos Error", error.localizedDescription)
            }
        }
    }

    @objc private func redeemTapped() {
        let ac = UIAlertController(
            title: "Redeem Program Code",
            message: "Enter the code provided by your physiotherapist.",
            preferredStyle: .alert
        )
        ac.addTextField { tf in
            tf.placeholder = "e.g., PHYSIO-2026"
            tf.autocapitalizationType = .allCharacters
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Redeem", style: .default) { [weak self] _ in
            guard let self else { return }
            let code = ac.textFields?.first?.text ?? ""
            Task { await self.redeem(code: code) }
        })

        present(ac, animated: true)
    }

    @objc private func redeemInlineTapped() {
        let code = videosView.redeemCodeField.text ?? ""
        Task { await redeem(code: code, clearFieldOnSuccess: true) }
    }

    private func redeem(code: String, clearFieldOnSuccess: Bool = false) async {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            await MainActor.run {
                self.showError("Redeem failed", "Please enter a valid program code.")
            }
            return
        }

        do {
            let redeemedProgramID = try await self.model.redeemProgram(code: trimmed)
            preferredProgramID = redeemedProgramID
            shouldPreferProgramOnce = true
            if clearFieldOnSuccess {
                await MainActor.run { self.videosView.redeemCodeField.text = "" }
            }
            await self.reload()
        } catch {
            await MainActor.run {
                self.showError("Redeem failed", error.localizedDescription)
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task {
            do {
                let rows = try await model.fetchFreeExercises(search: searchText)
                freeExercises = rows
                await MainActor.run { self.videosView.tableView.reloadData() }
            } catch {
                await MainActor.run { self.showError("Search error", error.localizedDescription) }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        isProgramTab ? programSections.count : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isProgramTab {
            guard programSections.indices.contains(section) else { return 0 }
            return programSections[section].items.count
        }
        return filteredFreeExercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isProgramTab {
            guard programSections.indices.contains(indexPath.section),
                  programSections[indexPath.section].items.indices.contains(indexPath.row)
            else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: ProgramExerciseCell.reuseID, for: indexPath) as! ProgramExerciseCell
            cell.selectionStyle = .none
            let row = programSections[indexPath.section].items[indexPath.row]
            let completed = completedRowKeys.contains(rowKey(for: row))
            let locked = isDayLocked(indexPath.section)
            cell.configure(
                title: row.title,
                subtitle: row.target_area ?? "General",
                durationSeconds: row.duration_seconds,
                completed: completed,
                locked: locked,
                thumbnailPath: row.thumbnail_path
            )
            loadThumbnail(for: row.thumbnail_path, in: cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseCell.reuseID, for: indexPath) as! ExerciseCell
            cell.selectionStyle = .none
            let row = filteredFreeExercises[indexPath.row]
            cell.configure(
                title: row.title,
                subtitle: "\(row.target_area ?? "General") - \(row.purpose ?? "Free")",
                description: row.description,
                durationSeconds: row.duration_seconds,
                badgeText: row.difficulty ?? "Free",
                thumbnailPath: row.thumbnail_path
            )
            loadThumbnail(for: row.thumbnail_path, in: cell)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isProgramTab, cell is ProgramExerciseCell else { return }
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        guard animatedProgramRows.insert(indexPath).inserted else { return }

        cell.alpha = 0.0
        cell.transform = CGAffineTransform(translationX: 0, y: 10)
        UIView.animate(withDuration: 0.4, delay: 0.03 * Double(indexPath.row), options: [.curveEaseOut]) {
            cell.alpha = 1.0
            cell.transform = .identity
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isProgramTab {
            guard programSections.indices.contains(indexPath.section),
                  programSections[indexPath.section].items.indices.contains(indexPath.row)
            else { return }
            if isDayLocked(indexPath.section) { return }
            let r = programSections[indexPath.section].items[indexPath.row]
            let nextUp = buildNextUpItems(currentID: r.exercise_id)
            let vc = ExerciseDetailViewController(
                headerTitleText: r.target_area ?? "Exercise",
                titleText: r.title,
                subtitle: "\(r.target_area ?? "General") - \(r.purpose ?? "Program")",
                descriptionText: r.description,
                durationSeconds: r.duration_seconds,
                videoPath: r.video_path,
                thumbnailPath: r.thumbnail_path,
                programID: r.program_id,
                exerciseID: r.exercise_id,
                rowKey: rowKey(for: r),
                sets: r.sets,
                reps: r.reps,
                hold: r.hold_seconds,
                nextUpItems: nextUp
            )
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let r = filteredFreeExercises[indexPath.row]
            let vc = ExerciseDetailViewController(
                headerTitleText: r.target_area ?? "Exercise",
                titleText: r.title,
                subtitle: "\(r.target_area ?? "General") - \(r.purpose ?? "Free")",
                descriptionText: r.description,
                durationSeconds: r.duration_seconds,
                videoPath: r.video_path,
                thumbnailPath: r.thumbnail_path,
                programID: nil,
                exerciseID: r.id,
                rowKey: nil,
                sets: nil,
                reps: nil,
                hold: nil,
                nextUpItems: []
            )
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func buildNextUpItems(currentID: UUID) -> [ExerciseDetailViewController.NextUpItem] {
        let sorted = programExercises.sorted { ($0.sort_order ?? 0) < ($1.sort_order ?? 0) }
        guard let currentIndex = sorted.firstIndex(where: { $0.exercise_id == currentID }) else { return [] }
        let tail = sorted.dropFirst(currentIndex + 1)
        let nextRows = Array(tail.prefix(3))
        return nextRows.enumerated().map { offset, row in
            let absoluteIndex = currentIndex + 1 + offset
            let dayIndex = absoluteIndex / itemsPerDay
            let locked = isDayLocked(dayIndex)
            return ExerciseDetailViewController.NextUpItem(
                title: row.title,
                subtitle: "\(row.target_area ?? "General")",
                durationSeconds: row.duration_seconds,
                videoPath: row.video_path,
                thumbnailPath: row.thumbnail_path,
                programID: row.program_id,
                exerciseID: row.exercise_id,
                rowKey: rowKey(for: row),
                locked: locked
            )
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        isProgramTab ? 52 : 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard isProgramTab, programSections.indices.contains(section) else { return nil }
        let header = ProgramDayHeaderView()
        let sectionData = programSections[section]
        let completedCount = sectionData.items.filter { completedRowKeys.contains(rowKey(for: $0)) }.count
        let isComplete = completedCount == sectionData.items.count && sectionData.items.count > 0
        header.configure(
            day: sectionData.day,
            title: sectionData.title,
            subtitle: sectionData.subtitle,
            completedCount: completedCount,
            totalCount: sectionData.items.count,
            isComplete: isComplete
        )
        let container = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(header)
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            header.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            header.topAnchor.constraint(equalTo: container.topAnchor),
            header.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExerciseFilterChipCell.reuseID, for: indexPath) as! ExerciseFilterChipCell
        cell.configure(title: filterOptions[indexPath.item],
                       isSelected: indexPath.item == selectedFilterIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousIndex = selectedFilterIndex
        guard previousIndex != indexPath.item else { return }
        selectedFilterIndex = indexPath.item
        var reloadItems: [IndexPath] = [indexPath]
        if previousIndex >= 0 && previousIndex < filterOptions.count {
            reloadItems.append(IndexPath(item: previousIndex, section: 0))
        }
        collectionView.reloadItems(at: reloadItems)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        videosView.tableView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = filterOptions[indexPath.item]
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let width = title.size(withAttributes: [.font: font]).width + 32
        return CGSize(width: max(64, width), height: 32)
    }

    private func loadThumbnail(for path: String?, in cell: ExerciseCell) {
        guard let path else { return }
        Task { [weak self, weak cell] in
            guard let self, let cell else { return }
            do {
                let url = try await self.model.signedThumbnailURL(path: path)
                await MainActor.run {
                    if cell.thumbnailPath == path {
                        cell.setThumbnail(url: url)
                    }
                }
            } catch {
                print("❌ Free thumb load failed for \(path): \(error)")
                return
            }
        }
    }

    private func loadThumbnail(for path: String?, in cell: ProgramExerciseCell) {
        guard let path else { return }
        Task { [weak self, weak cell] in
            guard let self, let cell else { return }
            do {
                let url = try await self.model.signedThumbnailURL(path: path)
                await MainActor.run {
                    if cell.thumbnailPath == path {
                        cell.setThumbnail(url: url)
                    }
                }
            } catch {
                print("❌ Program thumb load failed for \(path): \(error)")
                return
            }
        }
    }

    private func buildProgramSections(_ rows: [MyProgramExerciseRow]) -> [ProgramDaySection] {
        var sections: [ProgramDaySection] = []
        for (index, row) in rows.enumerated() {
            let day = (index / itemsPerDay) + 1
            if sections.last?.day != day {
                let subtitle = daySubtitles.indices.contains(day - 1) ? daySubtitles[day - 1] : "Recovery Focus"
                sections.append(ProgramDaySection(day: day, title: "Day \(day)", subtitle: subtitle, items: []))
            }
            sections[sections.count - 1].items.append(row)
        }
        return sections
    }

    private func isDayComplete(_ section: ProgramDaySection) -> Bool {
        let completedCount = section.items.filter { completedRowKeys.contains(rowKey(for: $0)) }.count
        return completedCount == section.items.count && section.items.count > 0
    }

    private func isDayLocked(_ sectionIndex: Int) -> Bool {
        let dayNumber = sectionIndex + 1
        return dayNumber > availableDayCount()
    }

    private func rowKey(for row: MyProgramExerciseRow) -> String {
        "\(row.program_id.uuidString)-\(row.program_exercise_id.uuidString)"
    }

    private func availableDayCount() -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: programStartDate ?? Date())
        let today = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, days + 1)
    }

    private func scheduledDateString(for row: MyProgramExerciseRow) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: programStartDate ?? Date())
        let index = programExercises.firstIndex(where: { rowKey(for: $0) == rowKey(for: row) }) ?? 0
        let dayOffset = index / itemsPerDay
        let date = calendar.date(byAdding: .day, value: dayOffset, to: start) ?? start
        return dateString(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func earliestProgressDate(from rows: [ExerciseProgressRow]) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        let dates = rows.compactMap { row -> Date? in
            guard let dateString = row.progress_date else { return nil }
            return formatter.date(from: dateString)
        }
        return dates.min()
    }

    private func buildCompletedRowKeys(rows: [MyProgramExerciseRow],
                                       progressRows: [ExerciseProgressRow],
                                       programID: UUID) -> Set<String> {
        let storedMap = ProgramRowCompletionStore.completionMap(programID: programID)
        var completedExerciseCounts: [UUID: Int] = [:]
        for row in progressRows {
            guard row.is_completed == true else { continue }
            completedExerciseCounts[row.exercise_id, default: 0] += 1
        }

        var keys: Set<String> = []

        // 1) Keep rows that are known completed locally (instant UI feedback).
        for row in rows {
            let key = rowKey(for: row)
            if storedMap[key] != nil {
                keys.insert(key)
            }
        }

        // 2) Deduct backend counts for rows already completed locally.
        for row in rows {
            let key = rowKey(for: row)
            guard keys.contains(key) else { continue }
            if let count = completedExerciseCounts[row.exercise_id], count > 0 {
                completedExerciseCounts[row.exercise_id] = count - 1
            }
        }

        // 3) Fill remaining completed cards strictly from backend counts.
        for row in rows {
            let key = rowKey(for: row)
            guard !keys.contains(key) else { continue }
            if let count = completedExerciseCounts[row.exercise_id], count > 0 {
                keys.insert(key)
                completedExerciseCounts[row.exercise_id] = count - 1
            }
        }

        return keys
    }

    private func applyProgramHeader(programTitle: String,
                                    adherencePercent: Int,
                                    completedCount: Int,
                                    totalCount: Int,
                                    weeklyMinutes: Int,
                                    painSeries: [Int],
                                    adherenceSeries: [Int]) {
        let header = UIView()
        header.backgroundColor = .clear

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        let summaryView = ProgramSummaryView()
        summaryView.configure(
            programTitle: programTitle,
            subtitle: "Prescribed by your physiotherapist",
            adherenceText: "\(adherencePercent)%",
            completedText: "\(completedCount)/\(totalCount)",
            timeText: "\(weeklyMinutes)m"
        )
        summaryView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true

        let trendsView = ProgramTrendsView()
        trendsView.configure(painSeries: painSeries, adherenceSeries: adherenceSeries)

        stack.addArrangedSubview(summaryView)
        stack.addArrangedSubview(trendsView)

        header.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: header.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)
        ])

        programHeaderView = header
        setTableHeaderView(header)
        updateHeaderLayout()
    }

    private func applyProgramFooter(completedDays: Int, totalDays: Int) {
        let footerContainer = UIView()
        footerContainer.backgroundColor = .clear

        let progressView = ProgramOverallProgressView()
        progressView.configure(completedDays: completedDays, totalDays: totalDays)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 12),
            progressView.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: footerContainer.bottomAnchor, constant: -24)
        ])

        programFooterView = footerContainer
        setTableFooterView(footerContainer)
        updateFooterLayout()
    }

    private func setTableHeaderView(_ header: UIView) {
        let width = videosView.tableView.bounds.width > 0 ? videosView.tableView.bounds.width : view.bounds.width
        header.bounds.size.width = width
        header.bounds.size.height = 1
        videosView.tableView.layoutIfNeeded()
        header.setNeedsLayout()
        header.layoutIfNeeded()

        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = header.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        videosView.tableView.tableHeaderView = header
    }

    private func updateHeaderLayout() {
        guard let header = programHeaderView else { return }
        let width = videosView.tableView.bounds.width > 0 ? videosView.tableView.bounds.width : view.bounds.width
        guard width > 0 else { return }
        setTableHeaderView(header)
    }

    private func setTableFooterView(_ footer: UIView) {
        let width = videosView.tableView.bounds.width > 0 ? videosView.tableView.bounds.width : view.bounds.width
        footer.bounds.size.width = width
        footer.bounds.size.height = 1
        videosView.tableView.layoutIfNeeded()
        footer.setNeedsLayout()
        footer.layoutIfNeeded()

        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = footer.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        footer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        videosView.tableView.tableFooterView = footer
    }

    private func updateFooterLayout() {
        guard let footer = programFooterView else { return }
        let width = videosView.tableView.bounds.width > 0 ? videosView.tableView.bounds.width : view.bounds.width
        guard width > 0 else { return }
        setTableFooterView(footer)
    }

    private func computeWeeklyMinutes(from rows: [ExerciseProgressRow]) -> Int {
        let now = Date()
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: now) ?? now
        let totalSeconds = rows.compactMap { row -> Int? in
            guard let dateString = row.progress_date,
                  let date = parseProgressDate(dateString) else { return nil }
            guard date >= weekAgo else { return nil }
            return row.watched_seconds
        }.reduce(0, +)
        return max(1, totalSeconds / 60)
    }

    private func buildSeries(from rows: [ExerciseProgressRow],
                             totalDays: Int,
                             programStartDate: Date,
                             expectedByDay: [Int: Int]) -> (pain: [Int], adherence: [Int]) {
        let calendar = Calendar.current
        let programDayCount = max(totalDays, 1)
        let start = calendar.startOfDay(for: programStartDate)
        let today = calendar.startOfDay(for: Date())
        let elapsedDays = max((calendar.dateComponents([.day], from: start, to: today).day ?? 0) + 1, 1)
        let maxRecordedOffset = rows.compactMap { row -> Int? in
            guard let raw = row.progress_date,
                  let date = parseProgressDate(raw) else { return nil }
            let day = calendar.startOfDay(for: date)
            let offset = calendar.dateComponents([.day], from: start, to: day).day ?? 0
            return max(0, offset)
        }.max() ?? (programDayCount - 1)
        // Keep chart dynamic: planned days + elapsed real days + recorded days.
        // This lets users who finish late still see D3, D4... with their saved values.
        let seriesCount = max(programDayCount, elapsedDays, maxRecordedOffset + 1)
        var painSeries: [Int] = []
        var adherenceSeries: [Int] = []
        let expectedFallback = max(
            Int(round(Double(expectedByDay.values.reduce(0, +)) / Double(max(expectedByDay.count, 1)))),
            1
        )

        for dayIndex in 0..<seriesCount {
            let day = calendar.date(byAdding: .day, value: dayIndex, to: start) ?? start
            let dayString = dateString(from: day)
            let dayRows = rows.filter { row in
                guard let raw = row.progress_date else { return false }
                return normalizedDateString(raw) == dayString
            }
            let painAvg: Int = {
                let pains = dayRows.filter { $0.is_completed == true }.compactMap { $0.pain_level }
                guard !pains.isEmpty else { return 0 }
                return Int(Double(pains.reduce(0, +)) / Double(pains.count))
            }()
            let completed = dayRows.filter { $0.is_completed == true }.count
            let expected = max(expectedByDay[dayIndex] ?? expectedFallback, 1)
            let adherence = min(100, Int((Double(completed) / Double(expected)) * 100.0))
            painSeries.append(painAvg)
            adherenceSeries.append(adherence)
        }
        return (painSeries, adherenceSeries)
    }

    private func parseProgressDate(_ raw: String) -> Date? {
        let normalized = normalizedDateString(raw)
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: normalized)
    }

    private func normalizedDateString(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 10 {
            return String(trimmed.prefix(10))
        }
        return trimmed
    }

    private struct ProgramDaySection {
        let day: Int
        let title: String
        let subtitle: String
        var items: [MyProgramExerciseRow]
    }

    private func showError(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    private func refreshProfileAvatar() async {
        await MainActor.run {
            PatientNavAvatarStyle.updateProfileButton(
                self.videosView.profileButton,
                urlString: ProfileModel.cachedAvatarURL()
            )
        }
        guard let profile = try? await profileModel.fetchCurrentProfile() else { return }
        await MainActor.run {
            PatientNavAvatarStyle.updateProfileButton(self.videosView.profileButton, urlString: profile.avatarURL)
        }
    }
}
