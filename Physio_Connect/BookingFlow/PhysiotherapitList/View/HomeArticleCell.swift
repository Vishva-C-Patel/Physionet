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
    private let ratingLabel = UILabel()
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
        ratingLabel.text = nil
        titleLabel.text = nil
        metaLabel.text = nil
    }

    func configure(with article: ArticleRow) {
        titleLabel.text = article.title
        metaLabel.text = "\(article.read_minutes ?? 0) min read"
        if let tag = article.tags?.first {
            tagPill.text = "  \(tag)  "
        } else {
            tagPill.text = "  Tips  "
        }
        let ratingText = String(format: "%.1f", article.rating ?? 0.0)
        ratingLabel.text = "⭐️ \(ratingText)"
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
        tagPill.font = .systemFont(ofSize: 12, weight: .semibold)
        tagPill.textColor = UIColor(hex: "1E6EF7")

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        ratingLabel.textColor = UIColor(hex: "F59E0B")

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2

        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.font = .systemFont(ofSize: 12, weight: .medium)
        metaLabel.textColor = UIColor.black.withAlphaComponent(0.55)

        card.addSubview(tagPill)
        card.addSubview(ratingLabel)
        card.addSubview(titleLabel)
        card.addSubview(metaLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            tagPill.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            tagPill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            ratingLabel.centerYAnchor.constraint(equalTo: tagPill.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: tagPill.trailingAnchor, constant: 8),

            titleLabel.topAnchor.constraint(equalTo: tagPill.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: tagPill.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
    }
}
