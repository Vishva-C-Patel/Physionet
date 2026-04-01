//
//  PhysioPatientReportView.swift
//  Physio_Connect
//
//  Created by user@8 on 29/01/26.
//

import UIKit

final class PhysioPatientReportView: UIView {

    struct SessionNoteVM {
        let dateText: String
        let therapistText: String
        let painText: String
        let exercises: [String]
        let notes: String
    }

    struct ViewModel {
        let patientName: String
        let subtitleText: String
        let programText: String
        let sessionsText: String
        let adherenceText: String
        let adherencePercent: Int
        let completedSessionsText: String
        let missedSessionsText: String
        let exercisesDoneText: String
        let totalHoursText: String
        let sessionNotes: [SessionNoteVM]
    }


    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let backgroundGlow = AppBackgroundTopGlowView()

    private let headerCard = UIView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let sessionsPill = PillView()
    private let adherencePill = PillView()

    private let adherenceCard = UIView()
    private let adherenceTitle = UILabel()
    private let adherenceValue = UILabel()
    private let adherenceBar = UIProgressView(progressViewStyle: .default)
    private let metricsStack = UIStackView()
    private let metricsRow1 = UIStackView()
    private let metricsRow2 = UIStackView()

    private let chartCard = UIView()
    let chartView = ProgramTrendsView()

    private let notesCard = UIView()
    private let notesTitle = UILabel()
    private let notesStack = UIStackView()
    private let emptyNotesLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(_ vm: ViewModel) {
        nameLabel.text = vm.patientName
        subtitleLabel.text = vm.subtitleText
        sessionsPill.configure(title: "Sessions", value: vm.sessionsText)
        adherencePill.configure(title: "Adherence", value: vm.adherenceText, accentColor: .systemGreen)

        adherenceValue.text = "\(vm.adherencePercent)%"
        adherenceBar.setProgress(Float(vm.adherencePercent) / 100.0, animated: false)

        metricsRow1.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metricsRow2.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metricsRow1.addArrangedSubview(MetricView(title: "Completed Sessions", value: vm.completedSessionsText, color: .systemBlue))
        metricsRow1.addArrangedSubview(MetricView(title: "Exercises Done", value: vm.exercisesDoneText, color: .systemGreen))
        metricsRow2.addArrangedSubview(MetricView(title: "Missed Sessions", value: vm.missedSessionsText, color: .systemOrange))
        metricsRow2.addArrangedSubview(MetricView(title: "Total Hours", value: vm.totalHoursText, color: .systemPurple))

        notesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if vm.sessionNotes.isEmpty {
            notesStack.addArrangedSubview(emptyNotesLabel)
        } else {
            for note in vm.sessionNotes {
                notesStack.addArrangedSubview(SessionNoteCard(note: note))
            }
        }
    }

    private func build() {
        backgroundColor = .clear

        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGlow)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16

        headerCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(headerCard)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .label

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UITheme.Colors.textSecondary

        sessionsPill.translatesAutoresizingMaskIntoConstraints = false
        adherencePill.translatesAutoresizingMaskIntoConstraints = false

        let pillsStack = UIStackView(arrangedSubviews: [sessionsPill, adherencePill])
        pillsStack.translatesAutoresizingMaskIntoConstraints = false
        pillsStack.axis = .horizontal
        pillsStack.spacing = 12
        pillsStack.distribution = .fillEqually

        headerCard.addSubview(nameLabel)
        headerCard.addSubview(subtitleLabel)
        headerCard.addSubview(pillsStack)

        adherenceCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(adherenceCard)

        adherenceTitle.translatesAutoresizingMaskIntoConstraints = false
        adherenceTitle.font = .systemFont(ofSize: 16, weight: .bold)
        adherenceTitle.textColor = .label
        adherenceTitle.text = "Exercise Adherence"

        adherenceValue.translatesAutoresizingMaskIntoConstraints = false
        adherenceValue.font = .systemFont(ofSize: 16, weight: .bold)
        adherenceValue.textColor = UITheme.Colors.accent
        adherenceValue.textAlignment = .right

        adherenceBar.translatesAutoresizingMaskIntoConstraints = false
        adherenceBar.trackTintColor = UITheme.Colors.neutralFill
        adherenceBar.progressTintColor = UITheme.Colors.accent
        adherenceBar.layer.cornerRadius = 4
        adherenceBar.clipsToBounds = true

        metricsStack.translatesAutoresizingMaskIntoConstraints = false
        metricsStack.axis = .vertical
        metricsStack.spacing = 10

        metricsRow1.axis = .horizontal
        metricsRow1.spacing = 12
        metricsRow1.distribution = .fillEqually

        metricsRow2.axis = .horizontal
        metricsRow2.spacing = 12
        metricsRow2.distribution = .fillEqually

        metricsStack.addArrangedSubview(metricsRow1)
        metricsStack.addArrangedSubview(metricsRow2)

        adherenceCard.addSubview(adherenceTitle)
        adherenceCard.addSubview(adherenceValue)
        adherenceCard.addSubview(adherenceBar)
        adherenceCard.addSubview(metricsStack)

        chartCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(chartCard)

        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartCard.addSubview(chartView)

        notesCard.translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(notesCard)

        notesTitle.translatesAutoresizingMaskIntoConstraints = false
        notesTitle.font = .systemFont(ofSize: 16, weight: .bold)
        notesTitle.textColor = .label
        notesTitle.text = "Session Notes"

        notesStack.translatesAutoresizingMaskIntoConstraints = false
        notesStack.axis = .vertical
        notesStack.spacing = 12

        emptyNotesLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyNotesLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emptyNotesLabel.textColor = UITheme.Colors.textSecondary
        emptyNotesLabel.text = "No session notes yet."
        emptyNotesLabel.textAlignment = .center

        notesCard.addSubview(notesTitle)
        notesCard.addSubview(notesStack)

        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerCard)
        contentStack.addArrangedSubview(adherenceCard)
        contentStack.addArrangedSubview(chartCard)
        contentStack.addArrangedSubview(notesCard)

        scrollView.contentInsetAdjustmentBehavior = .always

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            pillsStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            pillsStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            pillsStack.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            pillsStack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            adherenceTitle.topAnchor.constraint(equalTo: adherenceCard.topAnchor, constant: 16),
            adherenceTitle.leadingAnchor.constraint(equalTo: adherenceCard.leadingAnchor, constant: 16),
            adherenceTitle.trailingAnchor.constraint(equalTo: adherenceCard.trailingAnchor, constant: -16),

            adherenceValue.centerYAnchor.constraint(equalTo: adherenceTitle.centerYAnchor),
            adherenceValue.trailingAnchor.constraint(equalTo: adherenceCard.trailingAnchor, constant: -16),

            adherenceBar.topAnchor.constraint(equalTo: adherenceTitle.bottomAnchor, constant: 12),
            adherenceBar.leadingAnchor.constraint(equalTo: adherenceTitle.leadingAnchor),
            adherenceBar.trailingAnchor.constraint(equalTo: adherenceTitle.trailingAnchor),
            adherenceBar.heightAnchor.constraint(equalToConstant: 6),

            metricsStack.topAnchor.constraint(equalTo: adherenceBar.bottomAnchor, constant: 14),
            metricsStack.leadingAnchor.constraint(equalTo: adherenceTitle.leadingAnchor),
            metricsStack.trailingAnchor.constraint(equalTo: adherenceTitle.trailingAnchor),
            metricsStack.bottomAnchor.constraint(equalTo: adherenceCard.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: chartCard.topAnchor, constant: 12),
            chartView.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 12),
            chartView.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor, constant: -12),
            chartView.bottomAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            notesTitle.topAnchor.constraint(equalTo: notesCard.topAnchor, constant: 16),
            notesTitle.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 16),
            notesTitle.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor, constant: -16),

            notesStack.topAnchor.constraint(equalTo: notesTitle.bottomAnchor, constant: 12),
            notesStack.leadingAnchor.constraint(equalTo: notesTitle.leadingAnchor),
            notesStack.trailingAnchor.constraint(equalTo: notesTitle.trailingAnchor),
            notesStack.bottomAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: -16)
        ])
    }
}

private final class PillView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, value: String, accentColor: UIColor = UITheme.Colors.accent) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = accentColor
        backgroundColor = accentColor.withAlphaComponent(0.1)
    }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGroupedBackground
        layer.cornerRadius = 14

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = UITheme.Colors.textSecondary

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)

        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}

private final class MetricView: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    init(title: String, value: String, color: UIColor) {
        super.init(frame: .zero)
        valueLabel.text = value
        valueLabel.textColor = color
        titleLabel.text = title
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UITheme.Colors.surface
        layer.cornerRadius = 12

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UITheme.Colors.textSecondary
        titleLabel.numberOfLines = 2

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

private final class SessionNoteCard: UIView {
    private let dateLabel = UILabel()
    private let detailLabel = UILabel()
    private let painPill = UILabel()
    private let exercisesLabel = UILabel()
    private let exercisesStack = UIStackView()
    private let notesLabel = UILabel()
    private let divider = UIView()

    init(note: PhysioPatientReportView.SessionNoteVM) {
        super.init(frame: .zero)
        build()
        apply(note)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UITheme.Colors.surface
        layer.cornerRadius = 14

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.textColor = .label

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = .systemFont(ofSize: 12, weight: .medium)
        detailLabel.textColor = UITheme.Colors.textSecondary

        painPill.translatesAutoresizingMaskIntoConstraints = false
        painPill.font = .systemFont(ofSize: 12, weight: .semibold)
        painPill.textColor = .systemOrange
        painPill.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        painPill.textAlignment = .center
        painPill.layer.cornerRadius = 12
        painPill.clipsToBounds = true

        exercisesLabel.translatesAutoresizingMaskIntoConstraints = false
        exercisesLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        exercisesLabel.textColor = UITheme.Colors.textSecondary
        exercisesLabel.text = "Exercises:"

        exercisesStack.translatesAutoresizingMaskIntoConstraints = false
        exercisesStack.axis = .horizontal
        exercisesStack.spacing = 8
        exercisesStack.alignment = .leading
        exercisesStack.distribution = .fillProportionally

        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.font = .systemFont(ofSize: 13, weight: .regular)
        notesLabel.textColor = UITheme.Colors.textSecondary
        notesLabel.numberOfLines = 0

        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UITheme.Colors.border

        addSubview(dateLabel)
        addSubview(detailLabel)
        addSubview(painPill)
        addSubview(exercisesLabel)
        addSubview(exercisesStack)
        addSubview(divider)
        addSubview(notesLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            detailLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            painPill.centerYAnchor.constraint(equalTo: detailLabel.centerYAnchor),
            painPill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            painPill.heightAnchor.constraint(equalToConstant: 24),
            painPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 52),

            exercisesLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 10),
            exercisesLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),

            exercisesStack.topAnchor.constraint(equalTo: exercisesLabel.bottomAnchor, constant: 6),
            exercisesStack.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            exercisesStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            divider.topAnchor.constraint(equalTo: exercisesStack.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            divider.heightAnchor.constraint(equalToConstant: 1),

            notesLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 10),
            notesLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            notesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            notesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    private func apply(_ note: PhysioPatientReportView.SessionNoteVM) {
        dateLabel.text = note.dateText
        detailLabel.text = note.therapistText
        painPill.text = "  \(note.painText)  "

        exercisesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for title in note.exercises {
            exercisesStack.addArrangedSubview(makeChip(text: title))
        }
        notesLabel.text = note.notes
    }

    private func makeChip(text: String) -> UIView {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UITheme.Colors.accent
        label.backgroundColor = UITheme.Colors.accent.withAlphaComponent(0.12)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }
}

private final class PaddingLabel: UILabel {
    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
