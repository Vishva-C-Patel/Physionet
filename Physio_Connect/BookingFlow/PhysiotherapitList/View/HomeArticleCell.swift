//
//  HomeArticleCell.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class HomeArticleCell: UITableViewCell {
    static let reuseID = "HomeArticleCell"

    private let card = UIView()
    private let tagPill = UILabel()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tagPill.text = nil
        titleLabel.text = nil
        metaLabel.text = nil
    }

    func configure(with article: ArticleRow) {
        titleLabel.text = article.title
        metaLabel.text = "\(article.read_minutes ?? 0) min read"
        let sourceName = article.source_name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sourceSlug = article.source?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlSource = sourceHost(from: article.source_url) ?? sourceHost(from: article.url)
        let fallbackTag = article.tags?.first?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedSource = (sourceName?.isEmpty == false ? sourceName :
                              (sourceSlug?.isEmpty == false ? sourceSlug :
                               (urlSource?.isEmpty == false ? urlSource :
                                (fallbackTag?.isEmpty == false ? fallbackTag : "Source"))))
        tagPill.text = "  \(resolvedSource ?? "Source")  "
    }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(card)

        tagPill.translatesAutoresizingMaskIntoConstraints = false
        tagPill.backgroundColor = UIColor(hex: "E8F3FF")
        tagPill.layer.cornerRadius = 12
        tagPill.layer.masksToBounds = true
        tagPill.font = UITheme.Typography.caption
        tagPill.textColor = UIColor(hex: "1E6EF7")

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UITheme.Typography.cardTitle
        titleLabel.textColor = UITheme.Colors.textPrimary
        titleLabel.numberOfLines = 2

        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.font = UITheme.Typography.caption
        metaLabel.textColor = UITheme.Colors.textSecondary

        card.addSubview(tagPill)
        card.addSubview(titleLabel)
        card.addSubview(metaLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            tagPill.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            tagPill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: tagPill.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: tagPill.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
    }

    private func sourceHost(from urlString: String?) -> String? {
        guard let raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty,
              let url = URL(string: raw),
              let host = url.host
        else { return nil }
        return host.replacingOccurrences(of: "www.", with: "")
    }
}
