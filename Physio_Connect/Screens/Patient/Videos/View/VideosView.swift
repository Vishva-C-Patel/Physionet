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

    let programSummaryContainer = UIView()

    private let refreshControl = UIRefreshControl()
    
    private let searchBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

    private let backgroundGlow = AppBackgroundTopGlowView()

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let headerContainer = UIView()

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
        UIView.performWithoutAnimation {
            updateHeaderLayout()
        }
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
        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGlow)

        // Header container approach (like ArticlesView) for liquid glass nav bar
        headerContainer.translatesAutoresizingMaskIntoConstraints = true
        headerContainer.backgroundColor = .clear
        headerContainer.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        headerContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 170)

        profileButton.translatesAutoresizingMaskIntoConstraints = false
        let profileConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        profileButton.setImage(UIImage(systemName: "person.crop.circle.fill", withConfiguration: profileConfig), for: .normal)
        profileButton.tintColor = UITheme.Colors.textSecondary
        profileButton.imageView?.contentMode = .scaleAspectFill
        profileButton.layer.cornerRadius = 16
        profileButton.clipsToBounds = true
        NSLayoutConstraint.activate([
            profileButton.widthAnchor.constraint(equalToConstant: 32),
            profileButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.selectedSegmentIndex = 0
        UITheme.applySegmentedStyle(segmented)
        
        searchBar.placeholder = "Search exercises"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
            textField.layer.cornerRadius = 22
            textField.layer.masksToBounds = true
            
            searchBlur.translatesAutoresizingMaskIntoConstraints = false
            searchBlur.isUserInteractionEnabled = false
            searchBlur.layer.cornerRadius = 22
            searchBlur.clipsToBounds = true
            searchBlur.layer.borderWidth = 0.5
            searchBlur.layer.borderColor = UITheme.Colors.glassBorder.cgColor
            textField.insertSubview(searchBlur, at: 0)
            
            NSLayoutConstraint.activate([
                searchBlur.topAnchor.constraint(equalTo: textField.topAnchor),
                searchBlur.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
                searchBlur.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                searchBlur.trailingAnchor.constraint(equalTo: textField.trailingAnchor)
            ])
        }

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
        tableView.contentInsetAdjustmentBehavior = .always

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
        redeemButton.layer.cornerRadius = 27
        redeemButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        // Table view with header container (liquid glass scrolling)
        addSubview(tableView)
        addSubview(emptyCard)
        tableView.tableHeaderView = headerContainer
        tableView.contentInset = .zero

        // Header subviews
        headerContainer.addSubview(segmented)
        headerContainer.addSubview(searchBar)
        headerContainer.addSubview(filterCollectionView)
        headerContainer.addSubview(programRedeemCard)
        headerContainer.addSubview(programSummaryContainer)
        
        programSummaryContainer.translatesAutoresizingMaskIntoConstraints = false
        
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
            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor),

            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Header internal layout
            segmented.topAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.topAnchor),
            segmented.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            segmented.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),
            segmented.heightAnchor.constraint(equalToConstant: 36),

            searchBar.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -8),

            filterCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            filterCollectionView.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            filterCollectionView.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),

            programRedeemCard.topAnchor.constraint(equalTo: filterCollectionView.bottomAnchor, constant: 8),
            programRedeemCard.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            programRedeemCard.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),
            
            programSummaryContainer.topAnchor.constraint(equalTo: programRedeemCard.bottomAnchor, constant: 8),
            programSummaryContainer.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            programSummaryContainer.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            programSummaryContainer.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -10),

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

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeaderLayout()
    }

    func updateHeaderLayout() {
        guard let headerView = tableView.tableHeaderView else { return }
        let headerWidth = tableView.bounds.width
        if headerWidth <= 0 { return }
        headerView.frame.size.width = headerWidth
        headerView.layoutIfNeeded()
        let targetSize = CGSize(width: headerWidth, height: UIView.layoutFittingCompressedSize.height)
        let height = headerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        if headerView.frame.size.height != height || headerView.frame.size.width != headerWidth {
            headerView.frame = CGRect(x: 0, y: 0, width: headerWidth, height: height)
            tableView.tableHeaderView = headerView
        }
    }

    func setProgramSummaryView(_ view: UIView?) {
        programSummaryContainer.subviews.forEach { $0.removeFromSuperview() }
        if let view = view {
            view.translatesAutoresizingMaskIntoConstraints = false
            programSummaryContainer.addSubview(view)
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: programSummaryContainer.topAnchor),
                view.leadingAnchor.constraint(equalTo: programSummaryContainer.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: programSummaryContainer.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: programSummaryContainer.bottomAnchor)
            ])
        }
        updateHeaderLayout()
    }
}
