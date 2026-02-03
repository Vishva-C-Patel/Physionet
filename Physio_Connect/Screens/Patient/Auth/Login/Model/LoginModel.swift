//
//  LoginModel.swift
//  Physio_Connect
//
//  Created by user@8 on 06/01/26.
//

import Foundation

final class LoginModel {
    private let client = SupabaseManager.shared.client

    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        struct Row: Decodable { let id: UUID }
        let customerRows: [Row] = (try? await client
            .from("customers")
            .select("id")
            .eq("id", value: userID)
            .limit(1)
            .execute()
            .value) ?? []

        let physioRows: [Row] = (try? await client
            .from("physiotherapists")
            .select("id")
            .eq("id", value: userID)
            .limit(1)
            .execute()
            .value) ?? []

        if !customerRows.isEmpty && physioRows.isEmpty {
            return
        }

        try? await client.auth.signOut()
        if !physioRows.isEmpty {
            throw LoginError(message: "This account is registered as a physiotherapist. Please log in on the physio side.")
        }
        throw LoginError(message: "No patient account found for this email.")
    }
}

private struct LoginError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
