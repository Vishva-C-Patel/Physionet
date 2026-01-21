//
//  RoleSelectionView.swift
//  Physio_Connect
//
//  Created by user@8 on 07/01/26.
//
import UIKit

final class RoleSelectionView: UIView {

    // MARK: - UI
    private let container = UIView()
    let heroImageView = UIImageView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    let patientButton = UIButton(type: .system)
    let physioButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E3F0FF")
        buildUI()
        layoutUI()
        styleUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func buildUI() {
        addSubview(container)
        [heroImageView, titleLabel, subtitleLabel, patientButton, physioButton].forEach { container.addSubview($0) }
    }

    private func layoutUI() {
        container.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        patientButton.translatesAutoresizingMaskIntoConstraints = false
        physioButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),

            heroImageView.topAnchor.constraint(equalTo: container.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalTo: heroImageView.widthAnchor, multiplier: 0.62),

            titleLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),

            patientButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 26),
            patientButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            patientButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            patientButton.heightAnchor.constraint(equalToConstant: 52),

            physioButton.topAnchor.constraint(equalTo: patientButton.bottomAnchor, constant: 14),
            physioButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            physioButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            physioButton.heightAnchor.constraint(equalToConstant: 52),

            physioButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    private func styleUI() {
        // Hero
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.layer.cornerRadius = 16

        // Text
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.text = "Welcome to\nPhysioConnect"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .black

        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Find the perfect physiotherapist and resources to support your health journey."
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.45)

        // Buttons
        configurePrimaryButton(patientButton, title: "Patient")
        configurePrimaryButton(physioButton, title: "Physiotherapist")

    }

    private func configurePrimaryButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "1E6EF7")
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.10
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    // MARK: - Public
    func setHeroImage(_ image: UIImage?) {
        heroImageView.image = image
    }
}
