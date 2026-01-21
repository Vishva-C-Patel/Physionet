//
//  ProfileView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ProfileView: UIView {

    var onBack: (() -> Void)?
    var onEdit: (() -> Void)?
    var onPrivacyTapped: (() -> Void)?
    var onTermsTapped: (() -> Void)?
    var onSignOut: (() -> Void)?
    var onLogin: (() -> Void)?
    var onSignup: (() -> Void)?
    var onNotificationsChanged: ((Bool) -> Void)?
    var onRefresh: (() -> Void)?
    var onSwitchRole: (() -> Void)?
    var onChangePassword: (() -> Void)?
    var onAvailabilitySave: ((Date, Date, Date) -> Void)?
    private let switchRoleButton = UIButton(type: .system)


    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let refreshControl = UIRefreshControl()

    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private var shouldShowEditButton = true
    private var isLoggedInState = true

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()

    private let emailRow = ProfileRowView(title: "Email")
    private let phoneRow = ProfileRowView(title: "Phone")
    private let genderRow = ProfileRowView(title: "Gender")
    private let dobRow = ProfileRowView(title: "Date of Birth")

    private let addressRow = ProfileRowView(title: "Address")
    private let locationRow = ProfileRowView(title: "Location")
    private let notificationRow = ProfileToggleRowView(title: "Notifications")
    private let aboutRow = ProfileRowView(title: "About")
    private let yearsRow = ProfileRowView(title: "Years of Experience")

    private let privacyButton = ProfileActionRowButton(title: "Privacy Policy")
    private let termsButton = ProfileActionRowButton(title: "Terms of Service")

    private let availabilitySectionLabel = UILabel()
    private let availabilityCard = UIView()
    private let availabilityStack = UIStackView()
    private let availabilityDatePicker = UIDatePicker()
    private let availabilityStartPicker = UIDatePicker()
    private let availabilityEndPicker = UIDatePicker()
    private let availabilityHintLabel = UILabel()
    private let availabilitySaveButton = UIButton(type: .system)
    private var availabilityVisible = false

    private let authStack = UIStackView()
    private let signOutButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)
    private let signUpButton = UIButton(type: .system)

    private var currentAvatarURL: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E8EEF5")
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ data: ProfileViewData) {
        setLoggedIn(true)
        nameLabel.text = data.name
        emailRow.setValue(data.email)
        phoneRow.setValue(data.phone)
        genderRow.setValue(data.gender)
        dobRow.setValue(data.dateOfBirth)
        addressRow.setValue(data.address)
        locationRow.setValue(data.location)
        aboutRow.setValue(data.about)
        yearsRow.setValue(data.yearsExperience)
        notificationRow.setOn(data.notificationsEnabled)
        setAvatar(with: data.avatarURL)
    }

    func applyLoggedOut() {
        setLoggedIn(false)
        nameLabel.text = "Guest"
        emailRow.setValue("—")
        phoneRow.setValue("—")
        genderRow.setValue("—")
        dobRow.setValue("—")
        addressRow.setValue("—")
        locationRow.setValue("—")
        aboutRow.setValue("—")
        yearsRow.setValue("—")
        notificationRow.setOn(false)
        setAvatar(with: nil)
    }

    func setRefreshing(_ isRefreshing: Bool) {
        if isRefreshing {
            if !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
    }

    private func build() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.alwaysBounceVertical = true
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)

        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        buildTopBar()
        buildHeader()
        buildPersonalInfo()
        buildProfessionalInfo()
        buildSettings()
        buildAvailability()
        buildPrivacy()
        buildSignOut()
    }

    private func buildHeader() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = UIColor(hex: "96A7BD")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 46
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderWidth = 4
        avatarImageView.layer.borderColor = UIColor(hex: "D1D9E5").cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = UIColor.black
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(avatarImageView)
        container.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: container.topAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 92),
            avatarImageView.heightAnchor.constraint(equalToConstant: 92),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        stackView.addArrangedSubview(container)
        stackView.setCustomSpacing(8, after: container)
    }

    private func setAvatar(with urlString: String?) {
        currentAvatarURL = urlString
        let placeholder = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysTemplate)
        avatarImageView.image = placeholder
        avatarImageView.tintColor = UIColor(hex: "96A7BD")

        guard let trimmed = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return
        }

        let url: URL?
        if let absolute = URL(string: trimmed), absolute.scheme != nil {
            url = absolute
        } else {
            // Prefer physio bucket normalization using shared service
            if let built = PhysioService.shared.profileImageURL(pathOrUrl: trimmed, version: nil) {
                url = built
            } else {
                let normalized = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                url = URL(string: "\(SupabaseConfig.url)/storage/v1/object/public/\(normalized)")
            }
        }
        guard let finalURL = url else { return }

        ImageLoader.shared.load(finalURL) { [weak self] image in
            guard let self else { return }
            guard self.currentAvatarURL == urlString else { return }
            self.avatarImageView.image = image ?? placeholder
            self.avatarImageView.tintColor = image == nil ? UIColor(hex: "96A7BD") : .clear
        }
    }

    private func buildPersonalInfo() {
        let card = makeCardView()
        let stack = makeCardStack()

        stack.addArrangedSubview(emailRow)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(phoneRow)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(genderRow)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(dobRow)

        card.addSubview(stack)
        pinCardStack(stack, to: card)

        stackView.addArrangedSubview(card)
    }

    private func buildProfessionalInfo() {
        let sectionLabel = makeSectionLabel("Professional Details")
        stackView.addArrangedSubview(sectionLabel)

        let card = makeCardView()
        let stack = makeCardStack()

        stack.addArrangedSubview(aboutRow)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(yearsRow)

        card.addSubview(stack)
        pinCardStack(stack, to: card)

        stackView.addArrangedSubview(card)
    }

    private func buildTopBar() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor.black.withAlphaComponent(0.8)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        container.addSubview(backButton)
        container.addSubview(editButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            editButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            editButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        container.heightAnchor.constraint(equalToConstant: 32).isActive = true
        stackView.addArrangedSubview(container)
    }

    private func buildSettings() {
        let sectionLabel = makeSectionLabel("Settings")
        stackView.addArrangedSubview(sectionLabel)

        let card = makeCardView()
        let stack = makeCardStack()

        stack.addArrangedSubview(addressRow)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(locationRow)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(notificationRow)

        notificationRow.onToggleChanged = { [weak self] isOn in
            self?.onNotificationsChanged?(isOn)
        }

        card.addSubview(stack)
        pinCardStack(stack, to: card)

        stackView.addArrangedSubview(card)
    }

    private func buildPrivacy() {
        let sectionLabel = makeSectionLabel("Privacy & Security")
        stackView.addArrangedSubview(sectionLabel)

        let card = makeCardView()
        let stack = makeCardStack()

        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        

        stack.addArrangedSubview(privacyButton)
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(termsButton)

        card.addSubview(stack)
        pinCardStack(stack, to: card)

        stackView.addArrangedSubview(card)
    }

    private func buildAvailability() {
        availabilitySectionLabel.text = "Availability"
        availabilitySectionLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        availabilitySectionLabel.textColor = UIColor.black
        stackView.addArrangedSubview(availabilitySectionLabel)

        availabilityCard.backgroundColor = UIColor.white
        availabilityCard.layer.cornerRadius = 18
        availabilityCard.layer.shadowColor = UIColor.black.cgColor
        availabilityCard.layer.shadowOpacity = 0.05
        availabilityCard.layer.shadowRadius = 10
        availabilityCard.layer.shadowOffset = CGSize(width: 0, height: 6)

        availabilityStack.axis = .vertical
        availabilityStack.spacing = 12
        availabilityStack.translatesAutoresizingMaskIntoConstraints = false

        let dateRow = makeAvailabilityRow(title: "Date", picker: availabilityDatePicker, mode: .date)
        let startRow = makeAvailabilityRow(title: "Start Time", picker: availabilityStartPicker, mode: .time)
        let endRow = makeAvailabilityRow(title: "End Time", picker: availabilityEndPicker, mode: .time)

        availabilityDatePicker.minimumDate = Calendar.current.startOfDay(for: Date())

        availabilityHintLabel.text = "Slots are created in 1-hour blocks."
        availabilityHintLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        availabilityHintLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        availabilityHintLabel.translatesAutoresizingMaskIntoConstraints = false

        availabilitySaveButton.setTitle("Save Availability", for: .normal)
        availabilitySaveButton.setTitleColor(.white, for: .normal)
        availabilitySaveButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        availabilitySaveButton.backgroundColor = UIColor(hex: "1E6EF7")
        availabilitySaveButton.layer.cornerRadius = 16
        availabilitySaveButton.layer.shadowColor = UIColor.black.cgColor
        availabilitySaveButton.layer.shadowOpacity = 0.05
        availabilitySaveButton.layer.shadowRadius = 10
        availabilitySaveButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        availabilitySaveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        availabilitySaveButton.addTarget(self, action: #selector(saveAvailabilityTapped), for: .touchUpInside)
        availabilitySaveButton.translatesAutoresizingMaskIntoConstraints = false

        availabilityStack.addArrangedSubview(dateRow)
        availabilityStack.addArrangedSubview(startRow)
        availabilityStack.addArrangedSubview(endRow)
        let hintContainer = UIView()
        hintContainer.translatesAutoresizingMaskIntoConstraints = false
        hintContainer.addSubview(availabilityHintLabel)
        NSLayoutConstraint.activate([
            availabilityHintLabel.leadingAnchor.constraint(equalTo: hintContainer.leadingAnchor, constant: 14),
            availabilityHintLabel.trailingAnchor.constraint(equalTo: hintContainer.trailingAnchor, constant: -14),
            availabilityHintLabel.topAnchor.constraint(equalTo: hintContainer.topAnchor),
            availabilityHintLabel.bottomAnchor.constraint(equalTo: hintContainer.bottomAnchor)
        ])
        availabilityStack.addArrangedSubview(hintContainer)

        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(availabilitySaveButton)
        NSLayoutConstraint.activate([
            availabilitySaveButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 12),
            availabilitySaveButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -12),
            availabilitySaveButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            availabilitySaveButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
        ])
        availabilityStack.addArrangedSubview(buttonContainer)

        availabilityStack.isLayoutMarginsRelativeArrangement = true
        availabilityStack.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        availabilityCard.addSubview(availabilityStack)
        NSLayoutConstraint.activate([
            availabilityStack.topAnchor.constraint(equalTo: availabilityCard.topAnchor),
            availabilityStack.leadingAnchor.constraint(equalTo: availabilityCard.leadingAnchor),
            availabilityStack.trailingAnchor.constraint(equalTo: availabilityCard.trailingAnchor),
            availabilityStack.bottomAnchor.constraint(equalTo: availabilityCard.bottomAnchor)
        ])
        stackView.addArrangedSubview(availabilityCard)

        setAvailabilityVisible(false)
    }

    private func makeAvailabilityRow(title: String, picker: UIDatePicker, mode: UIDatePicker.Mode) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.black.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false

        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = UIColor(hex: "F1F3F7")
        picker.layer.cornerRadius = 16
        picker.layer.masksToBounds = true

        container.addSubview(label)
        container.addSubview(picker)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            label.centerYAnchor.constraint(equalTo: picker.centerYAnchor),

            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2)
        ])

        return container
    }
    
    func setLoggedIn(_ loggedIn: Bool) {
        isLoggedInState = loggedIn
        signOutButton.isHidden = !loggedIn
        loginButton.isHidden = loggedIn
        signUpButton.isHidden = loggedIn
        updateEditVisibility()

        // ✅ allow switching role always
        switchRoleButton.isHidden = false

        notificationRow.isUserInteractionEnabled = loggedIn
        notificationRow.alpha = loggedIn ? 1.0 : 0.5

        if !loggedIn {
            setAvailabilityVisible(false)
        }
    }

    func setShowsEditButton(_ show: Bool) {
        shouldShowEditButton = show
        updateEditVisibility()
    }

    private func updateEditVisibility() {
        editButton.isHidden = !isLoggedInState || !shouldShowEditButton
    }


    private func buildSignOut() {
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(UIColor(hex: "E54848"), for: .normal)
        signOutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        signOutButton.backgroundColor = UIColor.white
        signOutButton.layer.cornerRadius = 16
        signOutButton.layer.shadowColor = UIColor.black.cgColor
        signOutButton.layer.shadowOpacity = 0.05
        signOutButton.layer.shadowRadius = 10
        signOutButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        signOutButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)

        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        loginButton.backgroundColor = UIColor(hex: "1E6EF7")
        loginButton.layer.cornerRadius = 16
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.05
        loginButton.layer.shadowRadius = 10
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        loginButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        signUpButton.backgroundColor = UIColor.white
        signUpButton.layer.cornerRadius = 16
        signUpButton.layer.shadowColor = UIColor.black.cgColor
        signUpButton.layer.shadowOpacity = 0.05
        signUpButton.layer.shadowRadius = 10
        signUpButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        signUpButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)

        // ✅ Switch Role button (secondary style)
        switchRoleButton.setTitle("Switch Role", for: .normal)
        switchRoleButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        switchRoleButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        switchRoleButton.backgroundColor = UIColor.white
        switchRoleButton.layer.cornerRadius = 16
        switchRoleButton.layer.shadowColor = UIColor.black.cgColor
        switchRoleButton.layer.shadowOpacity = 0.05
        switchRoleButton.layer.shadowRadius = 10
        switchRoleButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        switchRoleButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        switchRoleButton.addTarget(self, action: #selector(switchRolePressed), for: .touchUpInside)

        authStack.axis = .vertical
        authStack.spacing = 12

        // Order:
        // logged in: Sign Out + Switch Role
        // logged out: Log In + Sign Up + Switch Role
        authStack.addArrangedSubview(signOutButton)
        authStack.addArrangedSubview(loginButton)
        authStack.addArrangedSubview(signUpButton)
        authStack.addArrangedSubview(switchRoleButton)

        stackView.addArrangedSubview(authStack)

        setLoggedIn(true)
    }


    private func makeCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }

    private func makeCardStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func pinCardStack(_ stack: UIStackView, to container: UIView) {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4)
        ])
    }

    private func makeSeparator() -> UIView {
        let sep = UIView()
        sep.backgroundColor = UIColor.black.withAlphaComponent(0.06)
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return sep
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.black
        return label
    }

    func setAvailabilityVisible(_ visible: Bool) {
        availabilityVisible = visible
        availabilitySectionLabel.isHidden = !visible
        availabilityCard.isHidden = !visible
    }

    func setAvailabilitySaving(_ saving: Bool) {
        availabilitySaveButton.isEnabled = !saving
        availabilitySaveButton.alpha = saving ? 0.7 : 1.0
    }

    @objc private func backTapped() {
        onBack?()
    }

    @objc private func editTapped() {
        onEdit?()
    }

    @objc private func privacyTapped() {
        onPrivacyTapped?()
    }

    @objc private func termsTapped() {
        onTermsTapped?()
    }

    @objc private func signOutTapped() {
        onSignOut?()
    }

    @objc private func loginTapped() {
        onLogin?()
    }

    @objc private func signUpTapped() {
        onSignup?()
    }

    @objc private func refreshPulled() {
        onRefresh?()
    }

    @objc private func switchRolePressed() {
        onSwitchRole?()
    }

    @objc private func saveAvailabilityTapped() {
        onAvailabilitySave?(availabilityDatePicker.date, availabilityStartPicker.date, availabilityEndPicker.date)
    }

    
    
}

final class ProfileRowView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.55)

        valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor = UIColor.black.withAlphaComponent(0.9)
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ value: String) {
        valueLabel.text = value
    }
}

final class ProfileToggleRowView: UIView {
    private let titleLabel = UILabel()
    private let toggle = UISwitch()
    var onToggleChanged: ((Bool) -> Void)?

    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.55)

        toggle.onTintColor = UIColor(hex: "38A169")
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [titleLabel, toggle])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        toggle.setContentHuggingPriority(.required, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOn(_ isOn: Bool) {
        toggle.setOn(isOn, animated: true)
    }

    @objc private func toggleChanged() {
        onToggleChanged?(toggle.isOn)
    }
}

final class ProfileActionRowButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        contentHorizontalAlignment = .left

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.black.withAlphaComponent(0.35)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(chevron)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            chevron.widthAnchor.constraint(equalToConstant: 12)
        ])

        contentEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 32)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
