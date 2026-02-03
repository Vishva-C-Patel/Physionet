//
//  ArticleFilterChipCell.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ArticleFilterChipCell: UICollectionViewCell {

    static let reuseID = "ArticleFilterChipCell"

    private let titleLabel = UILabel()

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
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)
        ])
    }

    private func applySelectionState(_ selected: Bool) {
        if selected {
            contentView.backgroundColor = UIColor(hex: "1E6EF7")
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .white
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        }
    }

    override var isSelected: Bool {
        didSet { applySelectionState(isSelected) }
    }
}
