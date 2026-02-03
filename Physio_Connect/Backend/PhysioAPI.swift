//
//  PhysioAPI.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//

import Foundation

final class PhysioAPI {

    static let shared = PhysioAPI()
    private init() {}

    private let baseURL = SupabaseConfig.url
    private let anonKey = SupabaseConfig.anonKey

    private func makeRequest(path: String, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        guard var comps = URLComponents(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        if !queryItems.isEmpty { comps.queryItems = queryItems }

        guard let url = comps.url else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        return req
    }

    private func fetch<T: Decodable>(_ type: T.Type, req: URLRequest) async throws -> T {
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    // -------------------------------------------------------
    // 1) List: physiotherapists
    // -------------------------------------------------------
    func fetchPhysiotherapists() async throws -> [Physiotherapist] {
        let req = try makeRequest(
            path: "/rest/v1/physiotherapists",
            queryItems: [
                .init(name: "select", value: "*"),
                .init(name: "order", value: "created_at.desc")
            ]
        )
        return try await fetch([Physiotherapist].self, req: req)
    }

    // -------------------------------------------------------
    // 2) Batch: specialization names for ALL physios
    // Uses embed: specializations(name)
    // -------------------------------------------------------
    func fetchAllPhysioSpecializations() async throws -> [PhysioSpecializationRow] {
        let req = try makeRequest(
            path: "/rest/v1/physio_specializations",
            queryItems: [
                .init(name: "select", value: "physio_id,specializations(name)")
            ]
        )
        return try await fetch([PhysioSpecializationRow].self, req: req)
    }

    // -------------------------------------------------------
    // 3) Detail: one physiotherapist
    // -------------------------------------------------------
    func fetchPhysiotherapist(id: UUID) async throws -> Physiotherapist? {
        let req = try makeRequest(
            path: "/rest/v1/physiotherapists",
            queryItems: [
                .init(name: "select", value: "*"),
                .init(name: "id", value: "eq.\(id.uuidString)"),
                .init(name: "limit", value: "1")
            ]
        )
        let rows = try await fetch([Physiotherapist].self, req: req)
        return rows.first
    }

    // -------------------------------------------------------
    // 4) Detail: reviews of a physio
    // -------------------------------------------------------
    func fetchReviews(physioID: UUID) async throws -> [PhysioReviewRow] {
        let req = try makeRequest(
            path: "/rest/v1/physio_reviews",
            queryItems: [
                .init(name: "select", value: "*"),
                .init(name: "physio_id", value: "eq.\(physioID.uuidString)"),
                .init(name: "order", value: "created_at.desc")
            ]
        )
        return try await fetch([PhysioReviewRow].self, req: req)
    }

    // -------------------------------------------------------
    // 5) Detail: specialization names for one physio
    // -------------------------------------------------------
    func fetchSpecializations(physioID: UUID) async throws -> [String] {
        let req = try makeRequest(
            path: "/rest/v1/physio_specializations",
            queryItems: [
                .init(name: "select", value: "specializations(name)"),
                .init(name: "physio_id", value: "eq.\(physioID.uuidString)")
            ]
        )
        let rows = try await fetch([PhysioSpecializationRow].self, req: req)
        return rows.compactMap { $0.specializations?.name }
    }
}

