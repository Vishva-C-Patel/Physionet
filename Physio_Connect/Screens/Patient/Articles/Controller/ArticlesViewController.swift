//
//  ArticlesViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//

import UIKit

final class ArticlesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    private let articlesView = ArticlesView()
    private let model = ArticlesModel()
    private let profileModel = ProfileModel()

    private var articles: [ArticleRow] = []
    private var featuredArticle: ArticleRow?
    private var bookmarkedArticles: [UUID: ArticleRow] = [:]
    private var isRefreshing = false
    private var bookmarkedIDs: Set<UUID> = []

    private let filterOptions = ["All", "Neck", "Upper Back", "Lower Back", "Shoulders"]
    private var selectedFilterIndex = 0
    private var selectedSegmentIndex = 0
    private let searchController = UISearchController(searchResultsController: nil)

    override func loadView() { view = articlesView }

    override func viewDidLoad() {
        super.viewDidLoad()
        UITheme.applyNativeNavBar(to: self, title: "Articles", largeTitle: true)
        articlesView.profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        setupFilterMenu()

        articlesView.tableView.dataSource = self
        articlesView.tableView.delegate = self
        setupSearchController()

        articlesView.tableView.register(ArticleCardCell.self, forCellReuseIdentifier: ArticleCardCell.reuseID)
        articlesView.tableView.rowHeight = UITableView.automaticDimension
        articlesView.tableView.estimatedRowHeight = 320
        articlesView.tableView.contentInset.bottom = 110
        articlesView.tableView.scrollIndicatorInsets.bottom = 110

        articlesView.setRefreshTarget(self, action: #selector(refreshPulled))
        articlesView.segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Ensure initial segment selection is rendered
        articlesView.layoutIfNeeded()

        articlesView.featuredCard.onReadTapped = { [weak self] in
            guard let self, let featuredArticle = self.featuredArticle else { return }
            self.openDetail(for: featuredArticle)
        }

        updateBookmarksVisibility()
        Task { await reload() }
        Task { await refreshProfileAvatar() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reset tab bar state in case search was active during a push/pop
        if !searchController.isActive {
            tabBarController?.tabBar.transform = .identity
            tabBarController?.tabBar.alpha = 1
        }
        Task { await refreshProfileAvatar() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        articlesView.updateHeaderLayout()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        articlesView.updateHeaderLayout()
    }

    @objc private func segmentChanged() {
        selectedSegmentIndex = articlesView.segmented.selectedSegmentIndex
        Task { await reload() }
    }

    @objc private func refreshPulled() {
        Task { await reload() }
    }

    private func currentSort() -> ArticleSort {
        switch selectedSegmentIndex {
        case 1: return .forYou
        default: return .recent
        }
    }

    private func currentCategory() -> String? {
        guard selectedFilterIndex > 0 else { return nil }
        return filterOptions[selectedFilterIndex]
    }

    private func reload() async {
        if isRefreshing { return }
        isRefreshing = true
        await MainActor.run { self.articlesView.setRefreshing(true) }
        defer {
            Task { @MainActor in
                self.isRefreshing = false
                self.articlesView.setRefreshing(false)
            }
        }

        do {
            if selectedSegmentIndex == 2 {
                await MainActor.run {
                    let rows = self.filteredBookmarks()
                    self.articles = rows
                    self.articlesView.updateResults(count: rows.count)
                    self.updateFeaturedArticle(from: rows)
                    self.articlesView.tableView.reloadData()
                }
            } else {
                let rows = try await model.fetchArticles(
                    search: searchController.searchBar.text,
                    category: currentCategory(),
                    sort: currentSort()
                )
                await MainActor.run {
                    self.articles = rows
                    self.articlesView.updateResults(count: rows.count)
                    self.updateFeaturedArticle(from: rows)
                    self.articlesView.tableView.reloadData()
                }
            }
        } catch {
            await MainActor.run { self.showError("Articles Error", error.localizedDescription) }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCardCell.reuseID, for: indexPath) as? ArticleCardCell else {
            return UITableViewCell()
        }
        let article = articles[indexPath.row]
        cell.configure(with: article)
        cell.setBookmarked(bookmarkedIDs.contains(article.id))
        cell.onBookmarkTapped = { [weak self] in
            self?.toggleBookmark(for: article, at: indexPath)
        }
        cell.onReadTapped = { [weak self] in
            self?.openDetail(for: article)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        openDetail(for: article)
    }

    // MARK: - Search
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search articles, topics..."
        searchController.hidesNavigationBarDuringPresentation = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }

    func updateSearchResults(for searchController: UISearchController) {
        Task { await reload() }
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3) {
            self.tabBarController?.tabBar.alpha = 0
        }
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        self.tabBarController?.tabBar.transform = .identity
        UIView.animate(withDuration: 0.3) {
            self.tabBarController?.tabBar.alpha = 1
        }
    }

    // MARK: - Native Filters Menu
    private func setupFilterMenu() {
        let actions = filterOptions.enumerated().map { index, title in
            let isSelected = index == selectedFilterIndex
            let action = UIAction(title: title, state: isSelected ? .on : .off) { [weak self] _ in
                self?.selectedFilterIndex = index
                self?.setupFilterMenu()
                Task { await self?.reload() }
            }
            if #available(iOS 15.0, *) { action.attributes = .keepsMenuPresented }
            return action
        }
        let menu = UIMenu(title: "Filter by Category", children: actions)

        let filterItem = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            primaryAction: nil,
            menu: menu
        )
        let profileItem = UIBarButtonItem(customView: articlesView.profileButton)
        navigationItem.rightBarButtonItems = [profileItem, filterItem]
    }

    private func showBookmarkToast(_ isBookmarked: Bool) {
        let title = isBookmarked ? "Saved" : "Removed"
        let message = isBookmarked ? "Added to your bookmarks." : "Removed from your bookmarks."
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(ac, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ac.dismiss(animated: true)
        }
    }

    private func toggleBookmark(for article: ArticleRow, at indexPath: IndexPath) {
        if bookmarkedIDs.contains(article.id) {
            bookmarkedIDs.remove(article.id)
            bookmarkedArticles.removeValue(forKey: article.id)
        } else {
            bookmarkedIDs.insert(article.id)
            bookmarkedArticles[article.id] = article
        }
        let isBookmarked = bookmarkedIDs.contains(article.id)
        if let cell = articlesView.tableView.cellForRow(at: indexPath) as? ArticleCardCell {
            cell.setBookmarked(isBookmarked)
        }
        updateBookmarksVisibility()
        if selectedSegmentIndex == 3 {
            let rows = filteredBookmarks()
            articles = rows
            articlesView.updateResults(count: rows.count)
            articlesView.tableView.reloadData()
        }
        showBookmarkToast(isBookmarked)
    }

    private func updateBookmarksVisibility() {
        let hasBookmarks = !bookmarkedIDs.isEmpty
        articlesView.setBookmarksVisible(hasBookmarks)
        if !hasBookmarks, selectedSegmentIndex == 3 {
            selectedSegmentIndex = 0
            articlesView.setSegmentSelection(0)
            Task { await reload() }
        }
    }

    private func filteredBookmarks() -> [ArticleRow] {
        let search = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let category = currentCategory()

        return bookmarkedArticles.values.filter { article in
            let matchesSearch: Bool = {
                guard let search, !search.isEmpty else { return true }
                return article.title.lowercased().contains(search)
            }()
            let matchesCategory: Bool = {
                guard let category else { return true }
                return article.tags?.contains(category) ?? false
            }()
            return matchesSearch && matchesCategory
        }
        .sorted { ($0.published_at ?? "") > ($1.published_at ?? "") }
    }

    private func openDetail(for article: ArticleRow) {
        let vc = ArticleDetailViewController(article: article)
        vc.onArticleUpdated = { [weak self] updated in
            guard let self = self else { return }
            guard let index = self.articles.firstIndex(where: { $0.id == updated.id }) else { return }
            self.articles[index] = updated
            self.articlesView.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func profileTapped() {
        let vc = ProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func refreshProfileAvatar() async {
        await MainActor.run {
            PatientNavAvatarStyle.updateProfileButton(
                self.articlesView.profileButton,
                urlString: ProfileModel.cachedAvatarURL()
            )
        }
        guard let profile = try? await profileModel.fetchCurrentProfile() else { return }
        await MainActor.run {
            PatientNavAvatarStyle.updateProfileButton(self.articlesView.profileButton, urlString: profile.avatarURL)
        }
    }

    private func updateFeaturedArticle(from rows: [ArticleRow]) {
        let featured = rows.first(where: { $0.is_trending ?? false })
        featuredArticle = featured
        articlesView.featuredCard.configure(with: featured)
        articlesView.setFeaturedVisible(featured != nil)
    }

    private func showError(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
