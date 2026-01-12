import Foundation
import Supabase

/// Fire-and-forget helper to trigger the articles edge function with simple debouncing.
final class ArticleTriggerService {
    static let shared = ArticleTriggerService()

    private let client = SupabaseManager.shared.client
    private let debounceSeconds: TimeInterval = 60
    private var lastKeyword: String?
    private var lastSentAt: Date?
    private let defaultsKey = "article_trigger_cache"

    private init() {
        loadCache()
    }

    func triggerArticles(keyword: String, source: String, context: [String: String]? = nil) {
        let normalized = keyword
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        guard normalized.count >= 2 else { return }

        let now = Date()
        if let lastKeyword,
           let lastSentAt,
           lastKeyword.caseInsensitiveCompare(normalized) == .orderedSame,
           now.timeIntervalSince(lastSentAt) < debounceSeconds {
            return
        }

        Task.detached { [weak self] in
            guard let self else { return }
            struct Payload: Encodable {
                let keyword: String
                let source: String
                let context: [String: String]?
            }

            do {
                let payload = Payload(keyword: normalized, source: source, context: context)
                let options = FunctionInvokeOptions(method: .post, body: payload)
                try await self.client.functions.invoke("trigger_articles", options: options)
                self.store(keyword: normalized, at: now)
            } catch {
                print("❌ trigger_articles failed for \(normalized): \(error)")
            }
        }
    }

    private func loadCache() {
        let cache = UserDefaults.standard.dictionary(forKey: defaultsKey) ?? [:]
        if let keyword = cache["keyword"] as? String,
           let ts = cache["timestamp"] as? TimeInterval {
            lastKeyword = keyword
            lastSentAt = Date(timeIntervalSince1970: ts)
        }
    }

    private func store(keyword: String, at date: Date) {
        lastKeyword = keyword
        lastSentAt = date
        let cache: [String: Any] = [
            "keyword": keyword,
            "timestamp": date.timeIntervalSince1970
        ]
        UserDefaults.standard.set(cache, forKey: defaultsKey)
    }
}
