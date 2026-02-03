//
//  AppointmentDetailsView.swift
//  Physio_Connect
//
//  Created by Ayush Rai on 02/01/26.
//
import UIKit

final class AppointmentDetailsView: UIView {

    // MARK: - UI
    let backButton = UIButton(type: .system)
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
        backgroundColor = UIColor(hex: "E3F0FF")
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func cardStyle(_ v: UIView) {
        v.backgroundColor = .white
        v.layer.cornerRadius = 22
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hex: "D4E3FE").cgColor
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    private func build() {
        // Scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor.black.withAlphaComponent(0.8)
        backButton.backgroundColor = .clear
        addSubview(backButton)

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
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
        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
        avatarImageView.tintColor = .gray
        doctorCard.addSubview(avatarImageView)

        func makeLabel(_ font: UIFont, _ color: UIColor) -> UILabel {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.font = font
            l.textColor = color
            return l
        }

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textColor = .black

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        ratingLabel.textColor = .darkGray

        specLabel.translatesAutoresizingMaskIntoConstraints = false
        specLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        specLabel.textColor = UIColor.black.withAlphaComponent(0.8)

        feeLabel.translatesAutoresizingMaskIntoConstraints = false
        feeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        feeLabel.textColor = UIColor(hex: "1E6EF7")

        [nameLabel, ratingLabel, specLabel, feeLabel].forEach { doctorCard.addSubview($0) }

        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.axis = .horizontal
        actionStack.alignment = .center
        actionStack.spacing = 12
        doctorCard.addSubview(actionStack)

        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.setImage(UIImage(systemName: "message"), for: .normal)
        messageButton.tintColor = UIColor.black.withAlphaComponent(0.75)

        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setImage(UIImage(systemName: "phone"), for: .normal)
        callButton.tintColor = UIColor.black.withAlphaComponent(0.75)
        actionStack.addArrangedSubview(messageButton)
        actionStack.addArrangedSubview(callButton)

        // Summary Card
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        cardStyle(summaryCard)
        contentView.addSubview(summaryCard)

        summaryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryTitleLabel.font = .boldSystemFont(ofSize: 18)
        summaryTitleLabel.textColor = .black
        summaryTitleLabel.text = "Appointment Summary"
        summaryCard.addSubview(summaryTitleLabel)

        func makeTitle(_ t: String) -> UILabel {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.font = .systemFont(ofSize: 15, weight: .semibold)
            l.textColor = UIColor.black.withAlphaComponent(0.85)
            l.text = t
            return l
        }

        dateTitleLabel.text = "Date & Time"
        locationTitleLabel.text = "Location"
        statusTitleLabel.text = "Status"

        [dateTitleLabel, locationTitleLabel, statusTitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.textColor = UIColor.black.withAlphaComponent(0.85)
            summaryCard.addSubview($0)
        }

        [dateValueLabel, locationValueLabel, statusValueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.textColor = UIColor.black.withAlphaComponent(0.8)
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
        notesTitleLabel.textColor = .black
        notesTitleLabel.text = "Session Notes"
        notesCard.addSubview(notesTitleLabel)

        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.font = .systemFont(ofSize: 16)
        notesTextView.backgroundColor = UIColor(hex: "EAF3FF")
        notesTextView.layer.cornerRadius = 14
        notesTextView.textContainerInset = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 48)
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

            nameLabel.topAnchor.constraint(equalTo: doctorCard.topAnchor, constant: 18),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: doctorCard.trailingAnchor, constant: -16),

            ratingLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            ratingLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: doctorCard.trailingAnchor, constant: -16),

            specLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 6),
            specLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specLabel.trailingAnchor.constraint(equalTo: doctorCard.trailingAnchor, constant: -16),

            feeLabel.topAnchor.constraint(equalTo: specLabel.bottomAnchor, constant: 8),
            feeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            feeLabel.trailingAnchor.constraint(equalTo: doctorCard.trailingAnchor, constant: -16),

            actionStack.topAnchor.constraint(equalTo: feeLabel.bottomAnchor, constant: 10),
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
        ratingLabel.text = model.ratingText
        specLabel.text = model.specializationText
        feeLabel.text = "Consultation fees:  \(model.feeText)"

        dateValueLabel.text = model.dateTimeText
        locationValueLabel.text = model.locationText
        statusValueLabel.text = model.statusText

        notesTextView.text = model.sessionNotes.isEmpty ? "session details" : model.sessionNotes
    }

    func setAvatarImage(_ image: UIImage?) {
        if let image {
            avatarImageView.image = image
            avatarImageView.tintColor = .clear
        } else {
            avatarImageView.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
            avatarImageView.tintColor = .gray
        }
    }

    func updateNotesHeight() {
        let targetWidth = max(1, notesTextView.bounds.width)
        let size = CGSize(width: targetWidth, height: CGFloat.greatestFiniteMagnitude)
        let desired = max(notesMinHeight, notesTextView.sizeThatFits(size).height)
        notesHeightConstraint?.constant = desired
    }
}
