//
//  HomeCardsCarouselView.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//
import UIKit

final class HomeCardsCarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    enum CardType {
        case upcoming(HomeUpcomingAppointment)
        case book
    }

    // Public
    let pageControl = UIPageControl()
    var onBookTapped: (() -> Void)?
    // Fires when user taps the Upcoming card primary button ("View Details")
    var onViewDetailsTapped: ((HomeUpcomingAppointment) -> Void)?

    private var cards: [CardType] = [.book]

    // Collection
    private lazy var layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 12            // ✅ spacing between cards
        l.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // ✅ iOS margins
        return l
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.isPagingEnabled = false // we will snap manually
        // ✅ Allow quick taps on buttons inside horizontally scrolling cells
        cv.delaysContentTouches = false
        cv.canCancelContentTouches = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(HomeCardCell.self, forCellWithReuseIdentifier: HomeCardCell.reuseID)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        addSubview(collectionView)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 1
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "1E6EF7")
        addSubview(pageControl)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 250), // ✅ compact card height

            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 14),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public update
    func setUpcoming(_ appts: [HomeUpcomingAppointment]) {
        if appts.isEmpty {
            cards = [.book]
        } else {
            cards = appts.map { .upcoming($0) } + [.book]
        }

        pageControl.numberOfPages = cards.count
        pageControl.currentPage = 0
        collectionView.reloadData()

        DispatchQueue.main.async {
            self.collectionView.setContentOffset(.zero, animated: false)
        }
    }

    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCardCell.reuseID, for: indexPath) as! HomeCardCell

        switch cards[indexPath.item] {
        case .book:
            cell.card.apply(state: .bookHomeVisit)
            cell.onPrimaryTapped = { [weak self] in
                self?.onBookTapped?()
            }

        case .upcoming(let appt):
            cell.card.apply(state: .upcoming(appt))
            cell.card.setAvatarImage(nil, path: appt.profileImagePath)
            if let path = appt.profileImagePath {
                PhysioService.shared.loadProfileImage(pathOrUrl: path, version: appt.profileImageVersion) { [weak card = cell.card] image in
                    guard let card else { return }
                    if card.isAvatarPath(path) {
                        card.setAvatarImage(image, path: path)
                    }
                }
            }
            cell.onPrimaryTapped = { [weak self] in
                self?.onViewDetailsTapped?(appt)
            }
        }

        return cell
    }

    // Size = full width minus margins (16+16), spacing handled by layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width - 32
        return CGSize(width: w, height: 230)
    }

    // MARK: - Snap + dots
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { updatePage() }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { updatePage() }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) { updatePage() }

    private func updatePage() {
        let pageWidth = (collectionView.bounds.width - 32) + layout.minimumLineSpacing
        let x = collectionView.contentOffset.x
        let page = Int(round(x / pageWidth))
        pageControl.currentPage = max(0, min(page, cards.count - 1))
    }

    // Snap to nearest cell
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = (collectionView.bounds.width - 32) + layout.minimumLineSpacing
        let x = scrollView.contentOffset.x
        let targetX = round((x + velocity.x * 60) / pageWidth) * pageWidth
        targetContentOffset.pointee = CGPoint(x: max(0, targetX), y: 0)
    }

}

// MARK: - Cell
private final class HomeCardCell: UICollectionViewCell {

    static let reuseID = "HomeCardCell"
    let card = HomeHeroCardView()
    var onPrimaryTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        onPrimaryTapped = nil
    }

    @objc private func primaryTapped() {
        onPrimaryTapped?()
    }
}
