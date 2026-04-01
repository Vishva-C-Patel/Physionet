//
//  RoleSelectionView.swift
//  Physio_Connect
//
//  Created by user@8 on 07/01/26.
//
import UIKit

final class RoleSelectionView: UIView {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
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
        backgroundColor = .systemGroupedBackground
        buildUI()
        layoutUI()
        styleUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func buildUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(container)
        [heroImageView, titleLabel, subtitleLabel, patientButton, physioButton].forEach { container.addSubview($0) }
    }

    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        patientButton.translatesAutoresizingMaskIntoConstraints = false
        physioButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

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
        scrollView.showsVerticalScrollIndicator = false

        // Hero
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.layer.cornerRadius = UITheme.Metrics.cardCornerRadius

        // Text
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.text = "Welcome to\nPhysioNet"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label

        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Find the perfect physiotherapist and resources to support your health journey."
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        subtitleLabel.textColor = .secondaryLabel

        // Buttons
        configurePrimaryButton(patientButton, title: "Patient")
        configurePrimaryButton(physioButton, title: "Physiotherapist")

    }

    private func configurePrimaryButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UITheme.Colors.accent
        button.layer.cornerRadius = 27
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
