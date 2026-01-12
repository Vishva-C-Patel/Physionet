//
//  ArticleDetailView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ArticleDetailView: UIView {

    private let topBar = UIView()
    let backButton = UIButton(type: .system)
    let shareButton = UIButton(type: .system)
    let titleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let coverImageView = UIImageView()
    private let sourcePill = UIView()
    private let sourceIcon = UIImageView()
    private let sourceLabel = UILabel()
    private let dateLabel = UILabel()
    private let metaStack = UIStackView()
    private let ratingLabel = UILabel()
    private let viewsLabel = UILabel()
    private let timeLabel = UILabel()
    private let tagsStack = UIStackView()
    private let userRatingLabel = UILabel()
    private let userRatingStack = UIStackView()
    private let articleTitleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let bodyLabel = UILabel()

    private var currentUserRating = 0
    var onRatingSelected: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E3F0FF")
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with article: ArticleRow) {
        titleLabel.text = "Read Article"
        articleTitleLabel.text = article.title
        summaryLabel.text = article.summary
        bodyLabel.text = preferredBodyText(for: article)
        sourceLabel.text = article.source_name ?? "Source"
        dateLabel.text = article.published_at ?? ""

        let ratingText = String(format: "%.1f", article.rating ?? 0.0)
        ratingLabel.text = "⭐️ \(ratingText)"
        viewsLabel.text = "👁️ \(formatViews(article.views_count ?? 0))"
        timeLabel.text = "⏱️ \(article.read_minutes ?? 0) min read"

        setTags(article.tags ?? [])
        setUserRating(currentUserRating)
    }

    private func preferredBodyText(for article: ArticleRow) -> String {
        let content = article.content?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let content, !content.isEmpty {
            return content
        }
        let summary = article.summary?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let summary, !summary.isEmpty {
            return summary
        }
        return "Full article content will appear here."
    }

    func setCoverImage(_ image: UIImage?) {
        if let image {
            coverImageView.image = image
            coverImageView.tintColor = .clear
        } else {
            coverImageView.image = UIImage(systemName: "photo")
            coverImageView.tintColor = UIColor.black.withAlphaComponent(0.15)
        }
    }

    private func build() {
        topBar.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 20
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.08
        backButton.layer.shadowRadius = 6
        backButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        let backConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = UIColor.black.withAlphaComponent(0.7)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.backgroundColor = UIColor(hex: "E8F7FF")
        shareButton.layer.cornerRadius = 20
        let shareConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: shareConfig), for: .normal)
        shareButton.tintColor = UIColor(hex: "1E6EF7")

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor(hex: "E3F0FF")
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor(hex: "E3F0FF")

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.backgroundColor = UIColor(hex: "E9EEF7")
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.image = UIImage(systemName: "photo")
        coverImageView.tintColor = UIColor.black.withAlphaComponent(0.15)

        sourcePill.translatesAutoresizingMaskIntoConstraints = false
        sourcePill.backgroundColor = UIColor(hex: "EAF9F1")
        sourcePill.layer.cornerRadius = 14

        sourceIcon.translatesAutoresizingMaskIntoConstraints = false
        sourceIcon.image = UIImage(systemName: "checkmark.seal.fill")
        sourceIcon.tintColor = UIColor(hex: "16A34A")

        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        sourceLabel.textColor = UIColor(hex: "15803D")

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = UIColor.black.withAlphaComponent(0.45)

        metaStack.translatesAutoresizingMaskIntoConstraints = false
        metaStack.axis = .horizontal
        metaStack.spacing = 12
        metaStack.alignment = .center

        [ratingLabel, viewsLabel, timeLabel].forEach {
            $0.font = .systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = UIColor.black.withAlphaComponent(0.6)
            metaStack.addArrangedSubview($0)
        }

        tagsStack.translatesAutoresizingMaskIntoConstraints = false
        tagsStack.axis = .horizontal
        tagsStack.spacing = 8
        tagsStack.alignment = .leading

        userRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        userRatingLabel.text = "Your Rating"
        userRatingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        userRatingLabel.textColor = UIColor.black.withAlphaComponent(0.7)

        userRatingStack.translatesAutoresizingMaskIntoConstraints = false
        userRatingStack.axis = .horizontal
        userRatingStack.spacing = 6
        userRatingStack.alignment = .center

        for i in 1...5 {
            let button = UIButton(type: .system)
            button.tag = i
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = UIColor(hex: "F4B400")
            button.addTarget(self, action: #selector(ratingTapped(_:)), for: .touchUpInside)
            userRatingStack.addArrangedSubview(button)
        }

        articleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        articleTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        articleTitleLabel.textColor = .black
        articleTitleLabel.numberOfLines = 0

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .systemFont(ofSize: 15, weight: .medium)
        summaryLabel.textColor = UIColor.black.withAlphaComponent(0.65)
        summaryLabel.numberOfLines = 0

        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        bodyLabel.textColor = UIColor.black.withAlphaComponent(0.75)
        bodyLabel.numberOfLines = 0

        addSubview(topBar)
        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(shareButton)

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(coverImageView)
        contentView.addSubview(sourcePill)
        sourcePill.addSubview(sourceIcon)
        sourcePill.addSubview(sourceLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(metaStack)
        contentView.addSubview(tagsStack)
        contentView.addSubview(userRatingLabel)
        contentView.addSubview(userRatingStack)
        contentView.addSubview(articleTitleLabel)
        contentView.addSubview(summaryLabel)
        contentView.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            topBar.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            shareButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
            shareButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 40),
            shareButton.heightAnchor.constraint(equalToConstant: 40),

            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            coverImageView.heightAnchor.constraint(equalToConstant: 220),

            sourcePill.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 12),
            sourcePill.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sourcePill.heightAnchor.constraint(equalToConstant: 28),

            sourceIcon.leadingAnchor.constraint(equalTo: sourcePill.leadingAnchor, constant: 10),
            sourceIcon.centerYAnchor.constraint(equalTo: sourcePill.centerYAnchor),
            sourceIcon.widthAnchor.constraint(equalToConstant: 14),
            sourceIcon.heightAnchor.constraint(equalToConstant: 14),

            sourceLabel.leadingAnchor.constraint(equalTo: sourceIcon.trailingAnchor, constant: 6),
            sourceLabel.trailingAnchor.constraint(equalTo: sourcePill.trailingAnchor, constant: -12),
            sourceLabel.centerYAnchor.constraint(equalTo: sourcePill.centerYAnchor),

            dateLabel.centerYAnchor.constraint(equalTo: sourcePill.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: sourcePill.trailingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            metaStack.topAnchor.constraint(equalTo: sourcePill.bottomAnchor, constant: 10),
            metaStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metaStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            tagsStack.topAnchor.constraint(equalTo: metaStack.bottomAnchor, constant: 12),
            tagsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            userRatingLabel.topAnchor.constraint(equalTo: tagsStack.bottomAnchor, constant: 14),
            userRatingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userRatingLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            userRatingStack.topAnchor.constraint(equalTo: userRatingLabel.bottomAnchor, constant: 8),
            userRatingStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            articleTitleLabel.topAnchor.constraint(equalTo: userRatingStack.bottomAnchor, constant: 14),
            articleTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articleTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            summaryLabel.topAnchor.constraint(equalTo: articleTitleLabel.bottomAnchor, constant: 10),
            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bodyLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 14),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setTags(_ tags: [String]) {
        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let displayTags = Array(tags.prefix(4))
        for tag in displayTags {
            let tagView = ArticleTagPillView(text: tag)
            tagsStack.addArrangedSubview(tagView)
        }
        tagsStack.isHidden = displayTags.isEmpty
    }

    private func formatViews(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000.0)
        }
        return "\(count)"
    }

    func setUserRating(_ rating: Int) {
        currentUserRating = max(0, min(5, rating))
        for case let button as UIButton in userRatingStack.arrangedSubviews {
            let imageName = button.tag <= currentUserRating ? "star.fill" : "star"
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        }
    }

    @objc private func ratingTapped(_ sender: UIButton) {
        let rating = sender.tag
        setUserRating(rating)
        onRatingSelected?(rating)
    }
}

private final class ArticleTagPillView: UIView {
    private let label = UILabel()

    init(text: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: "E8F3FF")
        layer.cornerRadius = 14
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(hex: "1E6EF7")
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
