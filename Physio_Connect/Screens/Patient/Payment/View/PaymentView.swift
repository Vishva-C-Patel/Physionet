//
//  PaymentView.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//
import UIKit

final class PaymentView: UIView {

    // Theme
    private let bg = UIColor(hex: "E3F0FF")
    private let primaryBlue = UIColor(hex: "1E6EF7")
    private let green = UIColor(hex: "2E9B5E")

    // Scroll
    let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    // Header
    let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let divider = UIView()
    private let summaryLabel = UILabel()
    private let paymentLabel = UILabel()

    // Cards
    private let savedCard = UIView()
    private let savedIconBg = UIView()
    private let savedIcon = UIImageView()
    private let savedTitle = UILabel()
    private let savedLine1 = UILabel()
    private let savedLine2 = UILabel()

    private let detailsCard = UIView()
    private let detailsTitle = UILabel()
    private let detailsText = UILabel()

    private let priceCard = UIView()
    private let priceTitle = UILabel()
    private let priceStack = UIStackView()
    private let totalRow = UIView()
    private let totalLeft = UILabel()
    private let totalRight = UILabel()

    private let securityCard = UIView()
    private let securityIcon = UIImageView()
    private let securityText = UILabel()
    private let paymentMethodCard = UIView()
    private let paymentMethodIconBg = UIView()
    private let paymentMethodIcon = UIImageView()
    private let paymentMethodTitle = UILabel()
    private let paymentMethodSub = UILabel()

    // Buttons
    let payButton = UIButton(type: .system)
    let payHint = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = bg
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {

        // Scroll
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Stack
        stack.axis = .vertical
        stack.spacing = 22
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        ])

        // Header
        let headerRow = UIView()
        headerRow.translatesAutoresizingMaskIntoConstraints = false

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = primaryBlue
        backButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Payment"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Complete payment to confirm your booking"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.textAlignment = .center

        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.black.withAlphaComponent(0.08)

        headerRow.addSubview(backButton)
        headerRow.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerRow.heightAnchor.constraint(equalToConstant: 40),
            backButton.leadingAnchor.constraint(equalTo: headerRow.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerRow.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor)
        ])

        stack.addArrangedSubview(headerRow)
        stack.addArrangedSubview(subtitleLabel)
        stack.addArrangedSubview(divider)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stack.setCustomSpacing(6, after: headerRow)
        stack.setCustomSpacing(14, after: subtitleLabel)
        stack.setCustomSpacing(20, after: divider)

        summaryLabel.text = "Booking Summary"
        summaryLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        summaryLabel.textColor = .darkGray
        stack.addArrangedSubview(summaryLabel)
        stack.setCustomSpacing(12, after: summaryLabel)

        // Saved banner card (blue like your ref)
        styleCard(savedCard)
        savedCard.layer.borderWidth = 1
        savedCard.layer.borderColor = primaryBlue.withAlphaComponent(0.25).cgColor
        savedCard.backgroundColor = primaryBlue.withAlphaComponent(0.08)

        savedIconBg.translatesAutoresizingMaskIntoConstraints = false
        savedIconBg.backgroundColor = primaryBlue
        savedIconBg.layer.cornerRadius = 20

        savedIcon.translatesAutoresizingMaskIntoConstraints = false
        savedIcon.image = UIImage(systemName: "checkmark")
        savedIcon.tintColor = .white
        savedIcon.contentMode = .scaleAspectFit

        savedTitle.translatesAutoresizingMaskIntoConstraints = false
        savedTitle.text = "Appointment Saved!"
        savedTitle.font = .systemFont(ofSize: 15, weight: .bold)
        savedTitle.textColor = primaryBlue

        savedLine1.translatesAutoresizingMaskIntoConstraints = false
        savedLine1.font = .systemFont(ofSize: 14, weight: .semibold)
        savedLine1.textColor = .black

        savedLine2.translatesAutoresizingMaskIntoConstraints = false
        savedLine2.font = .systemFont(ofSize: 13, weight: .medium)
        savedLine2.textColor = .darkGray
        savedLine2.text = "Pay now to confirm your booking"

        let savedTextStack = UIStackView(arrangedSubviews: [savedTitle, savedLine1, savedLine2])
        savedTextStack.axis = .vertical
        savedTextStack.spacing = 4
        savedTextStack.translatesAutoresizingMaskIntoConstraints = false

        savedCard.addSubview(savedIconBg)
        savedIconBg.addSubview(savedIcon)
        savedCard.addSubview(savedTextStack)

        NSLayoutConstraint.activate([
            savedIconBg.leadingAnchor.constraint(equalTo: savedCard.leadingAnchor, constant: 14),
            savedIconBg.topAnchor.constraint(equalTo: savedCard.topAnchor, constant: 14),
            savedIconBg.widthAnchor.constraint(equalToConstant: 40),
            savedIconBg.heightAnchor.constraint(equalToConstant: 40),

            savedIcon.centerXAnchor.constraint(equalTo: savedIconBg.centerXAnchor),
            savedIcon.centerYAnchor.constraint(equalTo: savedIconBg.centerYAnchor),
            savedIcon.widthAnchor.constraint(equalToConstant: 18),
            savedIcon.heightAnchor.constraint(equalToConstant: 18),

            savedTextStack.leadingAnchor.constraint(equalTo: savedIconBg.trailingAnchor, constant: 12),
            savedTextStack.trailingAnchor.constraint(equalTo: savedCard.trailingAnchor, constant: -14),
            savedTextStack.topAnchor.constraint(equalTo: savedCard.topAnchor, constant: 14),
            savedTextStack.bottomAnchor.constraint(equalTo: savedCard.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(savedCard)
        stack.setCustomSpacing(16, after: savedCard)

        // Details card
        styleCard(detailsCard)
        detailsTitle.text = "Booking Details"
        detailsTitle.font = .boldSystemFont(ofSize: 16)

        detailsText.numberOfLines = 0
        detailsText.font = .systemFont(ofSize: 13, weight: .medium)
        detailsText.textColor = .darkGray

        let detailsStack = UIStackView(arrangedSubviews: [detailsTitle, detailsText])
        detailsStack.axis = .vertical
        detailsStack.spacing = 12
        detailsStack.translatesAutoresizingMaskIntoConstraints = false

        detailsCard.addSubview(detailsStack)
        NSLayoutConstraint.activate([
            detailsStack.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 14),
            detailsStack.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 14),
            detailsStack.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -14),
            detailsStack.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(detailsCard)
        stack.setCustomSpacing(20, after: detailsCard)

        paymentLabel.text = "Payment"
        paymentLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        paymentLabel.textColor = .darkGray
        stack.addArrangedSubview(paymentLabel)
        stack.setCustomSpacing(12, after: paymentLabel)

        // Price card
        styleCard(priceCard)
        priceTitle.text = "Price Breakdown"
        priceTitle.font = .boldSystemFont(ofSize: 16)

        priceStack.axis = .vertical
        priceStack.spacing = 12
        priceStack.translatesAutoresizingMaskIntoConstraints = false

        totalLeft.text = "Total"
        totalLeft.font = .boldSystemFont(ofSize: 16)

        totalRight.text = "₹0"
        totalRight.font = .boldSystemFont(ofSize: 16)
        totalRight.textColor = green
        totalRight.textAlignment = .right

        totalRow.translatesAutoresizingMaskIntoConstraints = false
        totalRow.addSubview(totalLeft)
        totalRow.addSubview(totalRight)

        totalLeft.translatesAutoresizingMaskIntoConstraints = false
        totalRight.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            totalLeft.leadingAnchor.constraint(equalTo: totalRow.leadingAnchor),
            totalLeft.centerYAnchor.constraint(equalTo: totalRow.centerYAnchor),

            totalRight.trailingAnchor.constraint(equalTo: totalRow.trailingAnchor),
            totalRight.centerYAnchor.constraint(equalTo: totalRow.centerYAnchor)
        ])

        let priceContainer = UIStackView(arrangedSubviews: [priceTitle, priceStack, UIView(), totalRow])
        priceContainer.axis = .vertical
        priceContainer.spacing = 16
        priceContainer.translatesAutoresizingMaskIntoConstraints = false

        priceCard.addSubview(priceContainer)
        NSLayoutConstraint.activate([
            priceContainer.topAnchor.constraint(equalTo: priceCard.topAnchor, constant: 14),
            priceContainer.leadingAnchor.constraint(equalTo: priceCard.leadingAnchor, constant: 14),
            priceContainer.trailingAnchor.constraint(equalTo: priceCard.trailingAnchor, constant: -14),
            priceContainer.bottomAnchor.constraint(equalTo: priceCard.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(priceCard)
        stack.setCustomSpacing(12, after: priceCard)

        // Payment method card
        styleCard(paymentMethodCard)

        paymentMethodIconBg.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodIconBg.backgroundColor = primaryBlue.withAlphaComponent(0.12)
        paymentMethodIconBg.layer.cornerRadius = 18

        paymentMethodIcon.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodIcon.image = UIImage(systemName: "creditcard")
        paymentMethodIcon.tintColor = primaryBlue

        paymentMethodTitle.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodTitle.text = "Payment Method"
        paymentMethodTitle.font = .systemFont(ofSize: 15, weight: .bold)

        paymentMethodSub.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodSub.text = "Pay securely with UPI, card, or netbanking"
        paymentMethodSub.font = .systemFont(ofSize: 12, weight: .medium)
        paymentMethodSub.textColor = .darkGray

        let paymentMethodTextStack = UIStackView(arrangedSubviews: [paymentMethodTitle, paymentMethodSub])
        paymentMethodTextStack.axis = .vertical
        paymentMethodTextStack.spacing = 4
        paymentMethodTextStack.translatesAutoresizingMaskIntoConstraints = false

        paymentMethodCard.addSubview(paymentMethodIconBg)
        paymentMethodIconBg.addSubview(paymentMethodIcon)
        paymentMethodCard.addSubview(paymentMethodTextStack)

        NSLayoutConstraint.activate([
            paymentMethodIconBg.leadingAnchor.constraint(equalTo: paymentMethodCard.leadingAnchor, constant: 14),
            paymentMethodIconBg.centerYAnchor.constraint(equalTo: paymentMethodCard.centerYAnchor),
            paymentMethodIconBg.widthAnchor.constraint(equalToConstant: 36),
            paymentMethodIconBg.heightAnchor.constraint(equalToConstant: 36),

            paymentMethodIcon.centerXAnchor.constraint(equalTo: paymentMethodIconBg.centerXAnchor),
            paymentMethodIcon.centerYAnchor.constraint(equalTo: paymentMethodIconBg.centerYAnchor),
            paymentMethodIcon.widthAnchor.constraint(equalToConstant: 18),
            paymentMethodIcon.heightAnchor.constraint(equalToConstant: 18),

            paymentMethodTextStack.leadingAnchor.constraint(equalTo: paymentMethodIconBg.trailingAnchor, constant: 12),
            paymentMethodTextStack.trailingAnchor.constraint(equalTo: paymentMethodCard.trailingAnchor, constant: -14),
            paymentMethodTextStack.topAnchor.constraint(equalTo: paymentMethodCard.topAnchor, constant: 14),
            paymentMethodTextStack.bottomAnchor.constraint(equalTo: paymentMethodCard.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(paymentMethodCard)
        stack.setCustomSpacing(16, after: paymentMethodCard)

        // Security card (blue)
        styleCard(securityCard)
        securityCard.backgroundColor = primaryBlue.withAlphaComponent(0.08)
        securityCard.layer.borderWidth = 1
        securityCard.layer.borderColor = primaryBlue.withAlphaComponent(0.25).cgColor

        securityIcon.translatesAutoresizingMaskIntoConstraints = false
        securityIcon.image = UIImage(systemName: "lock.shield")
        securityIcon.tintColor = primaryBlue

        securityText.translatesAutoresizingMaskIntoConstraints = false
        securityText.numberOfLines = 0
        securityText.textColor = primaryBlue
        securityText.font = .systemFont(ofSize: 12, weight: .semibold)
        securityText.text = "Your information is encrypted and secure. We never share your data with third parties."

        securityCard.addSubview(securityIcon)
        securityCard.addSubview(securityText)

        NSLayoutConstraint.activate([
            securityIcon.leadingAnchor.constraint(equalTo: securityCard.leadingAnchor, constant: 14),
            securityIcon.topAnchor.constraint(equalTo: securityCard.topAnchor, constant: 14),
            securityIcon.widthAnchor.constraint(equalToConstant: 18),
            securityIcon.heightAnchor.constraint(equalToConstant: 18),

            securityText.leadingAnchor.constraint(equalTo: securityIcon.trailingAnchor, constant: 10),
            securityText.trailingAnchor.constraint(equalTo: securityCard.trailingAnchor, constant: -14),
            securityText.topAnchor.constraint(equalTo: securityCard.topAnchor, constant: 14),
            securityText.bottomAnchor.constraint(equalTo: securityCard.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(securityCard)
        stack.setCustomSpacing(20, after: securityCard)

        // Pay button
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.setTitle("Pay & Confirm Booking", for: .normal)
        payButton.setTitleColor(.white, for: .normal)
        payButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        payButton.backgroundColor = primaryBlue
        payButton.layer.cornerRadius = 18
        payButton.layer.shadowColor = UIColor.black.cgColor
        payButton.layer.shadowOpacity = 0.12
        payButton.layer.shadowRadius = 10
        payButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        payButton.heightAnchor.constraint(equalToConstant: 54).isActive = true

        payHint.text = "Payment is required to confirm your appointment"
        payHint.font = .systemFont(ofSize: 12, weight: .medium)
        payHint.textColor = .gray
        payHint.textAlignment = .center

        stack.addArrangedSubview(payButton)
        stack.addArrangedSubview(payHint)
    }

    // MARK: - Public render

    func render(model: PaymentModel) {
        savedLine1.text = model.formattedDateTime()

        let detailsString =
        "with \(model.draft.physioName)\n" +
        "\(model.draft.address)\n" +
        "\(model.draft.phone)"
        let detailsStyle = NSMutableParagraphStyle()
        detailsStyle.lineSpacing = 4
        detailsText.attributedText = NSAttributedString(
            string: detailsString,
            attributes: [
                .paragraphStyle: detailsStyle,
                .font: detailsText.font as Any,
                .foregroundColor: detailsText.textColor as Any
            ]
        )

        // price rows
        priceStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        priceStack.addArrangedSubview(makePriceRow("Session fee", "₹\(model.sessionFee)"))
        priceStack.addArrangedSubview(makePriceRow("Home visit fee", "₹\(model.homeVisitFee)"))
        priceStack.addArrangedSubview(makePriceRow("Platform fee", "₹\(model.platformFee)"))

        totalRight.text = "₹\(model.total)"
    }

    // MARK: - Helpers

    private func makePriceRow(_ left: String, _ right: String) -> UIView {
        let row = UIView()
        let l = UILabel()
        let r = UILabel()

        l.text = left
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .darkGray

        r.text = right
        r.font = .systemFont(ofSize: 13, weight: .semibold)
        r.textAlignment = .right

        l.translatesAutoresizingMaskIntoConstraints = false
        r.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(l)
        row.addSubview(r)

        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            l.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            r.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            r.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            l.trailingAnchor.constraint(lessThanOrEqualTo: r.leadingAnchor, constant: -10)
        ])

        return row
    }

    private func styleCard(_ v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
    }
}
