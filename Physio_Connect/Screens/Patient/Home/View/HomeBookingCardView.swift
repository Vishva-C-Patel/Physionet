//
//  HomeBookingCardView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class HomeBookingCardView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    let actionButton = UIButton(type: .system)
    private let iconCircle = UIView()
    private let iconView = UIImageView()
    private let bubbleLarge = UIView()
    private let bubbleSmall = UIView()

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

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    private func build() {
        layer.cornerRadius = 26
        layer.masksToBounds = true
        gradientLayer.colors = [
            UIColor(hex: "19C5F7").cgColor,
            UIColor(hex: "2C6BFF").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        bubbleLarge.translatesAutoresizingMaskIntoConstraints = false
        bubbleLarge.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        bubbleLarge.layer.cornerRadius = 90

        bubbleSmall.translatesAutoresizingMaskIntoConstraints = false
        bubbleSmall.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        bubbleSmall.layer.cornerRadius = 44

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 2

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle("Book Appointment", for: .normal)
        actionButton.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.backgroundColor = .white
        actionButton.layer.cornerRadius = 18
        actionButton.layer.shadowColor = UIColor.black.cgColor
        actionButton.layer.shadowOpacity = 0.12
        actionButton.layer.shadowRadius = 8
        actionButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)

        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        iconCircle.layer.cornerRadius = 32

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "calendar")
        iconView.tintColor = .white

        iconCircle.addSubview(iconView)

        addSubview(bubbleLarge)
        addSubview(bubbleSmall)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(actionButton)
        addSubview(iconCircle)

        NSLayoutConstraint.activate([
            bubbleLarge.widthAnchor.constraint(equalToConstant: 180),
            bubbleLarge.heightAnchor.constraint(equalToConstant: 180),
            bubbleLarge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 40),
            bubbleLarge.topAnchor.constraint(equalTo: topAnchor, constant: -30),

            bubbleSmall.widthAnchor.constraint(equalToConstant: 88),
            bubbleSmall.heightAnchor.constraint(equalToConstant: 88),
            bubbleSmall.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36),
            bubbleSmall.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -90),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            actionButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),

            iconCircle.widthAnchor.constraint(equalToConstant: 64),
            iconCircle.heightAnchor.constraint(equalToConstant: 64),
            iconCircle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            iconCircle.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor)
        ])
    }
}
