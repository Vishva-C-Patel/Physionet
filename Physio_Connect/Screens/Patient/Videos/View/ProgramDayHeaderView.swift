//
//  ProgramDayHeaderView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ProgramDayHeaderView: UIView {

    private let dayCircle = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(day: Int, title: String, subtitle: String, completedCount: Int, totalCount: Int, isComplete: Bool) {
        dayCircle.text = "\(day)"
        dayCircle.backgroundColor = isComplete ? UIColor(hex: "22C55E") : UIColor(hex: "E5E7EB")
        dayCircle.textColor = isComplete ? .white : UIColor.black.withAlphaComponent(0.6)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        countLabel.text = "\(completedCount)/\(totalCount)"
    }

    private func build() {
        dayCircle.translatesAutoresizingMaskIntoConstraints = false
        dayCircle.font = .systemFont(ofSize: 14, weight: .bold)
        dayCircle.textAlignment = .center
        dayCircle.layer.cornerRadius = 16
        dayCircle.layer.masksToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .black

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.55)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        countLabel.textColor = UIColor.black.withAlphaComponent(0.6)

        addSubview(dayCircle)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(countLabel)

        NSLayoutConstraint.activate([
            dayCircle.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            dayCircle.widthAnchor.constraint(equalToConstant: 32),
            dayCircle.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: dayCircle.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
