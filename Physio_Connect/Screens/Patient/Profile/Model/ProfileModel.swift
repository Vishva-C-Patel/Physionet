//
//  ProfileModel.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import Foundation
import Supabase
import UIKit

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
    let placeOfWork: String
    let consultationFee: String
    let address: String
    let gender: String
    let dateOfBirth: String
    let healthIdentifier: String
    let location: String
    let about: String
    let yearsExperience: String
    let notificationsEnabled: Bool
    let avatarURL: String?

    static func from(row: CustomerProfileRow?, emailFallback: String, metadataAvatarURL: String?) -> ProfileViewData {
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
            placeOfWork: "—",
            consultationFee: "—",
            address: address?.isEmpty == false ? address! : "—",
            gender: gender?.isEmpty == false ? gender! : "—",
            dateOfBirth: dob?.isEmpty == false ? dob! : "—",
            healthIdentifier: health?.isEmpty == false ? health! : "—",
            location: location?.isEmpty == false ? location! : (address?.isEmpty == false ? address! : "—"),
            about: "—",
            yearsExperience: "—",
            notificationsEnabled: row?.notifications_enabled ?? true,
            avatarURL: row?.avatar_url ?? metadataAvatarURL
        )
    }
}

final class ProfileModel {
    private let client = SupabaseManager.shared.client
    private let avatarBuckets = ["physiotherapists", "physio_proofs"]
    private static let avatarURLDefaultsKey = "patient_avatar_url"

    static func cachedAvatarURL() -> String? {
        UserDefaults.standard.string(forKey: avatarURLDefaultsKey)
    }

    static func clearCachedAvatarURL() {
        UserDefaults.standard.removeObject(forKey: avatarURLDefaultsKey)
    }

    private static func cacheAvatarURL(_ url: String?) {
        let trimmed = url?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmed, !trimmed.isEmpty {
            UserDefaults.standard.set(trimmed, forKey: avatarURLDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: avatarURLDefaultsKey)
        }
    }

    func hasActiveSession() async -> Bool {
        (try? await client.auth.session) != nil
    }

    func fetchCurrentProfile() async throws -> ProfileViewData {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString
        let emailFallback = session.user.email ?? "—"
        let metadataAvatarURL = session.user.userMetadata["avatar_url"]?.stringValue

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

        let data = ProfileViewData.from(row: row, emailFallback: emailFallback, metadataAvatarURL: metadataAvatarURL)
        Self.cacheAvatarURL(data.avatarURL)
        return data
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

    func uploadAvatarImage(_ imageData: Data) async throws {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString
        let filename = "avatar_\(UUID().uuidString).jpg"
        let candidatePaths = [
            "customers/\(userID)/\(filename)",
            "physios/\(userID)/\(filename)"
        ]

        var resolved: (bucket: String, path: String)?
        var lastError: Error?
        for bucket in avatarBuckets {
            for path in candidatePaths {
                do {
                    _ = try await client.storage
                        .from(bucket)
                        .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg", upsert: false))
                    resolved = (bucket, path)
                    break
                } catch {
                    lastError = error
                }
            }
            if resolved != nil { break }
        }

        guard let resolved else {
            throw lastError ?? NSError(domain: "avatar_upload", code: 1)
        }

        let publicURL = "\(SupabaseConfig.url)/storage/v1/object/public/\(resolved.bucket)/\(resolved.path)"

        do {
            _ = try await client
                .from("customers")
                .update(["avatar_url": publicURL])
                .eq("id", value: userID)
                .execute()
        } catch {
            // Fallback for schemas where customers.avatar_url does not exist.
            var metadata = session.user.userMetadata
            metadata["avatar_url"] = .string(publicURL)
            _ = try await client.auth.update(user: UserAttributes(data: metadata))
        }
        Self.cacheAvatarURL(publicURL)
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
