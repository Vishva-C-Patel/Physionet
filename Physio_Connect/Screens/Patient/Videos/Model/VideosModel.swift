//
//  VideosModel.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import Foundation
import Supabase

struct ExerciseVideoRow: Decodable {
    let id: UUID
    let physio_id: UUID?
    let video_path: String
    let title: String
    let description: String?
    let duration_seconds: Int?
    let thumbnail_path: String?
    let target_area: String?
    let purpose: String?
    let difficulty: String?
    let is_free: Bool
    let is_active: Bool
    let access_type: String?
}

struct MyProgramExerciseRow: Decodable {
    let program_exercise_id: UUID
    let exercise_id: UUID
    let title: String
    let target_area: String?
    let purpose: String?
    let description: String?
    let duration_seconds: Int?
    let difficulty: String?
    let thumbnail_path: String?
    let video_path: String
    let sets: Int?
    let reps: Int?
    let hold_seconds: Int?
    let notes: String?
    let sort_order: Int?
    let program_id: UUID
    let program_title: String
}

struct ExerciseProgressUpsert: Encodable {
    let customer_id: UUID
    let exercise_id: UUID
    let program_id: UUID?
    let progress_date: String
    let is_completed: Bool
    let watched_seconds: Int
    let pain_level: Int?
    let notes: String?
}

struct ExerciseProgressRow: Decodable {
    let exercise_id: UUID
    let program_id: UUID?
    let progress_date: String?
    let is_completed: Bool?
    let watched_seconds: Int?
    let pain_level: Int?
    let notes: String?
 }

private struct VideoProgramRedemptionRow: Decodable {
    let program_id: UUID
    let code_id: UUID?
    let redeemed_at: String?
}

private struct ProgramProgressLookupRow: Decodable {
    let program_id: UUID?
    let progress_date: String?
}

private struct ProgramAccessCodeLookupRow: Decodable {
    let id: UUID
    let program_id: UUID
    let is_active: Bool
}

private struct ProgramTitleRow: Decodable {
    let title: String
}

private struct ProgramExerciseJoinedRow: Decodable {
    let program_exercise_id: UUID
    let program_id: UUID
    let sort_order: Int?
    let sets: Int?
    let reps: Int?
    let hold_seconds: Int?
    let notes: String?
    let physio_videos: ExerciseVideoRow
    let physio_programs: ProgramTitleRow
}

final class VideosModel {
    private let client = SupabaseManager.shared.client

    private let videoBucket = "exercise_videos"
    private let thumbnailBucket = "exercise_thumbnails"

    func fetchFreeExercises(search: String?) async throws -> [ExerciseVideoRow] {
        var query = client
            .from("physio_videos")
            .select("*")
            .eq("is_free", value: true)
            .eq("is_active", value: true)

        if let search = search?.trimmingCharacters(in: .whitespacesAndNewlines), !search.isEmpty {
            query = query.ilike("title", pattern: "%\(search)%")
        }

        let rows: [ExerciseVideoRow] = try await query
            .order("created_at", ascending: false)
            .execute()
            .value
        return rows
    }

    func fetchMyProgramExercises(preferredProgramID: UUID? = nil) async throws -> [MyProgramExerciseRow] {
        let session = try await client.auth.session
        let customerID = session.user.id.uuidString

        let redemptionRows: [VideoProgramRedemptionRow] = try await client
            .from("program_redemptions")
            .select("program_id, code_id, redeemed_at")
            .eq("customer_id", value: customerID)
            .execute()
            .value

        let redeemedProgramIDs = redemptionRows.map(\.program_id)

        guard !redeemedProgramIDs.isEmpty else { return [] }

        let progressRows: [ProgramProgressLookupRow] = try await client
            .from("exercise_progress")
            .select("program_id, progress_date")
            .eq("customer_id", value: customerID)
            .in("program_id", values: redeemedProgramIDs.map { $0.uuidString })
            .order("progress_date", ascending: false)
            .limit(200)
            .execute()
            .value

        let rows: [ProgramExerciseJoinedRow] = try await client
            .from("program_exercises")
            .select("""
                program_exercise_id:id,
                program_id,
                sort_order,
                sets,
                reps,
                hold_seconds,
                notes,
                physio_videos (
                    id,
                    physio_id,
                    video_path,
                    title,
                    description,
                    duration_seconds,
                    thumbnail_path,
                    target_area,
                    purpose,
                    difficulty,
                    is_free,
                    is_active,
                    access_type
                ),
                physio_programs (
                    title
                )
            """)
            .in("program_id", values: redeemedProgramIDs.map { $0.uuidString })
            .order("sort_order", ascending: true)
            .execute()
            .value

        let grouped = Dictionary(grouping: rows, by: \.program_id)
        guard !grouped.isEmpty else { return [] }

        let activeFromProgress = progressRows
            .compactMap { row -> (UUID, String)? in
                guard let pid = row.program_id, let date = row.progress_date else { return nil }
                return (pid, date)
            }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
            .first { grouped[$0] != nil }

        let activeFromRedemption: UUID? = redemptionRows
            .max { lhs, rhs in
                let lhsDate = parseBackendTimestamp(lhs.redeemed_at) ?? .distantPast
                let rhsDate = parseBackendTimestamp(rhs.redeemed_at) ?? .distantPast
                return lhsDate < rhsDate
            }?
            .program_id

        let selectedProgramID =
            (preferredProgramID.flatMap { grouped[$0] != nil ? $0 : nil }) ??
            activeFromRedemption ??
            activeFromProgress ??
            grouped.max { lhs, rhs in lhs.value.count < rhs.value.count }?.key

        let selectedRows = selectedProgramID.flatMap { grouped[$0] } ?? []

        return selectedRows.map { row in
            MyProgramExerciseRow(
                program_exercise_id: row.program_exercise_id,
                exercise_id: row.physio_videos.id,
                title: row.physio_videos.title,
                target_area: row.physio_videos.target_area,
                purpose: row.physio_videos.purpose,
                description: row.physio_videos.description,
                duration_seconds: row.physio_videos.duration_seconds,
                difficulty: row.physio_videos.difficulty,
                thumbnail_path: row.physio_videos.thumbnail_path,
                video_path: row.physio_videos.video_path,
                sets: row.sets,
                reps: row.reps,
                hold_seconds: row.hold_seconds,
                notes: row.notes,
                sort_order: row.sort_order,
                program_id: row.program_id,
                program_title: row.physio_programs.title
            )
        }
    }

    func fetchProgramStartDate(programID: UUID) async throws -> Date? {
        let session = try await client.auth.session
        let customerID = session.user.id.uuidString

        struct RedemptionRow: Decodable {
            let redeemed_at: String?
        }

        let rows: [RedemptionRow] = try await client
            .from("program_redemptions")
            .select("redeemed_at")
            .eq("customer_id", value: customerID)
            .eq("program_id", value: programID.uuidString)
            .order("redeemed_at", ascending: true)
            .limit(1)
            .execute()
            .value

        guard let redeemedAt = rows.first?.redeemed_at else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: redeemedAt)
    }

    func redeemProgram(code: String) async throws -> UUID {
        let session = try await client.auth.session
        let customerID = session.user.id.uuidString

        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { throw NSError(domain: "redeem", code: 1) }

        let codeRows: [ProgramAccessCodeLookupRow] = try await client
            .from("program_access_codes")
            .select("id, program_id, is_active")
            .eq("code", value: trimmed)
            .limit(1)
            .execute()
            .value

        guard let codeRow = codeRows.first, codeRow.is_active else {
            throw NSError(domain: "redeem", code: 2)
        }

        let redemptionRows: [VideoProgramRedemptionRow] = try await client
            .from("program_redemptions")
            .select("program_id, code_id, redeemed_at")
            .eq("customer_id", value: customerID)
            .eq("code_id", value: codeRow.id.uuidString)
            .limit(1)
            .execute()
            .value

        let redemption: VideoProgramRedemptionRow
        if let existing = redemptionRows.first {
            redemption = existing
        } else {
            struct RedemptionInsert: Encodable {
                let customer_id: String
                let program_id: String
                let code_id: String
                let redeemed_at: String?
            }

            let payload = RedemptionInsert(
                customer_id: customerID,
                program_id: codeRow.program_id.uuidString,
                code_id: codeRow.id.uuidString,
                redeemed_at: nil
            )

            let inserted: [VideoProgramRedemptionRow] = try await client
                .from("program_redemptions")
                .insert(payload)
                .select("program_id, code_id, redeemed_at")
                .limit(1)
                .execute()
                .value

            guard let created = inserted.first else {
                throw NSError(domain: "redeem", code: 3)
            }
            redemption = created
        }

        if redemption.redeemed_at == nil {
            let now = ISO8601DateFormatter().string(from: Date())
            _ = try await client
                .from("program_redemptions")
                .update(["redeemed_at": now])
                .eq("customer_id", value: customerID)
                .eq("code_id", value: codeRow.id.uuidString)
                .execute()
        }

        return codeRow.program_id
    }

    func signedVideoURL(path: String) async throws -> URL {
        return try await signedURL(path: path, bucket: videoBucket)
    }

    func signedThumbnailURL(path: String) async throws -> URL {
        return try await signedURL(path: path, bucket: thumbnailBucket)
    }

    private func signedURL(path: String, bucket: String) async throws -> URL {
        let trimmed = path
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !trimmed.isEmpty else { throw URLError(.badURL) }

        if let direct = URL(string: trimmed), direct.scheme?.hasPrefix("http") == true {
            return direct
        }

        var lastError: Error?
        let candidates = candidateKeys(for: trimmed, bucket: bucket)
        for key in candidates {
            do {
                return try await client.storage
                    .from(bucket)
                    .createSignedURL(path: key, expiresIn: 3600)
            } catch {
                lastError = error
                if let publicURL = makePublicURL(bucket: bucket, key: key) {
                    print("ℹ️ Falling back to public URL for bucket \(bucket), key \(key): \(error)")
                    return publicURL
                }
            }
        }
        print("❌ All candidate keys failed for bucket \(bucket) from raw path '\(path)': \(candidates)")
        throw lastError ?? URLError(.fileDoesNotExist)
    }

    private func candidateKeys(for raw: String, bucket: String) -> [String] {
        var cleaned = raw
        if let qIndex = cleaned.firstIndex(of: "?") {
            cleaned = String(cleaned[..<qIndex])
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        var keys: [String] = []
        let publicPrefix = "storage/v1/object/public/\(bucket)/"
        if let range = cleaned.range(of: publicPrefix) {
            keys.append(String(cleaned[range.upperBound...]))
        } else if cleaned.hasPrefix("\(bucket)/") {
            keys.append(String(cleaned.dropFirst(bucket.count + 1)))
        }
        keys.append(cleaned)
        keys.append("\(bucket)/\(cleaned)")

        var seen = Set<String>()
        let unique = keys.filter { key in
            if seen.contains(key) {
                return false
            } else {
                seen.insert(key)
                return true
            }
        }
        return unique
    }

    private func supabaseBaseURL() -> String? {
        if let base = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String {
            return base
        }
        return SupabaseConfig.url
    }

    private func makePublicURL(bucket: String, key: String) -> URL? {
        guard let base = supabaseBaseURL() else { return nil }
        let path = key.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let encodedPath = path
            .split(separator: "/")
            .map { $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0) }
            .joined(separator: "/")
        return URL(string: "\(base)/storage/v1/object/public/\(bucket)/\(encodedPath)")
    }

    func upsertProgress(exerciseID: UUID,
                        programID: UUID?,
                        isCompleted: Bool,
                        watchedSeconds: Int,
                        painLevel: Int?,
                        notes: String?) async throws {
        let session = try await client.auth.session
        let customerID = session.user.id

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from: Date())

        let payload = ExerciseProgressUpsert(
            customer_id: customerID,
            exercise_id: exerciseID,
            program_id: programID,
            progress_date: today,
            is_completed: isCompleted,
            watched_seconds: watchedSeconds,
            pain_level: painLevel,
            notes: notes
        )

        _ = try await client
            .from("exercise_progress")
            .upsert(payload, onConflict: "customer_id,exercise_id,progress_date")
            .execute()
    }

    func fetchProgress(programID: UUID) async throws -> [ExerciseProgressRow] {
        let session = try await client.auth.session
        let customerID = session.user.id.uuidString

        let rows: [ExerciseProgressRow] = try await client
            .from("exercise_progress")
            .select("exercise_id, program_id, progress_date, is_completed, watched_seconds, pain_level, notes")
            .eq("customer_id", value: customerID)
            .eq("program_id", value: programID.uuidString)
            .execute()
            .value
        return rows
    }

    func fetchProgressForExercise(exerciseID: UUID, programID: UUID?) async throws -> ExerciseProgressRow? {
        let session = try await client.auth.session
        let customerID = session.user.id.uuidString

        var query = client
            .from("exercise_progress")
            .select("exercise_id, program_id, progress_date, is_completed, watched_seconds, pain_level, notes")
            .eq("customer_id", value: customerID)
            .eq("exercise_id", value: exerciseID.uuidString)

        if let programID {
            query = query.eq("program_id", value: programID.uuidString)
        }

        let rows: [ExerciseProgressRow] = try await query
            .order("progress_date", ascending: false)
            .limit(1)
            .execute()
            .value
        return rows.first
    }

    private func parseBackendTimestamp(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoPlain = ISO8601DateFormatter()
        isoPlain.formatOptions = [.withInternetDateTime]
        if let date = isoWithFraction.date(from: trimmed) ?? isoPlain.date(from: trimmed) {
            return date
        }

        let sqlFormatter = DateFormatter()
        sqlFormatter.locale = Locale(identifier: "en_US_POSIX")
        sqlFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        sqlFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSXXXXX"
        if let date = sqlFormatter.date(from: trimmed) {
            return date
        }
        sqlFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
        return sqlFormatter.date(from: trimmed)
    }
}
