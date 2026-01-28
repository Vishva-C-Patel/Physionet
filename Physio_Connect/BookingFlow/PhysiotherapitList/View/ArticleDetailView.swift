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
    private let contentCard = UIView()
    private let sourcePill = PaddedLabel(insets: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
    private let dateLabel = UILabel()
    private let tagsStack = UIStackView()
    private let articleTitleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let bodyLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "EAF2FF")
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
        sourcePill.text = article.source_name ?? "Source"
        dateLabel.text = article.published_at ?? ""

        setTags(article.tags ?? [])
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

    func preferredContentText(for article: ArticleRow) -> String {
        preferredBodyText(for: article)
    }

    private func build() {
        topBar.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        let backConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = UIColor.black.withAlphaComponent(0.7)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        let shareConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: shareConfig), for: .normal)
        shareButton.tintColor = UIColor(hex: "1E6EF7")

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor(hex: "EAF2FF")
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear

        contentCard.translatesAutoresizingMaskIntoConstraints = false
        contentCard.backgroundColor = .white
        contentCard.layer.cornerRadius = 22
        contentCard.layer.shadowColor = UIColor.black.cgColor
        contentCard.layer.shadowOpacity = 0.08
        contentCard.layer.shadowRadius = 12
        contentCard.layer.shadowOffset = CGSize(width: 0, height: 8)

        sourcePill.translatesAutoresizingMaskIntoConstraints = false
        sourcePill.backgroundColor = UIColor(hex: "EDF4FF")
        sourcePill.textColor = UIColor(hex: "1E6EF7")
        sourcePill.font = .systemFont(ofSize: 12, weight: .semibold)
        sourcePill.layer.cornerRadius = 14
        sourcePill.layer.masksToBounds = true

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = UIColor.black.withAlphaComponent(0.45)

        tagsStack.translatesAutoresizingMaskIntoConstraints = false
        tagsStack.axis = .horizontal
        tagsStack.spacing = 8
        tagsStack.alignment = .leading

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

        contentView.addSubview(contentCard)
        contentCard.addSubview(sourcePill)
        contentCard.addSubview(dateLabel)
        contentCard.addSubview(tagsStack)
        contentCard.addSubview(articleTitleLabel)
        contentCard.addSubview(summaryLabel)
        contentCard.addSubview(bodyLabel)

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

            contentCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            sourcePill.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 16),
            sourcePill.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            sourcePill.heightAnchor.constraint(equalToConstant: 28),

            dateLabel.centerYAnchor.constraint(equalTo: sourcePill.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: sourcePill.trailingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentCard.trailingAnchor, constant: -16),

            tagsStack.topAnchor.constraint(equalTo: sourcePill.bottomAnchor, constant: 12),
            tagsStack.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            tagsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentCard.trailingAnchor, constant: -16),

            articleTitleLabel.topAnchor.constraint(equalTo: tagsStack.bottomAnchor, constant: 14),
            articleTitleLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            articleTitleLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),

            summaryLabel.topAnchor.constraint(equalTo: articleTitleLabel.bottomAnchor, constant: 10),
            summaryLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),

            bodyLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 14),
            bodyLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: -20)
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
