//
//  PhysiotherapistCardCell.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//
import UIKit

final class PhysiotherapistCardCell: UITableViewCell {

    static let reuseID = "PhysiotherapistCardCell"

    // MAIN CARD
    private let card = UIView()

    // LEFT IMAGE
    private let avatarImage = UIImageView()

    // TEXTS
    private let nameLabel = UILabel()
    private let ratingLabel = UILabel()
    private let distanceLabel = UILabel()
    private let specializationLabel = UILabel()
    private let feeLabel = UILabel()
    var avatarPath: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarPath = nil
        setAvatarImage(nil)
    }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // ---------------- CARD STYLE (MATCH YOUR DoctorProfileCardView) ----------------
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(hex: "D4E3FE").cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.addSubview(card)

        // ---------------- IMAGE (MATCH) ----------------
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.layer.cornerRadius = 24
        avatarImage.clipsToBounds = true
        avatarImage.contentMode = .scaleAspectFill
        avatarImage.backgroundColor = .systemGray5
        avatarImage.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
        
        avatarImage.tintColor = .gray
        card.addSubview(avatarImage)

        // ---------------- LABELS (MATCH FONT SIZES) ----------------
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.textColor = .black

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 13)
        ratingLabel.textColor = .darkGray

        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = .systemFont(ofSize: 13)
        distanceLabel.textColor = .darkGray

        specializationLabel.translatesAutoresizingMaskIntoConstraints = false
        specializationLabel.font = .systemFont(ofSize: 13)
        specializationLabel.textColor = UIColor(hex: "1E6EF7")
        specializationLabel.numberOfLines = 1

        feeLabel.translatesAutoresizingMaskIntoConstraints = false
        feeLabel.font = .systemFont(ofSize: 13, weight: .bold)
        feeLabel.textColor = UIColor(hex: "1E6EF7")

        [nameLabel, specializationLabel, ratingLabel, distanceLabel, feeLabel].forEach {
            card.addSubview($0)
        }

        // ---------------- CONSTRAINTS (MATCH YOUR VIEW) ----------------
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            avatarImage.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatarImage.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            avatarImage.widthAnchor.constraint(equalToConstant: 110),
            avatarImage.heightAnchor.constraint(equalToConstant: 110),

            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            specializationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            specializationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specializationLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            ratingLabel.topAnchor.constraint(equalTo: specializationLabel.bottomAnchor, constant: 6),
            ratingLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            distanceLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 6),
            distanceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            feeLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 6),
            feeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            feeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            feeLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Configure
    func configure(with model: PhysiotherapistCardModel) {
        nameLabel.text = model.name
        specializationLabel.text = model.specializationText
        ratingLabel.text = "⭐️ \(String(format: "%.1f", model.rating)) | \(model.reviewsCount) reviews"
        distanceLabel.text = model.distanceText
        feeLabel.text = model.feeText

        // Placeholder (until you add image_url column)
        avatarImage.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
        avatarImage.tintColor = .gray
    }

    func setAvatarImage(_ image: UIImage?) {
        if let image {
            avatarImage.image = image
            avatarImage.tintColor = .clear
        } else {
            avatarImage.image = UIImage(named: "doctor_placeholder") ?? UIImage(systemName: "person.fill")
            avatarImage.tintColor = .gray
        }
    }
}
