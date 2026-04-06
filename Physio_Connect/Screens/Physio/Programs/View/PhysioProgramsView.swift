//
//  PhysioProgramsView.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import UIKit

final class PhysioProgramsView: UIView {

    let createButton = UIButton(type: .system)
    let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let refreshControl = UIRefreshControl()
    private let headerContainer = UIView()
    private let backgroundGlow = AppBackgroundTopGlowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setRefreshing(_ refreshing: Bool) {
        if refreshing {
            if !refreshControl.isRefreshing { refreshControl.beginRefreshing() }
        } else {
            refreshControl.endRefreshing()
        }
    }

    func setRefreshTarget(_ target: Any?, action: Selector) {
        refreshControl.addTarget(target, action: action, for: .valueChanged)
    }

    func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
        tableView.isHidden = show
    }

    private func build() {

        // Fix layout: Make the create button the table header
        // so the table can be pinned to topAnchor allowing the native scrollEdgeAppearance.
        headerContainer.backgroundColor = .clear

        createButton.translatesAutoresizingMaskIntoConstraints = false
        var createConfig = UIButton.Configuration.filled()
        createConfig.title = "Create Program"
        createConfig.image = UIImage(systemName: "plus")
        createConfig.imagePadding = 6
        createConfig.baseBackgroundColor = UITheme.Colors.accent
        createConfig.baseForegroundColor = .white
        createConfig.cornerStyle = .capsule
        createConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 15, weight: .bold)
            return out
        }
        createButton.configuration = createConfig
        createButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        tableView.refreshControl = refreshControl
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.backgroundView = backgroundGlow

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No programs yet."
        emptyLabel.textColor = .tertiaryLabel
        emptyLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        addSubview(tableView)
        addSubview(emptyLabel)

        // Set as header - button takes full width with 16px side padding to match cards
        headerContainer.addSubview(createButton)
        headerContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 74) // 12 + 50 + 12 = 74
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 12),
            createButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -12)
        ])
        tableView.tableHeaderView = headerContainer

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
}

final class ProgramCardCell: UITableViewCell {
    static let reuseID = "ProgramCardCell"

    private let card = UIView()
    private let titleLabel = UILabel()
    private let statusPill = UILabel()
    private let metricsStack = UIStackView()
    private let assignedLabel = UILabel()
    private let chipsStack = UIStackView()
    private let buttonsStack = UIStackView()
    private let assignButton = UIButton(type: .system)
    private let detailsButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let topButtonsRow = UIStackView()
    private var buttonsTopToChips: NSLayoutConstraint?
    private var buttonsTopToMetrics: NSLayoutConstraint?
    private var assignedLabelHeight: NSLayoutConstraint?
    private var chipsHeight: NSLayoutConstraint?

    var onAssign: (() -> Void)?
    var onDetails: (() -> Void)?
    var onDelete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ vm: ProgramCardVM) {
        titleLabel.text = vm.title
        statusPill.text = "  \(vm.statusText)  "
        statusPill.backgroundColor = vm.statusColor
        statusPill.textColor = vm.statusTextColor

        metricsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        vm.metrics.forEach { metric in
            let row = makeMetricRow(icon: metric.icon, text: metric.text)
            metricsStack.addArrangedSubview(row)
        }

        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let hasAssignments = !vm.assignedChips.isEmpty
        assignedLabel.isHidden = !hasAssignments
        chipsStack.isHidden = !hasAssignments
        vm.assignedChips.forEach { chip in
            chipsStack.addArrangedSubview(makeChipLabel(text: chip))
        }
        if vm.assignedOverflow > 0 {
            chipsStack.addArrangedSubview(makeChipLabel(text: "+\(vm.assignedOverflow)"))
        }
        buttonsTopToChips?.isActive = hasAssignments
        buttonsTopToMetrics?.isActive = !hasAssignments
        assignedLabelHeight?.isActive = !hasAssignments
        chipsHeight?.isActive = !hasAssignments
    }

    @objc private func assignTapped() { onAssign?() }
    @objc private func detailsTapped() { onDetails?() }
    @objc private func deleteTapped() { onDelete?() }

    private func build() {
        card.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(card)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.font = .systemFont(ofSize: 12, weight: .semibold)
        statusPill.textAlignment = .center
        statusPill.layer.cornerRadius = 12
        statusPill.clipsToBounds = true

        metricsStack.translatesAutoresizingMaskIntoConstraints = false
        metricsStack.axis = .vertical
        metricsStack.spacing = 8
        metricsStack.alignment = .leading

        assignedLabel.translatesAutoresizingMaskIntoConstraints = false
        assignedLabel.text = "Assigned to:"
        assignedLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        assignedLabel.textColor = .secondaryLabel

        chipsStack.translatesAutoresizingMaskIntoConstraints = false
        chipsStack.axis = .horizontal
        chipsStack.spacing = 8
        chipsStack.alignment = .leading
        chipsStack.distribution = .fillProportionally

        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 12

        topButtonsRow.translatesAutoresizingMaskIntoConstraints = false
        topButtonsRow.axis = .horizontal
        topButtonsRow.spacing = 10
        topButtonsRow.distribution = .fillEqually

        assignButton.translatesAutoresizingMaskIntoConstraints = false
        var assignConfig = UIButton.Configuration.filled()
        assignConfig.title = "Assign to Patients"
        assignConfig.baseForegroundColor = .white
        assignConfig.baseBackgroundColor = UITheme.Colors.accent
        assignConfig.cornerStyle = .capsule
        assignConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 14, weight: .semibold)
            return out
        }
        assignButton.configuration = assignConfig
        assignButton.addTarget(self, action: #selector(assignTapped), for: .touchUpInside)

        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        var detailsConfig = UIButton.Configuration.tinted()
        detailsConfig.title = "View Details"
        detailsConfig.baseForegroundColor = .label
        detailsConfig.baseBackgroundColor = .secondarySystemFill
        detailsConfig.cornerStyle = .capsule
        detailsConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 14, weight: .semibold)
            return out
        }
        detailsButton.configuration = detailsConfig
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        var deleteConfig = UIButton.Configuration.tinted()
        deleteConfig.title = "Delete Program"
        deleteConfig.baseForegroundColor = .systemRed
        deleteConfig.baseBackgroundColor = .systemRed
        deleteConfig.cornerStyle = .capsule
        deleteConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 14, weight: .semibold)
            return out
        }
        deleteButton.configuration = deleteConfig
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        topButtonsRow.addArrangedSubview(assignButton)
        topButtonsRow.addArrangedSubview(detailsButton)
        buttonsStack.addArrangedSubview(topButtonsRow)
        buttonsStack.addArrangedSubview(deleteButton)

        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(statusPill)
        card.addSubview(metricsStack)
        card.addSubview(assignedLabel)
        card.addSubview(chipsStack)
        card.addSubview(buttonsStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusPill.leadingAnchor, constant: -8),

            statusPill.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            statusPill.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusPill.heightAnchor.constraint(equalToConstant: 24),

            metricsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            metricsStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metricsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            assignedLabel.topAnchor.constraint(equalTo: metricsStack.bottomAnchor, constant: 12),
            assignedLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            assignedLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            chipsStack.topAnchor.constraint(equalTo: assignedLabel.bottomAnchor, constant: 8),
            chipsStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            chipsStack.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -14),

            buttonsStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            topButtonsRow.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            buttonsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        buttonsTopToChips = buttonsStack.topAnchor.constraint(equalTo: chipsStack.bottomAnchor, constant: 12)
        buttonsTopToMetrics = buttonsStack.topAnchor.constraint(equalTo: metricsStack.bottomAnchor, constant: 12)
        buttonsTopToChips?.isActive = true

        assignedLabelHeight = assignedLabel.heightAnchor.constraint(equalToConstant: 0)
        chipsHeight = chipsStack.heightAnchor.constraint(equalToConstant: 0)
    }

    private func makeMetricRow(icon: String, text: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UITheme.Colors.textSecondary
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = text

        row.addArrangedSubview(iconView)
        row.addArrangedSubview(label)
        return row
    }

    private func makeChipLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.backgroundColor = UIColor.tertiarySystemFill
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center
        label.text = "  \(text)  "
        return label
    }
}

struct ProgramCardVM {
    struct Metric {
        let icon: String
        let text: String
    }

    let title: String
    let statusText: String
    let statusColor: UIColor
    let statusTextColor: UIColor
    let metrics: [Metric]
    let assignedChips: [String]
    let assignedOverflow: Int
}
