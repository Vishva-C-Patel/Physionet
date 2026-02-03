//
//  PhysioService.swift
//  Physio_Connect
//
//  Created by user@8 on 29/12/25.

import Foundation
import Supabase
import UIKit

final class PhysioService {
    static let shared = PhysioService()
    private init() {}

    private let client = SupabaseManager.shared.client
    private let avatarBuckets = ["physiotherapists", "physio_proofs"]
    private let avatarLock = NSLock()
    private var signedAvatarURLCache: [String: (url: URL, expiry: Date)] = [:]

    func fetchPhysiotherapists() async throws -> [Physiotherapist] {
        try await client
            .from("physiotherapists")
            .select("""
                id,
                name,
                gender,
                about,
                years_experience,
                place_of_work,
                consultation_fee,
                latitude,
                longitude,
                location_text,
                patients_served,
                avg_rating,
                reviews_count,
                profile_image_path,
                created_at,
                updated_at
            """)
            .execute()
            .value
    }
}

// MARK: - List DTO with specialization join
struct PhysioListRow: Decodable {
    let id: UUID
    let name: String
    let gender: String?
    let consultation_fee: Double?
    let latitude: Double?
    let longitude: Double?
    let avg_rating: Double?
    let reviews_count: Int?
    let years_experience: Int?
    let patients_served: Int?
    let profile_image_path: String?
    let updated_at: String?

    let physio_specializations: [PhysioSpecJoin]?

    struct PhysioSpecJoin: Decodable {
        let specializations: Specialization?
        struct Specialization: Decodable {
            let name: String
        }
    }
}


    
    

extension PhysioService {

    func fetchPhysiotherapist(by id: UUID) async throws -> Physiotherapist {
        let rows: [Physiotherapist] = try await client
            .from("physiotherapists")
            .select("""
                id,
                name,
                gender,
                about,
                years_experience,
                place_of_work,
                consultation_fee,
                latitude,
                longitude,
                location_text,
                patients_served,
                avg_rating,
                reviews_count,
                profile_image_path,
                created_at,
                updated_at
            """)
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value

        guard let first = rows.first else { throw NSError(domain: "PhysioService", code: 404) }
        return first
    }
    
    func fetchPhysiotherapistsForList() async throws -> [PhysioListRow] {
        try await client
            .from("physiotherapists")
            .select("""
                id,
                name,
                gender,
                consultation_fee,
                latitude,
                longitude,
                avg_rating,
                reviews_count,
                years_experience,
                patients_served,
                profile_image_path,
                updated_at,
                physio_specializations(
                    specializations(name)
                )
            """)
            .execute()
            .value
    }

    func fetchAvailablePhysioIDs(at date: Date) async throws -> Set<UUID> {
        struct AvailabilityRow: Decodable { let physio_id: UUID }

        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let value = f.string(from: date)

        let rows: [AvailabilityRow] = try await client
            .from("physio_availability_slots")
            .select("physio_id")
            .eq("is_booked", value: false)
            .lte("start_time", value: value)
            .gt("end_time", value: value)
            .execute()
            .value

        return Set(rows.map(\.physio_id))
    }


    /// physio_specializations -> embedded specializations(name)
    func fetchSpecializationNames(for physioID: UUID) async throws -> [String] {
        let rows: [PhysioSpecializationRow] = try await client
            .from("physio_specializations")
            .select("physio_id, specializations(name)")
            .eq("physio_id", value: physioID.uuidString)
            .execute()
            .value

        return rows.compactMap { $0.specializations?.name }
    }
    

    func fetchReviews(for physioID: UUID, limit: Int = 3) async throws -> [PhysioReviewRow] {
        try await client
            .from("physio_reviews")
            .select("id, physio_id, reviewer_name, rating, review_text, created_at")
            .eq("physio_id", value: physioID.uuidString)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func profileImageURL(pathOrUrl: String, version: String?) -> URL? {
        if let url = URL(string: pathOrUrl), url.scheme?.hasPrefix("http") == true {
            return appendVersion(url, version: version)
        }
        let normalized = normalizeImagePath(pathOrUrl, bucket: "physiotherapists")
        guard let base = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            return nil
        }
        let url = URL(string: "\(base)/storage/v1/object/public/physiotherapists/\(normalized)")
        if let url {
            return appendVersion(url, version: version)
        }
        return nil
    }

    func loadProfileImage(pathOrUrl: String?, version: String?, completion: @escaping (UIImage?) -> Void) {
        guard let raw = pathOrUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            completion(nil)
            return
        }

        if let url = profileImageURL(pathOrUrl: raw, version: version) {
            ImageLoader.shared.load(url) { [weak self] image in
                if image != nil {
                    completion(image)
                    return
                }
                self?.loadSignedProfileImage(raw: raw, completion: completion)
            }
            return
        }

        loadSignedProfileImage(raw: raw, completion: completion)
    }

    private func normalizeImagePath(_ raw: String, bucket: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let publicPrefix = "/storage/v1/object/public/\(bucket)/"
        if let range = trimmed.range(of: publicPrefix) {
            return String(trimmed[range.upperBound...])
        }
        if let range = trimmed.range(of: "\(bucket)/") {
            return String(trimmed[range.upperBound...])
        }
        return trimmed
    }

    private func appendVersion(_ url: URL, version: String?) -> URL? {
        guard let version, !version.isEmpty else { return url }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var items = components?.queryItems ?? []
        items.append(URLQueryItem(name: "v", value: version))
        components?.queryItems = items
        return components?.url ?? url
    }

    private func loadSignedProfileImage(raw: String, completion: @escaping (UIImage?) -> Void) {
        if let cached = cachedSignedURL(for: raw) {
            ImageLoader.shared.load(cached, completion: completion)
            return
        }

        let refs = candidateStorageRefs(from: raw)
        guard !refs.isEmpty else {
            completion(nil)
            return
        }

        Task {
            for ref in refs {
                if let signed = try? await client.storage
                    .from(ref.bucket)
                    .createSignedURL(path: ref.path, expiresIn: 3600) {
                    cacheSignedURL(signed, for: raw)
                    ImageLoader.shared.load(signed, completion: completion)
                    return
                }
            }
            await MainActor.run { completion(nil) }
        }
    }

    private func candidateStorageRefs(from raw: String) -> [(bucket: String, path: String)] {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        if let range = trimmed.range(of: "/storage/v1/object/public/") {
            let tail = String(trimmed[range.upperBound...])
            let parts = tail.split(separator: "/", maxSplits: 1).map(String.init)
            if parts.count == 2 { return [(parts[0], parts[1])] }
        }

        if let range = trimmed.range(of: "/storage/v1/object/sign/") {
            let tail = String(trimmed[range.upperBound...])
            let parts = tail.split(separator: "/", maxSplits: 1).map(String.init)
            if parts.count == 2 { return [(parts[0], parts[1])] }
        }

        let clean = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let parts = clean.split(separator: "/", maxSplits: 1).map(String.init)
        if parts.count == 2, avatarBuckets.contains(parts[0]) {
            return [(parts[0], parts[1])]
        }

        return avatarBuckets.map { ($0, clean) }
    }

    private func cachedSignedURL(for raw: String) -> URL? {
        avatarLock.lock()
        defer { avatarLock.unlock() }
        guard let entry = signedAvatarURLCache[raw], entry.expiry > Date() else {
            signedAvatarURLCache.removeValue(forKey: raw)
            return nil
        }
        return entry.url
    }

    private func cacheSignedURL(_ url: URL, for raw: String) {
        avatarLock.lock()
        signedAvatarURLCache[raw] = (url, Date().addingTimeInterval(55 * 60))
        avatarLock.unlock()
    }
    
    func fetchAvailableSlots(physioID: UUID, forDayContaining date: Date) async throws -> [SlotRow] {
        // Ensure slots exist for the selected day when using templates.
        do {
            try await generateSlotsForDateIfNeeded(physioID: physioID, date: date)
        } catch {
            print("❌ generate_slots_for_range failed:", error)
        }

        // DB is timestamptz → use local day window for user-selected date
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current

        let startOfDay = cal.startOfDay(for: date)
        guard let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }

        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let rows: [SlotRow] = try await client
            .from("physio_availability_slots")
            .select("id, physio_id, start_time, end_time, is_booked")
            .eq("physio_id", value: physioID.uuidString)
            .gte("start_time", value: f.string(from: startOfDay))
            .lt("start_time", value: f.string(from: endOfDay))
            .order("start_time", ascending: true)
            .execute()
            .value

        return rows.filter { !$0.is_booked }
    }

    private func generateSlotsForDateIfNeeded(physioID: UUID, date: Date) async throws {
        let localCal = Calendar.current
        let startOfDay = localCal.startOfDay(for: date)

        let df = DateFormatter()
        df.calendar = localCal
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd"

        let day = df.string(from: startOfDay)
        let tz = TimeZone.current.identifier

        _ = try await client
            .rpc(
                "generate_slots_for_range",
                params: [
                    "p_physio_id": physioID.uuidString,
                    "p_from": day,
                    "p_to": day,
                    "p_tz": tz
                ]
            )
            .execute()
    }
    func fetchUpcomingAvailableSlots(
        physioID: UUID,
        from start: Date = Date(),
        limit: Int = 20
    ) async throws -> [SlotRow] {

        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let rows: [SlotRow] = try await client
            .from("physio_availability_slots")
            .select("id, physio_id, start_time, end_time, is_booked")
            .eq("physio_id", value: physioID.uuidString)
            .gte("start_time", value: f.string(from: start))
            .order("start_time", ascending: true)
            .limit(limit)
            .execute()
            .value

        return rows.filter { !$0.is_booked }
    }

        func createAppointment(_ payload: AppointmentInsertRow) async throws {
            // Make sure your "appointments" columns match AppointmentInsertRow keys
            _ = try await client
                .from("appointments")
                .insert(payload)
                .execute()
        }

        func markSlotBooked(slotID: UUID) async throws {
            _ = try await client
                .from("physio_availability_slots")
                .update(["is_booked": true])
                .eq("id", value: slotID.uuidString)
                .execute()
        }
}
