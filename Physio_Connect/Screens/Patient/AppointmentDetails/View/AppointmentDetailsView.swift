//
//  AppointmentDetailsView.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//
import UIKit

final class AppointmentDetailsView: UIView {

    private let backgroundGlow = AppBackgroundTopGlowView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Doctor card
    private let doctorCard = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let ratingLabel = UILabel()
    private let specLabel = UILabel()
    private let feeLabel = UILabel()

    private let actionStack = UIStackView()
    let messageButton = UIButton(type: .system)
    let callButton = UIButton(type: .system)

    // Summary card
    private let summaryCard = UIView()
    private let summaryTitleLabel = UILabel()

    private let dateTitleLabel = UILabel()
    private let locationTitleLabel = UILabel()
    private let statusTitleLabel = UILabel()

    private let dateValueLabel = UILabel()
    private let locationValueLabel = UILabel()
    private let statusValueLabel = UILabel()

    // Notes card
    private let notesCard = UIView()
    private let notesTitleLabel = UILabel()
    let notesTextView = UITextView()
    private let notesMinHeight: CGFloat = 140
    private var notesHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UITheme.Colors.background
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func cardStyle(_ v: UIView) {
        UITheme.applyCardStyle(v)
    }

    private func build() {
        // Scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .always
        
        contentView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        
        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(backgroundGlow, at: 0)
        
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor),

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

        // Doctor Card
        doctorCard.translatesAutoresizingMaskIntoConstraints = false
        cardStyle(doctorCard)
        contentView.addSubview(doctorCard)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = .tertiarySystemFill
        avatarImageView.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
        avatarImageView.tintColor = .tertiaryLabel
        doctorCard.addSubview(avatarImageView)

        func makeLabel(_ font: UIFont, _ color: UIColor) -> UILabel {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.font = font
            l.textColor = color
            return l
        }

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 2

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        ratingLabel.textColor = .secondaryLabel

        specLabel.translatesAutoresizingMaskIntoConstraints = false
        specLabel.font = .systemFont(ofSize: 14, weight: .medium)
        specLabel.textColor = .secondaryLabel

        feeLabel.translatesAutoresizingMaskIntoConstraints = false
        feeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        feeLabel.textColor = UITheme.Colors.accent

        let doctorInfoStack = UIStackView(arrangedSubviews: [nameLabel, ratingLabel, specLabel, feeLabel])
        doctorInfoStack.translatesAutoresizingMaskIntoConstraints = false
        doctorInfoStack.axis = .vertical
        doctorInfoStack.spacing = 6
        doctorInfoStack.alignment = .leading
        doctorCard.addSubview(doctorInfoStack)

        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.axis = .horizontal
        actionStack.alignment = .center
        actionStack.spacing = 12
        doctorCard.addSubview(actionStack)

        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.setImage(UIImage(systemName: "message"), for: .normal)
        messageButton.tintColor = .secondaryLabel

        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setImage(UIImage(systemName: "phone"), for: .normal)
        callButton.tintColor = .secondaryLabel
        actionStack.addArrangedSubview(messageButton)
        actionStack.addArrangedSubview(callButton)

        // Summary Card
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        cardStyle(summaryCard)
        contentView.addSubview(summaryCard)

        summaryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryTitleLabel.font = .boldSystemFont(ofSize: 18)
        summaryTitleLabel.textColor = .label
        summaryTitleLabel.text = "Appointment Summary"
        summaryCard.addSubview(summaryTitleLabel)

        func makeTitle(_ t: String) -> UILabel {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.font = .systemFont(ofSize: 15, weight: .semibold)
            l.textColor = .label
            l.text = t
            return l
        }

        dateTitleLabel.text = "Date & Time"
        locationTitleLabel.text = "Location"
        statusTitleLabel.text = "Status"

        [dateTitleLabel, locationTitleLabel, statusTitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.textColor = .label
            summaryCard.addSubview($0)
        }

        [dateValueLabel, locationValueLabel, statusValueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .right
            $0.numberOfLines = 0
            summaryCard.addSubview($0)
        }
        statusValueLabel.textColor = .systemGreen

        // Notes Card
        notesCard.translatesAutoresizingMaskIntoConstraints = false
        cardStyle(notesCard)
        contentView.addSubview(notesCard)

        notesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        notesTitleLabel.font = .boldSystemFont(ofSize: 18)
        notesTitleLabel.textColor = .label
        notesTitleLabel.text = "Session Notes"
        notesCard.addSubview(notesTitleLabel)

        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.font = .systemFont(ofSize: 16)
        notesTextView.backgroundColor = UITheme.Colors.neutralFill
        notesTextView.layer.cornerRadius = 14
        notesTextView.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        notesCard.addSubview(notesTextView)

        // Layout
        NSLayoutConstraint.activate([
            doctorCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            doctorCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            doctorCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            avatarImageView.leadingAnchor.constraint(equalTo: doctorCard.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: doctorCard.topAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 84),
            avatarImageView.heightAnchor.constraint(equalToConstant: 84),
            avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: doctorCard.bottomAnchor, constant: -16),

            doctorInfoStack.topAnchor.constraint(equalTo: doctorCard.topAnchor, constant: 18),
            doctorInfoStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 14),
            doctorInfoStack.trailingAnchor.constraint(equalTo: doctorCard.trailingAnchor, constant: -16),

            actionStack.topAnchor.constraint(equalTo: doctorInfoStack.bottomAnchor, constant: 12),
            actionStack.trailingAnchor.constraint(equalTo: doctorCard.trailingAnchor, constant: -16),
            actionStack.bottomAnchor.constraint(equalTo: doctorCard.bottomAnchor, constant: -16),

            messageButton.widthAnchor.constraint(equalToConstant: 30),
            messageButton.heightAnchor.constraint(equalToConstant: 30),
            callButton.widthAnchor.constraint(equalToConstant: 30),
            callButton.heightAnchor.constraint(equalToConstant: 30),

            summaryCard.topAnchor.constraint(equalTo: doctorCard.bottomAnchor, constant: 20),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            summaryTitleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 18),
            summaryTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            dateTitleLabel.topAnchor.constraint(equalTo: summaryTitleLabel.bottomAnchor, constant: 18),
            dateTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            dateValueLabel.topAnchor.constraint(equalTo: dateTitleLabel.topAnchor),
            dateValueLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),
            dateValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: dateTitleLabel.trailingAnchor, constant: 12),

            locationTitleLabel.topAnchor.constraint(equalTo: dateTitleLabel.bottomAnchor, constant: 14),
            locationTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            locationValueLabel.topAnchor.constraint(equalTo: locationTitleLabel.topAnchor),
            locationValueLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),
            locationValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: locationTitleLabel.trailingAnchor, constant: 12),

            statusTitleLabel.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 14),
            statusTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            statusTitleLabel.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -18),

            statusValueLabel.topAnchor.constraint(equalTo: statusTitleLabel.topAnchor),
            statusValueLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),
            statusValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: statusTitleLabel.trailingAnchor, constant: 12),

            notesCard.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 20),
            notesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            notesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            notesCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),

            notesTitleLabel.topAnchor.constraint(equalTo: notesCard.topAnchor, constant: 18),
            notesTitleLabel.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 16),

            notesTextView.topAnchor.constraint(equalTo: notesTitleLabel.bottomAnchor, constant: 12),
            notesTextView.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 16),
            notesTextView.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor, constant: -16),
            notesTextView.bottomAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: -18),
        ])

        let height = notesTextView.heightAnchor.constraint(equalToConstant: notesMinHeight)
        height.isActive = true
        notesHeightConstraint = height
    }

    // MARK: - Public
    func configure(with model: AppointmentDetailsModel) {
        nameLabel.text = model.physioName
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        let attrString = NSMutableAttributedString(attachment: attachment)
        attrString.append(NSAttributedString(string: "  \(model.ratingText)"))
        ratingLabel.attributedText = attrString
        
        specLabel.text = model.specializationText
        feeLabel.text = "Consultation fees:  \(model.feeText)"

        dateValueLabel.text = model.dateTimeText
        locationValueLabel.text = model.locationText
        statusValueLabel.text = model.statusText

        if model.sessionNotes.isEmpty {
            notesTextView.text = ""
        } else {
            notesTextView.text = model.sessionNotes
        }
    }

    func setAvatarImage(_ image: UIImage?) {
        if let image {
            avatarImageView.image = image
            avatarImageView.tintColor = .clear
        } else {
            avatarImageView.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
            avatarImageView.tintColor = .tertiaryLabel
        }
    }

    func updateNotesHeight() {
        let targetWidth = max(1, notesTextView.bounds.width)
        let size = CGSize(width: targetWidth, height: CGFloat.greatestFiniteMagnitude)
        let desired = max(notesMinHeight, notesTextView.sizeThatFits(size).height)
        notesHeightConstraint?.constant = desired
    }
}
