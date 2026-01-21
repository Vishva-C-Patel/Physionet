//
//  CreateProgramViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import UIKit

final class CreateProgramViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var onProgramCreated: ((String?) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bottomBar = UIView()
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let model = PhysioProgramsModel()

    private let nameField = UITextField()
    private let durationField = UITextField()
    private let perDayField = UITextField()
    private var exercises: [ExerciseVideoRow] = []
    private var dayPlans: [[UUID]] = []
    private var isLoading = false

    private enum Section: Int, CaseIterable {
        case info
        case schedule
    }
    private var exerciseLookup: [UUID: ExerciseVideoRow] {
        Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create New Program"
        view.backgroundColor = UIColor(hex: "E6F1FF")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        buildTable()
        buildBottomBar()
        Task { await loadData() }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func buildTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProgramInfoCell.self, forCellReuseIdentifier: ProgramInfoCell.reuseID)
        tableView.register(ProgramDayCell.self, forCellReuseIdentifier: ProgramDayCell.reuseID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 8
        }
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 120
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        view.addSubview(tableView)
        view.addSubview(bottomBar)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 84)
        ])

        nameField.placeholder = "Enter program name"
        nameField.autocapitalizationType = .words
        nameField.returnKeyType = .next
        nameField.font = .systemFont(ofSize: 17)
        nameField.textColor = .label
        nameField.delegate = self

        durationField.placeholder = "14"
        durationField.keyboardType = .numberPad
        durationField.font = .systemFont(ofSize: 17)
        durationField.textColor = .label
        durationField.delegate = self
        durationField.addTarget(self, action: #selector(inputsChanged), for: .editingChanged)

        perDayField.placeholder = "5"
        perDayField.keyboardType = .numberPad
        perDayField.font = .systemFont(ofSize: 17)
        perDayField.textColor = .label
        perDayField.delegate = self
        perDayField.addTarget(self, action: #selector(inputsChanged), for: .editingChanged)
    }

    private func buildBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = UIColor(hex: "E6F1FF")

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.backgroundColor = UIColor(hex: "EDEFF3")
        cancelButton.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        createButton.setTitle("Create Program", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        createButton.backgroundColor = UIColor(hex: "1E6EF7")
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.addSubview(cancelButton)
        bottomBar.addSubview(createButton)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: bottomBar.centerXAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),

            createButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            createButton.leadingAnchor.constraint(equalTo: bottomBar.centerXAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func loadData() async {
        if isLoading { return }
        isLoading = true
        do {
            async let exercisesRows = model.fetchExercises()
            let loadedExercises = try await exercisesRows
            await MainActor.run {
                self.exercises = loadedExercises
                self.updateDayPlans()
                self.tableView.reloadData()
            }
        } catch {
            await MainActor.run { self.showError("Load Error", error.localizedDescription) }
        }
        isLoading = false
    }

    @objc private func createTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name.isEmpty {
            showError("Missing Name", "Please enter a program name.")
            return
        }
        guard let durationDays = Int(durationField.text ?? ""), durationDays > 0 else {
            showError("Missing Duration", "Enter a valid number of days for the program.")
            return
        }
        guard let perDay = Int(perDayField.text ?? ""), perDay > 0 else {
            showError("Missing Exercises", "Enter a valid number of exercises per day.")
            return
        }
        let incompleteDays = dayPlans.enumerated().filter { $0.element.count != perDay }
        if !incompleteDays.isEmpty {
            let first = incompleteDays.first?.offset ?? 0
            showError("Select Exercises", "Day \(first + 1) needs \(perDay) exercises.")
            return
        }
        let orderedExerciseIDs = dayPlans.flatMap { $0 }

        Task {
            do {
                let physioID = try await model.resolvePhysioID()
                let programID = try await model.createProgram(
                    physioID: physioID,
                    title: name,
                    durationDays: durationDays,
                    exercisesPerDay: perDay
                )
                try await model.addExercises(programID: programID, orderedExerciseIDs: orderedExerciseIDs)
                await MainActor.run {
                    self.dismiss(animated: true) {
                        self.onProgramCreated?(nil)
                    }
                }
            } catch {
                await MainActor.run { self.showError("Create Error", error.localizedDescription) }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .info:
            return 3
        case .schedule:
            return dayPlans.isEmpty ? 1 : dayPlans.count
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .info:
            return "Program Details"
        case .schedule:
            return "Daily Exercises *"
        case .none:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .info:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgramInfoCell.reuseID, for: indexPath) as? ProgramInfoCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                cell.configure(title: "Program Name *", textField: nameField)
            } else if indexPath.row == 1 {
                cell.configure(title: "Program Duration (days)", textField: durationField)
            } else {
                cell.configure(title: "Exercises Per Day", textField: perDayField)
            }
            return cell
        case .schedule:
            if dayPlans.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Set program duration and exercises per day to build each day."
                cell.textLabel?.textColor = UIColor.black.withAlphaComponent(0.5)
                cell.textLabel?.numberOfLines = 0
                cell.selectionStyle = .none
                return cell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgramDayCell.reuseID, for: indexPath) as? ProgramDayCell else {
                return UITableViewCell()
            }
            let perDay = Int(perDayField.text ?? "") ?? 0
            cell.apply(
                dayIndex: indexPath.row,
                exerciseIDs: dayPlans[indexPath.row],
                exerciseLookup: exerciseLookup,
                perDay: perDay
            )
            cell.onAdd = { [weak self] in
                self?.presentExercisePicker(forDay: indexPath.row)
            }
            cell.onCopy = { [weak self] in
                self?.presentCopyPicker(forDay: indexPath.row)
            }
            cell.selectionStyle = .none
            return cell
        case .none:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            durationField.becomeFirstResponder()
        } else if textField == durationField {
            perDayField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    private func showError(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = Section(rawValue: section) else { return nil }
        switch sectionType {
        case .schedule:
            return nil
        case .info:
            let header = UILabel()
            header.text = "Program Details"
            header.font = .systemFont(ofSize: 14, weight: .semibold)
            header.textColor = UIColor.black.withAlphaComponent(0.7)
            return header
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        switch sectionType {
        case .schedule:
            return 40
        default:
            return 40
        }
    }

    @objc private func inputsChanged() {
        updateDayPlans()
        tableView.reloadSections(IndexSet(integer: Section.schedule.rawValue), with: .automatic)
    }

    private func updateDayPlans() {
        guard let durationDays = Int(durationField.text ?? ""),
              let perDay = Int(perDayField.text ?? ""),
              durationDays > 0,
              perDay > 0
        else {
            dayPlans = []
            return
        }

        if dayPlans.count < durationDays {
            dayPlans.append(contentsOf: Array(repeating: [], count: durationDays - dayPlans.count))
        } else if dayPlans.count > durationDays {
            dayPlans = Array(dayPlans.prefix(durationDays))
        }

        dayPlans = dayPlans.map { Array($0.prefix(perDay)) }
    }

    private func presentExercisePicker(forDay dayIndex: Int) {
        let perDay = Int(perDayField.text ?? "") ?? 0
        if perDay <= 0 {
            showError("Missing Exercises", "Enter exercises per day first.")
            return
        }
        if dayPlans[dayIndex].count >= perDay {
            showError("Limit Reached", "Day \(dayIndex + 1) already has \(perDay) exercises.")
            return
        }
        let picker = ExercisePickerViewController(exercises: exercises)
        picker.onSelected = { [weak self] exercise in
            guard let self else { return }
            self.dayPlans[dayIndex].append(exercise.id)
            self.tableView.reloadRows(at: [IndexPath(row: dayIndex, section: Section.schedule.rawValue)], with: .automatic)
        }
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func presentCopyPicker(forDay dayIndex: Int) {
        guard dayIndex > 0, !dayPlans.isEmpty else { return }
        let perDay = Int(perDayField.text ?? "") ?? 0
        if perDay <= 0 {
            showError("Missing Exercises", "Enter exercises per day first.")
            return
        }
        let ac = UIAlertController(title: "Copy Exercises", message: "Choose a previous day to copy.", preferredStyle: .actionSheet)
        for sourceIndex in 0..<dayIndex {
            ac.addAction(UIAlertAction(title: "Copy Day \(sourceIndex + 1)", style: .default, handler: { [weak self] _ in
                guard let self else { return }
                self.dayPlans[dayIndex] = Array(self.dayPlans[sourceIndex].prefix(perDay))
                self.tableView.reloadRows(at: [IndexPath(row: dayIndex, section: Section.schedule.rawValue)], with: .automatic)
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

final class ProgramInfoCell: UITableViewCell {
    static let reuseID = "ProgramInfoCell"
    private let titleLabel = UILabel()
    private let textFieldContainer = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, textField: UITextField) {
        titleLabel.text = title
        textFieldContainer.subviews.forEach { $0.removeFromSuperview() }
        textField.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainer.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor, constant: 12),
            textField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: -12),
            textField.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func build() {
        selectionStyle = .none
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainer.backgroundColor = .secondarySystemGroupedBackground
        textFieldContainer.layer.cornerRadius = 12
        textFieldContainer.layer.masksToBounds = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(textFieldContainer)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            textFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            textFieldContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textFieldContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}

final class ProgramDayCell: UITableViewCell {
    static let reuseID = "ProgramDayCell"

    var onAdd: (() -> Void)?
    var onCopy: (() -> Void)?

    private let titleLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let copyButton = UIButton(type: .system)
    private let stack = UIStackView()
    private let emptyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(dayIndex: Int,
               exerciseIDs: [UUID],
               exerciseLookup: [UUID: ExerciseVideoRow],
               perDay: Int) {
        titleLabel.text = "Day \(dayIndex + 1)"
        copyButton.isHidden = dayIndex == 0
        let remaining = max(0, perDay - exerciseIDs.count)
        addButton.isEnabled = remaining > 0
        addButton.alpha = remaining > 0 ? 1.0 : 0.5

        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if exerciseIDs.isEmpty {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
            for id in exerciseIDs {
                guard let exercise = exerciseLookup[id] else { continue }
                let label = UILabel()
                label.font = .systemFont(ofSize: 15, weight: .semibold)
                label.textColor = UIColor.black.withAlphaComponent(0.85)
                let mins = max(1, (exercise.duration_seconds ?? 0) / 60)
                label.text = "\(exercise.title) • \(mins) min"
                stack.addArrangedSubview(label)
            }
        }
    }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.04
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(card)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.85)

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = UIColor(hex: "1E6EF7")
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setTitle("Copy", for: .normal)
        copyButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "Select exercises for this day."
        emptyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        emptyLabel.textColor = UIColor.black.withAlphaComponent(0.5)

        card.addSubview(titleLabel)
        card.addSubview(addButton)
        card.addSubview(copyButton)
        card.addSubview(stack)
        card.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            addButton.widthAnchor.constraint(equalToConstant: 24),

            copyButton.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),
            copyButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            emptyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            emptyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            emptyLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            emptyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            stack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
    }

    @objc private func addTapped() {
        onAdd?()
    }

    @objc private func copyTapped() {
        onCopy?()
    }
}

final class ExercisePickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var onSelected: ((ExerciseVideoRow) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchBar = UISearchBar()
    private let exercises: [ExerciseVideoRow]
    private var filtered: [ExerciseVideoRow]

    init(exercises: [ExerciseVideoRow]) {
        self.exercises = exercises
        self.filtered = exercises
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Exercise"
        view.backgroundColor = UIColor(hex: "E6F1FF")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search videos"
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.layer.cornerRadius = 14
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SubtitleCell")

        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SubtitleCell")
        let exercise = filtered[indexPath.row]
        cell.textLabel?.text = exercise.title
        let mins = max(1, (exercise.duration_seconds ?? 0) / 60)
        cell.detailTextLabel?.text = "\(mins) min"
        cell.accessoryType = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exercise = filtered[indexPath.row]
        dismiss(animated: true) {
            self.onSelected?(exercise)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filtered = exercises
        } else {
            filtered = exercises.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
