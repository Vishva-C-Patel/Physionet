//
//  HomeViewController.swift
//  Physio_Connect
//
//  Created by Ayush Rai on 31/12/25.
//

import UIKit

final class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {

    private let homeView = HomeView()
    private let model = HomeModel()
    private let videosModel = VideosModel()
    private let articlesModel = ArticlesModel()
    private let locationService = LocationService.shared
    private var upcomingAppointments: [HomeUpcomingAppointment] = []
    private var upcomingTimer: Timer?
    private var freeVideos: [ExerciseVideoRow] = []
    private var thumbnailImages: [UUID: UIImage] = [:]
    private var nextProgramExercise: MyProgramExerciseRow?
    private var programExercises: [MyProgramExerciseRow] = []
    private var articles: [ArticleRow] = []
    private var articleImages: [UUID: UIImage] = [:]
    private var selectedArticlesSort: ArticleSort = .topRated
    private let itemsPerDay = 2

    override func loadView() { view = homeView }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        homeView.profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        homeView.videosCollectionView.dataSource = self
        homeView.videosCollectionView.delegate = self
        homeView.videosCollectionView.register(HomeVideoCardCell.self, forCellWithReuseIdentifier: HomeVideoCardCell.reuseID)
        homeView.videosActionButton.addTarget(self, action: #selector(viewAllVideos), for: .touchUpInside)
        homeView.articlesTableView.dataSource = self
        homeView.articlesTableView.delegate = self
        homeView.articlesTableView.register(HomeArticleCell.self, forCellReuseIdentifier: HomeArticleCell.reuseID)
        homeView.articlesSegmented.addTarget(self, action: #selector(articleSegmentChanged), for: .valueChanged)

        homeView.carousel.onViewDetailsTapped = { [weak self] appt in
            guard let self else { return }
            let appointment = self.makeAppointment(from: appt)
            let vc = AppointmentDetailsViewController(appointment: appointment)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        homeView.carousel.onBookTapped = { [weak self] in
            guard let self else { return }
            let vc = PhysiotherapistListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }

        homeView.upNextCard.primaryButton.addTarget(self, action: #selector(startNextExercise), for: .touchUpInside)

        locationService.onLocationUpdate = { [weak self] name, _ in
            DispatchQueue.main.async {
                self?.homeView.setLocationText(name)
            }
        }
        homeView.setLocationText("Locating...")
        locationService.requestLocation()

        Task { await refreshCards() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationService.requestLocation()
        Task { await refreshCards() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        upcomingTimer?.invalidate()
        upcomingTimer = nil
    }

    private func refreshCards() async {
        let emptyProgress = HomeModel.ProgressSummary(
            painSeries: Array(repeating: 0, count: 7),
            adherenceSeries: Array(repeating: 0, count: 6),
            weeklyAdherencePercent: 0,
            painDeltaPercent: 0,
            averagePain: 0
        )

        let isLoggedIn = (try? await SupabaseManager.shared.client.auth.session) != nil

        let videos = (try? await videosModel.fetchFreeExercises(search: nil)) ?? []
        let fetchedArticles = (try? await articlesModel.fetchArticles(search: nil, category: nil, sort: selectedArticlesSort)) ?? []

        var upcoming: [HomeUpcomingAppointment] = []
        var programRows: [MyProgramExerciseRow] = []
        var nextExercise: MyProgramExerciseRow?
        var progress = emptyProgress

        if isLoggedIn {
            upcoming = (try? await model.fetchUpcomingAppointments()) ?? []
            programRows = (try? await videosModel.fetchMyProgramExercises()) ?? []
            nextExercise = try? await resolveNextExercise(from: programRows)
            let programID = programRows.first?.program_id
            progress = (try? await model.fetchProgressSummary(programID: programID)) ?? emptyProgress
        }

        await MainActor.run {
            self.applyUpcoming(upcoming)
            self.freeVideos = Array(videos.prefix(4))
            self.thumbnailImages = [:]
            self.homeView.videosCollectionView.reloadData()
            self.homeView.updateVideosHeight(rows: self.freeVideos.count)
            self.homeView.painCard.configure(
                painSeries: progress.painSeries,
                averagePain: progress.averagePain,
                percentChange: progress.painDeltaPercent
            )
            self.homeView.adherenceCard.configure(
                adherenceSeries: progress.adherenceSeries,
                weeklyPercent: progress.weeklyAdherencePercent
            )
            self.programExercises = programRows
            self.nextProgramExercise = nextExercise
            self.applyUpNext()
            let hasProgram = !programRows.isEmpty
            self.homeView.setPainVisible(isLoggedIn && hasProgram)
            self.homeView.setUpNextVisible(isLoggedIn && hasProgram && nextExercise != nil)
            self.articles = Array(fetchedArticles.prefix(4))
            self.articleImages = [:]
            self.homeView.articlesTableView.reloadData()
            self.homeView.updateArticlesHeight(rows: self.articles.count)
            DispatchQueue.main.async {
                self.homeView.updateArticlesHeightToFit()
            }
        }
        loadThumbnails(for: Array(videos.prefix(4)))
        loadArticleImages(for: Array(fetchedArticles.prefix(4)))
    }

    private func applyUpNext() {
        guard let nextProgramExercise else {
            homeView.setUpNextVisible(false)
            return
        }
        homeView.setUpNextVisible(true)
        let totalExercises = programExercises.count
        let totalMinutes = max(1, programExercises.reduce(0) { $0 + (($1.duration_seconds ?? 0) / 60) })
        let meta = "\(totalExercises) exercises • \(totalMinutes) minutes"
        let vm = HomeUpNextCardView.ViewModel(
            timeText: "Next in your program",
            title: nextProgramExercise.title,
            metaText: meta,
            primaryTitle: "Start Session"
        )
        homeView.upNextCard.configure(with: vm)
    }

    private func resolveNextExercise(from rows: [MyProgramExerciseRow]) async throws -> MyProgramExerciseRow? {
        guard let programID = rows.first?.program_id else { return nil }
        let progressRows = try await videosModel.fetchProgress(programID: programID)
        let startDate = (try? await videosModel.fetchProgramStartDate(programID: programID)) ?? Date()
        let availableDays = availableDayCount(startDate: startDate)
        let completedPairs = Set(progressRows.compactMap { row -> String? in
            guard row.is_completed == true, let date = row.progress_date else { return nil }
            return "\(row.exercise_id.uuidString)-\(date)"
        })

        for (index, row) in rows.enumerated() {
            let day = (index / itemsPerDay) + 1
            guard day <= availableDays else { break }
            let scheduledDate = scheduledDateString(startDate: startDate, dayIndex: day - 1)
            let key = "\(row.exercise_id.uuidString)-\(scheduledDate)"
            if !completedPairs.contains(key) {
                return row
            }
        }
        return nil
    }

    private func availableDayCount(startDate: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, days + 1)
    }

    private func scheduledDateString(startDate: Date, dayIndex: Int) -> String {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: startDate)
        let date = calendar.date(byAdding: .day, value: dayIndex, to: base) ?? base
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func applyUpcoming(_ appts: [HomeUpcomingAppointment]) {
        upcomingTimer?.invalidate()
        upcomingTimer = nil
        upcomingAppointments = appts.filter { $0.startTime > Date() }
        homeView.setUpcoming(upcomingAppointments)

        if let nextDate = upcomingAppointments.map(\.startTime).min() {
            let interval = nextDate.timeIntervalSinceNow
            guard interval > 0 else { return }
            upcomingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                guard let self else { return }
                Task { await self.refreshCards() }
            }
        }
    }

    private func makeAppointment(from appt: HomeUpcomingAppointment) -> Appointment {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMM"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        let status: AppointmentStatus
        switch appt.status.lowercased() {
        case "completed":
            status = .completed
        case "cancelled_by_physio":
            status = .cancelledByPhysio
        case "cancelled", "canceled":
            status = .cancelled
        default:
            status = .upcoming
        }

        return Appointment(
            id: appt.appointmentID,
            doctorName: appt.physioName,
            specialization: appt.specializationText,
            ratingText: appt.ratingText,
            dateText: dateFormatter.string(from: appt.startTime),
            timeText: timeFormatter.string(from: appt.startTime),
            status: status,
            sessionNotes: "",
            phoneNumber: nil,
            locationText: appt.address,
            feeText: appt.consultationFeeText,
            profileImagePath: appt.profileImagePath,
            profileImageVersion: appt.profileImageVersion
        )
    }

    @objc private func profileTapped() {
        let vc = ProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func viewAllVideos() {
        guard let tabs = tabBarController else { return }
        let targetIndex = 2
        if let nav = tabs.viewControllers?[targetIndex] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
        tabs.selectedIndex = targetIndex
    }

    @objc private func articleSegmentChanged() {
        selectedArticlesSort = homeView.articlesSegmented.selectedSegmentIndex == 0 ? .topRated : .forYou
        Task { await refreshCards() }
    }

    @objc private func startNextExercise() {
        guard let exercise = nextProgramExercise else { return }
        let vc = ExerciseDetailViewController(
            headerTitleText: exercise.program_title,
            titleText: exercise.title,
            subtitle: exercise.target_area ?? "Upper Body",
            descriptionText: exercise.description,
            durationSeconds: exercise.duration_seconds,
            videoPath: exercise.video_path,
            thumbnailPath: exercise.thumbnail_path,
            programID: exercise.program_id,
            exerciseID: exercise.exercise_id,
            rowKey: "\(exercise.program_id.uuidString)-\(exercise.exercise_id.uuidString)-\(exercise.sort_order ?? 0)",
            sets: exercise.sets,
            reps: exercise.reps,
            hold: exercise.hold_seconds,
            nextUpItems: []
        )
        navigationController?.pushViewController(vc, animated: true)
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        freeVideos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeVideoCardCell.reuseID, for: indexPath) as? HomeVideoCardCell else {
            return UICollectionViewCell()
        }
        let video = freeVideos[indexPath.item]
        let thumbnail = thumbnailImages[video.id]
        cell.configure(with: video, thumbnail: thumbnail)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = freeVideos[indexPath.item]
        let vc = ExerciseDetailViewController(
            headerTitleText: "Free Exercise",
            titleText: video.title,
            subtitle: video.target_area ?? "Upper Body",
            descriptionText: video.description,
            durationSeconds: video.duration_seconds,
            videoPath: video.video_path,
            thumbnailPath: video.thumbnail_path,
            programID: nil,
            exerciseID: video.id,
            rowKey: nil,
            sets: nil,
            reps: nil,
            hold: nil,
            nextUpItems: []
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let itemWidth = (width - 12) / 2
        return CGSize(width: itemWidth, height: 160)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeArticleCell.reuseID, for: indexPath) as? HomeArticleCell else {
            return UITableViewCell()
        }
        let article = articles[indexPath.row]
        let image = articleImages[article.id]
        cell.configure(with: article, thumbnail: image)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        let vc = ArticleDetailViewController(article: article)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func loadThumbnails(for videos: [ExerciseVideoRow]) {
        for video in videos {
            guard let path = video.thumbnail_path, !path.isEmpty else { continue }
            Task {
                do {
                    let signedURL = try await videosModel.signedThumbnailURL(path: path)
                    ImageLoader.shared.load(signedURL) { [weak self] image in
                        guard let self, let image else { return }
                        self.thumbnailImages[video.id] = image
                        if let index = self.freeVideos.firstIndex(where: { $0.id == video.id }) {
                            self.homeView.videosCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        }
                    }
                } catch {
                    print("❌ Thumbnail error:", error)
                }
            }
        }
    }

    private func loadArticleImages(for articles: [ArticleRow]) {
        for article in articles {
            let pathOrUrl = article.image_url ?? article.image_path
            guard let pathOrUrl, !pathOrUrl.isEmpty else { continue }
            Task {
                do {
                    let url = try await articlesModel.signedImageURL(pathOrUrl: pathOrUrl)
                    ImageLoader.shared.load(url) { [weak self] image in
                        guard let self, let image else { return }
                        self.articleImages[article.id] = image
                        if let index = self.articles.firstIndex(where: { $0.id == article.id }) {
                            self.homeView.articlesTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                    }
                } catch {
                    print("❌ Article image error:", error)
                }
            }
        }
    }
}
