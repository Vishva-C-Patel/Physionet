//
//  PhysioProgramsModel.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import Foundation
import Supabase

struct PhysioProgramRow: Decodable {
    let id: UUID
    let physio_id: UUID
    let title: String
    let description: String?
    let is_active: Bool
    let created_at: String
}

struct ProgramExerciseRow: Decodable {
    let program_id: UUID
    let exercise_id: UUID
    let sort_order: Int?
}

struct ProgramRedemptionRow: Decodable {
    let program_id: UUID
    let customer_id: UUID
}

struct ProgramAccessCodeRow: Decodable {
    let id: UUID
    let program_id: UUID
    let physio_id: UUID
    let code: String
    let max_redemptions: Int?
    let expires_at: String?
    let is_active: Bool
    let created_at: String
}

struct ProgramAccessCodeResult {
    let id: UUID
    let code: String
}

struct ProgramsCustomerRow: Decodable {
    let id: UUID
    let full_name: String
    let email: String?
    let phone: String?
    let location: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        full_name = try container.decode(String.self, forKey: .full_name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        location = try container.decodeIfPresent(String.self, forKey: .location)

        if let phoneString = try container.decodeIfPresent(String.self, forKey: .phone) {
            phone = phoneString
        } else if let phoneInt = try container.decodeIfPresent(Int.self, forKey: .phone) {
            phone = String(phoneInt)
        } else {
            phone = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case full_name
        case email
        case phone
        case location
    }
}

struct ProgramMeta {
    let durationDays: Int?
    let exercisesPerDay: Int?
    let cleanedDescription: String
}

final class PhysioProgramsModel {
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

    func fetchPrograms(physioID: String) async throws -> [PhysioProgramRow] {
        let rows: [PhysioProgramRow] = try await client
            .from("physio_programs")
            .select("*")
            .eq("physio_id", value: physioID)
            .order("created_at", ascending: false)
            .execute()
            .value
        return rows
    }

    func fetchProgramExercises(programIDs: [UUID]) async throws -> [ProgramExerciseRow] {
        guard !programIDs.isEmpty else { return [] }
        let rows: [ProgramExerciseRow] = try await client
            .from("program_exercises")
            .select("program_id, exercise_id, sort_order")
            .in("program_id", values: programIDs.map { $0.uuidString })
            .execute()
            .value
        return rows
    }

    func fetchRedemptions(programIDs: [UUID]) async throws -> [ProgramRedemptionRow] {
        guard !programIDs.isEmpty else { return [] }
        let rows: [ProgramRedemptionRow] = try await client
            .from("program_redemptions")
            .select("program_id, customer_id")
            .in("program_id", values: programIDs.map { $0.uuidString })
            .execute()
            .value
        return rows
    }

    func fetchCustomers(ids: [UUID]) async throws -> [ProgramsCustomerRow] {
        guard !ids.isEmpty else { return [] }
        let rows: [ProgramsCustomerRow] = try await client
            .from("customers")
            .select("id, full_name, email, phone, location")
            .in("id", values: ids.map { $0.uuidString })
            .execute()
            .value
        return rows
    }

    func fetchPatientsForPhysio(physioID: String) async throws -> [ProgramsCustomerRow] {
        struct ApptRow: Decodable { let customer_id: UUID }

        let apptRows: [ApptRow] = try await client
            .from("appointments")
            .select("customer_id")
            .eq("physio_id", value: physioID)
            .execute()
            .value

        let uniqueIDs = Set(apptRows.map(\.customer_id))
        if uniqueIDs.isEmpty {
            let rows: [ProgramsCustomerRow] = try await client
                .from("customers")
                .select("id, full_name, email, phone, location")
                .order("created_at", ascending: false)
                .execute()
                .value
            return rows
        }
        return try await fetchCustomers(ids: Array(uniqueIDs))
    }

    func fetchProgramCodes(programIDs: [UUID]) async throws -> [ProgramAccessCodeRow] {
        guard !programIDs.isEmpty else { return [] }
        let rows: [ProgramAccessCodeRow] = try await client
            .from("program_access_codes")
            .select("id, program_id, physio_id, code, max_redemptions, expires_at, is_active, created_at")
            .in("program_id", values: programIDs.map { $0.uuidString })
            .execute()
            .value
        return rows
    }

    func fetchExercises() async throws -> [ExerciseVideoRow] {
        let rows: [ExerciseVideoRow] = try await client
            .from("physio_videos")
            .select("*")
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value
        return rows
    }

    func createProgram(physioID: String,
                       title: String,
                       durationDays: Int?,
                       exercisesPerDay: Int?) async throws -> UUID {
        let description = encodeDescription(durationDays: durationDays,
                                            exercisesPerDay: exercisesPerDay,
                                            description: nil)
        struct Payload: Encodable {
            let physio_id: String
            let title: String
            let description: String?
            let is_active: Bool
        }
        let payload = Payload(
            physio_id: physioID,
            title: title,
            description: description,
            is_active: true
        )

        struct Result: Decodable { let id: UUID }
        let result: Result = try await client
            .from("physio_programs")
            .insert(payload)
            .select("id")
            .single()
            .execute()
            .value
        return result.id
    }

    func addExercises(programID: UUID, orderedExerciseIDs: [UUID]) async throws {
        guard !orderedExerciseIDs.isEmpty else { return }
        struct Payload: Encodable {
            let program_id: UUID
            let exercise_id: UUID
            let sort_order: Int
        }
        let rows = orderedExerciseIDs.enumerated().map { index, id in
            Payload(program_id: programID, exercise_id: id, sort_order: index + 1)
        }
        _ = try await client
            .from("program_exercises")
            .insert(rows)
            .execute()
    }

    func createAccessCode(programID: UUID,
                          physioID: String,
                          maxRedemptions: Int) async throws -> ProgramAccessCodeResult {
        let code = generateCode(prefix: "PROG")
        struct Payload: Encodable {
            let program_id: UUID
            let physio_id: String
            let code: String
            let max_redemptions: Int
            let is_active: Bool
        }
        let payload = Payload(
            program_id: programID,
            physio_id: physioID,
            code: code,
            max_redemptions: maxRedemptions,
            is_active: true
        )
        struct Result: Decodable { let id: UUID }
        let result: Result = try await client
            .from("program_access_codes")
            .insert(payload)
            .select("id")
            .single()
            .execute()
            .value
        return ProgramAccessCodeResult(id: result.id, code: code)
    }

    func createRedemptions(programID: UUID, codeID: UUID, customerIDs: [UUID]) async throws {
        guard !customerIDs.isEmpty else { return }
        let redeemedAt = ISO8601DateFormatter().string(from: Date())
        struct Payload: Encodable {
            let customer_id: UUID
            let program_id: UUID
            let code_id: UUID
            let redeemed_at: String?
        }
        let rows = customerIDs.map { id in
            Payload(customer_id: id, program_id: programID, code_id: codeID, redeemed_at: redeemedAt)
        }
        _ = try await client
            .from("program_redemptions")
            .insert(rows)
            .execute()
    }

    func deleteProgram(programID: UUID) async throws {
        _ = try await client
            .from("program_exercises")
            .delete()
            .eq("program_id", value: programID.uuidString)
            .execute()

        _ = try await client
            .from("program_redemptions")
            .delete()
            .eq("program_id", value: programID.uuidString)
            .execute()

        _ = try await client
            .from("program_access_codes")
            .delete()
            .eq("program_id", value: programID.uuidString)
            .execute()

        _ = try await client
            .from("exercise_progress")
            .delete()
            .eq("program_id", value: programID.uuidString)
            .execute()

        _ = try await client
            .from("physio_programs")
            .delete()
            .eq("id", value: programID.uuidString)
            .execute()
    }

    func parseDescription(_ description: String?) -> ProgramMeta {
        let raw = description ?? ""
        let pattern = #"DurationDays=(\d+);ExercisesPerDay=(\d+);"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: raw, options: [], range: NSRange(location: 0, length: raw.count))
        else {
            return ProgramMeta(durationDays: nil, exercisesPerDay: nil, cleanedDescription: raw)
        }

        func int(from rangeIndex: Int) -> Int? {
            let range = match.range(at: rangeIndex)
            guard let swiftRange = Range(range, in: raw) else { return nil }
            return Int(raw[swiftRange])
        }

        let duration = int(from: 1)
        let perDay = int(from: 2)
        let cleaned = raw.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return ProgramMeta(durationDays: duration, exercisesPerDay: perDay, cleanedDescription: cleaned)
    }

    private func encodeDescription(durationDays: Int?,
                                   exercisesPerDay: Int?,
                                   description: String?) -> String? {
        guard let durationDays, let exercisesPerDay else { return description }
        let meta = "DurationDays=\(durationDays);ExercisesPerDay=\(exercisesPerDay);"
        let body = description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return meta + body
    }

    private func generateCode(prefix: String) -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let chunk = String((0..<6).compactMap { _ in letters.randomElement() })
        return "\(prefix)-\(chunk)"
    }
}
