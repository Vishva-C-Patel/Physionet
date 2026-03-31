//
//  VideosView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class VideosView: UIView {

    // MARK: - UI
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
    
    private let segBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let searchBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
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
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        let profileConfig = UIImage.SymbolConfiguration(pointSize: 36, weight: .light)
        profileButton.setImage(UIImage(systemName: "person.crop.circle.fill", withConfiguration: profileConfig), for: .normal)
        profileButton.tintColor = .secondaryLabel

        segmented.selectedSegmentIndex = 0
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.selectedSegmentTintColor = UITheme.Colors.accent.withAlphaComponent(0.6)
        segmented.backgroundColor = .clear
        
        segBlur.translatesAutoresizingMaskIntoConstraints = false
        segBlur.isUserInteractionEnabled = false
        segBlur.layer.cornerRadius = 16
        segBlur.clipsToBounds = true
        segBlur.layer.borderWidth = 0.5
        segBlur.layer.borderColor = UITheme.Colors.glassBorder.cgColor
        segmented.layer.cornerRadius = 16
        segmented.layer.masksToBounds = true
        segmented.setTitleTextAttributes(
            [.foregroundColor: UIColor.white, .font: UITheme.Typography.buttonSmall],
            for: .selected
        )
        segmented.setTitleTextAttributes(
            [.foregroundColor: UIColor.secondaryLabel, .font: UITheme.Typography.buttonSmall],
            for: .normal
        )

        searchBar.placeholder = "Search exercises"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .clear

        searchBlur.translatesAutoresizingMaskIntoConstraints = false
        searchBlur.isUserInteractionEnabled = false
        searchBlur.layer.cornerRadius = 12
        searchBlur.clipsToBounds = true
        searchBlur.layer.borderWidth = 0.5
        searchBlur.layer.borderColor = UITheme.Colors.glassBorder.cgColor
        searchBar.searchTextField.insertSubview(searchBlur, at: 0)

        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.showsHorizontalScrollIndicator = false

        programRedeemCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(programRedeemCard)
        programRedeemCard.isHidden = true

        redeemIcon.translatesAutoresizingMaskIntoConstraints = false
        redeemIcon.image = UIImage(systemName: "ticket.fill")
        redeemIcon.tintColor = UITheme.Colors.accent
        redeemIcon.contentMode = .scaleAspectFit

        redeemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        redeemTitleLabel.text = "Have a program code?"
        redeemTitleLabel.font = UITheme.Typography.cardTitle
        redeemTitleLabel.textColor = .label

        redeemSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        redeemSubtitleLabel.text = "Paste it here to unlock your assigned plan."
        redeemSubtitleLabel.font = UITheme.Typography.caption
        redeemSubtitleLabel.textColor = .secondaryLabel

        redeemInputContainer.translatesAutoresizingMaskIntoConstraints = false
        redeemInputContainer.backgroundColor = UITheme.Colors.neutralFill
        redeemInputContainer.layer.cornerRadius = 14
        redeemInputContainer.layer.borderWidth = 0.5
        redeemInputContainer.layer.borderColor = UITheme.Colors.border.cgColor

        redeemCodeField.translatesAutoresizingMaskIntoConstraints = false
        redeemCodeField.placeholder = "Enter code (e.g. PROG-AB12CD)"
        redeemCodeField.font = UITheme.Typography.buttonSmall
        redeemCodeField.autocapitalizationType = .allCharacters
        redeemCodeField.autocorrectionType = .no
        redeemCodeField.spellCheckingType = .no
        redeemCodeField.borderStyle = .none
        redeemCodeField.textColor = .label

        redeemInlineButton.translatesAutoresizingMaskIntoConstraints = false
        redeemInlineButton.setTitle("Redeem", for: .normal)
        redeemInlineButton.titleLabel?.font = UITheme.Typography.buttonSmall
        redeemInlineButton.backgroundColor = UITheme.Colors.accent
        redeemInlineButton.setTitleColor(.white, for: .normal)
        redeemInlineButton.layer.cornerRadius = 10
        redeemInlineButton.contentEdgeInsets = UIEdgeInsets(top: 9, left: 14, bottom: 9, right: 14)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl

        emptyCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(emptyCard)
        emptyCard.isHidden = true

        emptyTitle.translatesAutoresizingMaskIntoConstraints = false
        emptyTitle.text = "No Program Yet"
        emptyTitle.font = UITheme.Typography.sectionTitle
        emptyTitle.textColor = .label

        emptySub.translatesAutoresizingMaskIntoConstraints = false
        emptySub.text = "Redeem your physiotherapist's code to unlock your personalized program."
        emptySub.font = UITheme.Typography.bodySmall
        emptySub.textColor = UITheme.Colors.textSecondary
        emptySub.numberOfLines = 0

        redeemButton.translatesAutoresizingMaskIntoConstraints = false
        redeemButton.setTitle("Redeem Code", for: .normal)
        redeemButton.titleLabel?.font = UITheme.Typography.button
        redeemButton.backgroundColor = UITheme.Colors.accent
        redeemButton.setTitleColor(.white, for: .normal)
        redeemButton.layer.cornerRadius = 14
        redeemButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        // addSubview(topBar)
        // topBar.addSubview(titleLabel)
        // topBar.addSubview(profileButton)
        addSubview(segBlur)
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
            segBlur.topAnchor.constraint(equalTo: segmented.topAnchor),
            segBlur.bottomAnchor.constraint(equalTo: segmented.bottomAnchor),
            segBlur.leadingAnchor.constraint(equalTo: segmented.leadingAnchor),
            segBlur.trailingAnchor.constraint(equalTo: segmented.trailingAnchor),

            segmented.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            segmented.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmented.heightAnchor.constraint(equalToConstant: 32),

            searchBar.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            searchBlur.topAnchor.constraint(equalTo: searchBar.searchTextField.topAnchor),
            searchBlur.bottomAnchor.constraint(equalTo: searchBar.searchTextField.bottomAnchor),
            searchBlur.leadingAnchor.constraint(equalTo: searchBar.searchTextField.leadingAnchor),
            searchBlur.trailingAnchor.constraint(equalTo: searchBar.searchTextField.trailingAnchor),

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
