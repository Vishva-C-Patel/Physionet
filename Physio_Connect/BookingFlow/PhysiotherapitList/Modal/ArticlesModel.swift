//
//  ArticlesModel.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import Foundation
import Supabase

struct ArticleRow: Decodable {
    let id: UUID
    let title: String
    let summary: String?
    let content: String?
    let source: String?
    let source_name: String?
    let url: String?
    let source_url: String?
    let image_url: String?
    let image_path: String?
    let published_at: String?
    let created_at: String?
    let rating: Double?
    let views_count: Int?
    let read_minutes: Int?
    let is_trending: Bool?
    let tags: [String]?
}

enum ArticleSort {
    case recent
    case topRated
    case forYou
}

final class ArticlesModel {
    private let client = SupabaseManager.shared.client
    private let imageBucket = "article_images"

    func signedImageURL(pathOrUrl: String) async throws -> URL {
        if let url = URL(string: pathOrUrl), url.scheme?.hasPrefix("http") == true {
            return url
        }
        let normalized = normalizeImagePath(pathOrUrl)
        do {
            return try await client.storage
                .from(imageBucket)
                .createSignedURL(path: normalized, expiresIn: 3600)
        } catch {
            if let base = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
               let url = URL(string: "\(base)/storage/v1/object/public/\(imageBucket)/\(normalized)") {
                return url
            }
            throw error
        }
    }

    private func normalizeImagePath(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let publicPrefix = "/storage/v1/object/public/\(imageBucket)/"
        if let range = trimmed.range(of: publicPrefix) {
            return String(trimmed[range.upperBound...])
        }
        if let range = trimmed.range(of: "\(imageBucket)/") {
            return String(trimmed[range.upperBound...])
        }
        return trimmed
    }

    func fetchArticles(search: String?, category: String?, sort: ArticleSort) async throws -> [ArticleRow] {
        let limit = 30
        switch sort {
        case .forYou:
            return try await fetchPersonalizedArticles(limit: limit)
        case .topRated:
            return try await fetchTopRatedArticles(search: search, category: category, limit: limit)
        case .recent:
            return try await fetchRecentArticles(search: search, category: category, limit: limit)
        }
    }

    func submitRating(articleID: UUID, rating: Int) async throws {
        struct RatingUpsert: Encodable {
            let article_id: UUID
            let user_id: UUID
            let rating: Int
            let last_opened_at: String
        }

        let session = try await client.auth.session
        let userID = session.user.id
        let df = ISO8601DateFormatter()
        let payload = RatingUpsert(
            article_id: articleID,
            user_id: userID,
            rating: rating,
            last_opened_at: df.string(from: Date())
        )

        _ = try await client
            .from("article_interactions")
            .upsert(payload, onConflict: "article_id,user_id")
            .execute()
    }

    func fetchUserRating(articleID: UUID) async throws -> Int? {
        let session = try await client.auth.session
        let userID = session.user.id

        struct RatingRow: Decodable { let rating: Int? }

        let rows: [RatingRow] = try await client
            .from("article_interactions")
            .select("rating")
            .eq("article_id", value: articleID.uuidString)
            .eq("user_id", value: userID.uuidString)
            .limit(1)
            .execute()
            .value

        return rows.first?.rating
    }

    func fetchArticle(id: UUID) async throws -> ArticleRow {
        let row: ArticleRow = try await client
            .from("articles")
            .select("*")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        return row
    }

    func incrementViews(articleID: UUID) async throws {
        struct Args: Encodable { let p_article_id: UUID }
        _ = try await client
            .rpc("increment_article_view", params: Args(p_article_id: articleID))
            .execute()
    }

    private func baseArticlesQuery(search: String?, category: String?) -> PostgrestTransformBuilder {
        var query = client
            .from("articles")
            .select("*")

        if let search = search?.trimmingCharacters(in: .whitespacesAndNewlines), !search.isEmpty {
            query = query.ilike("title", pattern: "%\(search)%")
        }

        return query
    }

    private func fetchRecentArticles(search: String?, category: String?, limit: Int) async throws -> [ArticleRow] {
        var query = baseArticlesQuery(search: search, category: category)
        _ = query.order("published_at", ascending: false)
        _ = query.order("created_at", ascending: false)
        _ = query.limit(limit)
        return try await query.execute().value
    }

    private func fetchTopRatedArticles(search: String?, category: String?, limit: Int) async throws -> [ArticleRow] {
        var query = baseArticlesQuery(search: search, category: category)
        _ = query.order("rating", ascending: false)
        _ = query.order("published_at", ascending: false)
        _ = query.limit(limit)
        return try await query.execute().value
    }

    private func fetchPersonalizedArticles(limit: Int) async throws -> [ArticleRow] {
        let session = try await client.auth.session
        let userID = session.user.id

        struct FeedRow: Decodable {
            let created_at: String?
            let reason: String?
            let articles: ArticleRow?
        }

        var query = client
            .from("user_article_feed")
            .select("created_at,reason,articles:article_id(*)")
            .eq("user_id", value: userID.uuidString)
            .order("created_at", ascending: false)
            .limit(limit)

        let rows: [FeedRow] = try await query.execute().value
        return rows.compactMap { $0.articles }
    }
}
