//
//  RoleAccessGate.swift
//  Physio_Connect
//
//  Created by Codex on 08/01/26.
//
import Foundation

enum RoleAccessGate {
    private struct Row: Decodable { let id: UUID }

    static func isSessionValid(for role: AppRole) async -> Bool {
        guard let session = try? await SupabaseManager.shared.client.auth.session else {
            return false
        }
        let userID = session.user.id.uuidString

        switch role {
        case .patient:
            let isPhysio = await hasRow(table: "physiotherapists", userID: userID)
            if isPhysio { return false }
            return await hasRow(table: "customers", userID: userID)
        case .physiotherapist:
            let isCustomer = await hasRow(table: "customers", userID: userID)
            if isCustomer { return false }
            return await hasRow(table: "physiotherapists", userID: userID)
        }
    }

    private static func hasRow(table: String, userID: String) async -> Bool {
        let rows: [Row] = (try? await SupabaseManager.shared.client
            .from(table)
            .select("id")
            .eq("id", value: userID)
            .limit(1)
            .execute()
            .value) ?? []
        return rows.first != nil
    }
}
