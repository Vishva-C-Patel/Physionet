//
//  PhysiotherapistListView.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//
//
//  PhysiotherapistListView.swift
//  Physio_Connect
//

import UIKit

final class PhysiotherapistListView: UIView {

    // MARK: - Table
    let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Table Header (content)
    private let headerContentView = UIView()

    let locationIcon = UIImageView()
    let cityLabel: UILabel = {
        let l = UILabel()
        l.text = "Chennai"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UITheme.Colors.textSecondary
        return l
    }()

    let searchBar = UISearchBar()
    let filterButton = UIButton(type: .system)

    let selectDateLabel: UILabel = {
        let l = UILabel()
        l.text = "Select date and time"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UITheme.Colors.textSecondary
        return l
    }()

    let datePill = UIButton(type: .system)
    let timePill = UIButton(type: .system)

    // MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupTable()
        setupTableHeaderContents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Table
    private func setupTable() {
        tableView.register(PhysiotherapistCardCell.self, forCellReuseIdentifier: PhysiotherapistCardCell.reuseID)
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: Table Header Contents
    private func setupTableHeaderContents() {
        tableView.tableHeaderView = headerContentView
        headerContentView.translatesAutoresizingMaskIntoConstraints = false
        headerContentView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        headerContentView.backgroundColor = .clear
        headerContentView.layoutIfNeeded()

        // Custom location icon from assets (fallback to SF Symbol)
        locationIcon.image = UIImage(named: "location_icon") ?? UIImage(systemName: "location.fill")
        locationIcon.tintColor = UITheme.Colors.accent

        // Search bar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "name, neck, back.."

        // REMOVE SYSTEM BACKGROUND (VERY IMPORTANT)
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.backgroundColor = .clear

        // CUSTOMIZE INNER TEXT FIELD
        let textField = searchBar.searchTextField
        textField.backgroundColor = UITheme.Colors.neutralFill
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UITheme.Colors.border.cgColor
        textField.layer.cornerRadius = 12
        textField.clipsToBounds = true

        textField.attributedPlaceholder = NSAttributedString(
            string: "name, neck, back...",
            attributes: [.foregroundColor: UIColor.systemGray]
        )

        // Hugging priority
        searchBar.setContentHuggingPriority(.defaultLow, for: .horizontal)
        filterButton.setContentHuggingPriority(.required, for: .horizontal)

        // Filter button
        filterButton.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        filterButton.tintColor = UITheme.Colors.accent

        // Pills style
        [datePill, timePill].forEach {
            $0.setTitleColor(.label, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            $0.backgroundColor = UITheme.Colors.surface
            $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }
        datePill.setTitle("13 Nov 2025", for: .normal)
        timePill.setTitle("10:35 AM", for: .normal)

        [locationIcon, cityLabel,
         searchBar, filterButton,
         selectDateLabel,
         datePill, timePill].forEach {
            headerContentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // Location row
            locationIcon.topAnchor.constraint(equalTo: headerContentView.topAnchor, constant: 8),
            locationIcon.leadingAnchor.constraint(equalTo: headerContentView.leadingAnchor, constant: 16),
            locationIcon.widthAnchor.constraint(equalToConstant: 16),
            locationIcon.heightAnchor.constraint(equalToConstant: 16),

            cityLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            cityLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 6),

            // Search bar
            searchBar.topAnchor.constraint(equalTo: locationIcon.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: headerContentView.leadingAnchor, constant: 16),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            // Filter button
            filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            filterButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 10),
            filterButton.trailingAnchor.constraint(equalTo: headerContentView.trailingAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 32),
            filterButton.heightAnchor.constraint(equalToConstant: 32),

            // Select date label
            selectDateLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            selectDateLabel.leadingAnchor.constraint(equalTo: headerContentView.leadingAnchor, constant: 16),

            // Date / Time pills
            datePill.topAnchor.constraint(equalTo: selectDateLabel.bottomAnchor, constant: 8),
            datePill.leadingAnchor.constraint(equalTo: headerContentView.leadingAnchor, constant: 16),
            datePill.heightAnchor.constraint(equalToConstant: 30),

            timePill.leadingAnchor.constraint(equalTo: datePill.trailingAnchor, constant: 8),
            timePill.centerYAnchor.constraint(equalTo: datePill.centerYAnchor),
            timePill.heightAnchor.constraint(equalToConstant: 30),
            timePill.bottomAnchor.constraint(equalTo: headerContentView.bottomAnchor, constant: -16)
        ])
    }

    // Resize header for AutoLayout
    func layoutHeaderIfNeeded() {
        headerContentView.setNeedsLayout()
        headerContentView.layoutIfNeeded()

        let width = tableView.bounds.width
        let size = headerContentView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        )

        headerContentView.frame = CGRect(x: 0, y: 0, width: width, height: size.height)
        tableView.tableHeaderView = headerContentView
    }

    func setDateText(_ text: String) {
        datePill.setTitle(text, for: .normal)
    }

    func setTimeText(_ text: String) {
        timePill.setTitle(text, for: .normal)
    }
}
