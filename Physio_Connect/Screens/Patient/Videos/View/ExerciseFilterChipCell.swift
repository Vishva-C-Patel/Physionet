//
//  ExerciseFilterChipCell.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ExerciseFilterChipCell: UICollectionViewCell {

    static let reuseID = "ExerciseFilterChipCell"

    private let titleLabel = UILabel()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        applySelectionState(isSelected)
    }

    private func build() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UITheme.Colors.border.cgColor

        blurView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)
        ])
    }

    private func applySelectionState(_ selected: Bool) {
        if selected {
            contentView.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.85)
            blurView.isHidden = true
            titleLabel.textColor = .white
            contentView.layer.borderColor = UITheme.Colors.accent.cgColor
        } else {
            contentView.backgroundColor = .clear
            blurView.isHidden = false
            titleLabel.textColor = UITheme.Colors.textPrimary
            contentView.layer.borderColor = UITheme.Colors.glassBorder.cgColor
        }
    }

    override var isSelected: Bool {
        didSet { applySelectionState(isSelected) }
    }
}
