//
//  UpcomingAppointmentCardView.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//
import UIKit

final class UpcomingAppointmentCardView: UIView {

    // MARK: - UI

    private let container = UIView()

    private let topRow = UIStackView()
    private let leadingBadgeIcon = UIView()
    private let badgeIconImage = UIImageView()

    private let upcomingPill = UIView()
    private let upcomingLabel = UILabel()

    private let contentRow = UIStackView()

    private let avatarCircle = UIView()
    private let avatarIcon = UIImageView()
    private var avatarImagePath: String?

    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let metaStack = UIStackView()
    private let dateRow = MetaRow(icon: "calendar", text: "")
    private let timeRow = MetaRow(icon: "clock", text: "")

    let actionButton = UIButton(type: .system)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Public

    struct ViewModel {
        let doctorName: String
        let subtitle: String
        let dateText: String
        let timeText: String
        let buttonTitle: String
    }

    func configure(with vm: ViewModel) {
        nameLabel.text = vm.doctorName
        subtitleLabel.text = vm.subtitle
        dateRow.setText(vm.dateText)
        timeRow.setText(vm.timeText)
        actionButton.setTitle(vm.buttonTitle, for: .normal)
    }

    func setAvatarImage(_ image: UIImage?, path: String?) {
        avatarImagePath = path
        if let image {
            avatarIcon.image = image
            avatarIcon.tintColor = .clear
        } else {
            avatarIcon.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
            avatarIcon.tintColor = UIColor.systemBlue
        }
    }

    func isAvatarPath(_ path: String?) -> Bool {
        avatarImagePath == path
    }

    // MARK: - Build

    private func build() {
        backgroundColor = .clear

        // Container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.systemBackground
        container.layer.cornerRadius = 22
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 14
        container.layer.shadowOffset = CGSize(width: 0, height: 8)

        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Top row: calendar badge + pill
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 10
        topRow.translatesAutoresizingMaskIntoConstraints = false

        leadingBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        leadingBadgeIcon.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        leadingBadgeIcon.layer.cornerRadius = 18

        badgeIconImage.translatesAutoresizingMaskIntoConstraints = false
        badgeIconImage.image = UIImage(systemName: "calendar")
        badgeIconImage.tintColor = UIColor.systemBlue
        badgeIconImage.contentMode = .scaleAspectFit

        leadingBadgeIcon.addSubview(badgeIconImage)

        NSLayoutConstraint.activate([
            leadingBadgeIcon.widthAnchor.constraint(equalToConstant: 36),
            leadingBadgeIcon.heightAnchor.constraint(equalToConstant: 36),

            badgeIconImage.centerXAnchor.constraint(equalTo: leadingBadgeIcon.centerXAnchor),
            badgeIconImage.centerYAnchor.constraint(equalTo: leadingBadgeIcon.centerYAnchor)
        ])

        upcomingPill.translatesAutoresizingMaskIntoConstraints = false
        upcomingPill.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.14)
        upcomingPill.layer.cornerRadius = 14

        upcomingLabel.translatesAutoresizingMaskIntoConstraints = false
        upcomingLabel.text = "Upcoming"
        upcomingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        upcomingLabel.textColor = UIColor.systemGreen

        upcomingPill.addSubview(upcomingLabel)
        NSLayoutConstraint.activate([
            upcomingLabel.leadingAnchor.constraint(equalTo: upcomingPill.leadingAnchor, constant: 12),
            upcomingLabel.trailingAnchor.constraint(equalTo: upcomingPill.trailingAnchor, constant: -12),
            upcomingLabel.topAnchor.constraint(equalTo: upcomingPill.topAnchor, constant: 6),
            upcomingLabel.bottomAnchor.constraint(equalTo: upcomingPill.bottomAnchor, constant: -6)
        ])

        topRow.addArrangedSubview(leadingBadgeIcon)
        topRow.addArrangedSubview(upcomingPill)

        // Content row
        contentRow.axis = .horizontal
        contentRow.alignment = .top
        contentRow.spacing = 14
        contentRow.translatesAutoresizingMaskIntoConstraints = false

        // Avatar circle (stethoscope icon)
        avatarCircle.translatesAutoresizingMaskIntoConstraints = false
        avatarCircle.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.18)
        avatarCircle.layer.cornerRadius = 30

        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
        avatarIcon.tintColor = UIColor.systemBlue
        avatarIcon.contentMode = .scaleAspectFill
        avatarIcon.clipsToBounds = true

        avatarCircle.addSubview(avatarIcon)
        NSLayoutConstraint.activate([
            avatarCircle.widthAnchor.constraint(equalToConstant: 60),
            avatarCircle.heightAnchor.constraint(equalToConstant: 60),

            avatarIcon.topAnchor.constraint(equalTo: avatarCircle.topAnchor),
            avatarIcon.leadingAnchor.constraint(equalTo: avatarCircle.leadingAnchor),
            avatarIcon.trailingAnchor.constraint(equalTo: avatarCircle.trailingAnchor),
            avatarIcon.bottomAnchor.constraint(equalTo: avatarCircle.bottomAnchor)
        ])

        // Right stack (name, subtitle, meta)
        let rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.spacing = 10
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .label

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel

        metaStack.axis = .vertical
        metaStack.spacing = 8
        metaStack.translatesAutoresizingMaskIntoConstraints = false
        metaStack.addArrangedSubview(dateRow)
        metaStack.addArrangedSubview(timeRow)

        rightStack.addArrangedSubview(nameLabel)
        rightStack.addArrangedSubview(subtitleLabel)
        rightStack.addArrangedSubview(metaStack)

        contentRow.addArrangedSubview(avatarCircle)
        contentRow.addArrangedSubview(rightStack)

        // Button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle("View Details", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        actionButton.backgroundColor = UIColor.systemBlue
        actionButton.layer.cornerRadius = 14

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .white
        chevron.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addSubview(chevron)

        NSLayoutConstraint.activate([
            chevron.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: -16)
        ])

        // Layout inside container
        container.addSubview(topRow)
        container.addSubview(contentRow)
        container.addSubview(actionButton)

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            topRow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            topRow.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),

            contentRow.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 14),
            contentRow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            contentRow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            actionButton.topAnchor.constraint(equalTo: contentRow.bottomAnchor, constant: 16),
            actionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 52),
            actionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Small row (icon + text)

private final class MetaRow: UIView {

    private let iconView = UIImageView()
    private let label = UILabel()
    private let stack = UIStackView()

    init(icon: String, text: String) {
        super.init(frame: .zero)
        build(icon: icon, text: text)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setText(_ text: String) {
        label.text = text
    }

    private func build(icon: String, text: String) {
        translatesAutoresizingMaskIntoConstraints = false

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = UIColor.systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])

        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
