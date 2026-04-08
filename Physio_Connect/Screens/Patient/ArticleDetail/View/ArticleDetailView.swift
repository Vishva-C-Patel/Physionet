//
//  ArticleDetailView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit
import WebKit

final class ArticleDetailView: UIView {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentCard = UIView()
    private let sourcePill = PaddedLabel(insets: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
    private let dateLabel = UILabel()
    private let tagsStack = UIStackView()
    private let articleTitleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let bodyLabel = UILabel()
    let webView = WKWebView(frame: .zero)
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var currentSummaryText: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func sourceHost(from urlString: String?) -> String? {
        guard let raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty,
              let url = URL(string: raw),
              let host = url.host
        else { return nil }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    func configure(with article: ArticleRow) {
        showTextContent()
        articleTitleLabel.text = article.title
        let bodyText = preferredBodyText(for: article)
        let summaryText = article.summary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        currentSummaryText = summaryText
        let shouldShowSummary = !summaryText.isEmpty && bodyText.caseInsensitiveCompare(summaryText) != .orderedSame
        summaryLabel.text = shouldShowSummary ? article.summary : nil
        summaryLabel.isHidden = !shouldShowSummary
        bodyLabel.text = bodyText
        let sourceText = article.source_name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sourceSlug = article.source?.trimmingCharacters(in: .whitespacesAndNewlines)
        let fallback = article.tags?.first?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlFallback = sourceHost(from: article.source_url) ?? sourceHost(from: article.url)
        sourcePill.text = (sourceText?.isEmpty == false ? sourceText :
                           (sourceSlug?.isEmpty == false ? sourceSlug :
                            (urlFallback?.isEmpty == false ? urlFallback :
                             (fallback?.isEmpty == false ? fallback : "Source"))))
        dateLabel.text = nil
        dateLabel.isHidden = true
        setTags(article.tags ?? [])
    }

    func updateBodyText(_ text: String) {
        let normalized = normalizeBodyText(text)
        bodyLabel.text = normalized
        let shouldShowSummary = !currentSummaryText.isEmpty &&
            normalized.caseInsensitiveCompare(currentSummaryText) != .orderedSame
        summaryLabel.text = shouldShowSummary ? currentSummaryText : nil
        summaryLabel.isHidden = !shouldShowSummary
    }

    private func preferredBodyText(for article: ArticleRow) -> String {
        let content = article.content?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let content, !content.isEmpty {
            return normalizeBodyText(content)
        }
        let summary = article.summary?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let summary, !summary.isEmpty {
            return normalizeBodyText(summary)
        }
        return "Full article content will appear here."
    }

    private func normalizeBodyText(_ text: String) -> String {
        let decoded = decodeHTMLIfNeeded(text)
        return decoded
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\t", with: "\t")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func decodeHTMLIfNeeded(_ text: String) -> String {
        guard text.contains("<"), text.contains(">"), let data = text.data(using: .utf8) else { return text }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        }
        return text
    }

    func preferredContentText(for article: ArticleRow) -> String {
        preferredBodyText(for: article)
    }

    func showTextContent() {
        scrollView.isHidden = false
        webView.isHidden = true
        loadingIndicator.stopAnimating()
    }

    func showWebContentLoading() {
        scrollView.isHidden = true
        webView.isHidden = false
        loadingIndicator.startAnimating()
    }

    func showWebContentLoaded() {
        scrollView.isHidden = true
        webView.isHidden = false
        loadingIndicator.stopAnimating()
    }

    private func build() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemGroupedBackground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isHidden = true
        webView.backgroundColor = .systemGroupedBackground
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = UITheme.Colors.accent

        contentCard.translatesAutoresizingMaskIntoConstraints = false
        contentCard.backgroundColor = UITheme.Colors.surface
        contentCard.layer.cornerRadius = 22
        contentCard.layer.shadowColor = UIColor.black.cgColor
        contentCard.layer.shadowOpacity = 0.08
        contentCard.layer.shadowRadius = 12
        contentCard.layer.shadowOffset = CGSize(width: 0, height: 8)

        sourcePill.translatesAutoresizingMaskIntoConstraints = false
        sourcePill.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
        sourcePill.textColor = UITheme.Colors.accent
        sourcePill.font = UITheme.Typography.caption
        sourcePill.layer.cornerRadius = 14
        sourcePill.layer.masksToBounds = true

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UITheme.Typography.meta
        dateLabel.textColor = UITheme.Colors.textSecondary

        tagsStack.translatesAutoresizingMaskIntoConstraints = false
        tagsStack.axis = .horizontal
        tagsStack.spacing = 8
        tagsStack.alignment = .leading

        articleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        articleTitleLabel.font = UITheme.Typography.sectionTitle
        articleTitleLabel.textColor = UITheme.Colors.textPrimary
        articleTitleLabel.numberOfLines = 0

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = UITheme.Typography.body
        summaryLabel.textColor = UITheme.Colors.textSecondary
        summaryLabel.numberOfLines = 0

        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UITheme.Typography.body
        bodyLabel.textColor = UITheme.Colors.textPrimary
        bodyLabel.numberOfLines = 0

        addSubview(scrollView)
        addSubview(webView)
        addSubview(loadingIndicator)
        scrollView.addSubview(contentView)

        contentView.addSubview(contentCard)
        contentCard.addSubview(sourcePill)
        contentCard.addSubview(dateLabel)
        contentCard.addSubview(tagsStack)
        contentCard.addSubview(articleTitleLabel)
        contentCard.addSubview(summaryLabel)
        contentCard.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            webView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            contentCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            sourcePill.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 16),
            sourcePill.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            sourcePill.heightAnchor.constraint(equalToConstant: 28),

            dateLabel.centerYAnchor.constraint(equalTo: sourcePill.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: sourcePill.trailingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentCard.trailingAnchor, constant: -16),

            tagsStack.topAnchor.constraint(equalTo: sourcePill.bottomAnchor, constant: 12),
            tagsStack.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            tagsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentCard.trailingAnchor, constant: -16),

            articleTitleLabel.topAnchor.constraint(equalTo: tagsStack.bottomAnchor, constant: 14),
            articleTitleLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            articleTitleLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),

            summaryLabel.topAnchor.constraint(equalTo: articleTitleLabel.bottomAnchor, constant: 10),
            summaryLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),

            bodyLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 14),
            bodyLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: -20)
        ])
    }

    private func setTags(_ tags: [String]) {
        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let displayTags = Array(tags.prefix(4))
        for tag in displayTags {
            let tagView = ArticleTagPillView(text: tag)
            tagsStack.addArrangedSubview(tagView)
        }
        tagsStack.isHidden = displayTags.isEmpty
    }

}

private final class ArticleTagPillView: UIView {
    private let label = UILabel()

    init(text: String) {
        super.init(frame: .zero)
        backgroundColor = UITheme.Colors.surface
        layer.cornerRadius = 14
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UITheme.Colors.accent
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class PaddedLabel: UILabel {
    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
