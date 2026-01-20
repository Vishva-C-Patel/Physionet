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
    private let n8nWebhookURL: URL?
    private let n8nWebhookToken: String?

    private init() {
        let urlString = Bundle.main.object(forInfoDictionaryKey: "N8N_WEBHOOK_URL") as? String
        if let urlString = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            n8nWebhookURL = url
        } else {
            n8nWebhookURL = nil
        }

        let token = Bundle.main.object(forInfoDictionaryKey: "N8N_WEBHOOK_TOKEN") as? String
        let trimmedToken = token?.trimmingCharacters(in: .whitespacesAndNewlines)
        n8nWebhookToken = trimmedToken?.isEmpty == false ? trimmedToken : nil

        loadCache()
    }

    func triggerArticles(
        keyword: String,
        source: String,
        userID: String? = nil,
        context: [String: String]? = nil
    ) {
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
                let userID: String?
                let context: [String: String]?

                enum CodingKeys: String, CodingKey {
                    case keyword
                    case source
                    case userID = "user_id"
                    case context
                }
            }

            let payload = Payload(
                keyword: normalized,
                source: source,
                userID: userID,
                context: context
            )

            if await self.invokeWebhook(payload: payload, keyword: normalized, timestamp: now) {
                return
            }

            await self.invokeTrigger(
                payload: payload,
                keyword: normalized,
                timestamp: now,
                retryOn401: true
            )
        }
    }

    private func invokeTrigger(
        payload: some Encodable,
        keyword: String,
        timestamp: Date,
        retryOn401: Bool
    ) async {
        do {
            SupabaseManager.shared.debugPrintConfig()
            SupabaseManager.shared.debugPrintFunctionTarget(name: "trigger_articles")
            var session = try await client.auth.session
            // If token looks empty/invalid, try refreshing once before invoke
            if session.accessToken.isEmpty {
                session = try await client.auth.refreshSession()
            }
            // Proactively refresh to avoid stale tokens
            if let refreshed = try? await client.auth.refreshSession() {
                session = refreshed
            }
            let jwt = session.accessToken
            print("🧾 JWT iss =", jwtIssuer(jwt) ?? "nil")
            print("🪪 trigger_articles user=\(session.user.id) token_prefix=\(jwt.prefix(24))")

            var headers = ["Authorization": "Bearer \(jwt)"]
            if let anonKey = supabaseAnonKey() {
                headers["apikey"] = anonKey
            }

            let options = FunctionInvokeOptions(
                method: .post,
                headers: headers,
                body: payload
            )

            try await client.functions.invoke("trigger_articles", options: options)
            store(keyword: keyword, at: timestamp)
        } catch {
            if case let FunctionsError.httpError(code, data) = error, code == 401, retryOn401 {
                // Try refreshing session once, then retry
                do {
                    _ = try await client.auth.refreshSession()
                    await invokeTrigger(payload: payload, keyword: keyword, timestamp: timestamp, retryOn401: false)
                    return
                } catch {
                    print("❌ trigger_articles refresh failed for \(keyword): \(error)")
                }
            }

            if case let FunctionsError.httpError(code, data) = error {
                let body = String(data: data, encoding: .utf8) ?? "<no body>"
                print("❌ trigger_articles failed for \(keyword): code=\(code) body=\(body)")
            } else {
                print("❌ trigger_articles failed for \(keyword): \(error)")
            }
        }
    }

    private func invokeWebhook(
        payload: some Encodable,
        keyword: String,
        timestamp: Date
    ) async -> Bool {
        guard let url = n8nWebhookURL else { return false }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = n8nWebhookToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(payload)

            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                store(keyword: keyword, at: timestamp)
                return true
            }

            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ n8n webhook failed for \(keyword): code=\(status) body=\(body)")
        } catch {
            print("❌ n8n webhook error for \(keyword): \(error)")
        }

        return false
    }

    private func supabaseAnonKey() -> String? {
        let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String
        let trimmed = key?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }

    private func jwtIssuer(_ jwt: String) -> String? {
        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        guard
            let data = Data(base64Encoded: base64),
            let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return obj["iss"] as? String
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
