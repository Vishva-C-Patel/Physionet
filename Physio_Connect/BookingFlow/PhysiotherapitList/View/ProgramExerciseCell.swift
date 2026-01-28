//
//  ProgramExerciseCell.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ProgramExerciseCell: UITableViewCell {

    static let reuseID = "ProgramExerciseCell"

    private let card = UIView()
    private let thumbImageView = UIImageView()
    private let playOverlay = UIImageView()
    private let statusBadge = UIImageView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let statusPill = PillLabel()
    private let durationPill = PillLabel()
    private let chevron = UIImageView()

    private var imageTask: URLSessionDataTask?
    private(set) var thumbnailPath: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layoutMargins = .zero
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        thumbnailPath = nil
        thumbImageView.image = UIImage(systemName: "photo")
    }

    func configure(title: String,
                   subtitle: String,
                   durationSeconds: Int?,
                   completed: Bool,
                   locked: Bool,
                   thumbnailPath: String?) {
        titleLabel.text = title
        subLabel.text = subtitle
        let mins = max(1, (durationSeconds ?? 0) / 60)
        durationPill.text = "\(mins) min"
        self.thumbnailPath = thumbnailPath

        if locked {
            statusBadge.image = UIImage(systemName: "lock.fill")
            statusBadge.tintColor = UIColor.black.withAlphaComponent(0.35)
            playOverlay.image = UIImage(systemName: "lock.fill")
            playOverlay.tintColor = UIColor.black.withAlphaComponent(0.35)
            thumbImageView.alpha = 0.45
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            subLabel.textColor = UIColor.black.withAlphaComponent(0.3)
            durationPill.textColor = UIColor.black.withAlphaComponent(0.4)
            durationPill.backgroundColor = UITheme.Colors.neutralFill
            statusPill.text = "Locked"
            statusPill.textColor = UIColor.black.withAlphaComponent(0.5)
            statusPill.backgroundColor = UITheme.Colors.neutralFill
            chevron.alpha = 0.3
        } else if completed {
            statusBadge.image = UIImage(systemName: "checkmark.circle.fill")
            statusBadge.tintColor = UIColor(hex: "22C55E")
            playOverlay.image = UIImage(systemName: "checkmark")
            playOverlay.tintColor = UIColor(hex: "22C55E")
            thumbImageView.alpha = 1
            titleLabel.textColor = UITheme.Colors.textPrimary
            subLabel.textColor = UITheme.Colors.textSecondary
            durationPill.textColor = UIColor(hex: "1C7B3B")
            durationPill.backgroundColor = UIColor(hex: "E7F5ED")
            statusPill.text = "Done"
            statusPill.textColor = UIColor(hex: "1C7B3B")
            statusPill.backgroundColor = UIColor(hex: "E7F5ED")
            chevron.alpha = 1
        } else {
            statusBadge.image = UIImage(systemName: "play.circle.fill")
            statusBadge.tintColor = UITheme.Colors.accent
            playOverlay.image = UIImage(systemName: "play.fill")
            playOverlay.tintColor = UITheme.Colors.accent
            thumbImageView.alpha = 1
            titleLabel.textColor = UITheme.Colors.textPrimary
            subLabel.textColor = UITheme.Colors.textSecondary
            durationPill.textColor = UITheme.Colors.accent
            durationPill.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
            statusPill.text = "Up next"
            statusPill.textColor = UITheme.Colors.accent
            statusPill.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
            chevron.alpha = 1
        }

        thumbImageView.image = UIImage(systemName: "photo")
    }

    func setThumbnail(url: URL) {
        imageTask?.cancel()
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.thumbImageView.image = image }
        }
        imageTask?.resume()
    }

    private func build() {
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        card.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(card)

        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.layer.cornerRadius = 12
        thumbImageView.layer.masksToBounds = true
        thumbImageView.backgroundColor = UITheme.Colors.neutralFill
        thumbImageView.image = UIImage(systemName: "photo")

        playOverlay.translatesAutoresizingMaskIntoConstraints = false
        playOverlay.image = UIImage(systemName: "play.fill")
        playOverlay.tintColor = UITheme.Colors.accent
        playOverlay.backgroundColor = UIColor.white
        playOverlay.layer.cornerRadius = 16
        playOverlay.layer.masksToBounds = true
        playOverlay.contentMode = .center

        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = UITheme.Colors.textPrimary
        titleLabel.numberOfLines = 2

        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subLabel.textColor = UITheme.Colors.textSecondary
        subLabel.numberOfLines = 1

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.font = .systemFont(ofSize: 11, weight: .semibold)
        statusPill.textColor = UITheme.Colors.accent
        statusPill.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
        statusPill.setContentHuggingPriority(.required, for: .horizontal)

        durationPill.translatesAutoresizingMaskIntoConstraints = false
        durationPill.font = .systemFont(ofSize: 11, weight: .semibold)
        durationPill.textColor = UITheme.Colors.accent
        durationPill.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)

        chevron.translatesAutoresizingMaskIntoConstraints = false
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)
        chevron.tintColor = UIColor.black.withAlphaComponent(0.3)
        chevron.contentMode = .scaleAspectFit

        contentView.addSubview(card)
        card.addSubview(thumbImageView)
        thumbImageView.addSubview(playOverlay)
        card.addSubview(statusBadge)
        card.addSubview(titleLabel)
        card.addSubview(statusPill)
        card.addSubview(subLabel)
        card.addSubview(durationPill)
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            thumbImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            thumbImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            thumbImageView.widthAnchor.constraint(equalToConstant: 64),
            thumbImageView.heightAnchor.constraint(equalToConstant: 64),

            playOverlay.centerXAnchor.constraint(equalTo: thumbImageView.centerXAnchor),
            playOverlay.centerYAnchor.constraint(equalTo: thumbImageView.centerYAnchor),
            playOverlay.widthAnchor.constraint(equalToConstant: 32),
            playOverlay.heightAnchor.constraint(equalToConstant: 32),

            statusBadge.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 12),
            statusBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            statusBadge.widthAnchor.constraint(equalToConstant: 18),
            statusBadge.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusPill.leadingAnchor, constant: -8),

            statusPill.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusPill.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),

            subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            durationPill.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 6),
            durationPill.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            durationPill.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 10),
            chevron.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
}
