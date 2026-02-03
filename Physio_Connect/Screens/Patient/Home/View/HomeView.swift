//
//  HomeView.swift
//  Physio_Connect
//
//  Created by Ayush Rai on 31/12/25.
//

import UIKit

final class HomeView: UIView {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let topBar = UIView()
    private let locationIcon = UIImageView()
    private let locationLabel = UILabel()
    let profileButton = UIButton(type: .system)

    private let titleLabel = UILabel()

    let carousel = HomeCardsCarouselView()

    private let videosHeader = SectionHeaderView(title: "Free Exercise Videos", actionTitle: "View All")
    let videosCollectionView: UICollectionView
    private var videosHeightConstraint: NSLayoutConstraint?

    private let progressTitle = UILabel()
    let painCard = HomePainTrendCardView()
    let adherenceCard = HomeAdherenceCardView()
    private let upNextTitle = UILabel()
    let upNextCard = HomeUpNextCardView()
    private var progressTitleHeightConstraint: NSLayoutConstraint?
    private var painCardCollapsedConstraint: NSLayoutConstraint?
    private var adherenceCardCollapsedConstraint: NSLayoutConstraint?
    private var progressTopSpacingConstraint: NSLayoutConstraint?
    private var painTopSpacingConstraint: NSLayoutConstraint?
    private var adherenceTopSpacingConstraint: NSLayoutConstraint?
    private var upNextTitleHeightConstraint: NSLayoutConstraint?
    private var upNextCardHeightConstraint: NSLayoutConstraint?
    private var upNextCardCollapsedConstraint: NSLayoutConstraint?
    private var upNextTopSpacingConstraint: NSLayoutConstraint?
    private var upNextCardTopConstraint: NSLayoutConstraint?
    private var upNextBottomSpacingConstraint: NSLayoutConstraint?
    private var isProgressVisible = true
    private var isUpNextVisible = true
    private let articlesTitle = UILabel()
    let articlesSegmented = UISegmentedControl(items: ["Recent", "For You"])
    let articlesTableView = UITableView(frame: .zero, style: .plain)
    private var articlesHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 12
        videosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E3F0FF")
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomInset: CGFloat = 64
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }

    private func build() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        locationIcon.image = UIImage(systemName: "location")
        locationIcon.tintColor = UIColor(hex: "1E6EF7")
        locationIcon.translatesAutoresizingMaskIntoConstraints = false

        locationLabel.text = "Locating..."
        locationLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        locationLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false

        let profileConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        profileButton.setImage(UIImage(systemName: "person.circle", withConfiguration: profileConfig), for: .normal)
        profileButton.tintColor = UIColor.black.withAlphaComponent(0.7)
        profileButton.translatesAutoresizingMaskIntoConstraints = false

        topBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topBar)
        topBar.addSubview(locationIcon)
        topBar.addSubview(locationLabel)
        topBar.addSubview(profileButton)

        titleLabel.text = "Home"
        titleLabel.font = UITheme.Typography.screenTitle
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(titleLabel)

        carousel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(carousel)

        videosHeader.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(videosHeader)

        videosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        videosCollectionView.backgroundColor = .clear
        videosCollectionView.showsVerticalScrollIndicator = false
        videosCollectionView.isScrollEnabled = false
        contentView.addSubview(videosCollectionView)

        progressTitle.translatesAutoresizingMaskIntoConstraints = false
        progressTitle.text = "Progress Tracker"
        progressTitle.font = sectionTitleFont
        progressTitle.textColor = .black
        contentView.addSubview(progressTitle)

        painCard.translatesAutoresizingMaskIntoConstraints = false
        adherenceCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(painCard)
        contentView.addSubview(adherenceCard)

        upNextTitle.translatesAutoresizingMaskIntoConstraints = false
        upNextTitle.text = "Up Next"
        upNextTitle.font = sectionTitleFont
        upNextTitle.textColor = .black
        contentView.addSubview(upNextTitle)

        upNextCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(upNextCard)

        articlesTitle.translatesAutoresizingMaskIntoConstraints = false
        articlesTitle.text = "Articles & Tips"
        articlesTitle.font = sectionTitleFont
        articlesTitle.textColor = .black
        contentView.addSubview(articlesTitle)

        articlesSegmented.translatesAutoresizingMaskIntoConstraints = false
        articlesSegmented.selectedSegmentIndex = 0
        articlesSegmented.selectedSegmentTintColor = .white
        articlesSegmented.backgroundColor = UIColor(hex: "EEF3FA")
        articlesSegmented.setTitleTextAttributes(
            [.foregroundColor: UIColor.black.withAlphaComponent(0.55), .font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
            for: .normal
        )
        articlesSegmented.setTitleTextAttributes(
            [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
            for: .selected
        )
        contentView.addSubview(articlesSegmented)

        articlesTableView.translatesAutoresizingMaskIntoConstraints = false
        articlesTableView.backgroundColor = .clear
        articlesTableView.separatorStyle = .none
        articlesTableView.isScrollEnabled = false
        contentView.addSubview(articlesTableView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            topBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            topBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            topBar.heightAnchor.constraint(equalToConstant: 44),

            locationIcon.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            locationIcon.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            locationIcon.widthAnchor.constraint(equalToConstant: 18),
            locationIcon.heightAnchor.constraint(equalToConstant: 18),

            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 6),
            locationLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            profileButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
            profileButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 40),
            profileButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            carousel.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 14),
            carousel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            videosHeader.topAnchor.constraint(equalTo: carousel.bottomAnchor, constant: 18),
            videosHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            videosHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            videosCollectionView.topAnchor.constraint(equalTo: videosHeader.bottomAnchor, constant: 12),
            videosCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            videosCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            // spacing handled by progressTopSpacingConstraint

            progressTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // spacing handled by painTopSpacingConstraint
            painCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            painCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // spacing handled by adherenceTopSpacingConstraint
            adherenceCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            adherenceCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            upNextTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            upNextTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            upNextCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            upNextCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            articlesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articlesTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            articlesSegmented.topAnchor.constraint(equalTo: articlesTitle.bottomAnchor, constant: 12),
            articlesSegmented.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articlesSegmented.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            articlesTableView.topAnchor.constraint(equalTo: articlesSegmented.bottomAnchor, constant: 12),
            articlesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articlesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            articlesTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        videosHeightConstraint = videosCollectionView.heightAnchor.constraint(equalToConstant: 340)
        videosHeightConstraint?.isActive = true
        progressTitleHeightConstraint = progressTitle.heightAnchor.constraint(equalToConstant: 24)
        progressTitleHeightConstraint?.isActive = true
        painCardCollapsedConstraint = painCard.heightAnchor.constraint(equalToConstant: 0)
        painCardCollapsedConstraint?.isActive = false
        adherenceCardCollapsedConstraint = adherenceCard.heightAnchor.constraint(equalToConstant: 0)
        adherenceCardCollapsedConstraint?.isActive = false
        progressTopSpacingConstraint = videosCollectionView.bottomAnchor.constraint(equalTo: progressTitle.topAnchor, constant: -22)
        progressTopSpacingConstraint?.isActive = true
        painTopSpacingConstraint = painCard.topAnchor.constraint(equalTo: progressTitle.bottomAnchor, constant: 12)
        painTopSpacingConstraint?.isActive = true
        adherenceTopSpacingConstraint = adherenceCard.topAnchor.constraint(equalTo: painCard.bottomAnchor, constant: 16)
        adherenceTopSpacingConstraint?.isActive = true
        upNextTitleHeightConstraint = upNextTitle.heightAnchor.constraint(equalToConstant: 24)
        upNextTitleHeightConstraint?.isActive = true
        upNextCardHeightConstraint = upNextCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 160)
        upNextCardHeightConstraint?.priority = .defaultHigh
        upNextCardHeightConstraint?.isActive = true
        upNextCardCollapsedConstraint = upNextCard.heightAnchor.constraint(equalToConstant: 0)
        upNextCardCollapsedConstraint?.isActive = false
        upNextTopSpacingConstraint = adherenceCard.bottomAnchor.constraint(equalTo: upNextTitle.topAnchor, constant: -22)
        upNextTopSpacingConstraint?.isActive = true
        upNextCardTopConstraint = upNextCard.topAnchor.constraint(equalTo: upNextTitle.bottomAnchor, constant: 12)
        upNextCardTopConstraint?.isActive = true
        upNextBottomSpacingConstraint = upNextCard.bottomAnchor.constraint(equalTo: articlesTitle.topAnchor, constant: -22)
        upNextBottomSpacingConstraint?.isActive = true
        articlesHeightConstraint = articlesTableView.heightAnchor.constraint(equalToConstant: 260)
        articlesHeightConstraint?.isActive = true
    }

    func setUpcoming(_ appts: [HomeUpcomingAppointment]) {
        carousel.setUpcoming(appts)
    }

    func setLocationText(_ text: String) {
        locationLabel.text = text
    }

    func updateVideosHeight(rows: Int) {
        let rowCount = max(rows, 1)
        let rowHeight: CGFloat = 160
        let verticalSpacing: CGFloat = 14
        let rowsNeeded = CGFloat((rowCount + 1) / 2)
        let height = rowsNeeded * rowHeight + max(0, rowsNeeded - 1) * verticalSpacing
        videosHeightConstraint?.constant = height
        layoutIfNeeded()
    }

    var videosActionButton: UIButton {
        videosHeader.actionButton
    }

    private var sectionTitleFont: UIFont { UITheme.Typography.sectionTitle }

    func setUpNextVisible(_ visible: Bool) {
        isUpNextVisible = visible
        upNextTitle.isHidden = !visible
        upNextCard.isHidden = !visible
        upNextTitleHeightConstraint?.constant = visible ? 24 : 0
        upNextCardCollapsedConstraint?.isActive = !visible
        updateUpNextSpacing()
        upNextCardTopConstraint?.constant = visible ? 12 : 0
        upNextBottomSpacingConstraint?.constant = visible ? -22 : 0
        layoutIfNeeded()
    }

    func setPainVisible(_ visible: Bool) {
        painCard.isHidden = !visible
        painCardCollapsedConstraint?.isActive = !visible
        painTopSpacingConstraint?.constant = visible ? 12 : 0
        adherenceTopSpacingConstraint?.constant = visible ? 16 : 12
        layoutIfNeeded()
    }

    private func updateUpNextSpacing() {
        if isProgressVisible {
            upNextTopSpacingConstraint?.constant = isUpNextVisible ? -22 : -24
        } else {
            upNextTopSpacingConstraint?.constant = isUpNextVisible ? -12 : -24
        }
    }

    func updateArticlesHeight(rows: Int) {
        let rowHeight: CGFloat = 96
        let height = CGFloat(max(rows, 1)) * rowHeight
        articlesHeightConstraint?.constant = height
        layoutIfNeeded()
    }

    func updateArticlesHeightToFit() {
        articlesTableView.layoutIfNeeded()
        let height = max(articlesTableView.contentSize.height, 1)
        articlesHeightConstraint?.constant = height
        layoutIfNeeded()
    }
}

private final class SectionHeaderView: UIView {
    private let titleLabel = UILabel()
    let actionButton = UIButton(type: .system)

    init(title: String, actionTitle: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        actionButton.setTitle(actionTitle, for: .normal)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UITheme.Typography.sectionTitle
        titleLabel.textColor = .black

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        actionButton.titleLabel?.font = UITheme.Typography.buttonSmall

        addSubview(titleLabel)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            heightAnchor.constraint(equalToConstant: 28)
        ])
    }
}
