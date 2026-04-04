//
//  PhysioAppointmentsView.swift
//  Physio_Connect
//
//  Created by user@8 on 11/01/26.
//

import UIKit

final class PhysioAppointmentsView: UIView {
    struct AppointmentVM {
        let id: UUID
        let status: Status
        let title: String
        let patientName: String
        let timeText: String
        let durationText: String
        let locationText: String
        let isActionable: Bool
    }

    enum Status {
        case upcoming
        case completed
        case cancelled
        case cancelledByPhysio

        var text: String {
            switch self {
            case .upcoming: return "Upcoming"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            case .cancelledByPhysio: return "Cancelled by Physio"
            }
        }

        var pillBg: UIColor {
            switch self {
            case .upcoming: return UIColor(hex: "E6F5EA")
            case .completed: return UIColor(hex: "E6F1FF")
            case .cancelled, .cancelledByPhysio: return UIColor(hex: "FCE4E4")
            }
        }

        var pillText: UIColor {
            switch self {
            case .upcoming: return UIColor(hex: "2E7D32")
            case .completed: return UIColor(hex: "1E6EF7")
            case .cancelled, .cancelledByPhysio: return UIColor(hex: "E53935")
            }
        }
    }

    let segmentControl = UISegmentedControl(items: ["All", "Upcoming", "Completed"])
    let tableView = UITableView(frame: .zero, style: .plain)

    private let backgroundGlow = AppBackgroundTopGlowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = 0
        UITheme.applySegmentedStyle(segmentControl)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(PhysioAppointmentCell.self, forCellReuseIdentifier: "PhysioAppointmentCell")
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.backgroundView = backgroundGlow

        // Build table header with search + segment so tableView can be
        // pinned to topAnchor — enabling the native hovering-title glass nav bar.
        let headerContainer = UIView()
        headerContainer.backgroundColor = .clear

        headerContainer.addSubview(segmentControl)

        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),
            segmentControl.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -12)
        ])

        // Size the header to fit
        headerContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
        tableView.tableHeaderView = headerContainer

        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

final class PhysioAppointmentCell: UITableViewCell {
    private let card = UIView()
    private let statusPill = UILabel()
    private let titleLabel = UILabel()
    private let metricsStack = UIStackView()
    private let cancelButton = UIButton(type: .system)
    private let completeButton = UIButton(type: .system)
    private let buttonStack = UIStackView()
    private var buttonStackBottomConstraint: NSLayoutConstraint?
    private var buttonStackHeightConstraint: NSLayoutConstraint?
    private var metricsBottomConstraint: NSLayoutConstraint?

    var onCancelTapped: (() -> Void)?
    var onCompleteTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(card)
        contentView.addSubview(card)

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.font = .systemFont(ofSize: 12, weight: .semibold)
        statusPill.textAlignment = .center
        statusPill.layer.cornerRadius = 12
        statusPill.clipsToBounds = true
        card.addSubview(statusPill)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        card.addSubview(titleLabel)

        metricsStack.translatesAutoresizingMaskIntoConstraints = false
        metricsStack.axis = .vertical
        metricsStack.spacing = 8
        metricsStack.alignment = .leading
        card.addSubview(metricsStack)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        var cancelConfig = UIButton.Configuration.tinted()
        cancelConfig.title = "Cancel"
        cancelConfig.baseForegroundColor = UIColor(hex: "E53935")
        cancelConfig.baseBackgroundColor = UIColor(hex: "E53935")
        cancelConfig.cornerStyle = .capsule
        cancelButton.configuration = cancelConfig
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        completeButton.translatesAutoresizingMaskIntoConstraints = false
        var completeConfig = UIButton.Configuration.filled()
        completeConfig.title = "Completed"
        completeConfig.baseForegroundColor = .white
        completeConfig.baseBackgroundColor = UITheme.Colors.accent
        completeConfig.cornerStyle = .capsule
        completeButton.configuration = completeConfig
        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)

        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(completeButton)
        card.addSubview(buttonStack)

        buttonStackHeightConstraint = buttonStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        buttonStackBottomConstraint = buttonStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        metricsBottomConstraint = metricsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)

        var constraints: [NSLayoutConstraint] = [
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            statusPill.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            statusPill.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            statusPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
            statusPill.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusPill.leadingAnchor, constant: -8),

            metricsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            metricsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            metricsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            buttonStack.topAnchor.constraint(equalTo: metricsStack.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            buttonStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ]

        if let buttonStackHeightConstraint {
            constraints.append(buttonStackHeightConstraint)
        }
        if let buttonStackBottomConstraint {
            constraints.append(buttonStackBottomConstraint)
        }

        NSLayoutConstraint.activate(constraints)

        metricsBottomConstraint?.isActive = false
    }

    func apply(_ vm: PhysioAppointmentsView.AppointmentVM) {
        titleLabel.text = vm.title
        statusPill.text = "  \(vm.status.text)  "
        statusPill.backgroundColor = vm.status.pillBg
        statusPill.textColor = vm.status.pillText

        metricsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metricsStack.addArrangedSubview(makeMetricRow(icon: "person.fill", text: vm.patientName, color: .secondaryLabel))
        metricsStack.addArrangedSubview(makeMetricRow(icon: "clock.fill", text: vm.timeText, color: UITheme.Colors.accent))
        metricsStack.addArrangedSubview(makeMetricRow(icon: "hourglass", text: vm.durationText, color: .secondaryLabel))
        if !vm.locationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metricsStack.addArrangedSubview(makeMetricRow(icon: "mappin.and.ellipse", text: vm.locationText, color: .secondaryLabel))
        }

        let showsActions = vm.isActionable
        buttonStack.isHidden = !showsActions
        buttonStackHeightConstraint?.isActive = showsActions
        buttonStackBottomConstraint?.isActive = showsActions
        metricsBottomConstraint?.isActive = !showsActions
    }

    private func makeMetricRow(icon: String, text: String, color: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true

        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = color
        label.text = text
        label.numberOfLines = 0

        row.addArrangedSubview(iconView)
        row.addArrangedSubview(label)
        return row
    }

    @objc private func cancelTapped() {
        onCancelTapped?()
    }

    @objc private func completeTapped() {
        onCompleteTapped?()
    }
}
