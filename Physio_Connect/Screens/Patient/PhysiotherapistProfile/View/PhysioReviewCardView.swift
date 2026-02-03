//
//  PhysioReviewCardView.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//
import UIKit

final class PhysioReviewCardView: UIView {

    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let ratingPill = UILabel()
    private let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "D4E3FE").cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)

        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 18
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFill
        avatar.backgroundColor = .systemGray5
        avatar.image = UIImage(systemName: "person.fill")
        avatar.tintColor = .gray

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 15)
        nameLabel.textColor = .black

        ratingPill.translatesAutoresizingMaskIntoConstraints = false
        ratingPill.font = .systemFont(ofSize: 13, weight: .semibold)
        ratingPill.textAlignment = .center
        ratingPill.textColor = .black
        ratingPill.backgroundColor = UIColor(hex: "FFF3D6")
        ratingPill.layer.cornerRadius = 12
        ratingPill.clipsToBounds = true

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.textColor = .darkGray
        textLabel.numberOfLines = 0

        addSubview(avatar)
        addSubview(nameLabel)
        addSubview(ratingPill)
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            avatar.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            avatar.widthAnchor.constraint(equalToConstant: 36),
            avatar.heightAnchor.constraint(equalToConstant: 36),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingPill.leadingAnchor, constant: -10),

            ratingPill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            ratingPill.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            ratingPill.widthAnchor.constraint(equalToConstant: 52),
            ratingPill.heightAnchor.constraint(equalToConstant: 26),

            textLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            textLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 10),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    func configure(name: String, rating: Int, text: String) {
        nameLabel.text = name
        ratingPill.text = "⭐️ \(rating)"
        textLabel.text = text
    }
}

