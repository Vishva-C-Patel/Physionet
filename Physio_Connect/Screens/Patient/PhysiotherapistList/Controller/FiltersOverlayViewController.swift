//
//  FiltersOverlayViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//


import UIKit

final class FiltersOverlayViewController: UIViewController {

    var selectedFilters = Filters()
    var onApply: ((Filters) -> Void)?
    var onDismiss: (() -> Void)?

    private var selectedDistance: Double = 15
    private var selectedRating: Int = 0

    private var specialityButtons: [(String, UIButton)] = []
    private var genderButtons: [(String, UIButton)] = []
    private var ratingButtons: [UIButton] = []

    private let dimView = UIView()
    private let sheetView = UIView()

    private let headerView = UIView()
    private let headerTitle = UILabel()
    private let clearButton = UIButton(type: .system)

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let bottomButtons = UIStackView()

    private let distanceLabel = UILabel()
    private let distanceSlider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        preloadFromSelectedFilters()
    }

    private func preloadFromSelectedFilters() {
        selectedDistance = selectedFilters.maxDistance
        selectedRating = selectedFilters.minRating
        distanceSlider.value = Float(selectedDistance)
        distanceLabel.text = "within \(Int(selectedDistance)) km"
        updateRatingUI()
        updateSelectionUI()
    }

    private func buildUI() {

        // ================= Dim Background =================
        view.addSubview(dimView)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))

        // ================= Sheet View =================
        view.addSubview(sheetView)
        sheetView.backgroundColor = .systemGroupedBackground
        sheetView.layer.cornerRadius = 32
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        sheetView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sheetView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])

        // ================= Header =================
        sheetView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: sheetView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 70)
        ])

        headerTitle.text = "Filters"
        headerTitle.font = .boldSystemFont(ofSize: 22)

        clearButton.setTitle("clear", for: .normal)
        clearButton.setTitleColor(UITheme.Colors.textSecondary, for: .normal)
        clearButton.addTarget(self, action: #selector(resetFilters), for: .touchUpInside)

        [headerTitle, clearButton].forEach {
            headerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            headerTitle.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 5),

            clearButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            clearButton.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor)
        ])

        // ================= Scroll =================
        sheetView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: -100)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // ================= Cards =================
        let specialityCard = makeCardSection(
            title: "Speciality",
            items: ["Knee Physiotherapy", "Neck Physiotherapy", "Shoulder Physiotherapy"],
            storage: &specialityButtons
        )

        let genderCard = makeCardSection(
            title: "Gender Preference",
            items: ["Male", "Female", "Prefer not to say"],
            storage: &genderButtons
        )

        let distanceCard = makeDistanceCard()
        let ratingCard = makeRatingCard()

        [specialityCard, genderCard, distanceCard, ratingCard].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            specialityCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            specialityCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            specialityCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            genderCard.topAnchor.constraint(equalTo: specialityCard.bottomAnchor, constant: 20),
            genderCard.leadingAnchor.constraint(equalTo: specialityCard.leadingAnchor),
            genderCard.trailingAnchor.constraint(equalTo: specialityCard.trailingAnchor),

            distanceCard.topAnchor.constraint(equalTo: genderCard.bottomAnchor, constant: 20),
            distanceCard.leadingAnchor.constraint(equalTo: specialityCard.leadingAnchor),
            distanceCard.trailingAnchor.constraint(equalTo: specialityCard.trailingAnchor),

            ratingCard.topAnchor.constraint(equalTo: distanceCard.bottomAnchor, constant: 20),
            ratingCard.leadingAnchor.constraint(equalTo: specialityCard.leadingAnchor),
            ratingCard.trailingAnchor.constraint(equalTo: specialityCard.trailingAnchor),

            ratingCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])

        // ================= Bottom Buttons =================
        sheetView.addSubview(bottomButtons)
        bottomButtons.axis = .horizontal
        bottomButtons.spacing = 20
        bottomButtons.distribution = .fillEqually
        bottomButtons.translatesAutoresizingMaskIntoConstraints = false

        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.backgroundColor = UITheme.Colors.surface
        cancel.setTitleColor(.label, for: .normal)
        cancel.layer.cornerRadius = 22
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)

        let apply = UIButton(type: .system)
        apply.setTitle("Apply", for: .normal)
        apply.backgroundColor = UITheme.Colors.accent
        apply.setTitleColor(.white, for: .normal)
        apply.layer.cornerRadius = 22
        apply.addTarget(self, action: #selector(applyFiltersTapped), for: .touchUpInside)

        bottomButtons.addArrangedSubview(cancel)
        bottomButtons.addArrangedSubview(apply)

        NSLayoutConstraint.activate([
            bottomButtons.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            bottomButtons.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            bottomButtons.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: -20),
            bottomButtons.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    // MARK: - Reset (clear)
    @objc private func resetFilters() {

        // Speciality
        specialityButtons.forEach { (_, btn) in
            updateButton(btn, selected: false)
        }

        // Gender
        genderButtons.forEach { (_, btn) in
            updateButton(btn, selected: false)
        }

        // Distance
        selectedDistance = 15
        distanceSlider.value = 15
        distanceLabel.text = "within 15 km"

        // Rating
        selectedRating = 0
        updateRatingUI()

        selectedFilters = Filters()
    }

    // MARK: - Apply
    @objc private func applyFiltersTapped() {
        selectedFilters.specialities = specialityButtons.filter { $0.1.isSelected }.map { $0.0 }
        selectedFilters.gender = genderButtons.first(where: { $0.1.isSelected })?.0
        selectedFilters.maxDistance = selectedDistance
        selectedFilters.minRating = selectedRating

        onApply?(selectedFilters)
        dismiss(animated: false) { [weak self] in self?.onDismiss?() }
    }

    // MARK: - Close
    @objc private func close() {
        dismiss(animated: false) { [weak self] in self?.onDismiss?() }
    }

    // ============================================================
    // MARK: Card Builders (same styling)
    // ============================================================

    private func baseCard() -> UIView {
        let v = UIView()
        v.backgroundColor = UITheme.Colors.surface
        v.layer.cornerRadius = 20
        v.layer.shadowOpacity = 0.05
        v.layer.shadowRadius = 5
        v.layer.shadowOffset = .zero
        return v
    }

    private func makeCardSection(title: String,
                                 items: [String],
                                 storage: inout [(String, UIButton)]) -> UIView {

        let card = baseCard()

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        card.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16)
        ])

        var previous: UIView = titleLabel

        for item in items {
            let label = UILabel()
            label.text = item
            label.font = .systemFont(ofSize: 15)
            label.textColor = .label

            let btn = UIButton(type: .custom)
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.addTarget(self, action: #selector(toggleOption(_:)), for: .touchUpInside)

            card.addSubview(label)
            card.addSubview(btn)

            label.translatesAutoresizingMaskIntoConstraints = false
            btn.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 14),
                label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

                btn.centerYAnchor.constraint(equalTo: label.centerYAnchor),
                btn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                btn.widthAnchor.constraint(equalToConstant: 20),
                btn.heightAnchor.constraint(equalToConstant: 20)
            ])

            storage.append((item, btn))
            previous = label
        }

        previous.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16).isActive = true
        return card
    }

    private func makeDistanceCard() -> UIView {
        let card = baseCard()

        let title = UILabel()
        title.text = "Distance"
        title.font = .boldSystemFont(ofSize: 16)

        distanceLabel.text = "within \(Int(selectedDistance)) km"
        distanceLabel.font = .systemFont(ofSize: 14)
        distanceLabel.textColor = UITheme.Colors.textSecondary

        distanceSlider.minimumValue = 1
        distanceSlider.maximumValue = 50
        distanceSlider.value = Float(selectedDistance)
        distanceSlider.addTarget(self, action: #selector(distanceChanged), for: .valueChanged)

        [title, distanceLabel, distanceSlider].forEach {
            card.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            distanceLabel.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            distanceSlider.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            distanceSlider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            distanceSlider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            distanceSlider.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func makeRatingCard() -> UIView {
        let card = baseCard()

        let title = UILabel()
        title.text = "Ratings"
        title.font = .boldSystemFont(ofSize: 16)
        card.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16)
        ])

        var previousStar: UIButton?

        for i in 1...5 {
            let star = UIButton(type: .system)
            star.tag = i
            star.tintColor = .systemYellow
            star.setImage(UIImage(systemName: "star"), for: .normal)
            star.addTarget(self, action: #selector(ratingSelected(_:)), for: .touchUpInside)
            card.addSubview(star)

            star.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                star.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
                star.widthAnchor.constraint(equalToConstant: 26),
                star.heightAnchor.constraint(equalToConstant: 26)
            ])

            if let prev = previousStar {
                star.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 10).isActive = true
            } else {
                star.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
            }

            previousStar = star
            ratingButtons.append(star)
        }

        previousStar?.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16).isActive = true
        return card
    }

    // MARK: - Toggle / Slider / Rating
    @objc private func toggleOption(_ sender: UIButton) {
        if genderButtons.contains(where: { $0.1 == sender }) {
            let willSelect = !sender.isSelected
            genderButtons.forEach { (_, button) in
                updateButton(button, selected: false)
            }
            updateButton(sender, selected: willSelect)
        } else {
            updateButton(sender, selected: !sender.isSelected)
        }
    }

    @objc private func distanceChanged() {
        selectedDistance = Double(Int(distanceSlider.value))
        distanceLabel.text = "within \(Int(selectedDistance)) km"
    }

    @objc private func ratingSelected(_ sender: UIButton) {
        selectedRating = sender.tag
        updateRatingUI()
    }

    private func updateSelectionUI() {
        specialityButtons.forEach { title, button in
            updateButton(button, selected: selectedFilters.specialities.contains(title))
        }
        genderButtons.forEach { title, button in
            updateButton(button, selected: selectedFilters.gender == title)
        }
    }

    private func updateButton(_ button: UIButton, selected: Bool) {
        button.isSelected = selected
        button.backgroundColor = selected ? UITheme.Colors.accent : UITheme.Colors.surface
        button.layer.borderColor = selected ? UIColor.clear.cgColor : UITheme.Colors.border.cgColor
    }

    private func updateRatingUI() {
        ratingButtons.forEach { star in
            let filled = star.tag <= selectedRating
            star.setImage(UIImage(systemName: filled ? "star.fill" : "star"), for: .normal)
        }
    }
}
