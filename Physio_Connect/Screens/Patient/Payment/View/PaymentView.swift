//
//  PaymentView.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//
import UIKit

final class PaymentView: UIView {

    // Scroll
    let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let bottomContainer = UIView()
    private let bottomBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))

    // Header (No longer contains back button or nav title)
    private let summaryLabel = UILabel()
    private let paymentLabel = UILabel()

    private let backgroundGlow = AppBackgroundTopGlowView()

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
        backgroundColor = UITheme.Colors.background
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

        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(backgroundGlow, at: 0)

        // Bottom Container
        addSubview(bottomContainer)
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.backgroundColor = .clear

        bottomBlur.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(bottomBlur)

        NSLayoutConstraint.activate([
            bottomBlur.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            bottomBlur.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            bottomBlur.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            bottomBlur.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor),

            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Stack
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])

        summaryLabel.text = "Booking Summary"
        summaryLabel.font = UITheme.Typography.sectionTitle
        summaryLabel.textColor = UITheme.Colors.textSecondary
        stack.addArrangedSubview(summaryLabel)
        stack.setCustomSpacing(12, after: summaryLabel)

        // Saved banner card
        UITheme.applyCardStyle(savedCard)
        // Tint the background slightly to make it stand out as a success state
        savedCard.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.08)
        savedCard.layer.borderWidth = 1
        savedCard.layer.borderColor = UITheme.Colors.accent.withAlphaComponent(0.2).cgColor

        savedIconBg.translatesAutoresizingMaskIntoConstraints = false
        savedIconBg.backgroundColor = UITheme.Colors.accent
        savedIconBg.layer.cornerRadius = 20

        savedIcon.translatesAutoresizingMaskIntoConstraints = false
        savedIcon.image = UIImage(systemName: "checkmark")
        savedIcon.tintColor = .white
        savedIcon.contentMode = .scaleAspectFit

        savedTitle.translatesAutoresizingMaskIntoConstraints = false
        savedTitle.text = "Appointment Saved!"
        savedTitle.font = .systemFont(ofSize: 15, weight: .bold)
        savedTitle.textColor = UITheme.Colors.accent

        savedLine1.translatesAutoresizingMaskIntoConstraints = false
        savedLine1.font = .systemFont(ofSize: 15, weight: .semibold)
        savedLine1.textColor = UIColor.label

        savedLine2.translatesAutoresizingMaskIntoConstraints = false
        savedLine2.font = UITheme.Typography.caption
        savedLine2.textColor = UITheme.Colors.textSecondary
        savedLine2.text = "Pay now to confirm your booking"

        let savedTextStack = UIStackView(arrangedSubviews: [savedTitle, savedLine1, savedLine2])
        savedTextStack.axis = .vertical
        savedTextStack.spacing = 4
        savedTextStack.translatesAutoresizingMaskIntoConstraints = false

        savedCard.addSubview(savedIconBg)
        savedIconBg.addSubview(savedIcon)
        savedCard.addSubview(savedTextStack)

        NSLayoutConstraint.activate([
            savedIconBg.leadingAnchor.constraint(equalTo: savedCard.leadingAnchor, constant: 16),
            savedIconBg.topAnchor.constraint(equalTo: savedCard.topAnchor, constant: 16),
            savedIconBg.widthAnchor.constraint(equalToConstant: 40),
            savedIconBg.heightAnchor.constraint(equalToConstant: 40),

            savedIcon.centerXAnchor.constraint(equalTo: savedIconBg.centerXAnchor),
            savedIcon.centerYAnchor.constraint(equalTo: savedIconBg.centerYAnchor),
            savedIcon.widthAnchor.constraint(equalToConstant: 18),
            savedIcon.heightAnchor.constraint(equalToConstant: 18),

            savedTextStack.leadingAnchor.constraint(equalTo: savedIconBg.trailingAnchor, constant: 14),
            savedTextStack.trailingAnchor.constraint(equalTo: savedCard.trailingAnchor, constant: -16),
            savedTextStack.topAnchor.constraint(equalTo: savedCard.topAnchor, constant: 16),
            savedTextStack.bottomAnchor.constraint(equalTo: savedCard.bottomAnchor, constant: -16)
        ])

        stack.addArrangedSubview(savedCard)

        // Details card
        UITheme.applyCardStyle(detailsCard)
        detailsTitle.text = "Booking Details"
        detailsTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        detailsTitle.textColor = UIColor.label

        detailsText.numberOfLines = 0
        detailsText.font = UITheme.Typography.body
        detailsText.textColor = UITheme.Colors.textSecondary

        let detailsStack = UIStackView(arrangedSubviews: [detailsTitle, detailsText])
        detailsStack.axis = .vertical
        detailsStack.spacing = 12
        detailsStack.translatesAutoresizingMaskIntoConstraints = false

        detailsCard.addSubview(detailsStack)
        NSLayoutConstraint.activate([
            detailsStack.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 16),
            detailsStack.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            detailsStack.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            detailsStack.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -16)
        ])

        stack.addArrangedSubview(detailsCard)
        stack.setCustomSpacing(24, after: detailsCard)

        paymentLabel.text = "Payment"
        paymentLabel.font = UITheme.Typography.sectionTitle
        paymentLabel.textColor = UITheme.Colors.textSecondary
        stack.addArrangedSubview(paymentLabel)
        stack.setCustomSpacing(12, after: paymentLabel)

        // Price card
        UITheme.applyCardStyle(priceCard)
        priceTitle.text = "Price Breakdown"
        priceTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        priceTitle.textColor = UIColor.label

        priceStack.axis = .vertical
        priceStack.spacing = 14
        priceStack.translatesAutoresizingMaskIntoConstraints = false

        totalLeft.text = "Total"
        totalLeft.font = .systemFont(ofSize: 18, weight: .semibold)
        totalLeft.textColor = UIColor.label

        totalRight.text = "₹0"
        totalRight.font = .systemFont(ofSize: 28, weight: .heavy)
        totalRight.textColor = UITheme.Colors.accent
        totalRight.textAlignment = .right

        totalRow.translatesAutoresizingMaskIntoConstraints = false
        totalRow.addSubview(totalLeft)
        totalRow.addSubview(totalRight)

        totalLeft.translatesAutoresizingMaskIntoConstraints = false
        totalRight.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            totalLeft.topAnchor.constraint(equalTo: totalRow.topAnchor, constant: 4),
            totalLeft.leadingAnchor.constraint(equalTo: totalRow.leadingAnchor),
            totalLeft.bottomAnchor.constraint(equalTo: totalRow.bottomAnchor, constant: -4),

            totalRight.trailingAnchor.constraint(equalTo: totalRow.trailingAnchor),
            totalRight.centerYAnchor.constraint(equalTo: totalLeft.centerYAnchor)
        ])

        let priceContainer = UIStackView(arrangedSubviews: [priceTitle, priceStack, UIView(), totalRow])
        priceContainer.axis = .vertical
        priceContainer.spacing = 16
        priceContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add separator before total
        let priceDivider = UIView()
        priceDivider.backgroundColor = UIColor.separator.withAlphaComponent(0.5)
        priceDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        priceContainer.insertArrangedSubview(priceDivider, at: 2)

        priceCard.addSubview(priceContainer)
        NSLayoutConstraint.activate([
            priceContainer.topAnchor.constraint(equalTo: priceCard.topAnchor, constant: 16),
            priceContainer.leadingAnchor.constraint(equalTo: priceCard.leadingAnchor, constant: 16),
            priceContainer.trailingAnchor.constraint(equalTo: priceCard.trailingAnchor, constant: -16),
            priceContainer.bottomAnchor.constraint(equalTo: priceCard.bottomAnchor, constant: -16)
        ])

        stack.addArrangedSubview(priceCard)

        // Payment method card
        UITheme.applyCardStyle(paymentMethodCard)

        paymentMethodIconBg.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodIconBg.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
        paymentMethodIconBg.layer.cornerRadius = 18

        paymentMethodIcon.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodIcon.image = UIImage(systemName: "creditcard")
        paymentMethodIcon.tintColor = UITheme.Colors.accent

        paymentMethodTitle.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodTitle.text = "Payment Method"
        paymentMethodTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        paymentMethodTitle.textColor = UIColor.label

        paymentMethodSub.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodSub.text = "Pay securely with UPI, card, or netbanking"
        paymentMethodSub.font = UITheme.Typography.caption
        paymentMethodSub.textColor = UITheme.Colors.textSecondary

        let paymentMethodTextStack = UIStackView(arrangedSubviews: [paymentMethodTitle, paymentMethodSub])
        paymentMethodTextStack.axis = .vertical
        paymentMethodTextStack.spacing = 4
        paymentMethodTextStack.translatesAutoresizingMaskIntoConstraints = false

        paymentMethodCard.addSubview(paymentMethodIconBg)
        paymentMethodIconBg.addSubview(paymentMethodIcon)
        paymentMethodCard.addSubview(paymentMethodTextStack)

        NSLayoutConstraint.activate([
            paymentMethodIconBg.leadingAnchor.constraint(equalTo: paymentMethodCard.leadingAnchor, constant: 16),
            paymentMethodIconBg.centerYAnchor.constraint(equalTo: paymentMethodCard.centerYAnchor),
            paymentMethodIconBg.widthAnchor.constraint(equalToConstant: 36),
            paymentMethodIconBg.heightAnchor.constraint(equalToConstant: 36),

            paymentMethodIcon.centerXAnchor.constraint(equalTo: paymentMethodIconBg.centerXAnchor),
            paymentMethodIcon.centerYAnchor.constraint(equalTo: paymentMethodIconBg.centerYAnchor),
            paymentMethodIcon.widthAnchor.constraint(equalToConstant: 18),
            paymentMethodIcon.heightAnchor.constraint(equalToConstant: 18),

            paymentMethodTextStack.leadingAnchor.constraint(equalTo: paymentMethodIconBg.trailingAnchor, constant: 14),
            paymentMethodTextStack.trailingAnchor.constraint(equalTo: paymentMethodCard.trailingAnchor, constant: -16),
            paymentMethodTextStack.topAnchor.constraint(equalTo: paymentMethodCard.topAnchor, constant: 16),
            paymentMethodTextStack.bottomAnchor.constraint(equalTo: paymentMethodCard.bottomAnchor, constant: -16)
        ])

        stack.addArrangedSubview(paymentMethodCard)

        // Security card
        UITheme.applyCardStyle(securityCard)
        securityCard.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.08)
        securityCard.layer.borderWidth = 1
        securityCard.layer.borderColor = UITheme.Colors.accent.withAlphaComponent(0.2).cgColor

        securityIcon.translatesAutoresizingMaskIntoConstraints = false
        securityIcon.image = UIImage(systemName: "lock.shield.fill")
        securityIcon.tintColor = UITheme.Colors.accent

        securityText.translatesAutoresizingMaskIntoConstraints = false
        securityText.numberOfLines = 0
        securityText.textColor = UITheme.Colors.accent
        securityText.font = .systemFont(ofSize: 12, weight: .medium)
        securityText.text = "Your information is encrypted and secure. We never share your data with third parties."

        securityCard.addSubview(securityIcon)
        securityCard.addSubview(securityText)

        NSLayoutConstraint.activate([
            securityIcon.leadingAnchor.constraint(equalTo: securityCard.leadingAnchor, constant: 16),
            securityIcon.topAnchor.constraint(equalTo: securityCard.topAnchor, constant: 16),
            securityIcon.widthAnchor.constraint(equalToConstant: 20),
            securityIcon.heightAnchor.constraint(equalToConstant: 20),

            securityText.leadingAnchor.constraint(equalTo: securityIcon.trailingAnchor, constant: 12),
            securityText.trailingAnchor.constraint(equalTo: securityCard.trailingAnchor, constant: -16),
            securityText.topAnchor.constraint(equalTo: securityCard.topAnchor, constant: 16),
            securityText.bottomAnchor.constraint(equalTo: securityCard.bottomAnchor, constant: -16)
        ])

        stack.addArrangedSubview(securityCard)
        stack.setCustomSpacing(32, after: securityCard)

        // Pay button
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.setTitle("Pay & Confirm Booking", for: .normal)
        payButton.setTitleColor(.white, for: .normal)
        payButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        
        let payGradient = CAGradientLayer()
        payGradient.colors = [UITheme.Colors.accent.cgColor, UITheme.Colors.accent.withAlphaComponent(0.85).cgColor]
        payGradient.startPoint = CGPoint(x: 0, y: 0)
        payGradient.endPoint = CGPoint(x: 1, y: 1)
        payGradient.cornerRadius = 22
        payButton.layer.insertSublayer(payGradient, at: 0)
        
        payButton.layer.cornerRadius = 27
        payButton.layer.shadowColor = UITheme.Colors.accent.cgColor
        payButton.layer.shadowOpacity = 0.3
        payButton.layer.shadowRadius = 12
        payButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        payButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        // Ensure gradient resizes
        payButton.layer.masksToBounds = false
        DispatchQueue.main.async {
            payGradient.frame = self.payButton.bounds
        }

        payHint.text = "Payment is required to confirm your appointment"
        payHint.font = UITheme.Typography.caption
        payHint.textColor = UITheme.Colors.textSecondary
        payHint.textAlignment = .center

        bottomContainer.addSubview(payButton)
        bottomContainer.addSubview(payHint)

        payHint.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            payButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),

            payHint.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: 12),
            payHint.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            payHint.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            payHint.bottomAnchor.constraint(equalTo: bottomContainer.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        // Update gradient on layout
        payButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            payGradient.frame = self.payButton.bounds
        }, for: .allTouchEvents) // Small hack to ensure layout size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = payButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = payButton.bounds
        }
    }

    // MARK: - Public render

    func render(model: PaymentModel) {
        savedLine1.text = model.formattedDateTime()

        let detailsString =
        "with \(model.draft.physioName)\n" +
        "\(model.draft.address)\n" +
        "\(model.draft.phone)"
        let detailsStyle = NSMutableParagraphStyle()
        detailsStyle.lineSpacing = 6
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
        l.font = UITheme.Typography.body
        l.textColor = UITheme.Colors.textSecondary

        r.text = right
        r.font = .systemFont(ofSize: 15, weight: .semibold)
        r.textColor = UIColor.label
        r.textAlignment = .right

        l.translatesAutoresizingMaskIntoConstraints = false
        r.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(l)
        row.addSubview(r)

        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: row.topAnchor, constant: 4),
            l.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            l.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -4),

            r.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            r.centerYAnchor.constraint(equalTo: l.centerYAnchor),

            l.trailingAnchor.constraint(lessThanOrEqualTo: r.leadingAnchor, constant: -10)
        ])

        return row
    }
}
