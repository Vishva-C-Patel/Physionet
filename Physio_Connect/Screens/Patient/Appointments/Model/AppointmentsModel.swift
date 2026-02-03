//
//  AppointmentsModel.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//

import Foundation
import Supabase

final class AppointmentsModel {

    private let client = SupabaseManager.shared.client

    // MARK: - Public API

    /// Returns all upcoming "booked" appointments (future) for current user
    func fetchUpcomingAppointments() async throws -> [UpcomingAppointment] {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let nowISO = formatter.string(from: Date())

        let rows: [AppointmentJoinedRow] = try await client
            .from("appointments")
            .select("""
                id,
                status,
                address_text,
                created_at,
                physio_id,
                slot:physio_availability_slots!appointments_slot_id_fkey(
                    start_time
                ),
                physio:physiotherapists!appointments_physio_id_fkey(
                    id,
                    name,
                    avg_rating,
                    reviews_count,
                    location_text,
                    consultation_fee,
                    profile_image_path,
                    updated_at,
                    physio_specializations(
                        specializations(name)
                    )
                )
            """)
            .eq("customer_id", value: userID)
            .or("status.eq.booked,status.eq.confirmed,status.eq.scheduled")
            .gte("physio_availability_slots.start_time", value: nowISO) // future only (works with embedded)
            .order("start_time", ascending: true, referencedTable: "physio_availability_slots")
            .execute()
            .value
        let upcoming: [UpcomingAppointment] = rows.compactMap { row in
            guard let physio = row.physio else { return nil }
            guard let startTime = row.slot?.start_time, startTime > Date() else { return nil }
            return UpcomingAppointment(
                appointmentID: row.id,
                physioID: physio.id,
                physioName: physio.name,
                startTime: startTime,
                address: row.address_text ?? "",
                specialization: physio.primarySpecialization ?? "Healthcare Professional",
                profileImagePath: physio.profile_image_path,
                profileImageVersion: physio.updated_at,
                rating: physio.avg_rating,
                reviewsCount: physio.reviews_count,
                locationText: physio.location_text,
                fee: physio.consultation_fee
            )
        }

        return upcoming
    }

    func cancelAppointment(appointmentID: UUID) async throws {
        _ = try await client
            .from("appointments")
            .update(["status": "cancelled"])
            .eq("id", value: appointmentID.uuidString)
            .execute()
    }

    func submitReview(
        appointmentID: UUID,
        physioID: UUID,
        rating: Int,
        reviewText: String?
    ) async throws {
        let clamped = max(1, min(5, rating))
        let session = try await client.auth.session
        let userID = session.user.id
        let reviewerName = try await resolveReviewerName(userID: userID, fallbackEmail: session.user.email)

        struct ReviewInsertPayload: Encodable {
            let physio_id: UUID
            let reviewer_name: String
            let rating: Int
            let review_text: String?
        }

        let trimmedReview = reviewText?.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = ReviewInsertPayload(
            physio_id: physioID,
            reviewer_name: reviewerName,
            rating: clamped,
            review_text: (trimmedReview?.isEmpty == false) ? trimmedReview : nil
        )

        _ = try await client
            .from("physio_reviews")
            .insert(payload)
            .execute()

        try await refreshPhysioRatingStats(physioID: physioID)

        // Keep appointment status completed after review write.
        _ = try await client
            .from("appointments")
            .update(["status": "completed"])
            .eq("id", value: appointmentID.uuidString)
            .execute()
    }

    /// Returns past appointments for current user: completed + cancelled
    func fetchPastAppointments() async throws -> [PastAppointment] {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        // We'll do 2 queries (super safe with your current codebase),
        // then merge + sort desc by time.
        async let completedRows: [AppointmentJoinedRow] = client
            .from("appointments")
            .select(joinSelect)
            .eq("customer_id", value: userID)
            .eq("status", value: "completed")
            .order("start_time", ascending: true, referencedTable: "physio_availability_slots")

            .execute()
            .value

        async let cancelledRows: [AppointmentJoinedRow] = client
            .from("appointments")
            .select(joinSelect)
            .eq("customer_id", value: userID)
            .in("status", values: ["cancelled", "cancelled_by_physio"])
            .order("start_time", ascending: true, referencedTable: "physio_availability_slots")

            .execute()
            .value

        let completed = try await completedRows
        let cancelled = try await cancelledRows
        let merged = completed + cancelled

        // map -> view models
        let mapped: [PastAppointment] = merged.compactMap { row in
            guard let physio = row.physio else { return nil }
            let startTime = row.slot?.start_time ?? row.created_at
            return PastAppointment(
                appointmentID: row.id,
                physioID: physio.id,
                physioName: physio.name,
                status: row.status, // "completed" | "cancelled"
                startTime: startTime,
                specialization: physio.primarySpecialization ?? "Healthcare Professional",
                profileImagePath: physio.profile_image_path,
                profileImageVersion: physio.updated_at,
                rating: physio.avg_rating,
                reviewsCount: physio.reviews_count,
                locationText: physio.location_text,
                fee: physio.consultation_fee
            )
        }

        return mapped.sorted { $0.startTime > $1.startTime }
    }

    // MARK: - Private

    private var joinSelect: String {
        """
        id,
        status,
        address_text,
        created_at,
        physio_id,
        slot:physio_availability_slots!appointments_slot_id_fkey(
            start_time
        ),
        physio:physiotherapists!appointments_physio_id_fkey(
            id,
            name,
            avg_rating,
            reviews_count,
            location_text,
            consultation_fee,
            profile_image_path,
            updated_at,
            physio_specializations(
                specializations(name)
            )
        )
        """
    }

    private func resolveReviewerName(userID: UUID, fallbackEmail: String?) async throws -> String {
        struct CustomerNameRow: Decodable {
            let full_name: String?
        }
        let rows: [CustomerNameRow] = try await client
            .from("customers")
            .select("full_name")
            .eq("id", value: userID.uuidString)
            .limit(1)
            .execute()
            .value

        if let fullName = rows.first?.full_name?.trimmingCharacters(in: .whitespacesAndNewlines),
           !fullName.isEmpty {
            return fullName
        }
        if let email = fallbackEmail?.trimmingCharacters(in: .whitespacesAndNewlines),
           !email.isEmpty {
            return email.components(separatedBy: "@").first ?? "User"
        }
        return "User"
    }

    private func refreshPhysioRatingStats(physioID: UUID) async throws {
        struct RatingOnlyRow: Decodable {
            let rating: Double
        }
        struct PhysioRatingUpdatePayload: Encodable {
            let avg_rating: Double
            let reviews_count: Int
        }
        let rows: [RatingOnlyRow] = try await client
            .from("physio_reviews")
            .select("rating")
            .eq("physio_id", value: physioID.uuidString)
            .execute()
            .value

        let count = rows.count
        let avg = count > 0 ? (rows.reduce(0.0) { $0 + $1.rating } / Double(count)) : 0

        let payload = PhysioRatingUpdatePayload(avg_rating: avg, reviews_count: count)
        _ = try await client
            .from("physiotherapists")
            .update(payload)
            .eq("id", value: physioID.uuidString)
            .execute()
    }
}

// MARK: - DTOs (Supabase decode)

private struct AppointmentJoinedRow: Decodable {
    let id: UUID
    let status: String
    let address_text: String?
    let created_at: Date
    let physio_id: UUID

    let slot: SlotRow?
    let physio: PhysioRow?

    struct SlotRow: Decodable {
        let start_time: Date
    }

    struct PhysioRow: Decodable {
        let id: UUID
        let name: String
        let avg_rating: Double?
        let reviews_count: Int?
        let location_text: String?
        let consultation_fee: Double?
        let profile_image_path: String?
        let updated_at: String?

        let physio_specializations: [SpecJoin]?

        struct SpecJoin: Decodable {
            let specializations: Spec?
            struct Spec: Decodable { let name: String }
        }

        var primarySpecialization: String? {
            physio_specializations?.first?.specializations?.name
        }
    }
}

// MARK: - Clean models for VC

struct UpcomingAppointment {
    let appointmentID: UUID
    let physioID: UUID
    let physioName: String
    let startTime: Date
    let address: String
    let specialization: String
    let profileImagePath: String?
    let profileImageVersion: String?

    let rating: Double?
    let reviewsCount: Int?
    let locationText: String?
    let fee: Double?
}

struct PastAppointment {
    let appointmentID: UUID
    let physioID: UUID
    let physioName: String
    let status: String          // "completed" | "cancelled"
    let startTime: Date
    let specialization: String
    let profileImagePath: String?
    let profileImageVersion: String?

    let rating: Double?
    let reviewsCount: Int?
    let locationText: String?
    let fee: Double?
}
