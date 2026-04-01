//
//  ArticlesView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ArticlesView: UIView {

    // MARK: - UI
    let profileButton = UIButton(type: .system)

    let searchBar = UISearchBar()
    let segmented = UISegmentedControl(items: ["All", "For You", "Bookmarks"])
    private let segBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

    let featuredCard = FeaturedArticleCardView()
    private let recentHeaderStack = UIStackView()
    private let recentTitleLabel = UILabel()
    let resultsLabel = UILabel()
    let filterCollectionView: UICollectionView
    let tableView = UITableView(frame: .zero, style: .plain)

    private let refreshControl = UIRefreshControl()
    private let headerContainer = UIView()
    private var featuredHeightConstraint: NSLayoutConstraint?
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

    func setSegmentSelection(_ index: Int) {
        segmented.selectedSegmentIndex = index
    }

    func setBookmarksVisible(_ visible: Bool) {
        // UISegmentedControl doesn't easily hide segments normally, 
        // but we can either remove it or just leave it. 
        // The requirement is "uniform", so we'll just keep all 3 segments.
    }

    func updateResults(count: Int) {
        resultsLabel.text = "\(count) article\(count == 1 ? "" : "s")"
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

    func setFeaturedVisible(_ visible: Bool) {
        featuredCard.isHidden = !visible
        featuredHeightConstraint?.constant = visible ? 200 : 0
        setNeedsLayout()
    }

    func setRefreshTarget(_ target: Any?, action: Selector) {
        refreshControl.addTarget(target, action: action, for: .valueChanged)
    }

    private func build() {
        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGlow)

        headerContainer.translatesAutoresizingMaskIntoConstraints = true
        headerContainer.backgroundColor = .clear
        headerContainer.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        let profileConfig = UIImage.SymbolConfiguration(pointSize: 36, weight: .light)
        profileButton.setImage(UIImage(systemName: "person.crop.circle.fill", withConfiguration: profileConfig), for: .normal)
        profileButton.tintColor = .secondaryLabel

        searchBar.placeholder = "Search articles, topics, conditions..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        
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

        segmented.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applySegmentedStyle(segmented)
        segmented.selectedSegmentIndex = 0

        segBlur.translatesAutoresizingMaskIntoConstraints = false
        segBlur.isUserInteractionEnabled = false
        segBlur.layer.cornerRadius = 18
        segBlur.clipsToBounds = true
        segBlur.layer.borderWidth = 0.5
        segBlur.layer.borderColor = UITheme.Colors.glassBorder.cgColor

        recentHeaderStack.axis = .horizontal
        recentHeaderStack.alignment = .center
        recentHeaderStack.distribution = .fill
        recentHeaderStack.translatesAutoresizingMaskIntoConstraints = false

        recentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recentTitleLabel.font = UITheme.Typography.sectionTitle
        recentTitleLabel.textColor = .label
        recentTitleLabel.text = "Recent Articles"

        resultsLabel.translatesAutoresizingMaskIntoConstraints = false
        resultsLabel.font = UITheme.Typography.bodySmallMedium
        resultsLabel.textColor = UITheme.Colors.textSecondary
        resultsLabel.text = "0 articles"

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        recentHeaderStack.addArrangedSubview(recentTitleLabel)
        recentHeaderStack.addArrangedSubview(spacer)
        recentHeaderStack.addArrangedSubview(resultsLabel)

        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.showsHorizontalScrollIndicator = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl

        featuredCard.isHidden = true

        addSubview(tableView)
        tableView.tableHeaderView = headerContainer
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .always
        
        headerContainer.addSubview(searchBar)
        headerContainer.addSubview(segBlur)
        headerContainer.addSubview(segmented)
        headerContainer.addSubview(filterCollectionView)
        headerContainer.addSubview(featuredCard)
        headerContainer.addSubview(recentHeaderStack)

        featuredHeightConstraint = featuredCard.heightAnchor.constraint(equalToConstant: 0)
        featuredHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor),

            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            searchBar.topAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),

            segBlur.topAnchor.constraint(equalTo: segmented.topAnchor),
            segBlur.bottomAnchor.constraint(equalTo: segmented.bottomAnchor),
            segBlur.leadingAnchor.constraint(equalTo: segmented.leadingAnchor),
            segBlur.trailingAnchor.constraint(equalTo: segmented.trailingAnchor),

            segmented.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            segmented.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            segmented.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),
            segmented.heightAnchor.constraint(equalToConstant: 36),

            filterCollectionView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 12),
            filterCollectionView.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            filterCollectionView.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),
            filterCollectionView.heightAnchor.constraint(equalToConstant: 40),

            featuredCard.topAnchor.constraint(equalTo: filterCollectionView.bottomAnchor, constant: 14),
            featuredCard.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            featuredCard.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),

            recentHeaderStack.topAnchor.constraint(equalTo: featuredCard.bottomAnchor, constant: 18),
            recentHeaderStack.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            recentHeaderStack.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),
            recentHeaderStack.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -10)
        ])
    }

    private func configureSegmentButton(_ button: UIButton, title: String, icon: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 27
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)

        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: icon, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.setTitle(" \(title)", for: .normal)
    }

    private func applySegmentStyle(_ button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = UITheme.Colors.accent
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
        } else {
            button.backgroundColor = UITheme.Colors.surface
            button.setTitleColor(UITheme.Colors.textSecondary, for: .normal)
            button.tintColor = UITheme.Colors.textSecondary
        }
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
}
