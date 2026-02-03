//
//  ArticlesView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ArticlesView: UIView {

    private let topBar = UIView()
    let titleLabel = UILabel()

    let searchBar = UISearchBar()
    private let segmentScrollView = UIScrollView()
    let segmentStack = UIStackView()
    let segmentButtons: [UIButton] = [
        UIButton(type: .system),
        UIButton(type: .system),
        UIButton(type: .system)
    ]

    let featuredCard = FeaturedArticleCardView()
    private let recentHeaderStack = UIStackView()
    private let recentTitleLabel = UILabel()
    let resultsLabel = UILabel()
    let filterCollectionView: UICollectionView
    let tableView = UITableView(frame: .zero, style: .plain)

    private let refreshControl = UIRefreshControl()
    private let headerContainer = UIView()
    private var featuredHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "EAF2FF")
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSegmentSelection(_ index: Int) {
        for (idx, button) in segmentButtons.enumerated() {
            applySegmentStyle(button, selected: idx == index)
        }
    }

    func setBookmarksVisible(_ visible: Bool) {
        segmentButtons[2].isHidden = !visible
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
        topBar.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.translatesAutoresizingMaskIntoConstraints = true
        headerContainer.backgroundColor = .clear
        headerContainer.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Articles"
        titleLabel.font = UITheme.Typography.screenTitle
        titleLabel.textColor = UITheme.Colors.textPrimary
        titleLabel.textAlignment = .center

        searchBar.placeholder = "Search articles, topics, conditions..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.layer.cornerRadius = 20
        searchBar.searchTextField.layer.masksToBounds = true

        segmentScrollView.translatesAutoresizingMaskIntoConstraints = false
        segmentScrollView.showsHorizontalScrollIndicator = false
        segmentScrollView.alwaysBounceHorizontal = true

        segmentStack.axis = .horizontal
        segmentStack.spacing = 10
        segmentStack.translatesAutoresizingMaskIntoConstraints = false

        let segmentTitles = ["All", "For You", "Bookmarks"]
        let segmentIcons = ["drop.fill", "sparkles", "bookmark.fill"]
        for (index, button) in segmentButtons.enumerated() {
            configureSegmentButton(button, title: segmentTitles[index], icon: segmentIcons[index])
            segmentStack.addArrangedSubview(button)
        }
        setSegmentSelection(0)
        setBookmarksVisible(false)

        recentHeaderStack.axis = .horizontal
        recentHeaderStack.alignment = .center
        recentHeaderStack.distribution = .fill
        recentHeaderStack.translatesAutoresizingMaskIntoConstraints = false

        recentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recentTitleLabel.font = UITheme.Typography.sectionTitle
        recentTitleLabel.textColor = .black
        recentTitleLabel.text = "Recent Articles"

        resultsLabel.translatesAutoresizingMaskIntoConstraints = false
        resultsLabel.font = UITheme.Typography.bodySmallMedium
        resultsLabel.textColor = UIColor.black.withAlphaComponent(0.5)
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

        headerContainer.addSubview(topBar)
        topBar.addSubview(titleLabel)

        headerContainer.addSubview(searchBar)
        headerContainer.addSubview(segmentScrollView)
        segmentScrollView.addSubview(segmentStack)
        headerContainer.addSubview(filterCollectionView)
        headerContainer.addSubview(featuredCard)
        headerContainer.addSubview(recentHeaderStack)

        featuredHeightConstraint = featuredCard.heightAnchor.constraint(equalToConstant: 0)
        featuredHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            topBar.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 6),
            topBar.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: topBar.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topBar.trailingAnchor, constant: -16),

            searchBar.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),

            segmentScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            segmentScrollView.leadingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.leadingAnchor),
            segmentScrollView.trailingAnchor.constraint(equalTo: headerContainer.layoutMarginsGuide.trailingAnchor),
            segmentScrollView.heightAnchor.constraint(equalToConstant: 44),

            segmentStack.topAnchor.constraint(equalTo: segmentScrollView.contentLayoutGuide.topAnchor),
            segmentStack.bottomAnchor.constraint(equalTo: segmentScrollView.contentLayoutGuide.bottomAnchor),
            segmentStack.leadingAnchor.constraint(equalTo: segmentScrollView.contentLayoutGuide.leadingAnchor),
            segmentStack.trailingAnchor.constraint(equalTo: segmentScrollView.contentLayoutGuide.trailingAnchor),
            segmentStack.heightAnchor.constraint(equalTo: segmentScrollView.frameLayoutGuide.heightAnchor),

            filterCollectionView.topAnchor.constraint(equalTo: segmentScrollView.bottomAnchor, constant: 12),
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
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.08
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)

        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: icon, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.setTitle(" \(title)", for: .normal)
    }

    private func applySegmentStyle(_ button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = UIColor(hex: "1E6EF7")
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
        } else {
            button.backgroundColor = .white
            button.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .normal)
            button.tintColor = UIColor.black.withAlphaComponent(0.6)
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
