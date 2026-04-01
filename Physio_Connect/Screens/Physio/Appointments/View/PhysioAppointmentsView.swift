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

    let searchBar = UISearchBar()
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
        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGlow)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search patients or sessions..."
        searchBar.backgroundImage = UIImage()
        
        let searchField = searchBar.searchTextField
        searchField.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        searchField.layer.cornerRadius = 20
        searchField.layer.masksToBounds = true
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = searchField.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        searchField.insertSubview(blurView, at: 0)

        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = 0
        UITheme.applySegmentedStyle(segmentControl)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(PhysioAppointmentCell.self, forCellReuseIdentifier: "PhysioAppointmentCell")

        // Build table header with search + segment so tableView can be
        // pinned to topAnchor — enabling the native hovering-title glass nav bar.
        let headerContainer = UIView()
        headerContainer.backgroundColor = .clear

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.translatesAutoresizingMaskIntoConstraints = false

        headerContainer.addSubview(searchBar)
        headerContainer.addSubview(segmentControl)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),

            segmentControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            segmentControl.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),
            segmentControl.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -8)
        ])

        // Size the header to fit
        headerContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 110)
        tableView.tableHeaderView = headerContainer

        addSubview(tableView)

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor),

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
        UITheme.applyCardStyle(card)
        contentView.addSubview(card)

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.font = .systemFont(ofSize: 12, weight: .semibold)
        statusPill.textAlignment = .center
        statusPill.layer.cornerRadius = 12
        statusPill.clipsToBounds = true
        card.addSubview(statusPill)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        patientLabel.translatesAutoresizingMaskIntoConstraints = false
        patientLabel.font = .systemFont(ofSize: 14, weight: .medium)
        patientLabel.textColor = .secondaryLabel
        patientLabel.numberOfLines = 0

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        timeLabel.textColor = UITheme.Colors.accent
        timeLabel.numberOfLines = 0

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = .systemFont(ofSize: 13, weight: .medium)
        durationLabel.textColor = .tertiaryLabel
        durationLabel.numberOfLines = 0

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = .systemFont(ofSize: 13, weight: .medium)
        locationLabel.textColor = .tertiaryLabel
        locationLabel.numberOfLines = 0

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
