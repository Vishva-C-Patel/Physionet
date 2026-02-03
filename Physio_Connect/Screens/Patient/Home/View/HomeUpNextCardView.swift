//
//  HomeUpNextCardView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class HomeUpNextCardView: UIView {

    struct ViewModel {
        let timeText: String
        let title: String
        let metaText: String
        let primaryTitle: String
    }

    private let gradientLayer = CAGradientLayer()
    private let timePill = UIView()
    private let timeIcon = UIImageView()
    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    let primaryButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func configure(with vm: ViewModel) {
        timeLabel.text = vm.timeText
        titleLabel.text = vm.title
        metaLabel.text = vm.metaText
        primaryButton.setTitle(vm.primaryTitle, for: .normal)
        // secondary button removed
    }

    private func build() {
        layer.cornerRadius = 24
        layer.masksToBounds = true
        gradientLayer.colors = [
            UIColor(hex: "6D5BFF").cgColor,
            UIColor(hex: "8E3CFF").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        timePill.translatesAutoresizingMaskIntoConstraints = false
        timePill.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        timePill.layer.cornerRadius = 14

        timeIcon.translatesAutoresizingMaskIntoConstraints = false
        timeIcon.image = UIImage(systemName: "clock")
        timeIcon.tintColor = .white
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        timeLabel.textColor = .white

        timePill.addSubview(timeIcon)
        timePill.addSubview(timeLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.font = .systemFont(ofSize: 14, weight: .medium)
        metaLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.backgroundColor = .white
        primaryButton.setTitleColor(UIColor(hex: "6D5BFF"), for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        primaryButton.layer.cornerRadius = 18
        primaryButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)


        addSubview(timePill)
        addSubview(titleLabel)
        addSubview(metaLabel)
        addSubview(primaryButton)

        NSLayoutConstraint.activate([
            timePill.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            timePill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            timeIcon.leadingAnchor.constraint(equalTo: timePill.leadingAnchor, constant: 10),
            timeIcon.centerYAnchor.constraint(equalTo: timePill.centerYAnchor),
            timeIcon.widthAnchor.constraint(equalToConstant: 14),
            timeIcon.heightAnchor.constraint(equalToConstant: 14),

            timeLabel.leadingAnchor.constraint(equalTo: timeIcon.trailingAnchor, constant: 6),
            timeLabel.trailingAnchor.constraint(equalTo: timePill.trailingAnchor, constant: -12),
            timeLabel.topAnchor.constraint(equalTo: timePill.topAnchor, constant: 6),
            timeLabel.bottomAnchor.constraint(equalTo: timePill.bottomAnchor, constant: -6),

            titleLabel.topAnchor.constraint(equalTo: timePill.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            primaryButton.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 16),
            primaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            primaryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            primaryButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
}
