//
//  BookHomeVisitView.swift
//  Physio_Connect
//
//  Created by user@8 on 31/12/25.
//

import UIKit

final class BookHomeVisitView: UIView {

    // MARK: - Theme (match your app)
    private let bg = UITheme.Colors.background
    private let primaryBlue = UITheme.Colors.accent
    private let cardBg = UITheme.Colors.surface

    // MARK: - Scroll
    let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let backgroundGlow = AppBackgroundTopGlowView()

    // MARK: - Banner
    private let bannerCard = UIView()
    private let bannerIconBg = UIView()
    private let bannerIcon = UIImageView()
    private let bannerTopLabel = UILabel()
    private let bannerBottomLabel = UILabel()

    // MARK: - Doctor Card
    private let doctorCard = UIView()
    private let doctorTop = UIView()
    private let doctorBottom = UIView()

    private let doctorAvatar = UIImageView()
    private let doctorNameLabel = UILabel()
    private let doctorSpecLabel = UILabel()
    private let doctorRatingLabel = UILabel()

    private let sessionRow = UIView()
    private let homeRow = UIView()

    private let sessionIconBg = UIView()
    private let sessionIcon = UIImageView()
    private let sessionTitle = UILabel()
    private let sessionSub = UILabel()

    private let homeIconBg = UIView()
    private let homeIcon = UIImageView()
    private let homeTitle = UILabel()
    private let homeSub = UILabel()


    // MARK: - Address Card
    private let addressCard = UIView()
    private let addressTitleRow = UIView()
    private let addressIcon = UIImageView()
    private let addressTitle = UILabel()

    let addressField = UITextField()
    let phoneField = UITextField()
    let instructionsTextView = UITextView()

    // MARK: - Date/Time Card
    private let dateCard = UIView()
    private let dateTitleRow = UIView()
    private let dateIcon = UIImageView()
    private let dateTitle = UILabel()

    let datePill = UILabel()
    let timePill = UILabel()
    let calendarButton = UIButton(type: .system)

    // Native picker (hidden by default, toggled)
    let datePicker = UIDatePicker()
    private let datePickerContainer = UIView()
    private var datePickerHeight: NSLayoutConstraint!

    // MARK: - Slots
    private let slotsCard = UIView()
    private let slotsHeaderRow = UIView()
    private let slotsTitle = UILabel()
    let slotsCountLabel = UILabel()
    private let slotsLegend = UILabel()
    private let slotsGrid = UIStackView()

    // MARK: - Appointment Summary (GREEN)
    private let appointmentSummaryCard = UIView()
    private let summaryIconCircle = UIView()
    private let summaryIcon = UIImageView()
    private let summaryTitle = UILabel()
    private let summaryLine1 = UILabel()
    private let summaryLine2 = UILabel()
    private let summaryLine3 = UILabel()
    private let summaryGreenBg = UIColor.systemGreen.withAlphaComponent(0.12)
    private let summaryGreenBorder = UIColor.systemGreen.withAlphaComponent(0.3)
    private let summaryGreenIcon = UIColor.systemGreen

    // MARK: - Prepare (BLUE)
    private let prepareCard = UIView()
    private let prepareIconCircle = UIView()
    private let prepareBlueBg = UITheme.Colors.accent.withAlphaComponent(0.12)
    private let prepareBlueBorder = UITheme.Colors.accent.withAlphaComponent(0.3)
    private let prepareBlueIcon = UITheme.Colors.accent
    private let prepareIcon = UIImageView()
    private let prepareTitle = UILabel()
    private let prepareText = UILabel()

    // MARK: - Cancellation
    private let cancelCard = UIView()
    private let cancelText = UILabel()

    // MARK: - Confirm
    let confirmButton = UIButton(type: .system)
    private let confirmHint = UILabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGlow)

        // ========== SCROLL ==========
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .always

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // ========== MAIN STACK ==========
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        ])

        // ========== HEADER ==========
        // Custom header removed, using native navigation bar.
        
        // ========== BANNER ==========
        styleCard(bannerCard)
        bannerCard.backgroundColor = primaryBlue.withAlphaComponent(0.85)

        bannerIconBg.translatesAutoresizingMaskIntoConstraints = false
        bannerIconBg.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        bannerIconBg.layer.cornerRadius = 22

        bannerIcon.translatesAutoresizingMaskIntoConstraints = false
        bannerIcon.image = UIImage(systemName: "house.fill")
        bannerIcon.tintColor = .white
        bannerIcon.contentMode = .scaleAspectFit

        bannerTopLabel.translatesAutoresizingMaskIntoConstraints = false
        bannerTopLabel.text = "Home Service Available"
        bannerTopLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        bannerTopLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        bannerBottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bannerBottomLabel.text = "Convenient & Comfortable"
        bannerBottomLabel.font = .boldSystemFont(ofSize: 18)
        bannerBottomLabel.textColor = .white

        let bannerTextStack = UIStackView(arrangedSubviews: [bannerTopLabel, bannerBottomLabel])
        bannerTextStack.axis = .vertical
        bannerTextStack.spacing = 4
        bannerTextStack.translatesAutoresizingMaskIntoConstraints = false

        bannerCard.addSubview(bannerIconBg)
        bannerIconBg.addSubview(bannerIcon)
        bannerCard.addSubview(bannerTextStack)

        NSLayoutConstraint.activate([
            bannerCard.heightAnchor.constraint(equalToConstant: 86),

            bannerIconBg.leadingAnchor.constraint(equalTo: bannerCard.leadingAnchor, constant: 14),
            bannerIconBg.centerYAnchor.constraint(equalTo: bannerCard.centerYAnchor),
            bannerIconBg.widthAnchor.constraint(equalToConstant: 44),
            bannerIconBg.heightAnchor.constraint(equalToConstant: 44),

            bannerIcon.centerXAnchor.constraint(equalTo: bannerIconBg.centerXAnchor),
            bannerIcon.centerYAnchor.constraint(equalTo: bannerIconBg.centerYAnchor),
            bannerIcon.widthAnchor.constraint(equalToConstant: 22),
            bannerIcon.heightAnchor.constraint(equalToConstant: 22),

            bannerTextStack.leadingAnchor.constraint(equalTo: bannerIconBg.trailingAnchor, constant: 12),
            bannerTextStack.trailingAnchor.constraint(equalTo: bannerCard.trailingAnchor, constant: -12),
            bannerTextStack.centerYAnchor.constraint(equalTo: bannerCard.centerYAnchor)
        ])

        stack.addArrangedSubview(bannerCard)

        // ========== DOCTOR CARD ==========
        UITheme.applyCardStyle(doctorCard)
        doctorCard.clipsToBounds = true

        doctorTop.translatesAutoresizingMaskIntoConstraints = false
        doctorTop.backgroundColor = primaryBlue.withAlphaComponent(0.85)

        doctorBottom.translatesAutoresizingMaskIntoConstraints = false
        doctorBottom.backgroundColor = UITheme.Colors.surface

        doctorAvatar.translatesAutoresizingMaskIntoConstraints = false
        doctorAvatar.image = UIImage(systemName: "person.circle.fill")
        doctorAvatar.tintColor = .white
        doctorAvatar.contentMode = .scaleAspectFit
        doctorAvatar.layer.cornerRadius = 36
        doctorAvatar.clipsToBounds = true

        doctorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        doctorNameLabel.font = .boldSystemFont(ofSize: 20)
        doctorNameLabel.textColor = .white
        doctorNameLabel.text = "Loading..."

        doctorSpecLabel.translatesAutoresizingMaskIntoConstraints = false
        doctorSpecLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        doctorSpecLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        doctorSpecLabel.text = ""

        doctorRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        doctorRatingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        doctorRatingLabel.textColor = UIColor.white.withAlphaComponent(0.95)
        doctorRatingLabel.text = ""

        let doctorTextStack = UIStackView(arrangedSubviews: [doctorNameLabel, doctorSpecLabel, doctorRatingLabel])
        doctorTextStack.axis = .vertical
        doctorTextStack.spacing = 6
        doctorTextStack.translatesAutoresizingMaskIntoConstraints = false

        doctorTop.addSubview(doctorAvatar)
        doctorTop.addSubview(doctorTextStack)

        buildInfoRow(
            container: sessionRow,
            iconBg: sessionIconBg,
            icon: sessionIcon,
            title: sessionTitle,
            subtitle: sessionSub,
            iconName: "clock",
            iconTint: primaryBlue,
            titleText: "Session Duration",
            subText: "1 hour comprehensive treatment"
        )

        buildInfoRow(
            container: homeRow,
            iconBg: homeIconBg,
            icon: homeIcon,
            title: homeTitle,
            subtitle: homeSub,
            iconName: "house",
            iconTint: primaryBlue,
            titleText: "Home Visit Service",
            subText: "All equipment provided"
        )

        let bottomStack = UIStackView(arrangedSubviews: [sessionRow, homeRow])
        bottomStack.axis = .vertical
        bottomStack.spacing = 12
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        doctorBottom.addSubview(bottomStack)

        doctorCard.addSubview(doctorTop)
        doctorCard.addSubview(doctorBottom)

        NSLayoutConstraint.activate([
            doctorTop.topAnchor.constraint(equalTo: doctorCard.topAnchor),
            doctorTop.leadingAnchor.constraint(equalTo: doctorCard.leadingAnchor),
            doctorTop.trailingAnchor.constraint(equalTo: doctorCard.trailingAnchor),
            doctorTop.heightAnchor.constraint(equalToConstant: 110),

            doctorBottom.topAnchor.constraint(equalTo: doctorTop.bottomAnchor),
            doctorBottom.leadingAnchor.constraint(equalTo: doctorCard.leadingAnchor),
            doctorBottom.trailingAnchor.constraint(equalTo: doctorCard.trailingAnchor),
            doctorBottom.bottomAnchor.constraint(equalTo: doctorCard.bottomAnchor),

            doctorAvatar.leadingAnchor.constraint(equalTo: doctorTop.leadingAnchor, constant: 14),
            doctorAvatar.centerYAnchor.constraint(equalTo: doctorTop.centerYAnchor),
            doctorAvatar.widthAnchor.constraint(equalToConstant: 72),
            doctorAvatar.heightAnchor.constraint(equalToConstant: 72),

            doctorTextStack.leadingAnchor.constraint(equalTo: doctorAvatar.trailingAnchor, constant: 14),
            doctorTextStack.trailingAnchor.constraint(equalTo: doctorTop.trailingAnchor, constant: -14),
            doctorTextStack.centerYAnchor.constraint(equalTo: doctorTop.centerYAnchor),

            bottomStack.topAnchor.constraint(equalTo: doctorBottom.topAnchor, constant: 14),
            bottomStack.leadingAnchor.constraint(equalTo: doctorBottom.leadingAnchor, constant: 14),
            bottomStack.trailingAnchor.constraint(equalTo: doctorBottom.trailingAnchor, constant: -14),
            bottomStack.bottomAnchor.constraint(equalTo: doctorBottom.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(doctorCard)


        // ========== ADDRESS CARD ==========
        UITheme.applyCardStyle(addressCard)

        addressIcon.translatesAutoresizingMaskIntoConstraints = false
        addressIcon.image = UIImage(systemName: "mappin.and.ellipse")
        addressIcon.tintColor = primaryBlue
        addressIcon.contentMode = .scaleAspectFit

        addressTitle.translatesAutoresizingMaskIntoConstraints = false
        addressTitle.text = "Your Home Address"
        addressTitle.font = .boldSystemFont(ofSize: 18)

        addressTitleRow.translatesAutoresizingMaskIntoConstraints = false
        addressTitleRow.addSubview(addressIcon)
        addressTitleRow.addSubview(addressTitle)

        NSLayoutConstraint.activate([
            addressIcon.leadingAnchor.constraint(equalTo: addressTitleRow.leadingAnchor),
            addressIcon.centerYAnchor.constraint(equalTo: addressTitleRow.centerYAnchor),
            addressIcon.widthAnchor.constraint(equalToConstant: 20),
            addressIcon.heightAnchor.constraint(equalToConstant: 20),

            addressTitle.leadingAnchor.constraint(equalTo: addressIcon.trailingAnchor, constant: 8),
            addressTitle.trailingAnchor.constraint(equalTo: addressTitleRow.trailingAnchor),
            addressTitle.topAnchor.constraint(equalTo: addressTitleRow.topAnchor),
            addressTitle.bottomAnchor.constraint(equalTo: addressTitleRow.bottomAnchor)
        ])

        addressField.placeholder = "Enter your complete home address"
        phoneField.placeholder = "Contact Number"
        phoneField.keyboardType = .numberPad

        [addressField, phoneField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UITheme.Colors.neutralFill
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UITheme.Colors.border.cgColor
            $0.setLeftPadding(12)
            $0.textColor = UITheme.Colors.textPrimary
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }

        instructionsTextView.translatesAutoresizingMaskIntoConstraints = false
        instructionsTextView.backgroundColor = UITheme.Colors.neutralFill
        instructionsTextView.layer.cornerRadius = 12
        instructionsTextView.layer.borderWidth = 1
        instructionsTextView.layer.borderColor = UITheme.Colors.border.cgColor
        instructionsTextView.font = .systemFont(ofSize: 14)
        instructionsTextView.textColor = UITheme.Colors.textPrimary
        instructionsTextView.text = "Special instructions (parking, floor, access etc.)"
        instructionsTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)

        let addressStack = UIStackView(arrangedSubviews: [addressTitleRow, addressField, phoneField, instructionsTextView])
        addressStack.axis = .vertical
        addressStack.spacing = 12
        addressStack.translatesAutoresizingMaskIntoConstraints = false

        addressCard.addSubview(addressStack)
        NSLayoutConstraint.activate([
            instructionsTextView.heightAnchor.constraint(equalToConstant: 110),

            addressStack.topAnchor.constraint(equalTo: addressCard.topAnchor, constant: 14),
            addressStack.leadingAnchor.constraint(equalTo: addressCard.leadingAnchor, constant: 14),
            addressStack.trailingAnchor.constraint(equalTo: addressCard.trailingAnchor, constant: -14),
            addressStack.bottomAnchor.constraint(equalTo: addressCard.bottomAnchor, constant: -14)
        ])
        stack.addArrangedSubview(addressCard)

        // ========== DATE/TIME CARD ==========
        UITheme.applyCardStyle(dateCard)

        dateIcon.translatesAutoresizingMaskIntoConstraints = false
        dateIcon.image = UIImage(systemName: "calendar")
        dateIcon.tintColor = primaryBlue

        dateTitle.translatesAutoresizingMaskIntoConstraints = false
        dateTitle.text = "Select date and time"
        dateTitle.font = .boldSystemFont(ofSize: 18)

        dateTitleRow.translatesAutoresizingMaskIntoConstraints = false
        dateTitleRow.addSubview(dateIcon)
        dateTitleRow.addSubview(dateTitle)

        NSLayoutConstraint.activate([
            dateIcon.leadingAnchor.constraint(equalTo: dateTitleRow.leadingAnchor),
            dateIcon.centerYAnchor.constraint(equalTo: dateTitleRow.centerYAnchor),
            dateIcon.widthAnchor.constraint(equalToConstant: 20),
            dateIcon.heightAnchor.constraint(equalToConstant: 20),

            dateTitle.leadingAnchor.constraint(equalTo: dateIcon.trailingAnchor, constant: 8),
            dateTitle.trailingAnchor.constraint(equalTo: dateTitleRow.trailingAnchor),
            dateTitle.topAnchor.constraint(equalTo: dateTitleRow.topAnchor),
            dateTitle.bottomAnchor.constraint(equalTo: dateTitleRow.bottomAnchor)
        ])

        stylePill(datePill)
        stylePill(timePill)

        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarButton.tintColor = primaryBlue

        let pillsRow = UIStackView()
        pillsRow.axis = .horizontal
        pillsRow.spacing = 10
        pillsRow.alignment = .center
        pillsRow.translatesAutoresizingMaskIntoConstraints = false

        datePill.widthAnchor.constraint(equalToConstant: 150).isActive = true
        timePill.widthAnchor.constraint(equalToConstant: 120).isActive = true
        calendarButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        calendarButton.heightAnchor.constraint(equalToConstant: 34).isActive = true

        [datePill, timePill, UIView(), calendarButton].forEach { pillsRow.addArrangedSubview($0) }

        datePickerContainer.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer.backgroundColor = UITheme.Colors.surface
        datePickerContainer.layer.cornerRadius = 14
        datePickerContainer.clipsToBounds = true

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Calendar.current.startOfDay(for: Date())

        datePickerContainer.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: datePickerContainer.topAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor, constant: -8),
            datePicker.bottomAnchor.constraint(equalTo: datePickerContainer.bottomAnchor, constant: -8)
        ])

        datePickerHeight = datePickerContainer.heightAnchor.constraint(equalToConstant: 0)
        datePickerHeight.isActive = true
        datePickerContainer.clipsToBounds = true

        let dateStack = UIStackView(arrangedSubviews: [dateTitleRow, pillsRow, datePickerContainer])
        dateStack.axis = .vertical
        dateStack.spacing = 12
        dateStack.translatesAutoresizingMaskIntoConstraints = false

        dateCard.addSubview(dateStack)
        NSLayoutConstraint.activate([
            dateStack.topAnchor.constraint(equalTo: dateCard.topAnchor, constant: 14),
            dateStack.leadingAnchor.constraint(equalTo: dateCard.leadingAnchor, constant: 14),
            dateStack.trailingAnchor.constraint(equalTo: dateCard.trailingAnchor, constant: -14),
            dateStack.bottomAnchor.constraint(equalTo: dateCard.bottomAnchor, constant: -14)
        ])
        stack.addArrangedSubview(dateCard)

        // ========== SLOTS CARD ==========
        UITheme.applyCardStyle(slotsCard)

        slotsTitle.text = "Available Time Slots"
        slotsTitle.font = .boldSystemFont(ofSize: 18)

        slotsCountLabel.text = "0 slots"
        slotsCountLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        slotsCountLabel.textColor = primaryBlue
        slotsCountLabel.textAlignment = .right

        slotsHeaderRow.translatesAutoresizingMaskIntoConstraints = false
        slotsHeaderRow.addSubview(slotsTitle)
        slotsHeaderRow.addSubview(slotsCountLabel)
        slotsTitle.translatesAutoresizingMaskIntoConstraints = false
        slotsCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            slotsTitle.leadingAnchor.constraint(equalTo: slotsHeaderRow.leadingAnchor),
            slotsTitle.topAnchor.constraint(equalTo: slotsHeaderRow.topAnchor),
            slotsTitle.bottomAnchor.constraint(equalTo: slotsHeaderRow.bottomAnchor),

            slotsCountLabel.centerYAnchor.constraint(equalTo: slotsTitle.centerYAnchor),
            slotsCountLabel.trailingAnchor.constraint(equalTo: slotsHeaderRow.trailingAnchor)
        ])

        slotsGrid.axis = .vertical
        slotsGrid.spacing = 10
        slotsGrid.translatesAutoresizingMaskIntoConstraints = false

        slotsLegend.translatesAutoresizingMaskIntoConstraints = false
        slotsLegend.text = "• Greyed out slots are already booked"
        slotsLegend.font = .systemFont(ofSize: 12, weight: .medium)
        slotsLegend.textColor = .gray

        let slotsStack = UIStackView(arrangedSubviews: [slotsHeaderRow, slotsGrid, slotsLegend])
        slotsStack.axis = .vertical
        slotsStack.spacing = 12
        slotsStack.translatesAutoresizingMaskIntoConstraints = false

        slotsCard.addSubview(slotsStack)
        NSLayoutConstraint.activate([
            slotsStack.topAnchor.constraint(equalTo: slotsCard.topAnchor, constant: 14),
            slotsStack.leadingAnchor.constraint(equalTo: slotsCard.leadingAnchor, constant: 14),
            slotsStack.trailingAnchor.constraint(equalTo: slotsCard.trailingAnchor, constant: -14),
            slotsStack.bottomAnchor.constraint(equalTo: slotsCard.bottomAnchor, constant: -14)
        ])
        stack.addArrangedSubview(slotsCard)

        // ========== APPOINTMENT SUMMARY (GREEN TINT) ==========
        styleTintCard(appointmentSummaryCard, bg: summaryGreenBg, border: summaryGreenBorder)

        summaryIconCircle.translatesAutoresizingMaskIntoConstraints = false
        summaryIconCircle.backgroundColor = summaryGreenIcon
        summaryIconCircle.layer.cornerRadius = 18

        summaryIcon.translatesAutoresizingMaskIntoConstraints = false
        summaryIcon.image = UIImage(systemName: "checkmark")
        summaryIcon.tintColor = .white
        summaryIcon.contentMode = .scaleAspectFit

        summaryTitle.text = "Your Appointment Summary"
        summaryTitle.font = .boldSystemFont(ofSize: 16)
        summaryTitle.textColor = UITheme.Colors.textPrimary

        summaryLine1.font = .systemFont(ofSize: 14, weight: .semibold)
        summaryLine2.font = .systemFont(ofSize: 14, weight: .medium)
        summaryLine3.font = .systemFont(ofSize: 13, weight: .medium)

        summaryLine1.textColor = UITheme.Colors.textPrimary
        summaryLine2.textColor = UITheme.Colors.textSecondary
        summaryLine3.textColor = UITheme.Colors.textSecondary
        summaryLine3.numberOfLines = 2

        let summaryTextStack = UIStackView(arrangedSubviews: [summaryTitle, summaryLine1, summaryLine2, summaryLine3])
        summaryTextStack.axis = .vertical
        summaryTextStack.spacing = 6
        summaryTextStack.translatesAutoresizingMaskIntoConstraints = false

        appointmentSummaryCard.addSubview(summaryIconCircle)
        summaryIconCircle.addSubview(summaryIcon)
        appointmentSummaryCard.addSubview(summaryTextStack)

        NSLayoutConstraint.activate([
            summaryIconCircle.leadingAnchor.constraint(equalTo: appointmentSummaryCard.leadingAnchor, constant: 14),
            summaryIconCircle.topAnchor.constraint(equalTo: appointmentSummaryCard.topAnchor, constant: 14),
            summaryIconCircle.widthAnchor.constraint(equalToConstant: 36),
            summaryIconCircle.heightAnchor.constraint(equalToConstant: 36),

            summaryIcon.centerXAnchor.constraint(equalTo: summaryIconCircle.centerXAnchor),
            summaryIcon.centerYAnchor.constraint(equalTo: summaryIconCircle.centerYAnchor),
            summaryIcon.widthAnchor.constraint(equalToConstant: 18),
            summaryIcon.heightAnchor.constraint(equalToConstant: 18),

            summaryTextStack.leadingAnchor.constraint(equalTo: summaryIconCircle.trailingAnchor, constant: 12),
            summaryTextStack.trailingAnchor.constraint(equalTo: appointmentSummaryCard.trailingAnchor, constant: -14),
            summaryTextStack.topAnchor.constraint(equalTo: appointmentSummaryCard.topAnchor, constant: 14),
            summaryTextStack.bottomAnchor.constraint(equalTo: appointmentSummaryCard.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(appointmentSummaryCard)

        // ========== PREPARE CARD (BLUE TINT) ==========
        styleTintCard(prepareCard, bg: prepareBlueBg, border: prepareBlueBorder)

        prepareIconCircle.translatesAutoresizingMaskIntoConstraints = false
        prepareIconCircle.backgroundColor = prepareBlueIcon.withAlphaComponent(0.12)
        prepareIconCircle.layer.cornerRadius = 16

        prepareIcon.translatesAutoresizingMaskIntoConstraints = false
        prepareIcon.image = UIImage(systemName: "info.circle.fill")
        prepareIcon.tintColor = prepareBlueIcon
        prepareIcon.contentMode = .scaleAspectFit

        prepareTitle.text = "What to Prepare"
        prepareTitle.font = .boldSystemFont(ofSize: 16)
        prepareTitle.textColor = UITheme.Colors.textPrimary

        prepareText.text =
        "• Clear a comfortable space for treatment\n" +
        "• Wear loose, comfortable clothing\n" +
        "• Have your medical history ready\n" +
        "• Ensure someone is home to let the therapist in"
        prepareText.numberOfLines = 0
        prepareText.font = .systemFont(ofSize: 13, weight: .medium)
        prepareText.textColor = UITheme.Colors.textSecondary

        let prepareHeaderRow = UIStackView(arrangedSubviews: [prepareIconCircle, prepareTitle, UIView()])
        prepareHeaderRow.axis = .horizontal
        prepareHeaderRow.alignment = .center
        prepareHeaderRow.spacing = 10
        prepareHeaderRow.translatesAutoresizingMaskIntoConstraints = false

        prepareIconCircle.addSubview(prepareIcon)

        let prepareStack = UIStackView(arrangedSubviews: [prepareHeaderRow, prepareText])
        prepareStack.axis = .vertical
        prepareStack.spacing = 10
        prepareStack.translatesAutoresizingMaskIntoConstraints = false

        prepareCard.addSubview(prepareStack)

        NSLayoutConstraint.activate([
            prepareIconCircle.widthAnchor.constraint(equalToConstant: 32),
            prepareIconCircle.heightAnchor.constraint(equalToConstant: 32),

            prepareIcon.centerXAnchor.constraint(equalTo: prepareIconCircle.centerXAnchor),
            prepareIcon.centerYAnchor.constraint(equalTo: prepareIconCircle.centerYAnchor),
            prepareIcon.widthAnchor.constraint(equalToConstant: 18),
            prepareIcon.heightAnchor.constraint(equalToConstant: 18),

            prepareStack.topAnchor.constraint(equalTo: prepareCard.topAnchor, constant: 14),
            prepareStack.leadingAnchor.constraint(equalTo: prepareCard.leadingAnchor, constant: 14),
            prepareStack.trailingAnchor.constraint(equalTo: prepareCard.trailingAnchor, constant: -14),
            prepareStack.bottomAnchor.constraint(equalTo: prepareCard.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(prepareCard)

        // ========== CANCELLATION ==========
        UITheme.applyCardStyle(cancelCard)
        cancelCard.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.18)
        cancelCard.layer.borderWidth = 1
        cancelCard.layer.borderColor = UIColor.systemYellow.withAlphaComponent(0.35).cgColor

        cancelText.text = "Cancellation Policy: Free cancellation up to 24 hours before appointment. Late cancellation may incur charges."
        cancelText.numberOfLines = 0
        cancelText.font = .systemFont(ofSize: 13, weight: .medium)
        cancelText.textColor = .label

        cancelText.translatesAutoresizingMaskIntoConstraints = false
        cancelCard.addSubview(cancelText)
        NSLayoutConstraint.activate([
            cancelText.topAnchor.constraint(equalTo: cancelCard.topAnchor, constant: 14),
            cancelText.leadingAnchor.constraint(equalTo: cancelCard.leadingAnchor, constant: 14),
            cancelText.trailingAnchor.constraint(equalTo: cancelCard.trailingAnchor, constant: -14),
            cancelText.bottomAnchor.constraint(equalTo: cancelCard.bottomAnchor, constant: -14)
        ])
        stack.addArrangedSubview(cancelCard)

        // ========== CONFIRM ==========
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("Confirm Home Appointment", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        confirmButton.backgroundColor = primaryBlue
        confirmButton.layer.cornerRadius = 27
        confirmButton.clipsToBounds = true
        confirmButton.heightAnchor.constraint(equalToConstant: 54).isActive = true

        confirmHint.text = "You'll receive confirmation via SMS and email"
        confirmHint.font = .systemFont(ofSize: 12, weight: .medium)
        confirmHint.textColor = .gray
        confirmHint.textAlignment = .center

        stack.addArrangedSubview(confirmButton)
        stack.addArrangedSubview(confirmHint)

        // Initial pills
        setDate(Date())
        setSelectedTimeText(nil)
        updateAppointmentSummary(doctorName: nil, date: Date(), time: nil, address: nil)
    }

    // MARK: - Public APIs used by VC

    func toggleDatePickerVisible() {
        let isHidden = (datePickerHeight.constant == 0)
        datePickerHeight.constant = isHidden ? 330 : 0
        UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
    }

    func setDate(_ date: Date) {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        datePill.text = df.string(from: date)
    }

    func setSelectedTimeText(_ text: String?) {
        timePill.text = text ?? "--"
    }

    func setPhysio(name: String, spec: String, rating: String, fee: String) {
        doctorNameLabel.text = name
        doctorSpecLabel.text = spec
        doctorRatingLabel.text = rating
    }

    func setSlotsCount(_ count: Int) {
        slotsCountLabel.text = "\(count) slots"
    }

    struct SlotVM {
        let id: UUID
        let title: String
        let isBooked: Bool
    }

    func renderSlots(_ slots: [SlotVM], selectedID: UUID?, onTap: @escaping (UUID) -> Void) {
        slotsGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        setSlotsCount(slots.count)

        var rowStack: UIStackView?

        for (idx, s) in slots.enumerated() {
            if idx % 3 == 0 {
                rowStack = UIStackView()
                rowStack?.axis = .horizontal
                rowStack?.spacing = 10
                rowStack?.distribution = .fillEqually
                if let r = rowStack { slotsGrid.addArrangedSubview(r) }
            }

            let b = UIButton(type: .system)
            b.setTitle(s.title, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            b.layer.cornerRadius = 14
            b.layer.borderWidth = 1.5
            b.heightAnchor.constraint(equalToConstant: 44).isActive = true

            let isSelected = (s.id == selectedID)

            if s.isBooked {
                b.isEnabled = false
                b.backgroundColor = UIColor.quaternarySystemFill
                b.setTitleColor(.tertiaryLabel, for: .normal)
                b.layer.borderColor = UIColor.separator.cgColor
            } else {
                b.isEnabled = true
                b.backgroundColor = isSelected ? primaryBlue : UITheme.Colors.surface
                b.setTitleColor(isSelected ? .white : .label, for: .normal)
                b.layer.borderColor = isSelected ? primaryBlue.cgColor : UIColor.separator.cgColor
                b.addAction(UIAction(handler: { _ in onTap(s.id) }), for: .touchUpInside)
            }

            rowStack?.addArrangedSubview(b)
        }
    }

    func updateAppointmentSummary(doctorName: String?, date: Date, time: String?, address: String?) {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"

        summaryLine1.text = "\(df.string(from: date)) \(time ?? "--")"
        summaryLine2.text = doctorName != nil ? "with \(doctorName!)" : "with --"
        summaryLine3.text = address ?? "Address: --"
    }

    // MARK: - Helpers

    private func styleCard(_ v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = cardBg
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    private func styleTintCard(_ v: UIView, bg: UIColor, border: UIColor) {
        // keep the same shadow style as cards
        styleCard(v)
        v.backgroundColor = bg
        v.layer.borderWidth = 1.2
        v.layer.borderColor = border.cgColor
    }

    private func stylePill(_ l: UILabel) {
        l.translatesAutoresizingMaskIntoConstraints = false
        l.backgroundColor = UITheme.Colors.surface
        l.textAlignment = .center
        l.textColor = .label
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.layer.cornerRadius = 16
        l.layer.masksToBounds = true
        l.layer.borderWidth = 1
        l.layer.borderColor = UITheme.Colors.border.cgColor
        l.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }

    private func buildInfoRow(
        container: UIView,
        iconBg: UIView,
        icon: UIImageView,
        title: UILabel,
        subtitle: UILabel,
        iconName: String,
        iconTint: UIColor,
        titleText: String,
        subText: String
    ) {
        container.translatesAutoresizingMaskIntoConstraints = false

        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = iconTint.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 14

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: iconName)
        icon.tintColor = iconTint
        icon.contentMode = .scaleAspectFit

        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = titleText
        title.font = .systemFont(ofSize: 15, weight: .semibold)

        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = subText
        subtitle.font = .systemFont(ofSize: 13, weight: .medium)
        subtitle.textColor = .darkGray

        let textStack = UIStackView(arrangedSubviews: [title, subtitle])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconBg)
        iconBg.addSubview(icon)
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconBg.topAnchor.constraint(equalTo: container.topAnchor),
            iconBg.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),

            icon.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            textStack.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: - UITextField padding
private extension UITextField {
    func setLeftPadding(_ v: CGFloat) {
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: v, height: 1))
        leftView = pad
        leftViewMode = .always
    }
}
