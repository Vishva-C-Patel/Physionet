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
    private let backgroundGlow = AppBackgroundTopGlowView()

    let locationIcon = UIImageView()
    let cityLabel: UILabel = {
        let l = UILabel()
        l.text = "Chennai"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UITheme.Colors.textSecondary
        return l
    }()

    let searchBar = UISearchBar()

    let selectDateLabel: UILabel = {
        let l = UILabel()
        l.text = "Select date and time"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UITheme.Colors.textSecondary
        return l
    }()

    let datePill = UIButton(type: .system)
    let timePill = UIButton(type: .system)
    let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "No physiotherapists found matching your criteria."
        l.font = .systemFont(ofSize: 14)
        l.textColor = UITheme.Colors.textSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    // MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGlow)

        setupTable()
        setupTableHeaderContents()

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Table
    private func setupTable() {
        tableView.register(PhysiotherapistCardCell.self, forCellReuseIdentifier: PhysiotherapistCardCell.reuseID)
        addSubview(tableView)
        addSubview(emptyStateLabel)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.contentInsetAdjustmentBehavior = .always
 
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 100),
            emptyStateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
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
        searchBar.placeholder = "name, neck, back..."
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.backgroundColor = .clear

        let searchField = searchBar.searchTextField
        searchField.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        searchField.layer.cornerRadius = 20
        searchField.layer.masksToBounds = true
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = searchField.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        searchField.insertSubview(blurView, at: 0)

        searchField.attributedPlaceholder = NSAttributedString(
            string: "name, neck, back...",
            attributes: [.foregroundColor: UIColor.systemGray]
        )

        // Hugging priority
        searchBar.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // Pills style
        [datePill, timePill].forEach {
            $0.setTitleColor(.label, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            $0.backgroundColor = UITheme.Colors.surface
            $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UITheme.Colors.border.cgColor
        }
        datePill.setTitle("13 Nov 2025", for: .normal)
        timePill.setTitle("10:35 AM", for: .normal)

        [locationIcon, cityLabel,
         searchBar,
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
            searchBar.trailingAnchor.constraint(equalTo: headerContentView.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

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
