//
//  PhysioReportsView.swift
//  Physio_Connect
//
//  Created by Codex on 21/01/26.
//

import UIKit

final class PhysioReportsView: UIView {
    struct PatientVM {
        let id: UUID
        let name: String
        let age: String
        let location: String
        let programText: String
        let adherencePercent: Int
    }

    let tableView = UITableView(frame: .zero, style: .plain)
    let searchBar = UISearchBar()
    let refreshControl = UIRefreshControl()

    private let emptyLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        backgroundColor = UIColor(hex: "E6F1FF")

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search patients or programs..."
        searchBar.backgroundImage = UIImage()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.register(ReportPatientCell.self, forCellReuseIdentifier: ReportPatientCell.reuseID)
        tableView.refreshControl = refreshControl

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No program assignments yet.\nShare a program code to see patient reports."
        emptyLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        emptyLabel.textColor = UIColor.black.withAlphaComponent(0.55)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.isUserInteractionEnabled = false

        addSubview(searchBar)
        addSubview(tableView)
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
        if show { bringSubviewToFront(emptyLabel) }
    }
}

final class ReportPatientCell: UITableViewCell {
    static let reuseID = "ReportPatientCell"

    private let card = UIView()
    private let nameLabel = UILabel()
    private let agePill = UILabel()
    private let programLabel = UILabel()
    private let locationLabel = UILabel()
    private let divider = UIView()
    private let adherenceTitleLabel = UILabel()
    private let adherenceValueLabel = UILabel()
    private let adherenceBar = UIProgressView(progressViewStyle: .default)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(card)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = UIColor(hex: "102A43")

        agePill.translatesAutoresizingMaskIntoConstraints = false
        agePill.font = .systemFont(ofSize: 12, weight: .semibold)
        agePill.textColor = UIColor(hex: "1E6EF7")
        agePill.backgroundColor = UIColor(hex: "E6F1FF")
        agePill.textAlignment = .center
        agePill.layer.cornerRadius = 12
        agePill.clipsToBounds = true
        agePill.setContentHuggingPriority(.required, for: .horizontal)

        programLabel.translatesAutoresizingMaskIntoConstraints = false
        programLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        programLabel.textColor = UIColor.black.withAlphaComponent(0.75)
        programLabel.numberOfLines = 0

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = .systemFont(ofSize: 14, weight: .medium)
        locationLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        locationLabel.numberOfLines = 0

        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.black.withAlphaComponent(0.05)

        adherenceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        adherenceTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        adherenceTitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        adherenceTitleLabel.text = "Adherence Rate"

        adherenceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        adherenceValueLabel.font = .systemFont(ofSize: 13, weight: .bold)
        adherenceValueLabel.textColor = UIColor(hex: "1E6EF7")
        adherenceValueLabel.textAlignment = .right

        adherenceBar.translatesAutoresizingMaskIntoConstraints = false
        adherenceBar.trackTintColor = UIColor.black.withAlphaComponent(0.06)
        adherenceBar.progressTintColor = UIColor(hex: "1E6EF7")
        adherenceBar.layer.cornerRadius = 4
        adherenceBar.clipsToBounds = true

        card.addSubview(nameLabel)
        card.addSubview(agePill)
        card.addSubview(programLabel)
        card.addSubview(locationLabel)
        card.addSubview(divider)
        card.addSubview(adherenceTitleLabel)
        card.addSubview(adherenceValueLabel)
        card.addSubview(adherenceBar)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: agePill.leadingAnchor, constant: -10),

            agePill.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            agePill.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            agePill.heightAnchor.constraint(equalToConstant: 24),
            agePill.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            programLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            programLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            programLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            locationLabel.topAnchor.constraint(equalTo: programLabel.bottomAnchor, constant: 6),
            locationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            divider.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 1),

            adherenceTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 10),
            adherenceTitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            adherenceValueLabel.centerYAnchor.constraint(equalTo: adherenceTitleLabel.centerYAnchor),
            adherenceValueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            adherenceValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: adherenceTitleLabel.trailingAnchor, constant: 8),

            adherenceBar.topAnchor.constraint(equalTo: adherenceTitleLabel.bottomAnchor, constant: 8),
            adherenceBar.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            adherenceBar.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            adherenceBar.heightAnchor.constraint(equalToConstant: 6),
            adherenceBar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func apply(_ vm: PhysioReportsView.PatientVM) {
        nameLabel.text = vm.name
        let ageValue = vm.age.trimmingCharacters(in: .whitespacesAndNewlines)
        agePill.isHidden = ageValue.isEmpty || ageValue == "—"
        agePill.text = ageValue.isEmpty ? nil : "  \(ageValue)  "

        programLabel.text = "Program Assigned: \(vm.programText)"
        locationLabel.text = "Location: \(vm.location)"
        adherenceValueLabel.text = "\(vm.adherencePercent)%"
        adherenceBar.setProgress(Float(vm.adherencePercent) / 100.0, animated: false)
    }
}
