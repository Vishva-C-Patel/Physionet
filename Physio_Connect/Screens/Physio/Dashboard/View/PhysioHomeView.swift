//
//  PhysioHomeView.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
//

import UIKit

final class PhysioHomeView: UIView {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let statsStack = UIStackView()
    private let sessionsCard = StatCardView()
    private let upcomingCard = StatCardView()
    private let programsCard = StatCardView()

    private let upcomingTitle = UILabel()
    private let upcomingStack = UIStackView()
    private let upcomingEmptyLabel = UILabel()

    private let patientsTitle = UILabel()
    private let patientsStack = UIStackView()
    private let patientsEmptyLabel = UILabel()

    private let backgroundGlow = AppBackgroundTopGlowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .always
        addSubview(scrollView)

        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(backgroundGlow, at: 0)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)

        statsStack.axis = .horizontal
        statsStack.spacing = 12
        statsStack.distribution = .fillEqually
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.addArrangedSubview(sessionsCard)
        statsStack.addArrangedSubview(upcomingCard)
        statsStack.addArrangedSubview(programsCard)
        
        contentStack.addArrangedSubview(statsStack)

        upcomingTitle.text = "Upcoming Sessions"
        upcomingTitle.font = .systemFont(ofSize: 18, weight: .bold)
        upcomingTitle.textColor = .label
        contentStack.addArrangedSubview(upcomingTitle)

        upcomingStack.axis = .vertical
        upcomingStack.spacing = 12
        upcomingStack.alignment = .fill
        upcomingStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(upcomingStack)

        upcomingEmptyLabel.text = "No upcoming sessions yet."
        upcomingEmptyLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        upcomingEmptyLabel.textColor = UITheme.Colors.textMuted
        upcomingStack.addArrangedSubview(upcomingEmptyLabel)

        patientsTitle.text = "Patients"
        patientsTitle.font = .systemFont(ofSize: 18, weight: .bold)
        patientsTitle.textColor = .label
        contentStack.addArrangedSubview(patientsTitle)

        patientsStack.axis = .vertical
        patientsStack.spacing = 10
        patientsStack.alignment = .fill
        patientsStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(patientsStack)

        patientsEmptyLabel.text = "No patients assigned yet."
        patientsEmptyLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        patientsEmptyLabel.textColor = UITheme.Colors.textMuted
        patientsStack.addArrangedSubview(patientsEmptyLabel)

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -100),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    func setSummary(todaySessions: Int, upcomingAppointments: Int, activePrograms: Int) {
        sessionsCard.configure(title: "Today’s Sessions", value: "\(todaySessions)")
        upcomingCard.configure(title: "Upcoming Appointments", value: "\(upcomingAppointments)")
        programsCard.configure(title: "Active Programs", value: "\(activePrograms)")
    }

    func setUpcoming(_ sessions: [UpcomingItem]) {
        upcomingStack.arrangedSubviews.forEach { view in
            upcomingStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        if sessions.isEmpty {
            upcomingStack.addArrangedSubview(upcomingEmptyLabel)
            return
        }
        for session in sessions {
            let card = UpcomingSessionCard()
            card.configure(title: session.title, patient: session.patient, time: session.time, location: session.location)
            upcomingStack.addArrangedSubview(card)
        }
    }

    func setPatients(_ patients: [PatientItem]) {
        patientsStack.arrangedSubviews.forEach { view in
            patientsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        if patients.isEmpty {
            patientsStack.addArrangedSubview(patientsEmptyLabel)
            return
        }
        for patient in patients {
            let card = PatientCardView()
            card.configure(name: patient.name, contact: patient.contact, location: patient.location)
            patientsStack.addArrangedSubview(card)
        }
    }

    struct UpcomingItem {
        let title: String
        let patient: String
        let time: String
        let location: String
    }

    struct PatientItem {
        let name: String
        let contact: String
        let location: String
    }

    func setAvatar(urlString: String?) { /* header avatar removed by design */ }

    override func layoutSubviews() {
        super.layoutSubviews()
        let isCompact = bounds.width < 380
        statsStack.axis = isCompact ? .vertical : .horizontal
        statsStack.distribution = isCompact ? .fill : .fillEqually
    }

}

private final class StatCardView: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(self)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = UITheme.Colors.accent

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UITheme.Colors.textSecondary
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

private final class UpcomingSessionCard: UIView {
    private let titleLabel = UILabel()
    private let metricsStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(self)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        addSubview(titleLabel)

        metricsStack.translatesAutoresizingMaskIntoConstraints = false
        metricsStack.axis = .vertical
        metricsStack.spacing = 8
        metricsStack.alignment = .leading
        addSubview(metricsStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            metricsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            metricsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            metricsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            metricsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, patient: String, time: String, location: String) {
        titleLabel.text = title
        metricsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metricsStack.addArrangedSubview(makeMetricRow(icon: "person.fill", text: patient, color: .secondaryLabel))
        metricsStack.addArrangedSubview(makeMetricRow(icon: "clock.fill", text: time, color: UITheme.Colors.accent))
        if !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metricsStack.addArrangedSubview(makeMetricRow(icon: "mappin.and.ellipse", text: location, color: .secondaryLabel))
        }
    }

    private func makeMetricRow(icon: String, text: String, color: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true

        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = color
        label.text = text
        label.numberOfLines = 0

        row.addArrangedSubview(iconView)
        row.addArrangedSubview(label)
        return row
    }
}

private final class PatientCardView: UIView {
    private let nameLabel = UILabel()
    private let metricsStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        UITheme.applyCardStyle(self)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .label
        addSubview(nameLabel)

        metricsStack.translatesAutoresizingMaskIntoConstraints = false
        metricsStack.axis = .vertical
        metricsStack.spacing = 8
        metricsStack.alignment = .leading
        addSubview(metricsStack)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            metricsStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            metricsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            metricsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            metricsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(name: String, contact: String, location: String) {
        nameLabel.text = name
        metricsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metricsStack.addArrangedSubview(makeMetricRow(icon: "phone.fill", text: contact, color: .secondaryLabel))
        if !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metricsStack.addArrangedSubview(makeMetricRow(icon: "mappin.and.ellipse", text: location, color: .secondaryLabel))
        }
    }

    private func makeMetricRow(icon: String, text: String, color: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true

        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = color
        label.text = text
        label.numberOfLines = 0

        row.addArrangedSubview(iconView)
        row.addArrangedSubview(label)
        return row
    }
}
