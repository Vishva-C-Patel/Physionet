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
    private var hasLoadedUserRating = false

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
        loadCoverImage(for: article)
        detailView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        detailView.shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        detailView.onRatingSelected = { [weak self] rating in
            Task { await self?.submitRating(rating) }
        }
        Task { await loadUserRating() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { await incrementViewsAndRefresh() }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareTapped() {
        let shareText = article.title
        let shareURL = URL(string: article.url ?? article.source_url ?? article.image_url ?? "")
        let items: [Any] = [shareText, shareURL as Any].compactMap { $0 }
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true)
    }

    private func submitRating(_ rating: Int) async {
        do {
            try await model.submitRating(articleID: article.id, rating: rating)
            let refreshed = try await model.fetchArticle(id: article.id)
            await MainActor.run {
                self.article = refreshed
                self.detailView.configure(with: refreshed)
                self.loadCoverImage(for: refreshed)
                self.detailView.setUserRating(rating)
                self.onArticleUpdated?(refreshed)
                self.showToast("Thanks!", "Your rating was saved.")
            }
        } catch {
            await MainActor.run { self.showToast("Rating Error", error.localizedDescription) }
        }
    }

    private func loadUserRating() async {
        guard !hasLoadedUserRating else { return }
        do {
            let rating = try await model.fetchUserRating(articleID: article.id)
            await MainActor.run {
                if let rating {
                    self.detailView.setUserRating(rating)
                }
                self.hasLoadedUserRating = true
            }
        } catch {
            await MainActor.run { self.hasLoadedUserRating = true }
        }
    }

    private func incrementViewsAndRefresh() async {
        do {
            try await model.incrementViews(articleID: article.id)
            let refreshed = try await model.fetchArticle(id: article.id)
            await MainActor.run {
                self.article = refreshed
                self.detailView.configure(with: refreshed)
                self.loadCoverImage(for: refreshed)
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

    private func loadCoverImage(for article: ArticleRow) {
        let path = article.image_url ?? article.image_path
        guard let path else {
            detailView.setCoverImage(nil)
            return
        }
        Task {
            do {
                let url = try await model.signedImageURL(pathOrUrl: path)
                let (data, _) = try await URLSession.shared.data(from: url)
                let image = UIImage(data: data)
                await MainActor.run {
                    self.detailView.setCoverImage(image)
                }
            } catch {
                await MainActor.run {
                    self.detailView.setCoverImage(nil)
                }
            }
        }
    }
}
