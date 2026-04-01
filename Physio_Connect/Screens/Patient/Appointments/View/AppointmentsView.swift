//
//  AppointmentsView.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//

import UIKit

final class AppointmentsView: UIView {

    // MARK: - Callbacks (MVC friendly)
    var onProfileTapped: (() -> Void)?
    var onCancelTapped: ((UpcomingCardVM) -> Void)?
    var onRescheduleTapped: ((UpcomingCardVM) -> Void)?
    var onBookTapped: (() -> Void)?

    // Completed actions (per row)
    var onCompletedRebookTapped: ((CompletedAppointmentVM) -> Void)?
    var onCompletedReportTapped: ((CompletedAppointmentVM) -> Void)?
    var onCompletedReviewTapped: ((CompletedAppointmentVM) -> Void)?

    // MARK: - UI
    let profileButton = UIButton(type: .system)

    let segmented = UISegmentedControl(items: ["Upcoming", "Completed"])

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Cards (Upcoming tab)
    private let upcomingListStack = UIStackView()
    private var upcomingCardMap: [UUID: UpcomingAppointmentTabCardView] = [:]
    let bookCard = BookHomeVisitsCardView()
    private var hasUpcoming = false

    // Completed list (Completed tab)
    let completedList = CompletedAppointmentsListView()

    // MARK: - Init
    private let backgroundGlow = AppBackgroundTopGlowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        build()
        wireActions()
        applyDefaultUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func applyDefaultUI() {
        segmented.selectedSegmentIndex = 0
        UITheme.applySegmentedStyle(segmented)

        upcomingListStack.isHidden = false
        bookCard.isHidden = false
        completedList.isHidden = true
        
        // Force layout for immediate segmented selection rendering
        self.layoutIfNeeded()
    }

    private func wireActions() {
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        bookCard.bookButton.addTarget(self, action: #selector(bookTapped), for: .touchUpInside)

        // completed per-row callbacks
        completedList.onRebookTapped = { [weak self] vm in
            self?.onCompletedRebookTapped?(vm)
        }
        completedList.onReportTapped = { [weak self] vm in
            self?.onCompletedReportTapped?(vm)
        }
        completedList.onReviewTapped = { [weak self] vm in
            self?.onCompletedReviewTapped?(vm)
        }
    }

    private func build() {
        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGlow)

        // Segmented control
        segmented.translatesAutoresizingMaskIntoConstraints = false
        addSubview(segmented)

        // Scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // Add views into stack
        upcomingListStack.axis = .vertical
        upcomingListStack.spacing = 12
        upcomingListStack.translatesAutoresizingMaskIntoConstraints = false
        upcomingListStack.isLayoutMarginsRelativeArrangement = true
        upcomingListStack.directionalLayoutMargins = .zero

        bookCard.translatesAutoresizingMaskIntoConstraints = false
        completedList.translatesAutoresizingMaskIntoConstraints = false

        contentStack.addArrangedSubview(upcomingListStack)
        contentStack.addArrangedSubview(bookCard)
        contentStack.addArrangedSubview(completedList)

        upcomingListStack.setContentHuggingPriority(.required, for: .vertical)
        upcomingListStack.setContentCompressionResistancePriority(.required, for: .vertical)

        // Layout

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor),

            segmented.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 18),
            segmented.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmented.heightAnchor.constraint(equalToConstant: 36),

            scrollView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),

            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    // MARK: - Public API (Controller calls these)

    struct UpcomingCardVM {
        let appointmentID: UUID
        let physioID: UUID
        let dateTimeText: String
        let physioName: String
        let ratingText: String
        let distanceText: String
        let specializationText: String
        let feeText: String
        let image: UIImage?
    }

    func setUpcoming(_ vms: [UpcomingCardVM]) {
        upcomingListStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        upcomingCardMap.removeAll()

        hasUpcoming = !vms.isEmpty
        upcomingListStack.isHidden = vms.isEmpty

        var cards: [UIView] = []
        for vm in vms {
            let card = UpcomingAppointmentTabCardView()
            card.apply(vm: vm)
            card.onCancel = { [weak self] in
                self?.onCancelTapped?(vm)
            }
            card.onReschedule = { [weak self] in
                self?.onRescheduleTapped?(vm)
            }
            upcomingListStack.addArrangedSubview(card)
            upcomingCardMap[vm.appointmentID] = card
            cards.append(card)
        }

        animateCards(cards)
    }

    private func animateCards(_ cards: [UIView]) {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        for (index, card) in cards.enumerated() {
            card.alpha = 0.0
            card.transform = CGAffineTransform(translationX: 0, y: 12)
            UIView.animate(withDuration: 0.45,
                           delay: 0.04 * Double(index),
                           options: [.curveEaseOut]) {
                card.alpha = 1.0
                card.transform = .identity
            }
        }
    }

    func setCancelEnabled(_ enabled: Bool, appointmentID: UUID) {
        if let card = upcomingCardMap[appointmentID] {
            card.setCancelEnabled(enabled)
        }
    }

    func setCompleted(_ items: [CompletedAppointmentVM]) {
        completedList.set(items: items)
    }

    // MARK: - Actions
    @objc private func profileTapped() { onProfileTapped?() }
    @objc private func bookTapped() { onBookTapped?() }

    @objc private func segmentChanged() {
        let isUpcoming = segmented.selectedSegmentIndex == 0

        upcomingListStack.isHidden = !(isUpcoming && hasUpcoming)
        bookCard.isHidden = !isUpcoming
        completedList.isHidden = isUpcoming
    }
}

// MARK: - UpcomingAppointmentTabCardView (your working card)

final class UpcomingAppointmentTabCardView: UIView {

    private let container = UIView()
    private let chipsRow = UIStackView()
    private let statusChip = PillLabel()
    private let timeChip = PillLabel()

    private let cardRow = UIStackView()
    private let avatar = UIImageView()
    private let initialsLabel = UILabel()

    private let infoStack = UIStackView()
    private let nameLabel = UILabel()

    private let ratingRow = UILabel()
    private let distanceRow = UILabel()
    private let specRow = UILabel()
    private let feeRow = UILabel()

    private let buttonsRow = UIStackView()
    let cancelButton = UIButton(type: .system)
    let rescheduleButton = UIButton(type: .system)
    var onCancel: (() -> Void)?
    var onReschedule: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        container.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(container)
        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        chipsRow.axis = .horizontal
        chipsRow.alignment = .center
        chipsRow.spacing = 8
        chipsRow.translatesAutoresizingMaskIntoConstraints = false

        statusChip.font = .systemFont(ofSize: 12, weight: .semibold)
        statusChip.textColor = UITheme.Colors.accent
        statusChip.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
        statusChip.text = "Upcoming"
        statusChip.setContentHuggingPriority(.required, for: .horizontal)

        timeChip.font = .systemFont(ofSize: 12, weight: .semibold)
        timeChip.textColor = UITheme.Colors.textSecondary
        timeChip.backgroundColor = UITheme.Colors.neutralFill
        timeChip.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        chipsRow.addArrangedSubview(statusChip)
        chipsRow.addArrangedSubview(timeChip)

        cardRow.axis = .horizontal
        cardRow.alignment = .top
        cardRow.spacing = 10
        cardRow.translatesAutoresizingMaskIntoConstraints = false

        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 10
        avatar.backgroundColor = .tertiarySystemFill

        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = .systemFont(ofSize: 24, weight: .bold)
        initialsLabel.textColor = UITheme.Colors.accent
        initialsLabel.textAlignment = .center
        initialsLabel.isHidden = true
        
        cardRow.addArrangedSubview(avatar)
        container.addSubview(cardRow)
        container.addSubview(initialsLabel)

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 76),
            avatar.heightAnchor.constraint(equalToConstant: 76),
            initialsLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
        ])

        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = UITheme.Colors.textPrimary

        [ratingRow, distanceRow, specRow, feeRow].forEach {
            $0.font = .systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = UITheme.Colors.textSecondary
            $0.numberOfLines = 1
        }

        specRow.textColor = UITheme.Colors.accent
        feeRow.textColor = UITheme.Colors.accent

        infoStack.addArrangedSubview(nameLabel)
        infoStack.addArrangedSubview(specRow)
        infoStack.addArrangedSubview(ratingRow)
        infoStack.addArrangedSubview(distanceRow)
        infoStack.addArrangedSubview(feeRow)

        // avatar already added in cardRow above
        cardRow.addArrangedSubview(infoStack)

        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 10
        buttonsRow.distribution = .fillEqually
        buttonsRow.translatesAutoresizingMaskIntoConstraints = false

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.layer.cornerRadius = 20
        cancelButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        rescheduleButton.setTitle("Reschedule", for: .normal)
        rescheduleButton.backgroundColor = UITheme.Colors.accent
        rescheduleButton.setTitleColor(.white, for: .normal)
        rescheduleButton.layer.cornerRadius = 20
        rescheduleButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        rescheduleButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        rescheduleButton.addTarget(self, action: #selector(rescheduleTapped), for: .touchUpInside)

        buttonsRow.addArrangedSubview(cancelButton)
        buttonsRow.addArrangedSubview(rescheduleButton)

        container.addSubview(chipsRow)
        // cardRow already added in container above
        container.addSubview(buttonsRow)

        NSLayoutConstraint.activate([
            chipsRow.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            chipsRow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            chipsRow.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -12),

            cardRow.topAnchor.constraint(equalTo: chipsRow.bottomAnchor, constant: 10),
            cardRow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            cardRow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            buttonsRow.topAnchor.constraint(equalTo: cardRow.bottomAnchor, constant: 12),
            buttonsRow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            buttonsRow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            buttonsRow.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
        ])
    }

    func apply(vm: AppointmentsView.UpcomingCardVM) {
        timeChip.text = vm.dateTimeText
        nameLabel.text = vm.physioName
        ratingRow.text = vm.ratingText
        distanceRow.text = vm.distanceText
        specRow.text = vm.specializationText
        feeRow.text = vm.feeText
        if let image = vm.image {
            avatar.image = image
            avatar.backgroundColor = .clear
            initialsLabel.isHidden = true
        } else {
            avatar.image = nil
            avatar.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
            initialsLabel.text = UITheme.getInitials(from: vm.physioName)
            initialsLabel.isHidden = false
        }
    }

    func setCancelEnabled(_ enabled: Bool) {
        cancelButton.isEnabled = enabled
        cancelButton.alpha = enabled ? 1.0 : 0.6
    }

    @objc private func cancelTapped() { onCancel?() }
    @objc private func rescheduleTapped() { onReschedule?() }
}

// MARK: - BookHomeVisitsCardView

final class BookHomeVisitsCardView: UIView {

    private let container = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    let bookButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        container.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(container)
        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Book home visits"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UITheme.Colors.textPrimary

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Get certified physiotherapy at your doorsteps"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        subtitleLabel.textColor = UITheme.Colors.textSecondary
        subtitleLabel.numberOfLines = 2

        bookButton.translatesAutoresizingMaskIntoConstraints = false
        bookButton.setTitle("Book appointment", for: .normal)
        bookButton.setTitleColor(.white, for: .normal)
        bookButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        bookButton.backgroundColor = UITheme.Colors.accent
        bookButton.layer.cornerRadius = 20
        bookButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(bookButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            bookButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            bookButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            bookButton.widthAnchor.constraint(equalToConstant: 150),
            bookButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
}

// =======================================================
// ✅ COMPLETED SEGMENT UI BELOW
// =======================================================

struct CompletedAppointmentVM {
    enum Status {
        case completed
        case cancelled
        case cancelledByPhysio

        var text: String {
            switch self {
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            case .cancelledByPhysio: return "Cancelled by Physio"
            }
        }

        var pillBg: UIColor {
            switch self {
            case .completed: return UIColor.systemGreen.withAlphaComponent(0.15)
            case .cancelled, .cancelledByPhysio: return UIColor.systemRed.withAlphaComponent(0.15)
            }
        }

        var pillText: UIColor {
            switch self {
            case .completed: return .systemGreen
            case .cancelled, .cancelledByPhysio: return .systemRed
            }
        }

        var pillBorder: UIColor {
            switch self {
            case .completed: return UIColor.systemGreen.withAlphaComponent(0.3)
            case .cancelled, .cancelledByPhysio: return UIColor.systemRed.withAlphaComponent(0.3)
            }
        }
    }

    let appointmentID: UUID
    let physioID: UUID
    let status: Status

    let physioName: String
    let ratingText: String
    let distanceText: String
    let specializationText: String
    let feeText: String
    let image: UIImage?
}

final class CompletedAppointmentsListView: UIView, UITableViewDataSource, UITableViewDelegate {

    var onRebookTapped: ((CompletedAppointmentVM) -> Void)?
    var onReportTapped: ((CompletedAppointmentVM) -> Void)?
    var onReviewTapped: ((CompletedAppointmentVM) -> Void)?

    private let table = UITableView(frame: .zero, style: .plain)
    private var items: [CompletedAppointmentVM] = []
    private var heightConstraint: NSLayoutConstraint?
    private var animatedRows = Set<Int>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.isScrollEnabled = false
        table.register(CompletedAppointmentCell.self, forCellReuseIdentifier: "CompletedAppointmentCell")
        addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: topAnchor),
            table.leadingAnchor.constraint(equalTo: leadingAnchor),
            table.trailingAnchor.constraint(equalTo: trailingAnchor),
            table.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
    }

    func set(items: [CompletedAppointmentVM]) {
        self.items = items
        animatedRows.removeAll()
        table.reloadData()
        let totalHeight = items.reduce(CGFloat(0)) { partial, vm in
            partial + (vm.status == .completed ? 280 : 230)
        }
        heightConstraint?.constant = totalHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedAppointmentCell", for: indexPath) as! CompletedAppointmentCell
        cell.apply(vm: vm)

        cell.onRebook = { [weak self] in self?.onRebookTapped?(vm) }
        cell.onReport = { [weak self] in self?.onReportTapped?(vm) }
        cell.onReview = { [weak self] in self?.onReviewTapped?(vm) }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        items[indexPath.row].status == .completed ? 280 : 230
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        guard animatedRows.insert(indexPath.row).inserted else { return }

        cell.alpha = 0.0
        cell.transform = CGAffineTransform(translationX: 0, y: 12)
        UIView.animate(withDuration: 0.45, delay: 0.04 * Double(indexPath.row), options: [.curveEaseOut]) {
            cell.alpha = 1.0
            cell.transform = .identity
        }
    }
}

final class CompletedAppointmentCell: UITableViewCell {

    var onRebook: (() -> Void)?
    var onReport: (() -> Void)?
    var onReview: (() -> Void)?

    private let card = UIView()

    private let statusPill = UIView()
    private let statusRow = UIStackView()
    private let statusIcon = UIImageView()
    private let statusLabel = UILabel()

    private let headerRow = UIStackView()
    private let avatar = UIImageView()
    private let initialsLabel = UILabel()

    private let infoStack = UIStackView()
    private let nameLabel = UILabel()
    private let ratingLabel = UILabel()
    private let distanceLabel = UILabel()
    private let specLabel = UILabel()
    private let feeLabel = UILabel()

    private let buttonsRow = UIStackView()
    private let rebookButton = UIButton(type: .system)
    private let reportButton = UIButton(type: .system)
    private let reviewButton = UIButton(type: .system)
    private var reviewButtonHeightConstraint: NSLayoutConstraint?
    private var reviewButtonTopConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        card.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(card)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.layer.cornerRadius = UITheme.Metrics.chipCornerRadius
        statusPill.layer.borderWidth = 1

        statusRow.axis = .horizontal
        statusRow.alignment = .center
        statusRow.spacing = 6
        statusRow.translatesAutoresizingMaskIntoConstraints = false

        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.contentMode = .scaleAspectFit
        statusIcon.tintColor = .secondaryLabel
        NSLayoutConstraint.activate([
            statusIcon.widthAnchor.constraint(equalToConstant: 14),
            statusIcon.heightAnchor.constraint(equalToConstant: 14)
        ])

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textAlignment = .left
        statusLabel.numberOfLines = 1

        statusRow.addArrangedSubview(statusIcon)
        statusRow.addArrangedSubview(statusLabel)
        statusPill.addSubview(statusRow)

        NSLayoutConstraint.activate([
            statusRow.topAnchor.constraint(equalTo: statusPill.topAnchor, constant: 6),
            statusRow.bottomAnchor.constraint(equalTo: statusPill.bottomAnchor, constant: -6),
            statusRow.leadingAnchor.constraint(equalTo: statusPill.leadingAnchor, constant: 12),
            statusRow.trailingAnchor.constraint(equalTo: statusPill.trailingAnchor, constant: -12)
        ])

        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = 14
        headerRow.translatesAutoresizingMaskIntoConstraints = false

        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = .tertiarySystemFill
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 14

        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = .systemFont(ofSize: 24, weight: .bold)
        initialsLabel.textColor = UITheme.Colors.accent
        initialsLabel.textAlignment = .center
        initialsLabel.isHidden = true

        headerRow.addArrangedSubview(avatar)
        card.addSubview(headerRow)
        card.addSubview(initialsLabel)

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 78),
            avatar.heightAnchor.constraint(equalToConstant: 78),
            initialsLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
        ])

        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = UITheme.Colors.textPrimary

        [ratingLabel, distanceLabel, specLabel].forEach {
            $0.font = .systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = UITheme.Colors.textSecondary
            $0.numberOfLines = 1
        }

        specLabel.textColor = UITheme.Colors.accent
        feeLabel.font = .systemFont(ofSize: 13, weight: .bold)
        feeLabel.textColor = UITheme.Colors.accent
        feeLabel.numberOfLines = 1

        infoStack.addArrangedSubview(nameLabel)
        infoStack.addArrangedSubview(specLabel)
        infoStack.addArrangedSubview(ratingLabel)
        infoStack.addArrangedSubview(distanceLabel)
        infoStack.addArrangedSubview(feeLabel)

        // avatar already added in headerRow above
        headerRow.addArrangedSubview(infoStack)

        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 10
        buttonsRow.distribution = .fillEqually
        buttonsRow.translatesAutoresizingMaskIntoConstraints = false

        rebookButton.setTitle("Re-book", for: .normal)
        rebookButton.backgroundColor = UITheme.Colors.accent
        rebookButton.setTitleColor(.white, for: .normal)
        rebookButton.layer.cornerRadius = 20
        rebookButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        rebookButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        rebookButton.addTarget(self, action: #selector(rebookTapped), for: .touchUpInside)

        reportButton.setTitle("View Report", for: .normal)
        reportButton.backgroundColor = UITheme.Colors.neutralFill
        reportButton.setTitleColor(UITheme.Colors.accent, for: .normal)
        reportButton.layer.cornerRadius = 20
        reportButton.layer.borderWidth = 0
        reportButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        reportButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)

        buttonsRow.addArrangedSubview(rebookButton)
        buttonsRow.addArrangedSubview(reportButton)

        reviewButton.setTitle("Rate & Review", for: .normal)
        reviewButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        reviewButton.setTitleColor(.systemOrange, for: .normal)
        reviewButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        reviewButton.layer.cornerRadius = 20
        reviewButton.layer.borderWidth = 1
        reviewButton.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.3).cgColor
        reviewButton.titleLabel?.font = UITheme.Typography.buttonSmall
        reviewButton.translatesAutoresizingMaskIntoConstraints = false
        reviewButton.addTarget(self, action: #selector(reviewTapped), for: .touchUpInside)

        card.addSubview(statusPill)
        // headerRow already added in card above
        card.addSubview(buttonsRow)
        card.addSubview(reviewButton)

        reviewButtonHeightConstraint = reviewButton.heightAnchor.constraint(equalToConstant: 40)
        reviewButtonTopConstraint = reviewButton.topAnchor.constraint(equalTo: buttonsRow.bottomAnchor, constant: 10)
        reviewButtonHeightConstraint?.isActive = true
        reviewButtonTopConstraint?.isActive = true

        NSLayoutConstraint.activate([
            statusPill.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            statusPill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            statusPill.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -10),
            statusPill.heightAnchor.constraint(equalToConstant: 26),

            headerRow.topAnchor.constraint(equalTo: statusPill.bottomAnchor, constant: 10),
            headerRow.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            headerRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),

            buttonsRow.topAnchor.constraint(equalTo: headerRow.bottomAnchor, constant: 12),
            buttonsRow.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            buttonsRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),

            reviewButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            reviewButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            reviewButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
    }

    func apply(vm: CompletedAppointmentVM) {
        statusPill.backgroundColor = vm.status.pillBg
        statusLabel.textColor = vm.status.pillText
        statusLabel.text = vm.status.text
        statusPill.layer.borderColor = vm.status.pillBorder.cgColor
        let iconName: String = {
            switch vm.status {
            case .completed: return "checkmark.circle.fill"
            case .cancelled: return "xmark.circle.fill"
            case .cancelledByPhysio: return "xmark.circle.fill"
            }
        }()
        statusIcon.image = UIImage(systemName: iconName)
        statusIcon.tintColor = vm.status.pillText

        if let image = vm.image {
            avatar.image = image
            avatar.backgroundColor = .clear
            initialsLabel.isHidden = true
        } else {
            avatar.image = nil
            avatar.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
            initialsLabel.text = UITheme.getInitials(from: vm.physioName)
            initialsLabel.isHidden = false
        }
        nameLabel.text = vm.physioName
        ratingLabel.text = vm.ratingText
        distanceLabel.text = vm.distanceText
        specLabel.text = vm.specializationText
        feeLabel.text = vm.feeText

        let showReview = vm.status == .completed
        reviewButton.isHidden = !showReview
        reviewButtonHeightConstraint?.constant = showReview ? 40 : 0
        reviewButtonTopConstraint?.constant = showReview ? 10 : 0
    }

    @objc private func rebookTapped() { onRebook?() }
    @objc private func reportTapped() { onReport?() }
    @objc private func reviewTapped() { onReview?() }
}
