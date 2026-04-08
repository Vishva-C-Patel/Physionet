//
//  ArticleCardCell.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ArticleCardCell: UITableViewCell {

    static let reuseID = "ArticleCardCell"

    private let card = UIView()
    private let categoryPill = PaddedLabel(insets: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
    private let timeIcon = UIImageView()
    private let timeLabel = UILabel()
    private let bookmarkButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let readMoreButton = UIButton(type: .system)

    private let topMetaStack = UIStackView()
    private let timeStack = UIStackView()

    var onBookmarkTapped: (() -> Void)?
    var onReadTapped: (() -> Void)?
    private var isBookmarked = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func sourceHost(from urlString: String?) -> String? {
        guard let raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty,
              let url = URL(string: raw),
              let host = url.host
        else { return nil }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryPill.text = nil
        timeLabel.text = nil
        titleLabel.text = nil
        summaryLabel.text = nil
        setBookmarked(false)
    }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(card)
        contentView.addSubview(card)

        categoryPill.translatesAutoresizingMaskIntoConstraints = false
        categoryPill.font = UITheme.Typography.caption
        categoryPill.textColor = UITheme.Colors.accent
        categoryPill.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
        categoryPill.layer.cornerRadius = 14
        categoryPill.layer.masksToBounds = true
        categoryPill.textAlignment = .center
        categoryPill.lineBreakMode = .byTruncatingTail
        categoryPill.setContentHuggingPriority(.required, for: .horizontal)
        categoryPill.setContentCompressionResistancePriority(.required, for: .horizontal)

        timeIcon.translatesAutoresizingMaskIntoConstraints = false
        timeIcon.image = UIImage(systemName: "clock")
        timeIcon.tintColor = UITheme.Colors.textSecondary

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UITheme.Typography.caption
        timeLabel.textColor = UITheme.Colors.textSecondary

        timeStack.axis = .horizontal
        timeStack.spacing = 6
        timeStack.alignment = .center
        timeStack.translatesAutoresizingMaskIntoConstraints = false
        timeStack.setContentHuggingPriority(.required, for: .horizontal)
        timeStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeStack.addArrangedSubview(timeIcon)
        timeStack.addArrangedSubview(timeLabel)

        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.backgroundColor = UITheme.Colors.neutralFill
        bookmarkButton.layer.cornerRadius = 16
        let bookmarkConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        bookmarkButton.setImage(UIImage(systemName: "bookmark", withConfiguration: bookmarkConfig), for: .normal)
        bookmarkButton.tintColor = UITheme.Colors.textSecondary
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)

        topMetaStack.axis = .horizontal
        topMetaStack.spacing = 10
        topMetaStack.alignment = .center
        topMetaStack.translatesAutoresizingMaskIntoConstraints = false

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        topMetaStack.addArrangedSubview(categoryPill)
        topMetaStack.addArrangedSubview(timeStack)
        topMetaStack.addArrangedSubview(spacer)
        topMetaStack.addArrangedSubview(bookmarkButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UITheme.Typography.cardTitle
        titleLabel.textColor = UITheme.Colors.textPrimary
        titleLabel.numberOfLines = 0

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = UITheme.Typography.bodySmall
        summaryLabel.textColor = UITheme.Colors.textSecondary
        summaryLabel.numberOfLines = 2

        readMoreButton.setTitle("Read more", for: .normal)
        readMoreButton.setTitleColor(UITheme.Colors.accent, for: .normal)
        readMoreButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        readMoreButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: chevronConfig), for: .normal)
        readMoreButton.tintColor = UITheme.Colors.accent
        readMoreButton.semanticContentAttribute = .forceRightToLeft
        readMoreButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        readMoreButton.addTarget(self, action: #selector(readTapped), for: .touchUpInside)

        [topMetaStack, titleLabel, summaryLabel, readMoreButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            categoryPill.heightAnchor.constraint(equalToConstant: 28),

            bookmarkButton.widthAnchor.constraint(equalToConstant: 32),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 32),

            timeIcon.widthAnchor.constraint(equalToConstant: 12),
            timeIcon.heightAnchor.constraint(equalToConstant: 12),

            topMetaStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            topMetaStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            topMetaStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: topMetaStack.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            summaryLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            readMoreButton.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 12),
            readMoreButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            readMoreButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    func configure(with article: ArticleRow) {
        let sourceName = article.source_name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sourceSlug = article.source?.trimmingCharacters(in: .whitespacesAndNewlines)
        let tagFallback = article.tags?.first?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlFallback = sourceHost(from: article.source_url) ?? sourceHost(from: article.url)
        let resolvedSource = (sourceName?.isEmpty == false ? sourceName :
                              (sourceSlug?.isEmpty == false ? sourceSlug :
                               (urlFallback?.isEmpty == false ? urlFallback :
                                (tagFallback?.isEmpty == false ? tagFallback : "Article"))))
        categoryPill.text = resolvedSource
        titleLabel.text = article.title
        summaryLabel.text = article.summary
        let minutes = article.displayReadMinutes
        timeLabel.text = "\(minutes) min"
    }

    func setBookmarked(_ bookmarked: Bool) {
        isBookmarked = bookmarked
        let imageName = bookmarked ? "bookmark.fill" : "bookmark"
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        bookmarkButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        bookmarkButton.tintColor = bookmarked ? UITheme.Colors.accent : .tertiaryLabel
    }

    @objc private func bookmarkTapped() {
        onBookmarkTapped?()
    }

    @objc private func readTapped() {
        onReadTapped?()
    }
}

private final class PaddedLabel: UILabel {
    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
