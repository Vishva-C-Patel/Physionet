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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E3F0FF")
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

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
        upcomingTitle.textColor = UIColor(hex: "102A43")
        contentStack.addArrangedSubview(upcomingTitle)

        upcomingStack.axis = .vertical
        upcomingStack.spacing = 12
        upcomingStack.alignment = .fill
        upcomingStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(upcomingStack)

        upcomingEmptyLabel.text = "No upcoming sessions yet."
        upcomingEmptyLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        upcomingEmptyLabel.textColor = UIColor.black.withAlphaComponent(0.45)
        upcomingStack.addArrangedSubview(upcomingEmptyLabel)

        patientsTitle.text = "Patients"
        patientsTitle.font = .systemFont(ofSize: 18, weight: .bold)
        patientsTitle.textColor = UIColor(hex: "102A43")
        contentStack.addArrangedSubview(patientsTitle)

        patientsStack.axis = .vertical
        patientsStack.spacing = 10
        patientsStack.alignment = .fill
        patientsStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(patientsStack)

        patientsEmptyLabel.text = "No patients assigned yet."
        patientsEmptyLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        patientsEmptyLabel.textColor = UIColor.black.withAlphaComponent(0.45)
        patientsStack.addArrangedSubview(patientsEmptyLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
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
        backgroundColor = UIColor.white.withAlphaComponent(0.98)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = UIColor(hex: "1E6EF7")

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
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
    private let patientLabel = UILabel()
    private let timeLabel = UILabel()
    private let locationLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white.withAlphaComponent(0.98)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)

        [titleLabel, patientLabel, timeLabel, locationLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "102A43")

        patientLabel.font = .systemFont(ofSize: 14, weight: .medium)
        patientLabel.textColor = UIColor.black.withAlphaComponent(0.75)

        timeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        timeLabel.textColor = UIColor(hex: "1E6EF7")

        locationLabel.font = .systemFont(ofSize: 13, weight: .medium)
        locationLabel.textColor = UIColor.black.withAlphaComponent(0.6)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            patientLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            patientLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            patientLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            timeLabel.topAnchor.constraint(equalTo: patientLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            locationLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 6),
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, patient: String, time: String, location: String) {
        titleLabel.text = title
        patientLabel.text = patient
        timeLabel.text = time
        locationLabel.text = location
    }
}

private final class PatientCardView: UIView {
    private let nameLabel = UILabel()
    private let contactLabel = UILabel()
    private let locationLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white.withAlphaComponent(0.98)
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        [nameLabel, contactLabel, locationLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = UIColor(hex: "102A43")

        contactLabel.font = .systemFont(ofSize: 14, weight: .medium)
        contactLabel.textColor = UIColor.black.withAlphaComponent(0.7)

        locationLabel.font = .systemFont(ofSize: 13, weight: .medium)
        locationLabel.textColor = UIColor.black.withAlphaComponent(0.55)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            contactLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            contactLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            contactLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            locationLabel.topAnchor.constraint(equalTo: contactLabel.bottomAnchor, constant: 6),
            locationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(name: String, contact: String, location: String) {
        nameLabel.text = name
        contactLabel.text = contact
        locationLabel.text = location
    }
}
