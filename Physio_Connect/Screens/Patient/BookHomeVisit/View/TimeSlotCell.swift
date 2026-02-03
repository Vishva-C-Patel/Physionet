//
//  TimeSlotCell.swift
//  Physio_Connect
//
//  Created by user@8 on 31/12/25.
//

import UIKit

final class TimeSlotCell: UICollectionViewCell {
    static let reuseID = "TimeSlotCell"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.backgroundColor = .white

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label

        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override var isSelected: Bool {
        didSet { updateStyle() }
    }

    func configure(timeText: String, enabled: Bool) {
        label.text = timeText
        isUserInteractionEnabled = enabled
        contentView.alpha = enabled ? 1.0 : 0.45
        updateStyle()
    }

    private func updateStyle() {
        if isSelected {
            contentView.backgroundColor = UIColor(hex: "1E6EF7")
            contentView.layer.borderColor = UIColor(hex: "1E6EF7").cgColor
            label.textColor = .white
        } else {
            contentView.backgroundColor = .white
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            label.textColor = .label
        }
    }
}
