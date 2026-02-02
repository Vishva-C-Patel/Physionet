//
//  VideosView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class VideosView: UIView {

    private let topBar = UIView()
    let titleLabel = UILabel()
    let profileButton = UIButton(type: .system)
    let segmented = UISegmentedControl(items: ["Free Exercises", "My Program"])
    let searchBar = UISearchBar()
    let filterCollectionView: UICollectionView
    let tableView = UITableView(frame: .zero, style: .plain)
    let programRedeemCard = UIView()
    private let redeemIcon = UIImageView()
    private let redeemTitleLabel = UILabel()
    private let redeemSubtitleLabel = UILabel()
    private let redeemInputContainer = UIView()
    let redeemCodeField = UITextField()
    let redeemInlineButton = UIButton(type: .system)

    private var searchHeightConstraint: NSLayoutConstraint?
    private var filterHeightConstraint: NSLayoutConstraint?
    private var redeemCardHeightConstraint: NSLayoutConstraint?

    private let emptyCard = UIView()
    private let emptyTitle = UILabel()
    private let emptySub = UILabel()
    let redeemButton = UIButton(type: .system)

    private let refreshControl = UIRefreshControl()

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E3F0FF")
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showEmptyState(_ show: Bool) {
        emptyCard.isHidden = !show
        tableView.isHidden = show
    }

    func configureEmptyState(title: String, message: String, showRedeem: Bool) {
        emptyTitle.text = title
        emptySub.text = message
        redeemButton.isHidden = !showRedeem
    }

    func setProgramMode(_ enabled: Bool) {
        searchBar.isHidden = enabled
        filterCollectionView.isHidden = enabled
        searchHeightConstraint?.constant = enabled ? 0 : 44
        filterHeightConstraint?.constant = enabled ? 0 : 40
        if !enabled {
            setProgramRedeemVisible(false)
        }
        layoutIfNeeded()
    }

    func setProgramRedeemVisible(_ visible: Bool) {
        programRedeemCard.isHidden = !visible
        redeemCardHeightConstraint?.constant = visible ? 126 : 0
        if !visible { redeemCodeField.text = "" }
    }

    func setRefreshing(_ refreshing: Bool) {
        if refreshing {
            if !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
    }

    func setRefreshTarget(_ target: Any?, action: Selector) {
        refreshControl.addTarget(target, action: action, for: .valueChanged)
    }

    private func build() {
        topBar.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Exercises"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center

        profileButton.translatesAutoresizingMaskIntoConstraints = false
        let profileConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        profileButton.setImage(UIImage(systemName: "person.circle", withConfiguration: profileConfig), for: .normal)
        profileButton.tintColor = UIColor.black.withAlphaComponent(0.65)

        segmented.selectedSegmentIndex = 0
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.selectedSegmentTintColor = UIColor(hex: "1E6EF7")
        segmented.backgroundColor = .white
        segmented.layer.cornerRadius = 16
        segmented.layer.masksToBounds = true
        segmented.setTitleTextAttributes(
            [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
            for: .selected
        )
        segmented.setTitleTextAttributes(
            [.foregroundColor: UIColor.black.withAlphaComponent(0.65), .font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
            for: .normal
        )

        searchBar.placeholder = "Search exercises"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.layer.cornerRadius = 16
        searchBar.searchTextField.layer.masksToBounds = true

        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.showsHorizontalScrollIndicator = false

        programRedeemCard.translatesAutoresizingMaskIntoConstraints = false
        programRedeemCard.backgroundColor = UIColor(hex: "F7FAFF")
        programRedeemCard.layer.cornerRadius = 18
        programRedeemCard.layer.borderWidth = 1
        programRedeemCard.layer.borderColor = UIColor(hex: "D7E6FF").cgColor
        programRedeemCard.layer.shadowColor = UIColor.black.cgColor
        programRedeemCard.layer.shadowOpacity = 0.05
        programRedeemCard.layer.shadowRadius = 12
        programRedeemCard.layer.shadowOffset = CGSize(width: 0, height: 6)
        programRedeemCard.isHidden = true

        redeemIcon.translatesAutoresizingMaskIntoConstraints = false
        redeemIcon.image = UIImage(systemName: "ticket.fill")
        redeemIcon.tintColor = UIColor(hex: "1E6EF7")
        redeemIcon.contentMode = .scaleAspectFit

        redeemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        redeemTitleLabel.text = "Have a program code?"
        redeemTitleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        redeemTitleLabel.textColor = UIColor(hex: "153E75")

        redeemSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        redeemSubtitleLabel.text = "Paste it here to unlock your assigned plan."
        redeemSubtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        redeemSubtitleLabel.textColor = UIColor(hex: "5E7394")

        redeemInputContainer.translatesAutoresizingMaskIntoConstraints = false
        redeemInputContainer.backgroundColor = .white
        redeemInputContainer.layer.cornerRadius = 12
        redeemInputContainer.layer.borderWidth = 1
        redeemInputContainer.layer.borderColor = UIColor(hex: "D5E3FB").cgColor

        redeemCodeField.translatesAutoresizingMaskIntoConstraints = false
        redeemCodeField.placeholder = "Enter code (e.g. PROG-AB12CD)"
        redeemCodeField.font = .systemFont(ofSize: 14, weight: .semibold)
        redeemCodeField.autocapitalizationType = .allCharacters
        redeemCodeField.autocorrectionType = .no
        redeemCodeField.spellCheckingType = .no
        redeemCodeField.borderStyle = .none
        redeemCodeField.textColor = UIColor(hex: "1A3256")

        redeemInlineButton.translatesAutoresizingMaskIntoConstraints = false
        redeemInlineButton.setTitle("Redeem", for: .normal)
        redeemInlineButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        redeemInlineButton.backgroundColor = UIColor(hex: "1E6EF7")
        redeemInlineButton.setTitleColor(.white, for: .normal)
        redeemInlineButton.layer.cornerRadius = 10
        redeemInlineButton.contentEdgeInsets = UIEdgeInsets(top: 9, left: 14, bottom: 9, right: 14)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl

        emptyCard.translatesAutoresizingMaskIntoConstraints = false
        emptyCard.backgroundColor = .white
        emptyCard.layer.cornerRadius = 22
        emptyCard.layer.shadowColor = UIColor.black.cgColor
        emptyCard.layer.shadowOpacity = 0.08
        emptyCard.layer.shadowRadius = 10
        emptyCard.layer.shadowOffset = CGSize(width: 0, height: 6)
        emptyCard.isHidden = true

        emptyTitle.translatesAutoresizingMaskIntoConstraints = false
        emptyTitle.text = "No Program Yet"
        emptyTitle.font = .systemFont(ofSize: 20, weight: .bold)
        emptyTitle.textColor = .black

        emptySub.translatesAutoresizingMaskIntoConstraints = false
        emptySub.text = "Redeem your physiotherapist's code to unlock your personalized program."
        emptySub.font = .systemFont(ofSize: 14, weight: .regular)
        emptySub.textColor = .darkGray
        emptySub.numberOfLines = 0

        redeemButton.translatesAutoresizingMaskIntoConstraints = false
        redeemButton.setTitle("Redeem Code", for: .normal)
        redeemButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        redeemButton.backgroundColor = UIColor(hex: "1E6EF7")
        redeemButton.setTitleColor(.white, for: .normal)
        redeemButton.layer.cornerRadius = 14
        redeemButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        addSubview(topBar)
        topBar.addSubview(titleLabel)
        topBar.addSubview(profileButton)
        addSubview(segmented)
        addSubview(searchBar)
        addSubview(filterCollectionView)
        addSubview(programRedeemCard)
        addSubview(tableView)
        addSubview(emptyCard)
        programRedeemCard.addSubview(redeemIcon)
        programRedeemCard.addSubview(redeemTitleLabel)
        programRedeemCard.addSubview(redeemSubtitleLabel)
        programRedeemCard.addSubview(redeemInputContainer)
        redeemInputContainer.addSubview(redeemCodeField)
        redeemInputContainer.addSubview(redeemInlineButton)

        emptyCard.addSubview(emptyTitle)
        emptyCard.addSubview(emptySub)
        emptyCard.addSubview(redeemButton)

        searchHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 44)
        filterHeightConstraint = filterCollectionView.heightAnchor.constraint(equalToConstant: 40)
        redeemCardHeightConstraint = programRedeemCard.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            topBar.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            profileButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
            profileButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 40),
            profileButton.heightAnchor.constraint(equalToConstant: 40),

            segmented.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 10),
            segmented.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmented.heightAnchor.constraint(equalToConstant: 44),

            searchBar.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            filterCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            filterCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            filterCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            programRedeemCard.topAnchor.constraint(equalTo: filterCollectionView.bottomAnchor, constant: 8),
            programRedeemCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            programRedeemCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            redeemIcon.leadingAnchor.constraint(equalTo: programRedeemCard.leadingAnchor, constant: 14),
            redeemIcon.topAnchor.constraint(equalTo: programRedeemCard.topAnchor, constant: 12),
            redeemIcon.widthAnchor.constraint(equalToConstant: 18),
            redeemIcon.heightAnchor.constraint(equalToConstant: 18),

            redeemTitleLabel.centerYAnchor.constraint(equalTo: redeemIcon.centerYAnchor),
            redeemTitleLabel.leadingAnchor.constraint(equalTo: redeemIcon.trailingAnchor, constant: 8),
            redeemTitleLabel.trailingAnchor.constraint(equalTo: programRedeemCard.trailingAnchor, constant: -12),

            redeemSubtitleLabel.topAnchor.constraint(equalTo: redeemTitleLabel.bottomAnchor, constant: 4),
            redeemSubtitleLabel.leadingAnchor.constraint(equalTo: redeemTitleLabel.leadingAnchor),
            redeemSubtitleLabel.trailingAnchor.constraint(equalTo: programRedeemCard.trailingAnchor, constant: -12),

            redeemInputContainer.topAnchor.constraint(equalTo: redeemSubtitleLabel.bottomAnchor, constant: 10),
            redeemInputContainer.leadingAnchor.constraint(equalTo: programRedeemCard.leadingAnchor, constant: 12),
            redeemInputContainer.trailingAnchor.constraint(equalTo: programRedeemCard.trailingAnchor, constant: -12),
            redeemInputContainer.bottomAnchor.constraint(equalTo: programRedeemCard.bottomAnchor, constant: -12),
            redeemInputContainer.heightAnchor.constraint(equalToConstant: 42),

            redeemCodeField.leadingAnchor.constraint(equalTo: redeemInputContainer.leadingAnchor, constant: 12),
            redeemCodeField.centerYAnchor.constraint(equalTo: redeemInputContainer.centerYAnchor),

            redeemInlineButton.leadingAnchor.constraint(equalTo: redeemCodeField.trailingAnchor, constant: 10),
            redeemInlineButton.trailingAnchor.constraint(equalTo: redeemInputContainer.trailingAnchor, constant: -8),
            redeemInlineButton.centerYAnchor.constraint(equalTo: redeemInputContainer.centerYAnchor),
            redeemInlineButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 86),

            tableView.topAnchor.constraint(equalTo: programRedeemCard.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyCard.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emptyCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            emptyTitle.topAnchor.constraint(equalTo: emptyCard.topAnchor, constant: 18),
            emptyTitle.leadingAnchor.constraint(equalTo: emptyCard.leadingAnchor, constant: 18),
            emptyTitle.trailingAnchor.constraint(equalTo: emptyCard.trailingAnchor, constant: -18),

            emptySub.topAnchor.constraint(equalTo: emptyTitle.bottomAnchor, constant: 10),
            emptySub.leadingAnchor.constraint(equalTo: emptyCard.leadingAnchor, constant: 18),
            emptySub.trailingAnchor.constraint(equalTo: emptyCard.trailingAnchor, constant: -18),

            redeemButton.topAnchor.constraint(equalTo: emptySub.bottomAnchor, constant: 16),
            redeemButton.leadingAnchor.constraint(equalTo: emptyCard.leadingAnchor, constant: 18),
            redeemButton.trailingAnchor.constraint(equalTo: emptyCard.trailingAnchor, constant: -18),
            redeemButton.bottomAnchor.constraint(equalTo: emptyCard.bottomAnchor, constant: -18)
        ])

        searchHeightConstraint?.isActive = true
        filterHeightConstraint?.isActive = true
        redeemCardHeightConstraint?.isActive = true
    }
}
