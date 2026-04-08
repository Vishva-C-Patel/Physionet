//
//  PhysioProfileModel.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
//

import Foundation
import Supabase

struct PhysioProfileModel {
    private let client = SupabaseManager.shared.client
    private let avatarBuckets = ["physiotherapists", "physio_proofs"]
    private static let avatarURLDefaultsKey = "physio_avatar_url"

    struct EditProfileData {
        let name: String
        let gender: String
        let address: String
        let placeOfWork: String
        let phone: String
        let dateOfBirth: String
        let about: String
        let yearsExperience: String
        let consultationFee: String
        let latitude: String
        let longitude: String
        let profileImagePath: String
    }

    struct UpdateInput {
        let name: String
        let gender: String
        let location: String
        let placeOfWork: String
        let phone: String
        let dateOfBirth: String
        let about: String
        let yearsExperience: String
        let consultationFee: String
        let latitude: String
        let longitude: String
        let profileImagePath: String
    }

    static func cachedAvatarURL() -> String? {
        UserDefaults.standard.string(forKey: avatarURLDefaultsKey)
    }

    private static func cacheAvatarURL(_ url: String?) {
        let trimmed = url?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmed, !trimmed.isEmpty {
            UserDefaults.standard.set(trimmed, forKey: avatarURLDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: avatarURLDefaultsKey)
        }
    }

    func fetchProfile() async throws -> ProfileViewData {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        struct Row: Decodable {
            let id: UUID
            let name: String?
            let email: String?
            let gender: String?
            let location_text: String?
            let place_of_work: String?
            let consultation_fee: Double?
            let phone: String?
            let date_of_birth: String?
            let profile_image_path: String?
            let about: String?
            let years_experience: Int?
        }

        let rows: [Row] = try await client
            .from("physiotherapists")
            .select("id,name,email,gender,location_text,place_of_work,consultation_fee,phone,date_of_birth,profile_image_path,about,years_experience")
            .eq("id", value: userID)
            .limit(1)
            .execute()
            .value

        let row = rows.first
        let yearsText: String = {
            guard let value = row?.years_experience else { return "—" }
            return "\(value)"
        }()
        let aboutText = row?.about?.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneText = row?.phone?.trimmingCharacters(in: .whitespacesAndNewlines)
        let placeText = row?.place_of_work?.trimmingCharacters(in: .whitespacesAndNewlines)
        let imagePath = row?.profile_image_path?.trimmingCharacters(in: .whitespacesAndNewlines)
        let feeText: String = {
            guard let fee = row?.consultation_fee else { return "—" }
            let rounded = Int(fee.rounded())
            if abs(fee - Double(rounded)) < 0.001 {
                return "₹\(rounded)/hr"
            }
            return String(format: "₹%.2f/hr", fee)
        }()
        let data = ProfileViewData(
            name: row?.name ?? "Physiotherapist",
            email: row?.email ?? (session.user.email ?? "—"),
            phone: phoneText?.isEmpty == false ? phoneText! : "—",
            placeOfWork: placeText?.isEmpty == false ? placeText! : "—",
            consultationFee: feeText,
            address: row?.location_text ?? "—",
            gender: row?.gender ?? "—",
            dateOfBirth: row?.date_of_birth ?? "—",
            healthIdentifier: "—",
            location: "—",
            about: aboutText?.isEmpty == false ? aboutText! : "—",
            yearsExperience: yearsText,
            notificationsEnabled: true,
            avatarURL: imagePath?.isEmpty == false ? imagePath : nil
        )
        Self.cacheAvatarURL(data.avatarURL)
        return data
    }

    func fetchEditProfile() async throws -> EditProfileData {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        struct Row: Decodable {
            let name: String?
            let gender: String?
            let location_text: String?
            let place_of_work: String?
            let phone: String?
            let date_of_birth: String?
            let about: String?
            let years_experience: Int?
            let consultation_fee: Double?
            let latitude: Double?
            let longitude: Double?
            let profile_image_path: String?
        }

        let rows: [Row] = try await client
            .from("physiotherapists")
            .select("""
                name,
                gender,
                location_text,
                place_of_work,
                phone,
                date_of_birth,
                about,
                years_experience,
                consultation_fee,
                latitude,
                longitude,
                profile_image_path
            """)
            .eq("id", value: userID)
            .limit(1)
            .execute()
            .value

        let row = rows.first
        return EditProfileData(
            name: row?.name ?? "",
            gender: row?.gender ?? "",
            address: row?.location_text ?? "",
            placeOfWork: row?.place_of_work ?? "",
            phone: row?.phone ?? "",
            dateOfBirth: row?.date_of_birth ?? "",
            about: row?.about ?? "",
            yearsExperience: row?.years_experience.map { String($0) } ?? "",
            consultationFee: row?.consultation_fee.map { String(format: "%.2f", $0) } ?? "",
            latitude: row?.latitude.map { String($0) } ?? "",
            longitude: row?.longitude.map { String($0) } ?? "",
            profileImagePath: row?.profile_image_path ?? ""
        )
    }

    func updateProfile(_ input: UpdateInput) async throws {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        struct Payload: Encodable {
            let id: UUID
            let name: String?
            let email: String?
            let gender: String?
            let location_text: String?
            let place_of_work: String?
            let phone: String?
            let date_of_birth: String?
            let about: String?
            let years_experience: Int?
            let consultation_fee: Double?
            let latitude: Double?
            let longitude: Double?
            let profile_image_path: String?
            let updated_at: String
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let payload = Payload(
            id: UUID(uuidString: userID) ?? UUID(),
            name: input.name.trimmedOrNil,
            email: session.user.email,
            gender: input.gender.trimmedOrNil?.lowercased(),
            location_text: input.location.trimmedOrNil,
            place_of_work: input.placeOfWork.trimmedOrNil,
            phone: input.phone.trimmedOrNil,
            date_of_birth: input.dateOfBirth.trimmedOrNil,
            about: input.about.trimmedOrNil,
            years_experience: input.yearsExperience.intOrNil,
            consultation_fee: input.consultationFee.doubleOrNil,
            latitude: input.latitude.doubleOrNil,
            longitude: input.longitude.doubleOrNil,
            profile_image_path: input.profileImagePath.trimmedOrNil,
            updated_at: formatter.string(from: Date())
        )

        _ = try await client
            .from("physiotherapists")
            .upsert(payload, onConflict: "id")
            .execute()
    }

    func uploadAvatarImage(_ imageData: Data) async throws {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString
        let filename = "avatar_\(UUID().uuidString).jpg"
        let candidatePaths = [
            "physios/\(userID)/\(filename)",
            "customers/\(userID)/\(filename)"
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
        _ = try await client
            .from("physiotherapists")
            .update(["profile_image_path": publicURL])
            .eq("id", value: userID)
            .execute()

        if let session = try? await client.auth.session {
            var metadata = session.user.userMetadata
            metadata["avatar_url"] = .string(publicURL)
            _ = try? await client.auth.update(user: UserAttributes(data: metadata))
        }
        Self.cacheAvatarURL(publicURL)
    }
}

private extension String {
    var trimmedOrNil: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var intOrNil: Int? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(trimmed)
    }

    var doubleOrNil: Double? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(trimmed)
    }
}
