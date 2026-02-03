//
//  PhysioAppointmentsView.swift
//  Physio_Connect
//
//  Created by Codex on 11/01/26.
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

    let searchBar = UISearchBar()
    let segmentControl = UISegmentedControl(items: ["All", "Upcoming", "Completed"])
    let tableView = UITableView(frame: .zero, style: .plain)

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        backgroundColor = UIColor(hex: "E6F1FF")

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search patients or sessions..."

        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = UIColor(hex: "1E6EF7")
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black.withAlphaComponent(0.65)], for: .normal)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(PhysioAppointmentCell.self, forCellReuseIdentifier: "PhysioAppointmentCell")

        addSubview(searchBar)
        addSubview(segmentControl)
        addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            segmentControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            segmentControl.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 34),

            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 12),
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
    private let patientLabel = UILabel()
    private let timeLabel = UILabel()
    private let durationLabel = UILabel()
    private let locationLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let completeButton = UIButton(type: .system)
    private let buttonStack = UIStackView()
    private var buttonStackBottomConstraint: NSLayoutConstraint?
    private var buttonStackHeightConstraint: NSLayoutConstraint?
    private var locationBottomConstraint: NSLayoutConstraint?

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
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.addSubview(card)

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.font = .systemFont(ofSize: 12, weight: .semibold)
        statusPill.textAlignment = .center
        statusPill.layer.cornerRadius = 12
        statusPill.clipsToBounds = true
        card.addSubview(statusPill)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "102A43")

        patientLabel.translatesAutoresizingMaskIntoConstraints = false
        patientLabel.font = .systemFont(ofSize: 14, weight: .medium)
        patientLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        patientLabel.numberOfLines = 0

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        timeLabel.textColor = UIColor(hex: "1E6EF7")
        timeLabel.numberOfLines = 0

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = .systemFont(ofSize: 13, weight: .medium)
        durationLabel.textColor = UIColor.black.withAlphaComponent(0.55)
        durationLabel.numberOfLines = 0

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = .systemFont(ofSize: 13, weight: .medium)
        locationLabel.textColor = UIColor.black.withAlphaComponent(0.55)
        locationLabel.numberOfLines = 0

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        cancelButton.backgroundColor = UIColor(hex: "FCE4E4")
        cancelButton.setTitleColor(UIColor(hex: "E53935"), for: .normal)
        cancelButton.layer.cornerRadius = 12
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.setTitle("Completed", for: .normal)
        completeButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        completeButton.backgroundColor = UIColor(hex: "E6F1FF")
        completeButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        completeButton.layer.cornerRadius = 12
        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)

        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(completeButton)

        card.addSubview(titleLabel)
        card.addSubview(patientLabel)
        card.addSubview(timeLabel)
        card.addSubview(durationLabel)
        card.addSubview(locationLabel)
        card.addSubview(buttonStack)

        buttonStackHeightConstraint = buttonStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        buttonStackBottomConstraint = buttonStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        locationBottomConstraint = locationLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)

        var constraints: [NSLayoutConstraint] = [
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            statusPill.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            statusPill.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            statusPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
            statusPill.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusPill.leadingAnchor, constant: -8),

            patientLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            patientLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            patientLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            timeLabel.topAnchor.constraint(equalTo: patientLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            durationLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 6),
            durationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            locationLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 6),
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            buttonStack.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12)
        ]

        if let buttonStackHeightConstraint {
            constraints.append(buttonStackHeightConstraint)
        }
        if let buttonStackBottomConstraint {
            constraints.append(buttonStackBottomConstraint)
        }

        NSLayoutConstraint.activate(constraints)

        locationBottomConstraint?.isActive = false
    }

    func apply(_ vm: PhysioAppointmentsView.AppointmentVM) {
        titleLabel.text = vm.title
        patientLabel.text = vm.patientName
        timeLabel.text = vm.timeText
        durationLabel.text = vm.durationText
        locationLabel.text = vm.locationText
        statusPill.text = "  \(vm.status.text)  "
        statusPill.backgroundColor = vm.status.pillBg
        statusPill.textColor = vm.status.pillText

        let showsActions = vm.isActionable
        buttonStack.isHidden = !showsActions
        buttonStackHeightConstraint?.isActive = showsActions
        buttonStackBottomConstraint?.isActive = showsActions
        locationBottomConstraint?.isActive = !showsActions
    }

    @objc private func cancelTapped() {
        onCancelTapped?()
    }

    @objc private func completeTapped() {
        onCompleteTapped?()
    }
}
