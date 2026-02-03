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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E6F1FF")
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
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setTitle("Create Program", for: .normal)
        createButton.setImage(UIImage(systemName: "plus"), for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        createButton.tintColor = .white
        createButton.backgroundColor = UIColor(hex: "1E6EF7")
        createButton.layer.cornerRadius = 16
        createButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 110, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 12, left: 0, bottom: 110, right: 0)
        tableView.refreshControl = refreshControl

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No programs yet."
        emptyLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        emptyLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        addSubview(createButton)
        addSubview(tableView)
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            createButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 50),

            tableView.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
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
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 6)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .black

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
        assignedLabel.textColor = UIColor.black.withAlphaComponent(0.6)

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
        topButtonsRow.spacing = 12
        topButtonsRow.distribution = .fillEqually

        assignButton.translatesAutoresizingMaskIntoConstraints = false
        assignButton.setTitle("Assign to Patients", for: .normal)
        assignButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        assignButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        assignButton.backgroundColor = UIColor(hex: "EDF4FF")
        assignButton.layer.cornerRadius = 12
        assignButton.addTarget(self, action: #selector(assignTapped), for: .touchUpInside)

        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        detailsButton.setTitle("View Details", for: .normal)
        detailsButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        detailsButton.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .normal)
        detailsButton.backgroundColor = UIColor(hex: "F3F6FB")
        detailsButton.layer.cornerRadius = 12
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete Program", for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = UIColor(hex: "E5484D")
        deleteButton.layer.cornerRadius = 12
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
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

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
        iconView.tintColor = UIColor.black.withAlphaComponent(0.55)
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.black.withAlphaComponent(0.65)
        label.text = text

        row.addArrangedSubview(iconView)
        row.addArrangedSubview(label)
        return row
    }

    private func makeChipLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.black.withAlphaComponent(0.7)
        label.backgroundColor = UIColor(hex: "F2F4F7")
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
