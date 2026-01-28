//
//  FeaturedArticleCardView.swift
//  Physio_Connect
//
//  Created by user@8 on 28/01/26.
//

import UIKit

final class FeaturedArticleCardView: UIView {

    private let cardView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let badgeStack = UIStackView()
    private let badgeIcon = UIImageView()
    private let badgeLabel = UILabel()
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let readButton = UIButton(type: .system)

    var onReadTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = cardView.bounds
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 26
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.masksToBounds = false

        gradientLayer.colors = [
            UIColor(hex: "E6F3FF").cgColor,
            UIColor(hex: "FFE6D8").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 26
        cardView.layer.insertSublayer(gradientLayer, at: 0)

        badgeStack.axis = .horizontal
        badgeStack.spacing = 6
        badgeStack.alignment = .center
        badgeStack.translatesAutoresizingMaskIntoConstraints = false

        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeIcon.image = UIImage(systemName: "sparkles")
        badgeIcon.tintColor = UIColor(hex: "FF7A2F")

        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.text = "Editor's Choice"
        badgeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        badgeLabel.textColor = UIColor.black.withAlphaComponent(0.8)

        badgeStack.addArrangedSubview(badgeIcon)
        badgeStack.addArrangedSubview(badgeLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .systemFont(ofSize: 15, weight: .regular)
        summaryLabel.textColor = UIColor.black.withAlphaComponent(0.65)
        summaryLabel.numberOfLines = 3

        readButton.setTitle("Read Featured Story", for: .normal)
        readButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        readButton.setTitleColor(.white, for: .normal)
        readButton.backgroundColor = UIColor(hex: "1E6EF7")
        readButton.layer.cornerRadius = 18
        readButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        readButton.addTarget(self, action: #selector(readTapped), for: .touchUpInside)

        addSubview(cardView)
        [badgeStack, titleLabel, summaryLabel, readButton].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),

            badgeStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            badgeStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),

            badgeIcon.widthAnchor.constraint(equalToConstant: 16),
            badgeIcon.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.topAnchor.constraint(equalTo: badgeStack.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            summaryLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            summaryLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            readButton.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 16),
            readButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            readButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])
    }

    func configure(with article: ArticleRow?) {
        guard let article else {
            isHidden = true
            return
        }
        isHidden = false
        titleLabel.text = article.title
        summaryLabel.text = article.summary ?? "Explore the latest insights and research from our experts."
    }

    @objc private func readTapped() {
        onReadTapped?()
    }
}
