//
//  CreateProgramViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import UIKit

final class CreateProgramViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var onProgramCreated: ((String?) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .plain)
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
        UITheme.applyNativeNavBar(to: self, title: "Create New Program")
        view.backgroundColor = UITheme.Colors.background
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
        tableView.register(ProgramInfoCardCell.self, forCellReuseIdentifier: ProgramInfoCardCell.reuseID)
        tableView.register(ProgramDayCell.self, forCellReuseIdentifier: ProgramDayCell.reuseID)
        tableView.register(ProgramEmptyScheduleCell.self, forCellReuseIdentifier: ProgramEmptyScheduleCell.reuseID)
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
        bottomBar.backgroundColor = .secondarySystemGroupedBackground

        var cancelConfig = UIButton.Configuration.tinted()
        cancelConfig.title = "Cancel"
        cancelConfig.baseForegroundColor = .label
        cancelConfig.baseBackgroundColor = .secondarySystemFill
        cancelConfig.cornerStyle = .capsule
        cancelButton.configuration = cancelConfig
        cancelButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        var createConfig = UIButton.Configuration.filled()
        createConfig.title = "Create Program"
        createConfig.baseBackgroundColor = UITheme.Colors.accent
        createConfig.baseForegroundColor = .white
        createConfig.cornerStyle = .capsule
        createButton.configuration = createConfig
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
            return 1
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgramInfoCardCell.reuseID, for: indexPath) as? ProgramInfoCardCell else {
                return UITableViewCell()
            }
            cell.configure(nameField: nameField, durationField: durationField, perDayField: perDayField)
            return cell
        case .schedule:
            if dayPlans.isEmpty {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgramEmptyScheduleCell.reuseID, for: indexPath) as? ProgramEmptyScheduleCell else {
                    return UITableViewCell()
                }
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
        
        let container = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        switch sectionType {
        case .info:
            label.text = "PROGRAM DETAILS"
            return container
        case .schedule:
            label.text = "DAILY EXERCISES"
            return container
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
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

final class ProgramInfoCardCell: UITableViewCell {
    static let reuseID = "ProgramInfoCardCell"
    private let card = UIView()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func makeFieldRow(title: String, field: UITextField) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let fieldBg = UIView()
        fieldBg.translatesAutoresizingMaskIntoConstraints = false
        fieldBg.backgroundColor = .secondarySystemFill
        fieldBg.layer.cornerRadius = 10
        fieldBg.layer.masksToBounds = true
        fieldBg.layer.borderWidth = 0.5
        fieldBg.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        
        field.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(fieldBg)
        fieldBg.addSubview(field)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            fieldBg.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            fieldBg.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            fieldBg.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            fieldBg.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            fieldBg.heightAnchor.constraint(equalToConstant: 44),
            
            field.leadingAnchor.constraint(equalTo: fieldBg.leadingAnchor, constant: 12),
            field.trailingAnchor.constraint(equalTo: fieldBg.trailingAnchor, constant: -12),
            field.centerYAnchor.constraint(equalTo: fieldBg.centerYAnchor)
        ])
        return container
    }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear
        
        card.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(card)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        
        contentView.addSubview(card)
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }

    func configure(nameField: UITextField, durationField: UITextField, perDayField: UITextField) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(makeFieldRow(title: "Program Name *", field: nameField))
        stack.addArrangedSubview(makeFieldRow(title: "Program Duration (days)", field: durationField))
        stack.addArrangedSubview(makeFieldRow(title: "Exercises Per Day", field: perDayField))
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
                label.textColor = .label
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
        UITheme.applyCardStyle(card)
        contentView.addSubview(card)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

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
        emptyLabel.textColor = .secondaryLabel

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

final class ProgramEmptyScheduleCell: UITableViewCell {
    static let reuseID = "ProgramEmptyScheduleCell"
    private let card = UIView()
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        card.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(card)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Set program duration and exercises per day to build each day."
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        
        contentView.addSubview(card)
        card.addSubview(label)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
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
        view.backgroundColor = UITheme.Colors.background
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search videos"
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
