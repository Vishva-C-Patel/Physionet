//
//  PhysiotherapistProfileView.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//

import UIKit

final class PhysiotherapistProfileView: UIView {

    // MARK: Colors
    private let bg = UITheme.Colors.background
    private let primaryBlue = UITheme.Colors.accent

    // MARK: Scroll
    let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: Header (background)
    private let header = UIView()
    private let headerGradient = CAGradientLayer()


    private let profileCard = UIView()
    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let specializationLabel = UILabel()
    private let servicePlaceLabel = UILabel()
    private let locationIcon = UIImageView()

    private let statsDivider = UIView()

    // MARK: Consultation fee card
    private let specFeeCard = UIView()
    private let specTitle = UILabel()
    private let consultRow = UIView()
    private let consultIconContainer = UIView()
    private let consultIcon = UIImageView()
    private let consultName = UILabel()
    private let consultSubtitle = UILabel()
    private let feeValue = UILabel()

    private let statsStack = UIStackView()

    private let patientsLabel = UILabel()
    private let experienceLabel = UILabel()
    private let ratingNumLabel = UILabel()
    private let reviewsCountLabel = UILabel()

    // MARK: About
    private let aboutCard = UIView()
    private let aboutTitle = UILabel()
    private let aboutText = UILabel()

    let aboutMoreButton = UIButton(type: .system)
    private var aboutCollapsed = true
    private var needsAboutTruncationCheck = false

    // MARK: Button
    let bookButton = UIButton(type: .system)

    // MARK: Reviews header + table
    private let reviewsHeaderRow = UIView()
    private let reviewsTitle = UILabel()
    let seeAllButton = UIButton(type: .system)

    let reviewsTableView = UITableView(frame: .zero, style: .plain)
    private(set) var reviewsTableHeight: NSLayoutConstraint!

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = bg
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        headerGradient.frame = header.bounds

        if needsAboutTruncationCheck {
            needsAboutTruncationCheck = false
            updateAboutMoreVisibility()
        }
    }

    // MARK: Public
    func updateReviewsTableHeight() {
        reviewsTableView.layoutIfNeeded()
        reviewsTableHeight.constant = reviewsTableView.contentSize.height
    }

    // MARK: Stats helper (NO statItem used)
    private func makeStatCard(icon: String, label: UILabel) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = primaryBlue
        imageView.contentMode = .scaleAspectFit

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UITheme.Colors.textPrimary
        label.numberOfLines = 2
        label.textAlignment = .center

        container.addSubview(imageView)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    // MARK: Build UI
    private func build() {

        // Scroll
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Header (IMPORTANT: add to hierarchy)
        header.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(header)

        headerGradient.colors = [
            UITheme.Colors.accent.cgColor,
            UITheme.Colors.accent.withAlphaComponent(0.8).cgColor
        ]
        header.layer.insertSublayer(headerGradient, at: 0)

        // Profile card
        profileCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(profileCard)
        contentView.addSubview(profileCard)

        // Avatar
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 14
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFill
        avatar.backgroundColor = UITheme.Colors.neutralFill
        avatar.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
        avatar.tintColor = .lightGray

        // Name + specialization + location
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textColor = UITheme.Colors.textPrimary

        specializationLabel.translatesAutoresizingMaskIntoConstraints = false
        specializationLabel.font = .systemFont(ofSize: 14, weight: .medium)
        specializationLabel.textColor = UITheme.Colors.textSecondary

        servicePlaceLabel.translatesAutoresizingMaskIntoConstraints = false
        servicePlaceLabel.font = .systemFont(ofSize: 13, weight: .medium)
        servicePlaceLabel.textColor = UITheme.Colors.textMuted

        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.image = UIImage(systemName: "mappin.and.ellipse")
        locationIcon.tintColor = UITheme.Colors.textMuted

        statsDivider.translatesAutoresizingMaskIntoConstraints = false
        statsDivider.backgroundColor = UIColor.clear

        [avatar, nameLabel, specializationLabel, locationIcon, servicePlaceLabel, statsDivider].forEach { profileCard.addSubview($0) }

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: contentView.topAnchor),
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 160),


            profileCard.topAnchor.constraint(equalTo: header.bottomAnchor, constant: -46),
            profileCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            avatar.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 16),
            avatar.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: 16),
            avatar.widthAnchor.constraint(equalToConstant: 56),
            avatar.heightAnchor.constraint(equalToConstant: 56),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatar.topAnchor, constant: 2),

            specializationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specializationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            specializationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            locationIcon.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationIcon.topAnchor.constraint(equalTo: specializationLabel.bottomAnchor, constant: 6),
            locationIcon.widthAnchor.constraint(equalToConstant: 14),
            locationIcon.heightAnchor.constraint(equalToConstant: 14),

            servicePlaceLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 6),
            servicePlaceLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            servicePlaceLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            statsDivider.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 14),
            statsDivider.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 16),
            statsDivider.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -16),
            statsDivider.heightAnchor.constraint(equalToConstant: 0)
        ])

        // Stats card moved into profileCard
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.alignment = .center
        statsStack.spacing = 10
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        let rView  = makeStatCard(icon: "star.fill", label: ratingNumLabel)
        let pView  = makeStatCard(icon: "person.2.fill", label: patientsLabel)
        let eView  = makeStatCard(icon: "rosette", label: experienceLabel)

        [rView, pView, eView].forEach { statsStack.addArrangedSubview($0) }
        profileCard.addSubview(statsStack)

        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: statsDivider.bottomAnchor, constant: 12),
            statsStack.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 14),
            statsStack.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -14),
            statsStack.bottomAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: -16)
        ])

        // About card (expandable) — FIXED ORDER (prevents crash)
        aboutCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(aboutCard)

        aboutTitle.translatesAutoresizingMaskIntoConstraints = false
        aboutTitle.text = "About"
        aboutTitle.font = .boldSystemFont(ofSize: 18)
        aboutTitle.textColor = UITheme.Colors.textPrimary

        aboutText.translatesAutoresizingMaskIntoConstraints = false
        aboutText.font = .systemFont(ofSize: 13)
        aboutText.textColor = UITheme.Colors.textSecondary
        aboutText.numberOfLines = 3

        aboutMoreButton.translatesAutoresizingMaskIntoConstraints = false
        aboutMoreButton.setTitle("Read more", for: .normal)
        aboutMoreButton.setTitleColor(primaryBlue, for: .normal)
        aboutMoreButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        aboutMoreButton.isHidden = true

        // Add subviews BEFORE constraints
        aboutCard.addSubview(aboutTitle)
        aboutCard.addSubview(aboutText)
        aboutCard.addSubview(aboutMoreButton)
        contentView.addSubview(aboutCard)

        NSLayoutConstraint.activate([
            aboutCard.topAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: 16),
            aboutCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            aboutCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            aboutTitle.topAnchor.constraint(equalTo: aboutCard.topAnchor, constant: 16),
            aboutTitle.leadingAnchor.constraint(equalTo: aboutCard.leadingAnchor, constant: 16),
            aboutTitle.trailingAnchor.constraint(equalTo: aboutCard.trailingAnchor, constant: -16),

            aboutText.topAnchor.constraint(equalTo: aboutTitle.bottomAnchor, constant: 10),
            aboutText.leadingAnchor.constraint(equalTo: aboutCard.leadingAnchor, constant: 16),
            aboutText.trailingAnchor.constraint(equalTo: aboutCard.trailingAnchor, constant: -16),

            aboutMoreButton.topAnchor.constraint(equalTo: aboutText.bottomAnchor, constant: 10),
            aboutMoreButton.leadingAnchor.constraint(equalTo: aboutCard.leadingAnchor, constant: 16),
            aboutMoreButton.bottomAnchor.constraint(equalTo: aboutCard.bottomAnchor, constant: -14)
        ])

        // Consultation fee card
        specFeeCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(specFeeCard)

        specTitle.text = "Consultation Fee"
        specTitle.font = .systemFont(ofSize: 16, weight: .bold)
        specTitle.textColor = UITheme.Colors.textPrimary
        specTitle.translatesAutoresizingMaskIntoConstraints = false

        consultRow.translatesAutoresizingMaskIntoConstraints = false
        consultRow.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
        consultRow.layer.cornerRadius = 14

        consultIconContainer.translatesAutoresizingMaskIntoConstraints = false
        consultIconContainer.backgroundColor = UITheme.Colors.accent
        consultIconContainer.layer.cornerRadius = 18

        consultIcon.translatesAutoresizingMaskIntoConstraints = false
        consultIcon.image = UIImage(systemName: "clock")
        consultIcon.tintColor = .white

        consultName.translatesAutoresizingMaskIntoConstraints = false
        consultName.text = "Consultation"
        consultName.font = .systemFont(ofSize: 14, weight: .semibold)
        consultName.textColor = UITheme.Colors.textPrimary

        consultSubtitle.translatesAutoresizingMaskIntoConstraints = false
        consultSubtitle.text = "Per hour session"
        consultSubtitle.font = .systemFont(ofSize: 12, weight: .medium)
        consultSubtitle.textColor = UITheme.Colors.textMuted

        feeValue.font = .systemFont(ofSize: 16, weight: .bold)
        feeValue.textColor = UITheme.Colors.textPrimary
        feeValue.translatesAutoresizingMaskIntoConstraints = false

        consultIconContainer.addSubview(consultIcon)
        consultRow.addSubview(consultIconContainer)
        consultRow.addSubview(consultName)
        consultRow.addSubview(consultSubtitle)
        consultRow.addSubview(feeValue)
        specFeeCard.addSubview(specTitle)
        specFeeCard.addSubview(consultRow)
        contentView.addSubview(specFeeCard)

        NSLayoutConstraint.activate([
            specFeeCard.topAnchor.constraint(equalTo: aboutCard.bottomAnchor, constant: 16),
            specFeeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            specFeeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            specTitle.topAnchor.constraint(equalTo: specFeeCard.topAnchor, constant: 16),
            specTitle.leadingAnchor.constraint(equalTo: specFeeCard.leadingAnchor, constant: 16),
            specTitle.trailingAnchor.constraint(equalTo: specFeeCard.trailingAnchor, constant: -16),

            consultRow.topAnchor.constraint(equalTo: specTitle.bottomAnchor, constant: 12),
            consultRow.leadingAnchor.constraint(equalTo: specFeeCard.leadingAnchor, constant: 16),
            consultRow.trailingAnchor.constraint(equalTo: specFeeCard.trailingAnchor, constant: -16),
            consultRow.bottomAnchor.constraint(equalTo: specFeeCard.bottomAnchor, constant: -16),

            consultIconContainer.leadingAnchor.constraint(equalTo: consultRow.leadingAnchor, constant: 12),
            consultIconContainer.centerYAnchor.constraint(equalTo: consultRow.centerYAnchor),
            consultIconContainer.widthAnchor.constraint(equalToConstant: 36),
            consultIconContainer.heightAnchor.constraint(equalToConstant: 36),

            consultIcon.centerXAnchor.constraint(equalTo: consultIconContainer.centerXAnchor),
            consultIcon.centerYAnchor.constraint(equalTo: consultIconContainer.centerYAnchor),
            consultIcon.widthAnchor.constraint(equalToConstant: 18),
            consultIcon.heightAnchor.constraint(equalToConstant: 18),

            consultName.leadingAnchor.constraint(equalTo: consultIconContainer.trailingAnchor, constant: 12),
            consultName.topAnchor.constraint(equalTo: consultRow.topAnchor, constant: 10),
            consultName.trailingAnchor.constraint(lessThanOrEqualTo: feeValue.leadingAnchor, constant: -12),

            consultSubtitle.leadingAnchor.constraint(equalTo: consultName.leadingAnchor),
            consultSubtitle.topAnchor.constraint(equalTo: consultName.bottomAnchor, constant: 2),
            consultSubtitle.bottomAnchor.constraint(equalTo: consultRow.bottomAnchor, constant: -10),

            feeValue.trailingAnchor.constraint(equalTo: consultRow.trailingAnchor, constant: -12),
            feeValue.centerYAnchor.constraint(equalTo: consultRow.centerYAnchor)
        ])

        // Book button (solid pill)
        bookButton.translatesAutoresizingMaskIntoConstraints = false
        bookButton.setTitle("Book Appointment", for: .normal)
        bookButton.setTitleColor(.white, for: .normal)
        bookButton.setTitleColor(.white, for: .highlighted)
        bookButton.setTitleColor(.white, for: .disabled)
        bookButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        bookButton.backgroundColor = UITheme.Colors.accent
        bookButton.layer.cornerRadius = 26
        bookButton.clipsToBounds = true

        contentView.addSubview(bookButton)

        NSLayoutConstraint.activate([
            bookButton.topAnchor.constraint(equalTo: specFeeCard.bottomAnchor, constant: 18),
            bookButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bookButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bookButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // Reviews header row
        reviewsHeaderRow.translatesAutoresizingMaskIntoConstraints = false
        reviewsTitle.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false

        reviewsTitle.text = "Reviews"
        reviewsTitle.font = .boldSystemFont(ofSize: 18)
        reviewsTitle.textColor = UITheme.Colors.textPrimary

        seeAllButton.setTitle("See All  >", for: .normal)
        seeAllButton.setTitleColor(primaryBlue, for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)

        reviewsHeaderRow.addSubview(reviewsTitle)
        reviewsHeaderRow.addSubview(seeAllButton)
        contentView.addSubview(reviewsHeaderRow)

        NSLayoutConstraint.activate([
            reviewsHeaderRow.topAnchor.constraint(equalTo: bookButton.bottomAnchor, constant: 18),
            reviewsHeaderRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewsHeaderRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            reviewsTitle.topAnchor.constraint(equalTo: reviewsHeaderRow.topAnchor),
            reviewsTitle.leadingAnchor.constraint(equalTo: reviewsHeaderRow.leadingAnchor),
            reviewsTitle.bottomAnchor.constraint(equalTo: reviewsHeaderRow.bottomAnchor),

            seeAllButton.centerYAnchor.constraint(equalTo: reviewsTitle.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: reviewsHeaderRow.trailingAnchor)
        ])

        // Reviews Table
        reviewsTableView.translatesAutoresizingMaskIntoConstraints = false
        reviewsTableView.backgroundColor = .clear
        reviewsTableView.separatorStyle = .none
        reviewsTableView.isScrollEnabled = false
        reviewsTableView.showsVerticalScrollIndicator = false
        reviewsTableView.rowHeight = UITableView.automaticDimension
        reviewsTableView.estimatedRowHeight = 110
        reviewsTableView.contentInset = .zero

        reviewsTableView.register(PhysioReviewCell.self,
                                  forCellReuseIdentifier: PhysioReviewCell.reuseID)

        contentView.addSubview(reviewsTableView)

        reviewsTableHeight = reviewsTableView.heightAnchor.constraint(equalToConstant: 10)
        reviewsTableHeight.isActive = true

        NSLayoutConstraint.activate([
            reviewsTableView.topAnchor.constraint(equalTo: reviewsHeaderRow.bottomAnchor, constant: 12),
            reviewsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    // MARK: Configure UI
    func configure(with model: PhysiotherapistProfileModel) {
        nameLabel.text = model.name
        specializationLabel.text = model.specializationText
        servicePlaceLabel.text = model.servicePlaceText

        consultSubtitle.text = "Per hour session"
        feeValue.text = model.consultationFeeText

        ratingNumLabel.text = model.ratingNumberText
        patientsLabel.text = model.patientsText
        experienceLabel.text = model.experienceText

        setAboutText(model.about)
    }

    func setAvatarImage(_ image: UIImage?) {
        if let image {
            avatar.image = image
            avatar.tintColor = .clear
        } else {
            avatar.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
            avatar.tintColor = .white
        }
    }

    // MARK: About expand/collapse
    func setAboutText(_ text: String) {
        aboutText.text = text
        aboutText.numberOfLines = 3
        aboutCollapsed = true
        aboutMoreButton.setTitle("Read more", for: .normal)
        aboutMoreButton.isHidden = true

        // check truncation after layout has correct width
        needsAboutTruncationCheck = true
        setNeedsLayout()
    }

    private func updateAboutMoreVisibility() {
        aboutMoreButton.isHidden = !aboutText.isTruncated(maxLines: 3)
    }

    func toggleAbout() {
        aboutCollapsed.toggle()
        aboutText.numberOfLines = aboutCollapsed ? 3 : 0
        aboutMoreButton.setTitle(aboutCollapsed ? "Read more" : "Show less", for: .normal)

        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UILabel truncation helper
private extension UILabel {
    func isTruncated(maxLines: Int) -> Bool {
        guard let text = self.text, let font = self.font else { return false }
        let width = bounds.width
        if width <= 0 { return false }

        let fullHeight = text.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        ).height

        let maxHeight = CGFloat(maxLines) * font.lineHeight
        return fullHeight > maxHeight + 2
    }
}
