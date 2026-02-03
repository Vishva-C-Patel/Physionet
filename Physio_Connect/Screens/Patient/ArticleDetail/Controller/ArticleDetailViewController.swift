//
//  ArticleDetailViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ArticleDetailViewController: UIViewController {

    private let detailView = ArticleDetailView()
    private var article: ArticleRow
    private let model = ArticlesModel()
    var onArticleUpdated: ((ArticleRow) -> Void)?

    init(article: ArticleRow) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() { view = detailView }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        detailView.configure(with: article)
        detailView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        detailView.shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { await incrementViewsAndRefresh() }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareTapped() {
        let link = URL(string: article.url ?? article.source_url ?? article.image_url ?? "")
        let items: [Any] = [article.title, link as Any].compactMap { $0 }
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.completionWithItemsHandler = { [weak self] _, completed, _, _ in
            if completed {
                return
            }
            self?.downloadPDF()
        }
        if let popover = vc.popoverPresentationController {
            popover.sourceView = detailView.shareButton
            popover.sourceRect = detailView.shareButton.bounds
        }
        present(vc, animated: true)
    }

    private func downloadPDF() {
        guard let pdfURL = makeArticlePDF() else {
            showToast("PDF Error", "Unable to create PDF.")
            return
        }
        let picker = UIDocumentPickerViewController(forExporting: [pdfURL], asCopy: true)
        picker.modalPresentationStyle = .formSheet
        present(picker, animated: true)
    }


    private func makeArticlePDF() -> URL? {
        let pageWidth: CGFloat = 595
        let margin: CGFloat = 36
        let contentWidth = pageWidth - margin * 2

        let title = article.title
        let meta = [article.source_name, article.published_at].compactMap { $0 }.joined(separator: " • ")
        let summary = article.summary ?? ""
        let body = detailView.preferredContentText(for: article)

        let titleAttr = NSAttributedString(
            string: title + "\n",
            attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        )
        let metaAttr = NSAttributedString(
            string: meta.isEmpty ? "" : "\(meta)\n\n",
            attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium),
                         .foregroundColor: UIColor.darkGray]
        )
        let summaryAttr = NSAttributedString(
            string: summary.isEmpty ? "" : "\(summary)\n\n",
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
        )
        let bodyAttr = NSAttributedString(
            string: body,
            attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular)]
        )

        let fullText = NSMutableAttributedString()
        fullText.append(titleAttr)
        fullText.append(metaAttr)
        fullText.append(summaryAttr)
        fullText.append(bodyAttr)

        let boundingRect = fullText.boundingRect(
            with: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let pageHeight = max(842, boundingRect.height + margin * 2)
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { context in
            context.beginPage()
            fullText.draw(
                with: CGRect(x: margin, y: margin, width: contentWidth, height: pageHeight - margin * 2),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
        }

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("article-\(article.id).pdf")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }

    private func incrementViewsAndRefresh() async {
        do {
            try await model.incrementViews(articleID: article.id)
            let refreshed = try await model.fetchArticle(id: article.id)
            await MainActor.run {
                self.article = refreshed
                self.detailView.configure(with: refreshed)
                self.onArticleUpdated?(refreshed)
            }
        } catch {
            await MainActor.run { self.showToast("Views Error", error.localizedDescription) }
        }
    }

    private func showToast(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(ac, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ac.dismiss(animated: true)
        }
    }

}
