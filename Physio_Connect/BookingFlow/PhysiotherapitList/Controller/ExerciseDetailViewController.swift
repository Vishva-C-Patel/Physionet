//
//  ExerciseDetailViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit
import AVKit

final class ExerciseDetailViewController: UIViewController {

    static let progressUpdatedNotification = Notification.Name("exerciseProgressUpdated")

    struct NextUpItem {
        let title: String
        let subtitle: String
        let durationSeconds: Int?
        let videoPath: String
        let thumbnailPath: String?
        let programID: UUID?
        let exerciseID: UUID
        let rowKey: String?
        let locked: Bool
    }

    private let videosModel = VideosModel()

    private let headerTitleText: String
    private let titleText: String
    private let subtitleText: String
    private let descriptionText: String?
    private let durationSeconds: Int?
    private let videoPath: String
    private let thumbnailPath: String?
    private let programID: UUID?
    private let exerciseID: UUID
    private let rowKey: String?
    private let sets: Int?
    private let reps: Int?
    private let hold: Int?
    private let nextUpItems: [NextUpItem]
    private let displayNextUpItems: [NextUpItem]
    private let requiresPainFeedback: Bool

    private let detailView = ExerciseDetailView()
    private var isCompleted = false
    private var isScaleVisible = false
    private var hasSavedFeedback = false
    private var isSaving = false
    private var isSavingCompletion = false

    init(headerTitleText: String,
         titleText: String,
         subtitle: String,
         descriptionText: String?,
         durationSeconds: Int?,
         videoPath: String,
         thumbnailPath: String?,
         programID: UUID?,
         exerciseID: UUID,
         rowKey: String?,
         sets: Int?,
         reps: Int?,
         hold: Int?,
         nextUpItems: [NextUpItem]) {
        self.headerTitleText = headerTitleText
        self.titleText = titleText
        self.subtitleText = subtitle
        self.descriptionText = descriptionText
        self.durationSeconds = durationSeconds
        self.videoPath = videoPath
        self.thumbnailPath = thumbnailPath
        self.programID = programID
        self.exerciseID = exerciseID
        self.rowKey = rowKey
        self.sets = sets
        self.reps = reps
        self.hold = hold
        self.nextUpItems = nextUpItems
        self.displayNextUpItems = nextUpItems.filter { !$0.locked }
        self.requiresPainFeedback = programID != nil
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        detailView.configure(with: ExerciseDetailView.ViewModel(
            headerTitle: headerTitleText,
            title: titleText,
            durationMinutes: (durationSeconds ?? 0) / 60,
            description: descriptionText ?? "Follow the guided video and maintain controlled movement throughout."
        ))

        detailView.nextUpCollection.dataSource = self
        detailView.nextUpCollection.delegate = self
        detailView.nextUpCollection.register(NextUpCell.self, forCellWithReuseIdentifier: NextUpCell.reuseID)

        detailView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        detailView.playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        detailView.completeButton.addTarget(self, action: #selector(toggleCompleted), for: .touchUpInside)
        detailView.painScaleToggle.addTarget(self, action: #selector(toggleScale), for: .touchUpInside)
        detailView.painSlider.addTarget(self, action: #selector(painChanged), for: .valueChanged)
        detailView.painSlider.addTarget(self, action: #selector(painTouchDown), for: .touchDown)
        detailView.painSlider.addTarget(self, action: #selector(painTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        detailView.notesTextView.delegate = self
        detailView.saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        detailView.continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        detailView.setScaleVisible(false)
        isScaleVisible = false
        let hasNextUp = !displayNextUpItems.isEmpty
        detailView.setNextUpVisible(hasNextUp)
        detailView.setContinueEnabled(hasNextUp)
        detailView.setCompletedState(false, locked: false)
        detailView.setFeedbackVisible(false)

        loadThumbnail()
        loadProgressState()
    }

    @objc private func backTapped() {
        if isCompleted {
            if requiresPainFeedback {
                if hasSavedFeedback { recordCompletionLocally() }
            } else {
                Task { await saveCompletionProgress() }
            }
        }
        navigationController?.popViewController(animated: true)
    }

    @objc private func playTapped() {
        Task.detached { [weak self] in
            guard let self else { return }
            let session = try? await SupabaseManager.shared.client.auth.session
            ArticleTriggerService.shared.triggerArticles(
                keyword: self.titleText,
                source: "video",
                userID: session?.user.id.uuidString,
                context: ["video_id": self.exerciseID.uuidString]
            )
        }
        Task {
            do {
                let url = try await videosModel.signedVideoURL(path: videoPath)
                let player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player
                present(vc, animated: true) { player.play() }
            } catch {
                print("❌ Video URL error for path \(videoPath):", error)
                showError("Video error", error.localizedDescription)
            }
        }
    }

    private func loadThumbnail() {
        guard let thumbnailPath else { return }
        Task {
            do {
                let url = try await videosModel.signedThumbnailURL(path: thumbnailPath)
                let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self, let data, let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async { self.detailView.setThumbnailImage(image) }
                }
                task.resume()
            } catch {
                print("❌ Detail thumb error for path \(thumbnailPath):", error)
                return
            }
        }
    }

    private func loadProgressState() {
        Task {
            do {
                let progress = try await videosModel.fetchProgressForExercise(exerciseID: exerciseID, programID: programID)
                await MainActor.run {
                    let rowWasCompleted = isCurrentRowCompleted()
                    if let progress {
                        let savedPain = progress.pain_level
                        if requiresPainFeedback {
                            hasSavedFeedback = rowWasCompleted
                            isCompleted = rowWasCompleted
                            if rowWasCompleted {
                                if let pain = savedPain {
                                    detailView.painSlider.value = Float(pain)
                                    detailView.updatePainUI(value: pain)
                                }
                                if let notes = progress.notes, !notes.isEmpty {
                                    detailView.notesTextView.text = notes
                                    textViewDidChange(detailView.notesTextView)
                                }
                            }
                        } else {
                            isCompleted = progress.is_completed ?? false
                            hasSavedFeedback = isCompleted
                        }
                    } else if requiresPainFeedback {
                        hasSavedFeedback = rowWasCompleted
                        isCompleted = rowWasCompleted
                    }
                    detailView.setCompletedState(isCompleted, locked: hasSavedFeedback)
                    detailView.setFeedbackVisible(requiresPainFeedback && isCompleted && !hasSavedFeedback)
                }
            } catch {
                return
            }
        }
    }

    @objc private func toggleCompleted() {
        if hasSavedFeedback { return }
        isCompleted.toggle()
        detailView.setCompletedState(isCompleted, locked: false)
        if requiresPainFeedback {
            detailView.setFeedbackVisible(isCompleted)
        } else {
            detailView.setFeedbackVisible(false)
            if isCompleted {
                Task { await saveCompletionProgress() }
                hasSavedFeedback = true
                detailView.setCompletedState(true, locked: true)
            }
        }
    }

    @objc private func toggleScale() {
        isScaleVisible.toggle()
        detailView.setScaleVisible(isScaleVisible)
    }

    @objc private func painChanged() {
        let value = Int(detailView.painSlider.value.rounded())
        detailView.updatePainUI(value: value)
    }

    @objc private func painTouchDown() {
        detailView.scroll.isScrollEnabled = false
    }

    @objc private func painTouchUp() {
        detailView.scroll.isScrollEnabled = true
    }

    @objc private func saveTapped() {
        if isSaving { return }
        guard requiresPainFeedback, isCompleted else { return }
        isSaving = true
        detailView.saveButton.isEnabled = false
        let painValue = Int(detailView.painSlider.value.rounded())
        let notes = detailView.notesTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let payloadNotes = notes.isEmpty ? nil : notes

        Task {
            do {
                try await videosModel.upsertProgress(
                    exerciseID: exerciseID,
                    programID: programID,
                    isCompleted: isCompleted,
                    watchedSeconds: durationSeconds ?? 0,
                    painLevel: painValue,
                    notes: payloadNotes
                )
                hasSavedFeedback = true
                isCompleted = true
                let done = UIAlertController(title: "Saved", message: "Progress updated.", preferredStyle: .alert)
                done.addAction(UIAlertAction(title: "OK", style: .default))
                present(done, animated: true)
                detailView.setFeedbackVisible(false)
                detailView.setCompletedState(true, locked: true)
                detailView.saveButton.isEnabled = true
                isSaving = false
                recordCompletionLocally()
            } catch {
                detailView.saveButton.isEnabled = true
                isSaving = false
                showError("Save failed", error.localizedDescription)
            }
        }
    }

    @objc private func continueTapped() {
        guard let first = displayNextUpItems.first else { return }
        let vc = ExerciseDetailViewController(
            headerTitleText: headerTitleText,
            titleText: first.title,
            subtitle: first.subtitle,
            descriptionText: descriptionText,
            durationSeconds: first.durationSeconds,
            videoPath: first.videoPath,
            thumbnailPath: first.thumbnailPath,
            programID: first.programID,
            exerciseID: first.exerciseID,
            rowKey: first.rowKey,
            sets: nil,
            reps: nil,
            hold: nil,
            nextUpItems: Array(displayNextUpItems.dropFirst())
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showError(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    private func saveCompletionProgress() async {
        guard !isSavingCompletion else { return }
        isSavingCompletion = true
        defer { isSavingCompletion = false }
        do {
            try await videosModel.upsertProgress(
                exerciseID: exerciseID,
                programID: programID,
                isCompleted: true,
                watchedSeconds: durationSeconds ?? 0,
                painLevel: nil,
                notes: nil
            )
        } catch {
            return
        }
    }

    private func recordCompletionLocally() {
        print("✅ Completed rowKey:", rowKey as Any, "programID:", programID as Any, "exerciseID:", exerciseID)
        if let programID, let rowKey {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy-MM-dd"
            ProgramRowCompletionStore.add(
                rowKey: rowKey,
                programID: programID,
                completionDate: formatter.string(from: Date())
            )
        }
        NotificationCenter.default.post(
            name: ExerciseDetailViewController.progressUpdatedNotification,
            object: nil,
            userInfo: ["exerciseID": exerciseID, "programID": programID as Any, "rowKey": rowKey as Any]
        )
    }

    private func isCurrentRowCompleted() -> Bool {
        guard requiresPainFeedback, let programID, let rowKey else { return false }
        return ProgramRowCompletionStore.completionMap(programID: programID)[rowKey] != nil
    }
}

extension ExerciseDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let isEmpty = textView.text.isEmpty
        for subview in textView.subviews {
            if let label = subview as? UILabel {
                label.isHidden = !isEmpty
            }
        }
    }
}

extension ExerciseDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayNextUpItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NextUpCell.reuseID, for: indexPath) as! NextUpCell
        let item = displayNextUpItems[indexPath.item]
        cell.configure(title: item.title, subtitle: item.subtitle, locked: item.locked)
        if let path = item.thumbnailPath {
            Task {
                if let url = try? await videosModel.signedThumbnailURL(path: path) {
                    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data, let image = UIImage(data: data) else { return }
                        DispatchQueue.main.async { cell.setImage(image) }
                    }
                    task.resume()
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = displayNextUpItems[indexPath.item]
        if item.locked { return }
        let vc = ExerciseDetailViewController(
            headerTitleText: headerTitleText,
            titleText: item.title,
            subtitle: item.subtitle,
            descriptionText: descriptionText,
            durationSeconds: item.durationSeconds,
            videoPath: item.videoPath,
            thumbnailPath: item.thumbnailPath,
            programID: item.programID,
            exerciseID: item.exerciseID,
            rowKey: item.rowKey,
            sets: nil,
            reps: nil,
            hold: nil,
            nextUpItems: Array(displayNextUpItems.dropFirst(indexPath.item + 1))
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class NextUpCell: UICollectionViewCell {
    static let reuseID = "NextUpCell"

    private let card = UIView()
    private let imageView = UIImageView()
    private let playIcon = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        playIcon.image = UIImage(systemName: "play.fill")
        playIcon.tintColor = UIColor(hex: "1E6EF7")
        imageView.alpha = 1
        titleLabel.textColor = UIColor(hex: "1E2A44")
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
    }

    func configure(title: String, subtitle: String, locked: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        if locked {
            playIcon.image = UIImage(systemName: "lock.fill")
            playIcon.tintColor = UIColor.black.withAlphaComponent(0.35)
            imageView.alpha = 0.5
            titleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.35)
        } else {
            playIcon.image = UIImage(systemName: "play.fill")
            playIcon.tintColor = UIColor(hex: "1E6EF7")
            imageView.alpha = 1
            titleLabel.textColor = UIColor(hex: "1E2A44")
            subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        }
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }

    private func build() {
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 4)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(hex: "E3F0FF")

        playIcon.translatesAutoresizingMaskIntoConstraints = false
        playIcon.image = UIImage(systemName: "play.fill")
        playIcon.tintColor = UIColor(hex: "1E6EF7")
        playIcon.backgroundColor = .white
        playIcon.layer.cornerRadius = 16
        playIcon.layer.masksToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = UIColor(hex: "1E2A44")
        titleLabel.numberOfLines = 2

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        subtitleLabel.numberOfLines = 2

        contentView.addSubview(card)
        card.addSubview(imageView)
        card.addSubview(playIcon)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalToConstant: 76),

            playIcon.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            playIcon.widthAnchor.constraint(equalToConstant: 32),
            playIcon.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
}
