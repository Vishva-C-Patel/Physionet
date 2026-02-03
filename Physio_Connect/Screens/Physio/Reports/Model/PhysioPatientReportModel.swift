//
//  PhysioPatientReportModel.swift
//  Physio_Connect
//
//  Created by Codex on 29/01/26.
//

import Foundation
import Supabase

struct PatientReportDetail {
    let patientID: UUID
    let patientName: String
    let ageText: String
    let location: String
    let programTitle: String
    let sessionsCount: Int
    let adherencePercent: Int
    let completedSessions: Int
    let missedSessions: Int
    let exercisesDone: Int
    let totalHours: Int
    let painSeries: [Int]
    let adherenceSeries: [Int]
    let sessionNotes: [SessionNoteRow]
    let therapistName: String
}

struct SessionNoteRow {
    let date: Date
    let painLevel: Int?
    let durationMinutes: Int
    let exercises: [String]
    let notes: String
}

final class PhysioPatientReportModel {
    private let client = SupabaseManager.shared.client
    private let itemsPerDay = 2

    func fetchDetail(patientID: UUID, physioID: String) async throws -> PatientReportDetail? {
        guard let customer = try await fetchCustomer(id: patientID) else { return nil }
        let programs = try await fetchPrograms(physioID: physioID)
        let programIDs = programs.map { $0.id }
        let redemptions = try await fetchRedemptions(programIDs: programIDs, patientID: patientID)
        let programTitleByID = Dictionary(uniqueKeysWithValues: programs.map { ($0.id, $0.title) })

        let sessionsCount = redemptions.count
        let primaryProgram = resolvePrimaryProgram(from: redemptions)
        let programTitle = primaryProgram.flatMap { programTitleByID[$0.program_id] } ?? "—"
        let therapistName = (try? await fetchPhysioName(physioID: physioID)) ?? "Physiotherapist"

        guard let programID = primaryProgram?.program_id else {
            return PatientReportDetail(
                patientID: patientID,
                patientName: customer.full_name ?? "Patient",
                ageText: ageString(from: customer.date_of_birth) ?? "—",
                location: customer.location ?? "Location unavailable",
                programTitle: "—",
                sessionsCount: sessionsCount,
                adherencePercent: 0,
                completedSessions: 0,
                missedSessions: 0,
                exercisesDone: 0,
                totalHours: 0,
                painSeries: [],
                adherenceSeries: [],
                sessionNotes: [],
                therapistName: therapistName
            )
        }

        let programExercises = try await fetchProgramExercises(programID: programID)
        let exerciseIDs = programExercises.map { $0.exercise_id }
        let exerciseInfo = try await fetchExerciseInfo(ids: exerciseIDs)
        let progressRows = try await fetchProgressRows(patientID: patientID, programID: programID)

        let totalExercises = programExercises.count
        let totalDays = max(1, Int(ceil(Double(totalExercises) / Double(itemsPerDay))))
        let completedExercises = progressRows.filter { $0.is_completed == true }.count
        let adherencePercent = totalExercises == 0 ? 0 : min(100, Int(Double(completedExercises) / Double(totalExercises) * 100.0))

        let startDate = primaryProgram.flatMap { parseDate($0.redeemed_at ?? "") } ?? Date()
        let expectedByDay = expectedExercisesByDay(totalExercises: totalExercises)
        let progressByDate = Dictionary(grouping: progressRows, by: { $0.progress_date ?? "" })

        var completedSessions = 0
        for dayIndex in 0..<totalDays {
            let dateString = dateString(from: startDate, dayOffset: dayIndex)
            let expected = expectedByDay[dayIndex] ?? 0
            guard expected > 0 else { continue }
            let completed = progressByDate[dateString]?.filter { $0.is_completed == true }.count ?? 0
            if completed >= expected { completedSessions += 1 }
        }
        let missedSessions = max(totalDays - completedSessions, 0)

        let totalHours = max(0, Int(Double(progressRows.reduce(0) { $0 + ($1.watched_seconds ?? 0) }) / 3600.0))

        let series = buildSeries(rows: progressRows, startDate: startDate, totalDays: totalDays, expectedByDay: expectedByDay)
        let notes = buildSessionNotes(rows: progressRows, startDate: startDate, totalDays: totalDays, exerciseInfo: exerciseInfo)

        return PatientReportDetail(
            patientID: patientID,
            patientName: customer.full_name ?? "Patient",
            ageText: ageString(from: customer.date_of_birth) ?? "—",
            location: customer.location ?? "Location unavailable",
            programTitle: programTitle,
            sessionsCount: sessionsCount,
            adherencePercent: adherencePercent,
            completedSessions: completedSessions,
            missedSessions: missedSessions,
            exercisesDone: completedExercises,
            totalHours: totalHours,
            painSeries: series.pain,
            adherenceSeries: series.adherence,
            sessionNotes: notes,
            therapistName: therapistName
        )
    }

    private func fetchPhysioName(physioID: String) async throws -> String? {
        struct Row: Decodable { let name: String? }
        let rows: [Row] = try await client
            .from("physiotherapists")
            .select("name")
            .eq("id", value: physioID)
            .limit(1)
            .execute()
            .value
        return rows.first?.name
    }

    private func fetchCustomer(id: UUID) async throws -> CustomerRow? {
        let rows: [CustomerRow] = try await client
            .from("customers")
            .select("id,full_name,location,date_of_birth")
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value
        return rows.first
    }

    private func fetchPrograms(physioID: String) async throws -> [ProgramRow] {
        let rows: [ProgramRow] = try await client
            .from("physio_programs")
            .select("id,title,is_active")
            .eq("physio_id", value: physioID)
            .eq("is_active", value: true)
            .execute()
            .value
        return rows
    }

    private func fetchRedemptions(programIDs: [UUID], patientID: UUID) async throws -> [RedemptionRow] {
        guard !programIDs.isEmpty else { return [] }
        let rows: [RedemptionRow] = try await client
            .from("program_redemptions")
            .select("program_id,customer_id,redeemed_at")
            .in("program_id", values: programIDs.map { $0.uuidString })
            .eq("customer_id", value: patientID.uuidString)
            .execute()
            .value
        return rows
    }

    private func fetchProgramExercises(programID: UUID) async throws -> [PatientProgramExerciseRow] {
        let rows: [PatientProgramExerciseRow] = try await client
            .from("program_exercises")
            .select("program_id,exercise_id,sort_order")
            .eq("program_id", value: programID.uuidString)
            .order("sort_order", ascending: true)
            .execute()
            .value
        return rows
    }

    private func fetchExerciseInfo(ids: [UUID]) async throws -> [UUID: ExerciseInfoRow] {
        guard !ids.isEmpty else { return [:] }
        let rows: [ExerciseInfoRow] = try await client
            .from("physio_videos")
            .select("id,title,duration_seconds")
            .in("id", values: ids.map { $0.uuidString })
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
    }

    private func fetchProgressRows(patientID: UUID, programID: UUID) async throws -> [ProgressRow] {
        let rows: [ProgressRow] = try await client
            .from("exercise_progress")
            .select("exercise_id,progress_date,is_completed,pain_level,notes,watched_seconds")
            .eq("customer_id", value: patientID.uuidString)
            .eq("program_id", value: programID.uuidString)
            .execute()
            .value
        return rows
    }

    private func resolvePrimaryProgram(from redemptions: [RedemptionRow]) -> RedemptionRow? {
        return redemptions
            .sorted { parseDate($0.redeemed_at ?? "") ?? Date.distantPast < parseDate($1.redeemed_at ?? "") ?? Date.distantPast }
            .last
    }

    private func expectedExercisesByDay(totalExercises: Int) -> [Int: Int] {
        guard totalExercises > 0 else { return [:] }
        let totalDays = max(1, Int(ceil(Double(totalExercises) / Double(itemsPerDay))))
        var expected: [Int: Int] = [:]
        for dayIndex in 0..<totalDays {
            let remaining = totalExercises - (dayIndex * itemsPerDay)
            expected[dayIndex] = max(0, min(itemsPerDay, remaining))
        }
        return expected
    }

    private func buildSeries(rows: [ProgressRow],
                             startDate: Date,
                             totalDays: Int,
                             expectedByDay: [Int: Int]) -> (pain: [Int], adherence: [Int]) {
        let grouped = Dictionary(grouping: rows, by: { $0.progress_date ?? "" })
        var painSeries: [Int] = []
        var adherenceSeries: [Int] = []
        for dayIndex in 0..<totalDays {
            let dateString = dateString(from: startDate, dayOffset: dayIndex)
            let dayRows = grouped[dateString] ?? []
            let pains = dayRows.compactMap { $0.pain_level }
            let painAvg = pains.isEmpty ? 0 : Int(Double(pains.reduce(0, +)) / Double(pains.count))
            let expected = expectedByDay[dayIndex] ?? 0
            let completed = dayRows.filter { $0.is_completed == true }.count
            let adherence = expected == 0 ? 0 : min(100, Int((Double(completed) / Double(expected)) * 100.0))
            painSeries.append(painAvg)
            adherenceSeries.append(adherence)
        }
        return (painSeries, adherenceSeries)
    }

    private func buildSessionNotes(rows: [ProgressRow],
                                   startDate: Date,
                                   totalDays: Int,
                                   exerciseInfo: [UUID: ExerciseInfoRow]) -> [SessionNoteRow] {
        let grouped = Dictionary(grouping: rows, by: { $0.progress_date ?? "" })
        var notes: [SessionNoteRow] = []
        for dayIndex in 0..<totalDays {
            let dateString = dateString(from: startDate, dayOffset: dayIndex)
            let dayRows = grouped[dateString] ?? []
            let noteTexts = dayRows.compactMap { row -> String? in
                let trimmed = row.notes?.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed?.isEmpty == false ? trimmed : nil
            }
            let painValues = dayRows.compactMap { $0.pain_level }
            let painAvg = painValues.isEmpty ? nil : Int(Double(painValues.reduce(0, +)) / Double(painValues.count))
            let exercises = Array(Set(dayRows.compactMap { exerciseInfo[$0.exercise_id]?.title })).sorted()
            let durationMinutes = dayRows.reduce(0) { total, row in
                total + ((exerciseInfo[row.exercise_id]?.duration_seconds ?? 0) / 60)
            }
            guard !noteTexts.isEmpty || painAvg != nil else { continue }
            let noteText = noteTexts.joined(separator: "\n")
            let date = parseDate(dateString) ?? Date()
            notes.append(SessionNoteRow(
                date: date,
                painLevel: painAvg,
                durationMinutes: max(1, durationMinutes),
                exercises: exercises,
                notes: noteText
            ))
        }
        return notes.sorted { $0.date > $1.date }
    }

    private func ageString(from dob: String?) -> String? {
        guard let dob else { return nil }
        let trimmed = dob.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let date = parseDate(trimmed) else { return nil }
        let years = Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
        return years > 0 ? "\(years) yrs" : nil
    }

    private func dateString(from date: Date, dayOffset: Int) -> String {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: date)
        let day = calendar.date(byAdding: .day, value: dayOffset, to: base) ?? base
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: day)
    }

    private func parseDate(_ raw: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: raw) { return d }

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        if let d = df.date(from: raw) { return d }

        df.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
        if let d = df.date(from: raw) { return d }

        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: raw)
    }
}

private struct ProgramRow: Decodable {
    let id: UUID
    let title: String
    let is_active: Bool
}

private struct RedemptionRow: Decodable {
    let program_id: UUID
    let customer_id: UUID
    let redeemed_at: String?
}

private struct PatientProgramExerciseRow: Decodable {
    let program_id: UUID
    let exercise_id: UUID
    let sort_order: Int?
}

private struct ExerciseInfoRow: Decodable {
    let id: UUID
    let title: String
    let duration_seconds: Int?
}

private struct ProgressRow: Decodable {
    let exercise_id: UUID
    let progress_date: String?
    let is_completed: Bool?
    let pain_level: Int?
    let notes: String?
    let watched_seconds: Int?
}

private struct CustomerRow: Decodable {
    let id: UUID
    let full_name: String?
    let location: String?
    let date_of_birth: String?
}
