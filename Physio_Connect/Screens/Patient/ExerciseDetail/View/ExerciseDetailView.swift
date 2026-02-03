//
//  ExerciseDetailView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ExerciseDetailView: UIView, UIGestureRecognizerDelegate {

    struct ViewModel {
        let headerTitle: String
        let title: String
        let durationMinutes: Int
        let description: String
    }

    let scroll = UIScrollView()
    let content = UIStackView()

    let backButton = UIButton(type: .system)
    let playButton = UIButton(type: .system)
    let completeButton = UIButton(type: .system)
    let painScaleToggle = UIButton(type: .system)
    let painSlider = UISlider()
    let notesTextView = UITextView()
    let saveButton = UIButton(type: .system)
    let nextUpCollection: UICollectionView
    let continueButton = UIButton(type: .system)

    private let topBar = UIView()
    private let headerTitle = UILabel()

    private let videoCard = UIView()
    private let thumbnailImageView = UIImageView()

    private let infoCard = UIView()
    private let metaTitle = UILabel()
    private let metaDuration = UILabel()
    private let metaDesc = UILabel()

    private let progressTitle = UILabel()
    private let completeCard = UIView()
    private let completeLabel = UILabel()

    private let painCard = UIView()
    private let painTitle = UILabel()
    private let painValueLabel = UILabel()
    private let painSubtitleLabel = UILabel()
    private let painEmoji = UILabel()
    private let painScaleTrack = UIView()
    private let painMinLabel = UILabel()
    private let painMaxLabel = UILabel()
    private let painScaleCard = UIView()
    private let painScaleStack = UIStackView()
    private var isScaleVisible = false
    private var painScaleBottomConstraint: NSLayoutConstraint?
    private var painMinBottomConstraint: NSLayoutConstraint?
    private lazy var painTrackPan: UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer(target: self, action: #selector(trackPanned(_:)))
        gr.cancelsTouchesInView = false
        gr.delegate = self
        return gr
    }()
    private lazy var painTrackTap: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(trackTapped(_:)))
        gr.cancelsTouchesInView = false
        gr.delegate = self
        return gr
    }()

    private let notesCard = UIView()
    private let notesTitle = UILabel()
    private let notesPlaceholder = UILabel()

    private let nextUpTitle = UILabel()

    private var gradientLayer: CAGradientLayer?

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        nextUpCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E3F0FF")
        build()
        updatePainUI(value: Int(painSlider.value))
        setScaleVisible(false)
        setFeedbackVisible(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradient = gradientLayer {
            gradient.frame = painScaleTrack.bounds
        }
        painCard.bringSubviewToFront(painSlider)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        let sliderFrame = painSlider.convert(painSlider.bounds, to: self).insetBy(dx: -12, dy: -12)
        if sliderFrame.contains(point) {
            return painSlider
        }
        return view
    }

    @objc private func trackPanned(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: painScaleTrack)
        updateSlider(with: location)
    }

    @objc private func trackTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: painScaleTrack)
        updateSlider(with: location)
    }

    private func updateSlider(with location: CGPoint) {
        let width = max(painScaleTrack.bounds.width, 1)
        let clampedX = min(max(location.x, 0), width)
        let percent = Float(clampedX / width)
        let value = painSlider.minimumValue + (painSlider.maximumValue - painSlider.minimumValue) * percent
        painSlider.setValue(value, animated: false)
        painSlider.sendActions(for: .valueChanged)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == scroll.panGestureRecognizer {
            return false
        }
        return true
    }

    func configure(with viewModel: ViewModel) {
        headerTitle.text = viewModel.headerTitle
        metaTitle.text = viewModel.title
        metaDuration.text = "\(max(1, viewModel.durationMinutes)) min"
        metaDesc.text = viewModel.description
    }

    func setThumbnailImage(_ image: UIImage?) {
        thumbnailImageView.image = image
    }

    func updatePainUI(value: Int) {
        painValueLabel.text = "\(value) /10"
        let descriptor: String
        switch value {
        case 0...2: descriptor = "No Pain"
        case 3...5: descriptor = "Mild Pain"
        case 6...7: descriptor = "Moderate Pain"
        default: descriptor = "Severe Pain"
        }
        painSubtitleLabel.text = descriptor

        switch value {
        case 0...2: painEmoji.text = "😌"; painSubtitleLabel.textColor = UIColor(hex: "22C55E")
        case 3...5: painEmoji.text = "🙂"; painSubtitleLabel.textColor = UIColor(hex: "84CC16")
        case 6...7: painEmoji.text = "😐"; painSubtitleLabel.textColor = UIColor(hex: "F59E0B")
        default: painEmoji.text = "😣"; painSubtitleLabel.textColor = UIColor(hex: "EF4444")
        }
    }

    func setScaleVisible(_ visible: Bool) {
        isScaleVisible = visible
        painScaleCard.isHidden = !visible
        painScaleToggle.setTitle(visible ? "Hide Scale" : "View Scale", for: .normal)
        painScaleBottomConstraint?.isActive = visible
        painMinBottomConstraint?.isActive = !visible
        setNeedsLayout()
        layoutIfNeeded()
    }

    func setFeedbackVisible(_ visible: Bool) {
        painCard.isHidden = !visible
        notesCard.isHidden = !visible
        saveButton.isHidden = !visible
    }

    func setCompletedState(_ completed: Bool, locked: Bool) {
        let imageName = completed ? "checkmark.circle.fill" : "circle"
        completeButton.setImage(UIImage(systemName: imageName), for: .normal)
        completeButton.tintColor = completed ? UIColor(hex: "22C55E") : UIColor(hex: "94A3B8")
        completeButton.isEnabled = !locked
        completeButton.alpha = locked ? 0.6 : 1.0
        completeLabel.text = completed ? "Completed" : "Mark as Completed"
        completeLabel.alpha = locked ? 0.6 : 1.0
    }

    func setNextUpVisible(_ visible: Bool) {
        nextUpTitle.isHidden = !visible
        nextUpCollection.isHidden = !visible
        continueButton.isHidden = !visible
    }

    func setContinueEnabled(_ enabled: Bool) {
        continueButton.isEnabled = enabled
        continueButton.alpha = enabled ? 1.0 : 0.5
    }

    private func build() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.delaysContentTouches = false
        scroll.canCancelContentTouches = true

        content.translatesAutoresizingMaskIntoConstraints = false
        content.axis = .vertical
        content.spacing = 16

        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = UIColor(hex: "E3F0FF")

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor.black.withAlphaComponent(0.75)

        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.font = .boldSystemFont(ofSize: 18)
        headerTitle.textColor = .black

        topBar.addSubview(backButton)
        topBar.addSubview(headerTitle)

        addSubview(topBar)
        addSubview(scroll)
        scroll.addSubview(content)

        let topBarHeight = topBar.heightAnchor.constraint(equalToConstant: 36)
        topBarHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            topBarHeight,

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            headerTitle.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            headerTitle.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            scroll.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 10),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 8),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        buildVideoCard()
        buildInfoCard()
        buildProgressCard()
        buildPainCard()
        buildNotesCard()
        buildSaveButton()
        buildNextUp()

        content.addArrangedSubview(videoCard)
        content.addArrangedSubview(infoCard)
        content.addArrangedSubview(progressTitle)
        content.addArrangedSubview(completeCard)
        content.addArrangedSubview(painCard)
        content.addArrangedSubview(notesCard)
        content.addArrangedSubview(saveButton)
        content.addArrangedSubview(nextUpTitle)
        content.addArrangedSubview(nextUpCollection)
        content.addArrangedSubview(continueButton)
    }

    private func buildVideoCard() {
        videoCard.translatesAutoresizingMaskIntoConstraints = false
        videoCard.backgroundColor = .white
        videoCard.layer.cornerRadius = 22
        videoCard.layer.shadowColor = UIColor.black.cgColor
        videoCard.layer.shadowOpacity = 0.06
        videoCard.layer.shadowRadius = 14
        videoCard.layer.shadowOffset = CGSize(width: 0, height: 10)

        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 22
        thumbnailImageView.backgroundColor = UIColor(hex: "E3F0FF")

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = UIColor(hex: "1E6EF7")
        playButton.backgroundColor = .white
        playButton.layer.cornerRadius = 32
        playButton.layer.shadowColor = UIColor.black.cgColor
        playButton.layer.shadowOpacity = 0.12
        playButton.layer.shadowRadius = 12
        playButton.layer.shadowOffset = CGSize(width: 0, height: 8)

        videoCard.addSubview(thumbnailImageView)
        videoCard.addSubview(playButton)

        NSLayoutConstraint.activate([
            videoCard.heightAnchor.constraint(equalToConstant: 220),

            thumbnailImageView.topAnchor.constraint(equalTo: videoCard.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: videoCard.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: videoCard.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: videoCard.bottomAnchor),

            playButton.centerXAnchor.constraint(equalTo: videoCard.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: videoCard.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 64),
            playButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    private func buildInfoCard() {
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        infoCard.backgroundColor = .white
        infoCard.layer.cornerRadius = 20
        infoCard.layer.shadowColor = UIColor.black.cgColor
        infoCard.layer.shadowOpacity = 0.05
        infoCard.layer.shadowRadius = 12
        infoCard.layer.shadowOffset = CGSize(width: 0, height: 8)

        metaTitle.translatesAutoresizingMaskIntoConstraints = false
        metaTitle.font = .systemFont(ofSize: 21, weight: .bold)
        metaTitle.textColor = UIColor(hex: "1E2A44")
        metaTitle.numberOfLines = 2

        metaDuration.translatesAutoresizingMaskIntoConstraints = false
        metaDuration.font = .systemFont(ofSize: 13, weight: .bold)
        metaDuration.textColor = UIColor(hex: "1E6EF7")

        metaDesc.translatesAutoresizingMaskIntoConstraints = false
        metaDesc.font = .systemFont(ofSize: 14, weight: .regular)
        metaDesc.textColor = UIColor.black.withAlphaComponent(0.68)
        metaDesc.numberOfLines = 0

        infoCard.addSubview(metaTitle)
        infoCard.addSubview(metaDuration)
        infoCard.addSubview(metaDesc)

        NSLayoutConstraint.activate([
            metaTitle.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
            metaTitle.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            metaTitle.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),

            metaDuration.topAnchor.constraint(equalTo: metaTitle.bottomAnchor, constant: 6),
            metaDuration.leadingAnchor.constraint(equalTo: metaTitle.leadingAnchor),

            metaDesc.topAnchor.constraint(equalTo: metaDuration.bottomAnchor, constant: 10),
            metaDesc.leadingAnchor.constraint(equalTo: metaTitle.leadingAnchor),
            metaDesc.trailingAnchor.constraint(equalTo: metaTitle.trailingAnchor),
            metaDesc.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -16)
        ])
    }

    private func buildProgressCard() {
        progressTitle.translatesAutoresizingMaskIntoConstraints = false
        progressTitle.text = "Log Your Progress"
        progressTitle.font = .systemFont(ofSize: 16, weight: .bold)
        progressTitle.textColor = UIColor(hex: "1E2A44")

        completeCard.translatesAutoresizingMaskIntoConstraints = false
        completeCard.backgroundColor = UIColor(hex: "F8FAFF")
        completeCard.layer.cornerRadius = 18
        completeCard.layer.borderWidth = 1
        completeCard.layer.borderColor = UIColor(hex: "DCE8FF").cgColor
        completeCard.layer.shadowColor = UIColor.black.cgColor
        completeCard.layer.shadowOpacity = 0.04
        completeCard.layer.shadowRadius = 8
        completeCard.layer.shadowOffset = CGSize(width: 0, height: 5)

        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.setImage(UIImage(systemName: "circle"), for: .normal)
        completeButton.tintColor = UIColor(hex: "94A3B8")

        completeLabel.translatesAutoresizingMaskIntoConstraints = false
        completeLabel.text = "Mark as Completed"
        completeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        completeLabel.textColor = UIColor.black.withAlphaComponent(0.75)

        completeCard.addSubview(completeButton)
        completeCard.addSubview(completeLabel)

        NSLayoutConstraint.activate([
            completeButton.leadingAnchor.constraint(equalTo: completeCard.leadingAnchor, constant: 16),
            completeButton.centerYAnchor.constraint(equalTo: completeCard.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 24),
            completeButton.heightAnchor.constraint(equalToConstant: 24),

            completeLabel.leadingAnchor.constraint(equalTo: completeButton.trailingAnchor, constant: 12),
            completeLabel.trailingAnchor.constraint(equalTo: completeCard.trailingAnchor, constant: -16),
            completeLabel.centerYAnchor.constraint(equalTo: completeCard.centerYAnchor),

            completeCard.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func buildPainCard() {
        painCard.translatesAutoresizingMaskIntoConstraints = false
        painCard.backgroundColor = .white
        painCard.layer.cornerRadius = 20
        painCard.layer.shadowColor = UIColor.black.cgColor
        painCard.layer.shadowOpacity = 0.05
        painCard.layer.shadowRadius = 12
        painCard.layer.shadowOffset = CGSize(width: 0, height: 8)

        painTitle.translatesAutoresizingMaskIntoConstraints = false
        painTitle.text = "How are you feeling today?"
        painTitle.font = .systemFont(ofSize: 16, weight: .bold)
        painTitle.textColor = UIColor(hex: "1E2A44")

        painScaleToggle.translatesAutoresizingMaskIntoConstraints = false
        painScaleToggle.setTitle("View Scale", for: .normal)
        painScaleToggle.setTitleColor(UIColor(hex: "1E6EF7"), for: .normal)
        painScaleToggle.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)

        painEmoji.translatesAutoresizingMaskIntoConstraints = false
        painEmoji.text = "😐"
        painEmoji.font = .systemFont(ofSize: 32)

        painValueLabel.translatesAutoresizingMaskIntoConstraints = false
        painValueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        painValueLabel.textColor = UIColor(hex: "1E2A44")

        painSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        painSubtitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        painSubtitleLabel.textColor = UIColor(hex: "F59E0B")

        painScaleTrack.translatesAutoresizingMaskIntoConstraints = false
        painScaleTrack.layer.cornerRadius = 7
        painScaleTrack.clipsToBounds = true
        painScaleTrack.isUserInteractionEnabled = true
        painScaleTrack.addGestureRecognizer(painTrackPan)
        painScaleTrack.addGestureRecognizer(painTrackTap)
        scroll.panGestureRecognizer.require(toFail: painTrackPan)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hex: "22C55E").cgColor, UIColor(hex: "F59E0B").cgColor, UIColor(hex: "EF4444").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        painScaleTrack.layer.addSublayer(gradient)
        gradientLayer = gradient

        painSlider.translatesAutoresizingMaskIntoConstraints = false
        painSlider.minimumValue = 0
        painSlider.maximumValue = 10
        painSlider.value = 6
        painSlider.isContinuous = true
        painSlider.isUserInteractionEnabled = true

        painMinLabel.translatesAutoresizingMaskIntoConstraints = false
        painMinLabel.text = "No Pain"
        painMinLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        painMinLabel.textColor = UIColor.black.withAlphaComponent(0.45)

        painMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        painMaxLabel.text = "Worst Pain"
        painMaxLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        painMaxLabel.textColor = UIColor.black.withAlphaComponent(0.45)

        painScaleCard.translatesAutoresizingMaskIntoConstraints = false
        painScaleCard.backgroundColor = UIColor(hex: "F8FAFC")
        painScaleCard.layer.cornerRadius = 16
        painScaleCard.isHidden = true

        painScaleStack.translatesAutoresizingMaskIntoConstraints = false
        painScaleStack.axis = .vertical
        painScaleStack.spacing = 8
        painScaleStack.alignment = .fill

        let scaleRows: [(String, String, UIColor)] = [
            ("0", "No pain", UIColor(hex: "16A34A")),
            ("1-3", "Mild, manageable pain", UIColor(hex: "84CC16")),
            ("4-6", "Moderate, noticeable pain", UIColor(hex: "F59E0B")),
            ("7-9", "Severe, limiting activities", UIColor(hex: "F97316")),
            ("10", "Worst possible pain", UIColor(hex: "EF4444"))
        ]

        scaleRows.forEach { (left, right, color) in
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false

            let leftLabel = UILabel()
            leftLabel.translatesAutoresizingMaskIntoConstraints = false
            leftLabel.text = left
            leftLabel.font = .systemFont(ofSize: 13, weight: .bold)
            leftLabel.textColor = color

            let rightLabel = UILabel()
            rightLabel.translatesAutoresizingMaskIntoConstraints = false
            rightLabel.text = right
            rightLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            rightLabel.textColor = UIColor.black.withAlphaComponent(0.7)
            rightLabel.textAlignment = .right

            row.addSubview(leftLabel)
            row.addSubview(rightLabel)

            NSLayoutConstraint.activate([
                leftLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                leftLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

                rightLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                rightLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                rightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftLabel.trailingAnchor, constant: 8)
            ])
            row.heightAnchor.constraint(equalToConstant: 18).isActive = true

            painScaleStack.addArrangedSubview(row)
        }

        painScaleCard.addSubview(painScaleStack)

        painCard.addSubview(painTitle)
        painCard.addSubview(painScaleToggle)
        painCard.addSubview(painEmoji)
        painCard.addSubview(painValueLabel)
        painCard.addSubview(painSubtitleLabel)
        painCard.addSubview(painScaleTrack)
        painCard.addSubview(painSlider)
        painCard.addSubview(painMinLabel)
        painCard.addSubview(painMaxLabel)
        painCard.addSubview(painScaleCard)

        NSLayoutConstraint.activate([
            painTitle.topAnchor.constraint(equalTo: painCard.topAnchor, constant: 16),
            painTitle.leadingAnchor.constraint(equalTo: painCard.leadingAnchor, constant: 16),
            painTitle.trailingAnchor.constraint(equalTo: painCard.trailingAnchor, constant: -16),

            painScaleToggle.centerYAnchor.constraint(equalTo: painTitle.centerYAnchor),
            painScaleToggle.trailingAnchor.constraint(equalTo: painCard.trailingAnchor, constant: -16),

            painEmoji.topAnchor.constraint(equalTo: painTitle.bottomAnchor, constant: 12),
            painEmoji.leadingAnchor.constraint(equalTo: painTitle.leadingAnchor),

            painValueLabel.centerYAnchor.constraint(equalTo: painEmoji.centerYAnchor),
            painValueLabel.leadingAnchor.constraint(equalTo: painEmoji.trailingAnchor, constant: 10),

            painSubtitleLabel.topAnchor.constraint(equalTo: painValueLabel.bottomAnchor, constant: 2),
            painSubtitleLabel.leadingAnchor.constraint(equalTo: painValueLabel.leadingAnchor),

            painScaleTrack.topAnchor.constraint(equalTo: painEmoji.bottomAnchor, constant: 16),
            painScaleTrack.leadingAnchor.constraint(equalTo: painTitle.leadingAnchor),
            painScaleTrack.trailingAnchor.constraint(equalTo: painTitle.trailingAnchor),
            painScaleTrack.heightAnchor.constraint(equalToConstant: 12),

            painSlider.centerYAnchor.constraint(equalTo: painScaleTrack.centerYAnchor),
            painSlider.leadingAnchor.constraint(equalTo: painScaleTrack.leadingAnchor),
            painSlider.trailingAnchor.constraint(equalTo: painScaleTrack.trailingAnchor),
            painSlider.heightAnchor.constraint(equalToConstant: 32),

            painMinLabel.topAnchor.constraint(equalTo: painScaleTrack.bottomAnchor, constant: 6),
            painMinLabel.leadingAnchor.constraint(equalTo: painScaleTrack.leadingAnchor),

            painMaxLabel.topAnchor.constraint(equalTo: painScaleTrack.bottomAnchor, constant: 6),
            painMaxLabel.trailingAnchor.constraint(equalTo: painScaleTrack.trailingAnchor),

            painScaleCard.topAnchor.constraint(equalTo: painMinLabel.bottomAnchor, constant: 14),
            painScaleCard.leadingAnchor.constraint(equalTo: painTitle.leadingAnchor),
            painScaleCard.trailingAnchor.constraint(equalTo: painTitle.trailingAnchor),

            painScaleStack.topAnchor.constraint(equalTo: painScaleCard.topAnchor, constant: 12),
            painScaleStack.leadingAnchor.constraint(equalTo: painScaleCard.leadingAnchor, constant: 12),
            painScaleStack.trailingAnchor.constraint(equalTo: painScaleCard.trailingAnchor, constant: -12),
            painScaleStack.bottomAnchor.constraint(equalTo: painScaleCard.bottomAnchor, constant: -12)
        ])

        painScaleBottomConstraint = painScaleCard.bottomAnchor.constraint(equalTo: painCard.bottomAnchor, constant: -16)
        painScaleBottomConstraint?.isActive = false

        painMinBottomConstraint = painMaxLabel.bottomAnchor.constraint(equalTo: painCard.bottomAnchor, constant: -16)
        painMinBottomConstraint?.isActive = true

    }

    private func buildNotesCard() {
        notesCard.translatesAutoresizingMaskIntoConstraints = false
        notesCard.backgroundColor = .white
        notesCard.layer.cornerRadius = 20
        notesCard.layer.shadowColor = UIColor.black.cgColor
        notesCard.layer.shadowOpacity = 0.05
        notesCard.layer.shadowRadius = 12
        notesCard.layer.shadowOffset = CGSize(width: 0, height: 8)

        notesTitle.translatesAutoresizingMaskIntoConstraints = false
        notesTitle.text = "Discomfort Notes"
        notesTitle.font = .systemFont(ofSize: 15, weight: .bold)
        notesTitle.textColor = UIColor(hex: "1E2A44")

        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.font = .systemFont(ofSize: 14, weight: .regular)
        notesTextView.textColor = UIColor.black.withAlphaComponent(0.8)
        notesTextView.backgroundColor = UIColor(hex: "F2F6FF")
        notesTextView.layer.cornerRadius = 14
        notesTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        notesPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        notesPlaceholder.text = "e.g. felt a slight twinge in my lower back."
        notesPlaceholder.font = .systemFont(ofSize: 14, weight: .regular)
        notesPlaceholder.textColor = UIColor.black.withAlphaComponent(0.35)

        notesTextView.addSubview(notesPlaceholder)
        notesCard.addSubview(notesTitle)
        notesCard.addSubview(notesTextView)

        NSLayoutConstraint.activate([
            notesTitle.topAnchor.constraint(equalTo: notesCard.topAnchor, constant: 16),
            notesTitle.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 16),
            notesTitle.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor, constant: -16),

            notesTextView.topAnchor.constraint(equalTo: notesTitle.bottomAnchor, constant: 12),
            notesTextView.leadingAnchor.constraint(equalTo: notesTitle.leadingAnchor),
            notesTextView.trailingAnchor.constraint(equalTo: notesTitle.trailingAnchor),
            notesTextView.heightAnchor.constraint(equalToConstant: 110),
            notesTextView.bottomAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: -16),

            notesPlaceholder.topAnchor.constraint(equalTo: notesTextView.topAnchor, constant: 12),
            notesPlaceholder.leadingAnchor.constraint(equalTo: notesTextView.leadingAnchor, constant: 16),
            notesPlaceholder.trailingAnchor.constraint(equalTo: notesTextView.trailingAnchor, constant: -16)
        ])
    }

    private func buildSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        saveButton.backgroundColor = UIColor(hex: "1E6EF7")
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 18
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOpacity = 0.12
        saveButton.layer.shadowRadius = 10
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    private func buildNextUp() {
        nextUpTitle.translatesAutoresizingMaskIntoConstraints = false
        nextUpTitle.text = "Next Up"
        nextUpTitle.font = .systemFont(ofSize: 16, weight: .bold)
        nextUpTitle.textColor = UIColor(hex: "1E2A44")

        nextUpCollection.translatesAutoresizingMaskIntoConstraints = false
        nextUpCollection.backgroundColor = .clear
        nextUpCollection.showsHorizontalScrollIndicator = false

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue to Next Exercise", for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        continueButton.backgroundColor = UIColor(hex: "1E6EF7")
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 18
        continueButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        continueButton.layer.shadowColor = UIColor.black.cgColor
        continueButton.layer.shadowOpacity = 0.12
        continueButton.layer.shadowRadius = 10
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 6)

        nextUpCollection.heightAnchor.constraint(equalToConstant: 160).isActive = true
    }
}
