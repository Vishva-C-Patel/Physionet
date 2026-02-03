//
//  ProgramOverallProgressView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ProgramOverallProgressView: UIView {

    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(completedDays: Int, totalDays: Int) {
        titleLabel.text = "Overall Progress"
        countLabel.text = "\(completedDays) of \(totalDays) days"
        let progress = totalDays == 0 ? 0 : Float(completedDays) / Float(totalDays)
        progressBar.setProgress(progress, animated: true)
    }

    private func build() {
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.7)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        countLabel.textColor = UIColor(hex: "1E6EF7")

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.trackTintColor = UIColor.black.withAlphaComponent(0.08)
        progressBar.progressTintColor = UIColor(hex: "1E6EF7")
        progressBar.layer.cornerRadius = 4
        progressBar.clipsToBounds = true

        addSubview(titleLabel)
        addSubview(countLabel)
        addSubview(progressBar)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            countLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            progressBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            progressBar.heightAnchor.constraint(equalToConstant: 8),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
