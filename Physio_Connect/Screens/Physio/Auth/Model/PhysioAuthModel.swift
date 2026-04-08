//
//  PhysioAuthModel.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
//

import Foundation
import Supabase

struct PhysioAuthModel {
    private let client = SupabaseManager.shared.client
    
    struct PhysioAuthError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    struct PhysioSignupInput {
        let name: String
        let email: String
        let phone: String
        let password: String
        let idProofData: Data?
        let idProofFilename: String?
        let licenseProofData: Data?
        let licenseProofFilename: String?
    }

    func login(email: String, password: String) async throws -> User {
        let session = try await client.auth.signIn(email: email, password: password)
        let user = session.user

        // Ensure physiotherapist profile exists; otherwise block login
        struct Row: Decodable { let id: UUID }
        let rows: [Row] = try await client
            .from("physiotherapists")
            .select("id")
            .eq("id", value: user.id.uuidString)
            .limit(1)
            .execute()
            .value

        let customerRows: [Row] = (try? await client
            .from("customers")
            .select("id")
            .eq("id", value: user.id.uuidString)
            .limit(1)
            .execute()
            .value) ?? []

        guard rows.first != nil else {
            // No physio record => sign out and reject login
            try? await client.auth.signOut()
            throw PhysioAuthError(message: "No physiotherapist account found for this email.")
        }

        if customerRows.first != nil {
            try? await client.auth.signOut()
            throw PhysioAuthError(message: "This account is registered as a patient. Please log in on the user side.")
        }

        return user
    }

    func signup(input: PhysioSignupInput) async throws -> User {
        let normalizedEmail = input.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let user = try await resolveSignupUser(email: normalizedEmail, password: input.password)

        var roleState = try await fetchRoleState(for: user.id)
        if roleState.hasCustomer {
            try? await client.auth.signOut()
            throw PhysioAuthError(message: "This account is registered as a patient. Please log in on the user side.")
        }

        // If profile exists and both proofs are already stored, treat as successful recovery.
        if roleState.hasPhysio && roleState.idProofPath != nil && roleState.licenseProofPath != nil {
            let normalizedPhone = normalizedIndianPhone(from: input.phone)
            try await updatePhoneNumber(userID: user.id, phone: normalizedPhone)
            return user
        }

        let proofPaths = try await uploadProofs(
            userID: user.id,
            idProofData: input.idProofData,
            idProofFilename: input.idProofFilename,
            licenseProofData: input.licenseProofData,
            licenseProofFilename: input.licenseProofFilename
        )

        let finalIDProof = proofPaths.idProofPath ?? roleState.idProofPath
        let finalLicenseProof = proofPaths.licenseProofPath ?? roleState.licenseProofPath
        if roleState.hasPhysio {
            try await updateProofPaths(userID: user.id, idProofPath: finalIDProof, licenseProofPath: finalLicenseProof)
            let normalizedPhone = normalizedIndianPhone(from: input.phone)
            try await updatePhoneNumber(userID: user.id, phone: normalizedPhone)
            return user
        }

        do {
            try await createPhysioProfile(
                userID: user.id,
                name: input.name,
                email: normalizedEmail,
                idProofPath: finalIDProof,
                licenseProofPath: finalLicenseProof
            )
        } catch {
            let latest = try? await fetchRoleState(for: user.id)
            if latest?.hasPhysio == true {
                let normalizedPhone = normalizedIndianPhone(from: input.phone)
                try await updatePhoneNumber(userID: user.id, phone: normalizedPhone)
                return user
            }
            throw PhysioAuthError(message: "Profile creation failed. \(error.localizedDescription)")
        }
        let normalizedPhone = normalizedIndianPhone(from: input.phone)
        try await updatePhoneNumber(userID: user.id, phone: normalizedPhone)
        return user
    }

    private func resolveSignupUser(email: String, password: String) async throws -> User {
        var hitAlreadyRegistered = false
        var signedUpWithoutSession = false

        do {
            let signup = try await client.auth.signUp(email: email, password: password)
            if let session = signup.session {
                return session.user
            }
            signedUpWithoutSession = true
        } catch {
            guard isAlreadyRegisteredError(error) else {
                throw error
            }
            hitAlreadyRegistered = true
        }

        // Ensure we have an authenticated session before hitting Storage policies.
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            return session.user
        } catch {
            if (hitAlreadyRegistered || signedUpWithoutSession) && isInvalidLoginCredentialsError(error) {
                throw PhysioAuthError(message: "This email already has an account with a different password. Use the original password or reset it, then continue signup.")
            }
            if isAlreadyRegisteredError(error) {
                throw PhysioAuthError(message: "This email is already registered. Use the original password to continue setup, or reset password.")
            }
            if isEmailNotConfirmedError(error) {
                throw PhysioAuthError(message: "Please verify your email first, then log in and complete onboarding.")
            }
            throw error
        }
    }

    private func isAlreadyRegisteredError(_ error: Error) -> Bool {
        let text = error.localizedDescription.lowercased()
        return text.contains("already registered") || text.contains("user already exists")
    }

    private func isInvalidLoginCredentialsError(_ error: Error) -> Bool {
        error.localizedDescription.lowercased().contains("invalid login credentials")
    }

    private func isEmailNotConfirmedError(_ error: Error) -> Bool {
        let text = error.localizedDescription.lowercased()
        return text.contains("email not confirmed") || text.contains("confirm your email")
    }

    private func fetchRoleState(for userID: UUID) async throws -> (hasPhysio: Bool, hasCustomer: Bool, idProofPath: String?, licenseProofPath: String?) {
        struct Row: Decodable { let id: UUID }
        struct PhysioRow: Decodable {
            let id: UUID
            let id_proof_path: String?
            let license_proof_path: String?
        }

        let physioRows: [PhysioRow] = (try? await client
            .from("physiotherapists")
            .select("id,id_proof_path,license_proof_path")
            .eq("id", value: userID.uuidString)
            .limit(1)
            .execute()
            .value) ?? []

        let customerRows: [Row] = (try? await client
            .from("customers")
            .select("id")
            .eq("id", value: userID.uuidString)
            .limit(1)
            .execute()
            .value) ?? []

        let physio = physioRows.first
        return (
            !physioRows.isEmpty,
            !customerRows.isEmpty,
            physio?.id_proof_path?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            physio?.license_proof_path?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
    }

    private func updateProofPaths(userID: UUID, idProofPath: String?, licenseProofPath: String?) async throws {
        struct ProofUpdate: Encodable {
            let id_proof_path: String?
            let license_proof_path: String?
        }

        let payload = ProofUpdate(
            id_proof_path: idProofPath,
            license_proof_path: licenseProofPath
        )

        _ = try await client
            .from("physiotherapists")
            .update(payload)
            .eq("id", value: userID.uuidString)
            .execute()
    }

    private func createPhysioProfile(userID: UUID, name: String, email: String, idProofPath: String?, licenseProofPath: String?) async throws {
        struct Payload: Encodable {
            let user_id: String
            let name: String
            let email: String
            let id_proof_path: String?
            let license_proof_path: String?
        }

        let payload = Payload(
            user_id: userID.uuidString,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.lowercased(),
            id_proof_path: idProofPath,
            license_proof_path: licenseProofPath
        )

        _ = try await client
            .rpc("create_physio_profile", params: payload)
            .execute()
    }

    private func updatePhoneNumber(userID: UUID, phone: String?) async throws {
        struct PhoneUpdate: Encodable {
            let phone: String?
        }
        let payload = PhoneUpdate(phone: phone)
        _ = try await client
            .from("physiotherapists")
            .update(payload)
            .eq("id", value: userID.uuidString)
            .execute()
    }

    private func uploadProofs(userID: UUID,
                              idProofData: Data?,
                              idProofFilename: String?,
                              licenseProofData: Data?,
                              licenseProofFilename: String?) async throws -> (idProofPath: String?, licenseProofPath: String?) {
        let bucket = "physio_proofs"
        let basePath = "physios/\(userID.uuidString)"
        let uploadOptions = FileOptions(contentType: "image/jpeg", upsert: false)

        var idPath: String?
        if let data = idProofData {
            let safeName = uniqueProofFilename(prefix: "id_proof", original: idProofFilename)
            let path = "\(basePath)/\(safeName)"
            do {
                _ = try await client.storage
                    .from(bucket)
                    .upload(path, data: data, options: uploadOptions)
            } catch {
                let lower = error.localizedDescription.lowercased()
                if lower.contains("cannot parse response") {
                    throw PhysioAuthError(message: "ID proof upload failed. Storage policy/bucket rejected the request. Please verify Supabase storage rules for signed-in physiotherapists.")
                }
                throw PhysioAuthError(message: "ID proof upload failed. \(error.localizedDescription)")
            }
            idPath = path
        }

        var licensePath: String?
        if let data = licenseProofData {
            let safeName = uniqueProofFilename(prefix: "physio_proof", original: licenseProofFilename)
            let path = "\(basePath)/\(safeName)"
            do {
                _ = try await client.storage
                    .from(bucket)
                    .upload(path, data: data, options: uploadOptions)
            } catch {
                let lower = error.localizedDescription.lowercased()
                if lower.contains("cannot parse response") {
                    throw PhysioAuthError(message: "Physio proof upload failed. Storage policy/bucket rejected the request. Please verify Supabase storage rules for signed-in physiotherapists.")
                }
                throw PhysioAuthError(message: "Physio proof upload failed. \(error.localizedDescription)")
            }
            licensePath = path
        }

        return (idPath, licensePath)
    }

    private func uniqueProofFilename(prefix: String, original: String?) -> String {
        let trimmed = original?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let ext = (trimmed as NSString).pathExtension
        let suffix = UUID().uuidString
        let resolvedExt = ext.isEmpty ? "jpg" : ext
        return "\(prefix)_\(suffix).\(resolvedExt)"
    }

    private func normalizedIndianPhone(from raw: String) -> String? {
        let digits = raw.filter { $0.isNumber }
        let core: String
        if digits.count > 10, digits.hasPrefix("91") {
            core = String(digits.suffix(10))
        } else {
            core = String(digits.suffix(10))
        }
        guard core.count == 10 else { return nil }
        return "+91\(core)"
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
