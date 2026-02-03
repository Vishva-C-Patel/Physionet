//
//  HomeHeroCardView.swift
//  Physio_Connect
//
//  Created by Ayush Rai on 31/12/25.
//

import UIKit

final class HomeHeroCardView: UIView {

    enum State {
        case bookHomeVisit
        case upcoming(HomeUpcomingAppointment)
    }

    // MARK: - UI

    private let container = UIView()
    private let backgroundGradient = CAGradientLayer()
    private let bubbleLarge = UIView()
    private let bubbleSmall = UIView()
    private let featureCircle = UIView()
    private let featureIcon = UIImageView()

    // Top: calendar badge + pill
    private let topRow = UIStackView()
    private let badgeIconWrap = UIView()
    private let badgeIcon = UIImageView()

    private let pill = UIView()
    private let pillLabel = UILabel()
    private let pillIcon = UIImageView()

    // Main content row
    private let contentRow = UIStackView()
    private let avatarWrap = UIView()
    private let avatarIcon = UIImageView()
    private var avatarImagePath: String?

    private let textStack = UIStackView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()

    // ✅ Wrap metaStack so we can hide it without collapsing spacing weirdly
    private let metaContainer = UIView()
    private let metaStack = UIStackView()
    private let dateRow = MetaRow(icon: "calendar", text: "")
    private let timeRow = MetaRow(icon: "clock", text: "")

    // Button
    let primaryButton = UIButton(type: .system)
    private let buttonChevron = UIImageView()

    private var gradientLayer: CAGradientLayer?
    private var contentTopToTopRowConstraint: NSLayoutConstraint?
    private var contentTopToContainerConstraint: NSLayoutConstraint?
    private var buttonTopConstraint: NSLayoutConstraint?
    private var usesWhiteButton = false

    private var currentState: State = .bookHomeVisit

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        apply(state: .bookHomeVisit)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Build

    private func build() {
        backgroundColor = .clear

        // Container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 22
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 14
        container.layer.shadowOffset = CGSize(width: 0, height: 8)
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])

        bubbleLarge.translatesAutoresizingMaskIntoConstraints = false
        bubbleLarge.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        bubbleLarge.layer.cornerRadius = 90
        bubbleLarge.isHidden = true

        bubbleSmall.translatesAutoresizingMaskIntoConstraints = false
        bubbleSmall.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        bubbleSmall.layer.cornerRadius = 44
        bubbleSmall.isHidden = true

        featureCircle.translatesAutoresizingMaskIntoConstraints = false
        featureCircle.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        featureCircle.layer.cornerRadius = 32
        featureCircle.isHidden = true

        featureIcon.translatesAutoresizingMaskIntoConstraints = false
        featureIcon.image = UIImage(systemName: "calendar")
        featureIcon.tintColor = .white
        featureCircle.addSubview(featureIcon)

        container.addSubview(bubbleLarge)
        container.addSubview(bubbleSmall)
        container.addSubview(featureCircle)

        NSLayoutConstraint.activate([
            bubbleLarge.widthAnchor.constraint(equalToConstant: 180),
            bubbleLarge.heightAnchor.constraint(equalToConstant: 180),
            bubbleLarge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 40),
            bubbleLarge.topAnchor.constraint(equalTo: container.topAnchor, constant: -30),

            bubbleSmall.widthAnchor.constraint(equalToConstant: 88),
            bubbleSmall.heightAnchor.constraint(equalToConstant: 88),
            bubbleSmall.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -36),
            bubbleSmall.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 20),

            featureCircle.widthAnchor.constraint(equalToConstant: 64),
            featureCircle.heightAnchor.constraint(equalToConstant: 64),
            featureCircle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            featureCircle.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            featureIcon.centerXAnchor.constraint(equalTo: featureCircle.centerXAnchor),
            featureIcon.centerYAnchor.constraint(equalTo: featureCircle.centerYAnchor)
        ])

        // --- Top row ---
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 12
        topRow.translatesAutoresizingMaskIntoConstraints = false

        badgeIconWrap.translatesAutoresizingMaskIntoConstraints = false
        badgeIconWrap.backgroundColor = UIColor(hex: "1E6EF7").withAlphaComponent(0.12)
        badgeIconWrap.layer.cornerRadius = 18

        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeIcon.image = UIImage(systemName: "calendar")
        badgeIcon.tintColor = UIColor(hex: "1E6EF7")
        badgeIcon.contentMode = .scaleAspectFit

        badgeIconWrap.addSubview(badgeIcon)

        NSLayoutConstraint.activate([
            badgeIconWrap.widthAnchor.constraint(equalToConstant: 36),
            badgeIconWrap.heightAnchor.constraint(equalToConstant: 36),

            badgeIcon.centerXAnchor.constraint(equalTo: badgeIconWrap.centerXAnchor),
            badgeIcon.centerYAnchor.constraint(equalTo: badgeIconWrap.centerYAnchor),
            badgeIcon.widthAnchor.constraint(equalToConstant: 18),
            badgeIcon.heightAnchor.constraint(equalToConstant: 18)
        ])

        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.14)
        pill.layer.cornerRadius = 14

        pillIcon.translatesAutoresizingMaskIntoConstraints = false
        pillIcon.image = UIImage(systemName: "clock")
        pillIcon.tintColor = UIColor.systemGreen
        pillIcon.contentMode = .scaleAspectFit

        pillLabel.translatesAutoresizingMaskIntoConstraints = false
        pillLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        pillLabel.textColor = UIColor.systemGreen
        pillLabel.text = "Upcoming"

        pill.addSubview(pillIcon)
        pill.addSubview(pillLabel)

        NSLayoutConstraint.activate([
            pillIcon.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 10),
            pillIcon.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            pillIcon.widthAnchor.constraint(equalToConstant: 14),
            pillIcon.heightAnchor.constraint(equalToConstant: 14),

            pillLabel.leadingAnchor.constraint(equalTo: pillIcon.trailingAnchor, constant: 6),
            pillLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),
            pillLabel.topAnchor.constraint(equalTo: pill.topAnchor, constant: 6),
            pillLabel.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -6)
        ])

        topRow.addArrangedSubview(badgeIconWrap)
        topRow.addArrangedSubview(pill)

        // --- Content row ---
        contentRow.axis = .horizontal
        contentRow.alignment = .top
        contentRow.spacing = 12
        contentRow.translatesAutoresizingMaskIntoConstraints = false

        avatarWrap.translatesAutoresizingMaskIntoConstraints = false
        avatarWrap.backgroundColor = UIColor(hex: "1E6EF7").withAlphaComponent(0.16)
        avatarWrap.layer.cornerRadius = 30
        avatarWrap.clipsToBounds = true

        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
        avatarIcon.tintColor = UIColor(hex: "1E6EF7")
        avatarIcon.contentMode = .scaleAspectFill
        avatarIcon.clipsToBounds = true

        avatarWrap.addSubview(avatarIcon)

        NSLayoutConstraint.activate([
            avatarWrap.widthAnchor.constraint(equalToConstant: 60),
            avatarWrap.heightAnchor.constraint(equalToConstant: 60),

            avatarIcon.topAnchor.constraint(equalTo: avatarWrap.topAnchor),
            avatarIcon.leadingAnchor.constraint(equalTo: avatarWrap.leadingAnchor),
            avatarIcon.trailingAnchor.constraint(equalTo: avatarWrap.trailingAnchor),
            avatarIcon.bottomAnchor.constraint(equalTo: avatarWrap.bottomAnchor)
        ])

        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 2

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.55)
        subtitleLabel.numberOfLines = 2

        // Meta stack
        metaStack.axis = .vertical
        metaStack.spacing = 6
        metaStack.translatesAutoresizingMaskIntoConstraints = false
        metaStack.addArrangedSubview(dateRow)
        metaStack.addArrangedSubview(timeRow)

        metaContainer.translatesAutoresizingMaskIntoConstraints = false
        metaContainer.addSubview(metaStack)

        NSLayoutConstraint.activate([
            metaStack.topAnchor.constraint(equalTo: metaContainer.topAnchor),
            metaStack.leadingAnchor.constraint(equalTo: metaContainer.leadingAnchor),
            metaStack.trailingAnchor.constraint(equalTo: metaContainer.trailingAnchor),
            metaStack.bottomAnchor.constraint(equalTo: metaContainer.bottomAnchor)
        ])

        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(subtitleLabel)
        textStack.addArrangedSubview(metaContainer)

        contentRow.addArrangedSubview(avatarWrap)
        contentRow.addArrangedSubview(textStack)

        // --- Button ---
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.setTitle("View Details", for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        primaryButton.layer.cornerRadius = 14
        primaryButton.clipsToBounds = true
        primaryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        buttonChevron.translatesAutoresizingMaskIntoConstraints = false
        buttonChevron.image = UIImage(systemName: "chevron.right")
        buttonChevron.tintColor = .white

        primaryButton.addSubview(buttonChevron)

        NSLayoutConstraint.activate([
            buttonChevron.centerYAnchor.constraint(equalTo: primaryButton.centerYAnchor),
            buttonChevron.trailingAnchor.constraint(equalTo: primaryButton.trailingAnchor, constant: -16)
        ])

        // Add to container
        container.addSubview(topRow)
        container.addSubview(contentRow)
        container.addSubview(primaryButton)

        contentTopToTopRowConstraint = contentRow.topAnchor.constraint(equalToSystemSpacingBelow: topRow.bottomAnchor, multiplier: 1.0)
        contentTopToContainerConstraint = contentRow.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor)
        contentTopToContainerConstraint?.isActive = false
        buttonTopConstraint = primaryButton.topAnchor.constraint(equalTo: contentRow.bottomAnchor, constant: 12)

        let contentTrailing = contentRow.trailingAnchor.constraint(lessThanOrEqualTo: container.layoutMarginsGuide.trailingAnchor)
        contentTrailing.priority = .defaultHigh

        let buttonLeading = primaryButton.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor)
        buttonLeading.priority = .defaultHigh
        let buttonTrailing = primaryButton.trailingAnchor.constraint(lessThanOrEqualTo: container.layoutMarginsGuide.trailingAnchor)
        buttonTrailing.priority = .defaultHigh

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            topRow.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            topRow.trailingAnchor.constraint(lessThanOrEqualTo: container.layoutMarginsGuide.trailingAnchor),

            contentTopToTopRowConstraint!,
            contentRow.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            contentTrailing,
            // ✅ Button always visible at bottom
            buttonLeading,
            buttonTrailing,
            primaryButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 48),
            primaryButton.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor),

            // ✅ Keep fixed spacing between content and button
            buttonTopConstraint!
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyButtonGradient()
        if backgroundGradient.superlayer != nil {
            backgroundGradient.frame = container.bounds
            backgroundGradient.cornerRadius = container.layer.cornerRadius
        }
    }

    private func applyButtonGradient() {
        gradientLayer?.removeFromSuperlayer()

        if usesWhiteButton {
            primaryButton.backgroundColor = .white
            primaryButton.layer.borderWidth = 0
            return
        }

        let g = CAGradientLayer()
        g.frame = primaryButton.bounds
        g.cornerRadius = primaryButton.layer.cornerRadius
        g.colors = [
            UIColor(hex: "1E6EF7").cgColor,
            UIColor(hex: "4E8CFF").cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint = CGPoint(x: 1, y: 0.5)

        primaryButton.layer.insertSublayer(g, at: 0)
        gradientLayer = g
    }

    // MARK: - State

    func apply(state: State) {
        currentState = state

        switch state {

        case .bookHomeVisit:
            usesWhiteButton = true
            topRow.isHidden = true
            pill.isHidden = true
            setAvatarImage(nil, path: nil)

            nameLabel.text = "Book Home Visits"
            subtitleLabel.text = "Get certified physiotherapy at your doorstep"
            nameLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
            avatarWrap.isHidden = true
            bubbleLarge.isHidden = false
            bubbleSmall.isHidden = false
            featureCircle.isHidden = false
            container.backgroundColor = .clear
            backgroundGradient.colors = [
                UIColor(hex: "19C5F7").cgColor,
                UIColor(hex: "2C6BFF").cgColor
            ]
            backgroundGradient.startPoint = CGPoint(x: 0, y: 0.2)
            backgroundGradient.endPoint = CGPoint(x: 1, y: 1)
            if backgroundGradient.superlayer == nil {
                container.layer.insertSublayer(backgroundGradient, at: 0)
            }

            // ✅ Hide meta cleanly
            metaContainer.isHidden = true
            contentTopToTopRowConstraint?.isActive = false
            contentTopToContainerConstraint?.isActive = true
            buttonTopConstraint?.constant = 8

            primaryButton.setTitle("Book Appointment", for: .normal)
            primaryButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
            primaryButton.layer.shadowColor = UIColor.black.cgColor
            primaryButton.layer.shadowOpacity = 0.12
            primaryButton.layer.shadowRadius = 8
            primaryButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            buttonChevron.isHidden = true

        case .upcoming(let appt):
            usesWhiteButton = true
            topRow.isHidden = false
            pill.isHidden = false
            pillLabel.text = "Upcoming"
            badgeIconWrap.isHidden = true

            nameLabel.text = appt.physioName

            subtitleLabel.text = appt.specializationText
            nameLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
            avatarWrap.isHidden = false
            bubbleLarge.isHidden = false
            bubbleSmall.isHidden = false
            featureCircle.isHidden = false
            container.backgroundColor = .clear
            backgroundGradient.colors = [
                UIColor(hex: "19C5F7").cgColor,
                UIColor(hex: "2C6BFF").cgColor
            ]
            backgroundGradient.startPoint = CGPoint(x: 0, y: 0.2)
            backgroundGradient.endPoint = CGPoint(x: 1, y: 1)
            if backgroundGradient.superlayer == nil {
                container.layer.insertSublayer(backgroundGradient, at: 0)
            }

            pill.backgroundColor = UIColor(hex: "C7F5D7")
            pillIcon.tintColor = UIColor(hex: "1C7B3B")
            pillLabel.textColor = UIColor(hex: "1C7B3B")

            dateRow.setStyle(iconColor: UIColor.white.withAlphaComponent(0.9),
                             textColor: UIColor.white.withAlphaComponent(0.95))
            timeRow.setStyle(iconColor: UIColor.white.withAlphaComponent(0.9),
                             textColor: UIColor.white.withAlphaComponent(0.95))
            metaContainer.isHidden = false
            contentTopToContainerConstraint?.isActive = false
            contentTopToTopRowConstraint?.isActive = true
            buttonTopConstraint?.constant = 12

            let df1 = DateFormatter()
            df1.dateFormat = "EEEE, dd MMM"

            let df2 = DateFormatter()
            df2.dateFormat = "h:mm a"

            dateRow.setText(df1.string(from: appt.startTime))
            timeRow.setText(df2.string(from: appt.startTime))

            primaryButton.setTitle("View Details", for: .normal)
            primaryButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
            primaryButton.layer.shadowColor = UIColor.black.cgColor
            primaryButton.layer.shadowOpacity = 0.12
            primaryButton.layer.shadowRadius = 8
            primaryButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            buttonChevron.isHidden = true
        }

        // ✅ Force refresh so button doesn’t get “stuck”
        setNeedsLayout()
        layoutIfNeeded()
    }

    func setAvatarImage(_ image: UIImage?, path: String?) {
        avatarImagePath = path
        if let image {
            avatarIcon.image = image
            avatarIcon.tintColor = .clear
        } else {
            avatarIcon.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
            avatarIcon.tintColor = UIColor(hex: "1E6EF7")
        }
    }

    func isAvatarPath(_ path: String?) -> Bool {
        avatarImagePath == path
    }
}

// MARK: - MetaRow (icon + text)

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

    func setStyle(iconColor: UIColor, textColor: UIColor) {
        iconView.tintColor = iconColor
        label.textColor = textColor
    }

    private func build(icon: String, text: String) {
        translatesAutoresizingMaskIntoConstraints = false

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = UIColor(hex: "1E6EF7")
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])

        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor.black.withAlphaComponent(0.75)

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
