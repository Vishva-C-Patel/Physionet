//
//  HomeVideoCardCell.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class HomeVideoCardCell: UICollectionViewCell {
    static let reuseID = "HomeVideoCardCell"

    private let card = UIView()
    private let thumbnailView = UIImageView()
    private let playCircle = UIView()
    private let playIcon = UIImageView()
    private let durationLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailView.image = UIImage(systemName: "photo")
        titleLabel.text = nil
        subtitleLabel.text = nil
        durationLabel.text = nil
    }

    func configure(with video: ExerciseVideoRow, thumbnail: UIImage?) {
        titleLabel.text = video.title
        subtitleLabel.text = video.target_area ?? "Upper Body"
        let minutes = max(1, (video.duration_seconds ?? 0) / 60)
        durationLabel.text = "\(minutes) min"
        if let thumbnail {
            thumbnailView.image = thumbnail
            thumbnailView.tintColor = nil
        } else {
            thumbnailView.image = UIImage(systemName: "photo")
            thumbnailView.tintColor = UIColor.black.withAlphaComponent(0.2)
        }
    }

    private func build() {
        backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(card)

        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.backgroundColor = UIColor(hex: "E9EEF7")
        thumbnailView.layer.cornerRadius = 14
        thumbnailView.clipsToBounds = true
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.image = UIImage(systemName: "photo")
        thumbnailView.tintColor = UIColor.black.withAlphaComponent(0.2)

        playCircle.translatesAutoresizingMaskIntoConstraints = false
        playCircle.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        playCircle.layer.cornerRadius = 18

        playIcon.translatesAutoresizingMaskIntoConstraints = false
        playIcon.image = UIImage(systemName: "play.fill")
        playIcon.tintColor = UIColor(hex: "1E6EF7")

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UITheme.Typography.caption
        durationLabel.textColor = UIColor.white

        let durationBg = UIView()
        durationBg.translatesAutoresizingMaskIntoConstraints = false
        durationBg.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        durationBg.layer.cornerRadius = 10

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UITheme.Typography.cardTitle
        titleLabel.textColor = UITheme.Colors.textPrimary
        titleLabel.numberOfLines = 2

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UITheme.Typography.caption
        subtitleLabel.textColor = UITheme.Colors.textSecondary

        card.addSubview(thumbnailView)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        thumbnailView.addSubview(playCircle)
        playCircle.addSubview(playIcon)
        thumbnailView.addSubview(durationBg)
        durationBg.addSubview(durationLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            thumbnailView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            thumbnailView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            thumbnailView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            thumbnailView.heightAnchor.constraint(equalToConstant: 110),

            playCircle.centerXAnchor.constraint(equalTo: thumbnailView.centerXAnchor),
            playCircle.centerYAnchor.constraint(equalTo: thumbnailView.centerYAnchor),
            playCircle.widthAnchor.constraint(equalToConstant: 36),
            playCircle.heightAnchor.constraint(equalToConstant: 36),

            playIcon.centerXAnchor.constraint(equalTo: playCircle.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: playCircle.centerYAnchor),

            durationBg.leadingAnchor.constraint(equalTo: thumbnailView.leadingAnchor, constant: 8),
            durationBg.bottomAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: -8),

            durationLabel.leadingAnchor.constraint(equalTo: durationBg.leadingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: durationBg.trailingAnchor, constant: -8),
            durationLabel.topAnchor.constraint(equalTo: durationBg.topAnchor, constant: 4),
            durationLabel.bottomAnchor.constraint(equalTo: durationBg.bottomAnchor, constant: -4),

            titleLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -10)
        ])
    }
}
