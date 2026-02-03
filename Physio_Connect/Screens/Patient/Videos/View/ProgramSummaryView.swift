//
//  ProgramSummaryView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ProgramSummaryView: UIView {

    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let weekBadge = UILabel()

    private let statsStack = UIStackView()
    private let adherenceCard = MetricCardView(iconName: "chart.line.uptrend.xyaxis", title: "Adherence")
    private let completedCard = MetricCardView(iconName: "checkmark.circle", title: "Completed")
    private let timeCard = MetricCardView(iconName: "clock", title: "This week")

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    func configure(programTitle: String, subtitle: String, adherenceText: String, completedText: String, timeText: String) {
        titleLabel.text = programTitle
        subtitleLabel.text = subtitle
        adherenceCard.setValue(adherenceText)
        completedCard.setValue(completedText)
        timeCard.setValue(timeText)
    }

    private func build() {
        layer.cornerRadius = 22
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 10)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 22
        contentView.layer.masksToBounds = true
        addSubview(contentView)

        gradientLayer.colors = [UIColor(hex: "2D7CFF").cgColor, UIColor(hex: "1F62F3").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gradientLayer, at: 0)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 1

        weekBadge.translatesAutoresizingMaskIntoConstraints = false
        weekBadge.text = "Week 1"
        weekBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        weekBadge.textColor = .white
        weekBadge.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        weekBadge.layer.cornerRadius = 14
        weekBadge.clipsToBounds = true
        weekBadge.textAlignment = .center

        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .horizontal
        statsStack.spacing = 12
        statsStack.distribution = .fillEqually

        statsStack.addArrangedSubview(adherenceCard)
        statsStack.addArrangedSubview(completedCard)
        statsStack.addArrangedSubview(timeCard)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(weekBadge)
        contentView.addSubview(statsStack)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: weekBadge.leadingAnchor, constant: -12),

            weekBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            weekBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            weekBadge.widthAnchor.constraint(equalToConstant: 60),
            weekBadge.heightAnchor.constraint(equalToConstant: 28),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            statsStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            statsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        ])
    }
}

private final class MetricCardView: UIView {

    private let iconView = UIImageView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    init(iconName: String, title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        iconView.image = UIImage(systemName: iconName)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ value: String) {
        valueLabel.text = value
    }

    private func build() {
        backgroundColor = UIColor.white.withAlphaComponent(0.12)
        layer.cornerRadius = 16

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.text = "--"

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        titleLabel.textAlignment = .center

        addSubview(iconView)
        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            valueLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 6),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
