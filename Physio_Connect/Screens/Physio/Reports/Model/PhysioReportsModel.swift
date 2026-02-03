//
//  PhysioReportsModel.swift
//  Physio_Connect
//
//  Created by Codex on 21/01/26.
//

import Foundation
import Supabase

struct PatientReportRow {
    let id: UUID
    let name: String
    let ageText: String
    let location: String
    let programTitles: [String]
    let adherencePercent: Int
}

struct PhysioReportsSnapshot {
    let patients: [PatientReportRow]
    let totalPrograms: Int
    let totalAssignments: Int
}

final class PhysioReportsModel {
    private let client = SupabaseManager.shared.client

    func resolvePhysioID() async throws -> String {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        struct Row: Decodable { let id: UUID }

        let direct: [Row] = try await client
            .from("physiotherapists")
            .select("id")
            .eq("id", value: userID)
            .limit(1)
            .execute()
            .value

        if let match = direct.first {
            return match.id.uuidString
        }

        guard let email = session.user.email?.lowercased() else {
            return userID
        }

        let byEmail: [Row] = try await client
            .from("physiotherapists")
            .select("id")
            .eq("email", value: email)
            .order("updated_at", ascending: false)
            .limit(1)
            .execute()
            .value

        return byEmail.first?.id.uuidString ?? userID
    }

    func fetchReport(physioID: String) async throws -> PhysioReportsSnapshot {
        let programs = try await fetchPrograms(physioID: physioID)
        let programIDs = programs.map(\.id)
        let redemptions = try await fetchRedemptions(programIDs: programIDs)

        let customerIDs = Set(redemptions.map(\.customer_id))
        let customers = try await fetchCustomers(ids: Array(customerIDs))

        let programByID = Dictionary(uniqueKeysWithValues: programs.map { ($0.id, $0.title) })
        let programExerciseCounts = try await fetchProgramExerciseCounts(programIDs: programIDs)
        let progressRows = try await fetchProgressRows(customerIDs: Array(customerIDs), programIDs: programIDs)
        let completedByCustomer = Dictionary(grouping: progressRows.filter { $0.is_completed == true }, by: \.customer_id)

        let patients: [PatientReportRow] = customers.map { customer in
            let programsForPatient = redemptions
                .filter { $0.customer_id == customer.id }
                .compactMap { programByID[$0.program_id] }
            let ageText = ageString(from: customer.date_of_birth) ?? "—"
            let location = Self.firstNonEmpty(
                values: [customer.location],
                fallback: "Location unavailable"
            )
            let assignedProgramIDs = redemptions.filter { $0.customer_id == customer.id }.map(\.program_id)
            let totalExercises = assignedProgramIDs.reduce(0) { $0 + (programExerciseCounts[$1] ?? 0) }
            let completedCount = completedByCustomer[customer.id]?.count ?? 0
            let adherence = totalExercises == 0 ? 0 : min(100, Int(Double(completedCount) / Double(totalExercises) * 100.0))
            return PatientReportRow(
                id: customer.id,
                name: Self.firstNonEmpty(values: [customer.full_name], fallback: "Patient"),
                ageText: ageText,
                location: location,
                programTitles: programsForPatient,
                adherencePercent: adherence
            )
        }

        return PhysioReportsSnapshot(
            patients: patients.sorted { $0.name.lowercased() < $1.name.lowercased() },
            totalPrograms: programs.count,
            totalAssignments: redemptions.count
        )
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

    private func fetchRedemptions(programIDs: [UUID]) async throws -> [RedemptionRow] {
        guard !programIDs.isEmpty else { return [] }
        let rows: [RedemptionRow] = try await client
            .from("program_redemptions")
            .select("program_id,customer_id,redeemed_at")
            .in("program_id", values: programIDs.map { $0.uuidString })
            .execute()
            .value
        return rows
    }

    private func fetchCustomers(ids: [UUID]) async throws -> [CustomerRow] {
        let unique = Array(Set(ids))
        guard !unique.isEmpty else { return [] }
        let rows: [CustomerRow] = try await client
            .from("customers")
            .select("id,full_name,email,phone,location,date_of_birth")
            .in("id", values: unique.map { $0.uuidString })
            .execute()
            .value
        return rows
    }

    private func fetchProgramExerciseCounts(programIDs: [UUID]) async throws -> [UUID: Int] {
        guard !programIDs.isEmpty else { return [:] }
        struct Row: Decodable {
            let program_id: UUID
        }
        let rows: [Row] = try await client
            .from("program_exercises")
            .select("program_id")
            .in("program_id", values: programIDs.map { $0.uuidString })
            .execute()
            .value
        var counts: [UUID: Int] = [:]
        for row in rows {
            counts[row.program_id, default: 0] += 1
        }
        return counts
    }

    private func fetchProgressRows(customerIDs: [UUID], programIDs: [UUID]) async throws -> [ProgressRow] {
        guard !customerIDs.isEmpty, !programIDs.isEmpty else { return [] }
        let rows: [ProgressRow] = try await client
            .from("exercise_progress")
            .select("customer_id,program_id,is_completed")
            .in("customer_id", values: customerIDs.map { $0.uuidString })
            .in("program_id", values: programIDs.map { $0.uuidString })
            .execute()
            .value
        return rows
    }

    private func ageString(from dob: String?) -> String? {
        guard let dob else { return nil }
        let trimmed = dob.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let date = parseDate(trimmed) else { return nil }
        let years = Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
        return years > 0 ? "\(years) yrs" : nil
    }

    private static func firstNonEmpty(values: [String?], fallback: String) -> String {
        for value in values {
            if let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty {
                return trimmed
            }
        }
        return fallback
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

private struct ProgressRow: Decodable {
    let customer_id: UUID
    let program_id: UUID
    let is_completed: Bool?
}

private struct CustomerRow: Decodable {
    let id: UUID
    let full_name: String?
    let email: String?
    let phone: String?
    let location: String?
    let date_of_birth: String?

    enum CodingKeys: String, CodingKey {
        case id
        case full_name
        case email
        case phone
        case location
        case date_of_birth
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        full_name = try container.decodeIfPresent(String.self, forKey: .full_name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        date_of_birth = try container.decodeIfPresent(String.self, forKey: .date_of_birth)
        phone = Self.decodeFlexibleString(from: container, forKey: .phone)
    }

    private static func decodeFlexibleString(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> String? {
        if let value = try? container.decodeIfPresent(String.self, forKey: key) {
            return value
        }
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return String(intValue)
        }
        if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: key) {
            if doubleValue.rounded() == doubleValue {
                return String(Int(doubleValue))
            }
            return String(doubleValue)
        }
        return nil
    }
}
