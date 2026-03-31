//
//  RepeatSelectionViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 21/01/26.
//

import UIKit

final class RepeatSelectionViewController: UIViewController {
    var onSave: (([Int], Bool) -> Void)?
    var onCancel: (() -> Void)?

    private let selectedDate: Date
    private var selectedWeekdays: Set<Int>
    private var onlyThisDateSelected = false

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let onlyThisDateButton = UIButton(type: .system)
    private let daysStack = UIStackView()
    private let actionStack = UIStackView()
    private var dayButtons: [Int: UIButton] = [:]

    init(selectedDate: Date, initialWeekdays: [Int]) {
        self.selectedDate = selectedDate
        self.selectedWeekdays = Set(initialWeekdays)
        self.onlyThisDateSelected = initialWeekdays.isEmpty
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        build()
        applySelectionState()

        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }

    private func build() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Repeat Availability"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Apply this time range to:"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)

        onlyThisDateButton.translatesAutoresizingMaskIntoConstraints = false
        onlyThisDateButton.setTitle("Only this date", for: .normal)
        onlyThisDateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        onlyThisDateButton.layer.cornerRadius = 12
        onlyThisDateButton.layer.borderWidth = 1
        onlyThisDateButton.addTarget(self, action: #selector(onlyThisDateTapped), for: .touchUpInside)

        daysStack.translatesAutoresizingMaskIntoConstraints = false
        daysStack.axis = .vertical
        daysStack.spacing = 10

        let weekdaySymbols = Calendar.current.shortWeekdaySymbols
        let indices = Array(0...6)
        var buttons: [UIButton] = []
        for index in indices {
            let title = weekdaySymbols[index]
            let button = makeDayButton(title: title)
            button.tag = index
            dayButtons[index] = button
            buttons.append(button)
        }

        let rows = stride(from: 0, to: buttons.count, by: 2).map { start -> UIStackView in
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.distribution = .fillEqually
            row.translatesAutoresizingMaskIntoConstraints = false
            row.addArrangedSubview(buttons[start])
            if start + 1 < buttons.count {
                row.addArrangedSubview(buttons[start + 1])
            } else {
                row.addArrangedSubview(UIView())
            }
            return row
        }

        rows.forEach { daysStack.addArrangedSubview($0) }

        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.axis = .horizontal
        actionStack.spacing = 12
        actionStack.distribution = .fillEqually

        let cancelButton = makeActionButton(title: "Cancel", filled: false)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        let saveButton = makeActionButton(title: "Apply", filled: true)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        actionStack.addArrangedSubview(cancelButton)
        actionStack.addArrangedSubview(saveButton)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(onlyThisDateButton)
        view.addSubview(daysStack)
        view.addSubview(actionStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            onlyThisDateButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            onlyThisDateButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            onlyThisDateButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            onlyThisDateButton.heightAnchor.constraint(equalToConstant: 40),

            daysStack.topAnchor.constraint(equalTo: onlyThisDateButton.bottomAnchor, constant: 14),
            daysStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            daysStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            actionStack.topAnchor.constraint(greaterThanOrEqualTo: daysStack.bottomAnchor, constant: 16),
            actionStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            actionStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            actionStack.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    private func makeDayButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
        return button
    }

    private func makeActionButton(title: String, filled: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        if filled {
            button.backgroundColor = UITheme.Colors.accent
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UITheme.Colors.accent.cgColor
        } else {
            button.backgroundColor = .tertiarySystemFill
            button.setTitleColor(UITheme.Colors.accent, for: .normal)
            button.layer.borderColor = UITheme.Colors.accent.cgColor
        }
        return button
    }

    private func applySelectionState() {
        let isOnlyDate = onlyThisDateSelected
        onlyThisDateButton.layer.borderColor = (isOnlyDate ? UITheme.Colors.accent : UIColor.separator).cgColor
        onlyThisDateButton.backgroundColor = isOnlyDate ? UITheme.Colors.accent.withAlphaComponent(0.12) : .tertiarySystemFill
        onlyThisDateButton.setTitleColor(isOnlyDate ? UITheme.Colors.accent : .secondaryLabel, for: .normal)

        for (weekday, button) in dayButtons {
            let selected = selectedWeekdays.contains(weekday)
            button.isEnabled = !isOnlyDate
            button.layer.borderColor = selected ? UITheme.Colors.accent.cgColor : UIColor.separator.cgColor
            button.backgroundColor = selected ? UITheme.Colors.accent.withAlphaComponent(0.12) : .tertiarySystemFill
            let titleColor = selected ? UITheme.Colors.accent : .secondaryLabel
            button.setTitleColor(titleColor, for: .normal)
            button.alpha = isOnlyDate ? 0.4 : 1.0
        }
    }

    @objc private func onlyThisDateTapped() {
        onlyThisDateSelected.toggle()
        if onlyThisDateSelected {
            selectedWeekdays.removeAll()
        } else if selectedWeekdays.isEmpty {
            let weekday = Calendar.current.component(.weekday, from: selectedDate) - 1
            selectedWeekdays.insert(weekday)
        }
        applySelectionState()
    }

    @objc private func dayTapped(_ sender: UIButton) {
        guard !onlyThisDateSelected else { return }
        let weekday = sender.tag
        if selectedWeekdays.contains(weekday) {
            selectedWeekdays.remove(weekday)
        } else {
            selectedWeekdays.insert(weekday)
        }
        applySelectionState()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }

    @objc private func saveTapped() {
        let result = Array(selectedWeekdays).sorted()
        let isSingleDate = onlyThisDateSelected || result.isEmpty
        dismiss(animated: true) { [weak self] in
            self?.onSave?(result, isSingleDate)
        }
    }
}
