import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient
    private let supabaseURL: URL

    private init() {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString),
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String
        else {
            fatalError("Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY in Info.plist")
        }

        supabaseURL = url
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }

    // Debug helpers
    func debugPrintConfig() {
        let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? "<nil>"
        let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String ?? "<nil>"
        print("🔧 Supabase config URL=\(url) key_prefix=\(key.prefix(16))")
    }

    func debugPrintSession() async {
        do {
            let session = try await client.auth.session
            print("🔧 Session user=\(session.user.id) token_prefix=\(session.accessToken.prefix(24))")
        } catch {
            print("🔧 Session unavailable: \(error)")
        }
    }

    func resetAuth() async {
        do {
            try await client.auth.signOut()
            print("🔧 Signed out and cleared session. Please log in again.")
        } catch {
            print("🔧 Sign-out failed: \(error)")
        }
    }

    func debugPrintFunctionTarget(name: String) {
        let full = "\(supabaseURL.absoluteString)/functions/v1/\(name)"
        print("🔧 Function target: \(full)")
    }

    func forceFreshAuthSession() async {
        await resetAuth()
        // Note: user must log in again after this; no auto-login to avoid stale tokens.
    }
}
