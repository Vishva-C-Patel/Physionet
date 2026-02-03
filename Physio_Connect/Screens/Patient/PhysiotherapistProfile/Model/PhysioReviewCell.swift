//
//  PhysioReviewCell.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//
import UIKit

final class PhysioReviewCell: UITableViewCell {

    static let reuseID = "PhysioReviewCell"

    private let card = UIView()
    private let avatar = UIImageView()

    private let nameLabel = UILabel()
    private let ratingPill = UILabel()
    private let reviewLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 4)

        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.image = UIImage(systemName: "person.crop.circle.fill")
        avatar.tintColor = .systemGray3
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 18

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        ratingPill.translatesAutoresizingMaskIntoConstraints = false
        ratingPill.font = .systemFont(ofSize: 13, weight: .semibold)
        ratingPill.textAlignment = .center
        ratingPill.textColor = .black
        ratingPill.backgroundColor = UIColor(hex: "FFF3D6")
        ratingPill.layer.cornerRadius = 12
        ratingPill.clipsToBounds = true
        ratingPill.setContentCompressionResistancePriority(.required, for: .horizontal)

        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewLabel.font = .systemFont(ofSize: 14)
        reviewLabel.textColor = .darkGray
        reviewLabel.numberOfLines = 0

        let headerRow = UIStackView(arrangedSubviews: [nameLabel, UIView(), ratingPill])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.translatesAutoresizingMaskIntoConstraints = false

        let vStack = UIStackView(arrangedSubviews: [headerRow, reviewLabel])
        vStack.axis = .vertical
        vStack.spacing = 10
        vStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(card)
        card.addSubview(avatar)
        card.addSubview(vStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            avatar.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            avatar.widthAnchor.constraint(equalToConstant: 36),
            avatar.heightAnchor.constraint(equalToConstant: 36),

            vStack.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            vStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            ratingPill.widthAnchor.constraint(equalToConstant: 54),
            ratingPill.heightAnchor.constraint(equalToConstant: 26)
        ])
    }

    func configure(_ review: PhysioReviewRow) {
        nameLabel.text = review.reviewer_name
        ratingPill.text = "⭐️ \(review.rating)"
        reviewLabel.text = (review.review_text?.isEmpty == false) ? review.review_text! : "No comment provided."
    }
}

