//
//  PhysioAuthModel.swift
//  Physio_Connect
//
//  Created by Codex on 08/01/26.
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
        _ = try await client.auth.signUp(email: input.email, password: input.password)

        // Ensure we have an authenticated session before hitting Storage policies.
        let session = try await client.auth.signIn(email: input.email, password: input.password)
        let user = session.user

        let proofPaths = try await uploadProofs(
            userID: user.id,
            idProofData: input.idProofData,
            idProofFilename: input.idProofFilename,
            licenseProofData: input.licenseProofData,
            licenseProofFilename: input.licenseProofFilename
        )

        do {
            try await createPhysioProfile(
                userID: user.id,
                name: input.name,
                email: input.email,
                idProofPath: proofPaths.idProofPath,
                licenseProofPath: proofPaths.licenseProofPath
            )
        } catch {
            throw PhysioAuthError(message: "Profile creation failed. \(error.localizedDescription)")
        }
        return user
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
}
