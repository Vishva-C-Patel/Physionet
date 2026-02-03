//
//  PhysioPatientReportViewController.swift
//  Physio_Connect
//
//  Created by Codex on 29/01/26.
//

import UIKit

final class PhysioPatientReportViewController: UIViewController {
    private let contentView = PhysioPatientReportView()
    private let model = PhysioPatientReportModel()
    private let patientID: UUID
    private var physioID: String?
    private var isLoading = false

    init(patientID: UUID) {
        self.patientID = patientID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        contentView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        Task { await loadDetail() }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func loadDetail() async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let id = try await resolvePhysioID()
            let detail = try await model.fetchDetail(patientID: patientID, physioID: id)
            guard let detail else { return }
            await MainActor.run {
                self.apply(detail)
            }
        } catch {
            await MainActor.run {
                let ac = UIAlertController(title: "Report Error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(ac, animated: true)
            }
        }
    }

    private func resolvePhysioID() async throws -> String {
        if let physioID { return physioID }
        let id = try await PhysioReportsModel().resolvePhysioID()
        physioID = id
        return id
    }

    private func apply(_ detail: PatientReportDetail) {
        let ageText = detail.ageText == "—" ? "Age unavailable" : detail.ageText
        let subtitle = "\(ageText) • \(detail.programTitle)"
        let sessionsText = "\(detail.sessionsCount)"
        let adherenceText = "\(detail.adherencePercent)%"

        let sessionNotes = detail.sessionNotes.map { row -> PhysioPatientReportView.SessionNoteVM in
            let dateText = formatDate(row.date)
            let therapistText = "Therapist: \(detail.therapistName) • Duration: \(row.durationMinutes) mins"
            let painText = row.painLevel.map { "\($0)/10" } ?? "—"
            return PhysioPatientReportView.SessionNoteVM(
                dateText: dateText,
                therapistText: therapistText,
                painText: painText,
                exercises: row.exercises,
                notes: row.notes
            )
        }

        let vm = PhysioPatientReportView.ViewModel(
            patientName: detail.patientName,
            subtitleText: subtitle,
            programText: detail.programTitle,
            sessionsText: sessionsText,
            adherenceText: adherenceText,
            adherencePercent: detail.adherencePercent,
            completedSessionsText: "\(detail.completedSessions)",
            missedSessionsText: "\(detail.missedSessions)",
            exercisesDoneText: "\(detail.exercisesDone)",
            totalHoursText: "\(detail.totalHours)",
            sessionNotes: sessionNotes
        )

        contentView.apply(vm)
        contentView.chartView.configure(painSeries: detail.painSeries, adherenceSeries: detail.adherenceSeries)
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df.string(from: date)
    }
}
