//
//  ProfileModel.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import Foundation
import Supabase

struct CustomerProfileRow: Decodable {
    let id: UUID
    let full_name: String?
    let email: String?
    let phone: String?
    let address: String?
    let gender: String?
    let date_of_birth: String?
    let health_identifier: String?
    let medical_condition: String?
    let location: String?
    let notifications_enabled: Bool?
    let avatar_url: String?
}

struct ProfileViewData {
    let name: String
    let email: String
    let phone: String
    let address: String
    let gender: String
    let dateOfBirth: String
    let healthIdentifier: String
    let location: String
    let about: String
    let yearsExperience: String
    let notificationsEnabled: Bool
    let avatarURL: String?

    static func from(row: CustomerProfileRow?, emailFallback: String) -> ProfileViewData {
        let rawName = row?.full_name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = (rawName?.isEmpty == false) ? rawName! : "User"

        let email = (row?.email?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ? row!.email!
        : emailFallback

        let phone = row?.phone?.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = row?.address?.trimmingCharacters(in: .whitespacesAndNewlines)
        let gender = row?.gender?.trimmingCharacters(in: .whitespacesAndNewlines)
        let dob = row?.date_of_birth?.trimmingCharacters(in: .whitespacesAndNewlines)
        let health = row?.health_identifier?.trimmingCharacters(in: .whitespacesAndNewlines)
        ?? row?.medical_condition?.trimmingCharacters(in: .whitespacesAndNewlines)
        let location = row?.location?.trimmingCharacters(in: .whitespacesAndNewlines)

        return ProfileViewData(
            name: name,
            email: email.isEmpty ? "—" : email,
            phone: phone?.isEmpty == false ? phone! : "—",
            address: address?.isEmpty == false ? address! : "—",
            gender: gender?.isEmpty == false ? gender! : "—",
            dateOfBirth: dob?.isEmpty == false ? dob! : "—",
            healthIdentifier: health?.isEmpty == false ? health! : "—",
            location: location?.isEmpty == false ? location! : (address?.isEmpty == false ? address! : "—"),
            about: "—",
            yearsExperience: "—",
            notificationsEnabled: row?.notifications_enabled ?? true,
            avatarURL: row?.avatar_url
        )
    }
}

final class ProfileModel {
    private let client = SupabaseManager.shared.client

    func hasActiveSession() async -> Bool {
        (try? await client.auth.session) != nil
    }

    func fetchCurrentProfile() async throws -> ProfileViewData {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString
        let emailFallback = session.user.email ?? "—"

        var row: CustomerProfileRow?
        do {
            let rows: [CustomerProfileRow] = try await client
                .from("customers")
                .select("*")
                .eq("id", value: userID)
                .limit(1)
                .execute()
                .value
            row = rows.first
        } catch {
            print("❌ Profile fetch error:", error)
        }

        return ProfileViewData.from(row: row, emailFallback: emailFallback)
    }

    func updateNotifications(enabled: Bool) async {
        do {
            let session = try await client.auth.session
            let userID = session.user.id.uuidString
            _ = try await client
                .from("customers")
                .update(["notifications_enabled": enabled])
                .eq("id", value: userID)
                .execute()
        } catch {
            print("❌ Notification update error:", error)
        }
    }

    struct ProfileUpdateInput {
        let name: String
        let phone: String
        let gender: String
        let dateOfBirth: String
        let location: String
    }

    func updateProfile(_ input: ProfileUpdateInput) async throws {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        struct UpdatePayload: Encodable {
            let full_name: String?
            let phone: String?
            let gender: String?
            let date_of_birth: String?
            let location: String?
        }

        let payload = UpdatePayload(
            full_name: input.name.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            phone: input.phone.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            gender: input.gender.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            date_of_birth: input.dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            location: input.location.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )

        _ = try await client
            .from("customers")
            .update(payload)
            .eq("id", value: userID)
            .execute()
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
