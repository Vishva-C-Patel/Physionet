//
//  GoogleOAuthHandler.swift
//  Physio_Connect
//
//  Handles Google OAuth sign-in via Supabase using ASWebAuthenticationSession.
//

import UIKit
import AuthenticationServices
import Supabase

// MARK: - Errors

enum OAuthError: LocalizedError, Equatable {
    case cancelled
    case noCallbackURL
    case noWindow

    var errorDescription: String? {
        switch self {
        case .cancelled:       return "Sign-in was cancelled."
        case .noCallbackURL:   return "OAuth callback URL was missing."
        case .noWindow:        return "Could not find a window to present the sign-in sheet."
        }
    }
}

// MARK: - GoogleOAuthHandler

/// Singleton that drives Google OAuth sign-in for both patient and physio flows.
/// After a successful call to `signIn(from:)` the Supabase client holds an
/// active session; callers must then perform their own role-check / DB upsert.
@MainActor
final class GoogleOAuthHandler: NSObject {

    static let shared = GoogleOAuthHandler()
    private override init() {}

    // Must match the URL scheme registered in Info.plist AND the redirect URL
    // added to Supabase → Authentication → URL Configuration → Redirect URLs.
    static let callbackScheme = "io.supabase.bvguhuumnumebhblmjrd"
    static let redirectURL    = URL(string: "\(callbackScheme)://login-callback")!

    private weak var presentingWindow: UIWindow?
    private var webAuthSession: ASWebAuthenticationSession?

    // MARK: - Public API

    /// Launches the Google OAuth web flow.
    /// Throws `OAuthError.cancelled` if the user dismisses the sheet,
    /// or any underlying `Auth` / network error.
    func signIn(from viewController: UIViewController) async throws {
        guard let window = viewController.view.window else {
            throw OAuthError.noWindow
        }
        presentingWindow = window

        try await SupabaseManager.shared.client.auth.signInWithOAuth(
            provider: .google,
            redirectTo: Self.redirectURL,
            queryParams: [("prompt", "select_account")]
        ) { [weak self] url in
            guard let self else { throw OAuthError.cancelled }
            return try await self.present(oauthURL: url)
        }
    }

    // MARK: - Private helpers

    /// Opens `url` in ASWebAuthenticationSession and returns the callback URL.
    private func present(oauthURL: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: oauthURL,
                callbackURLScheme: Self.callbackScheme
            ) { callbackURL, error in
                if let error {
                    let code = (error as? ASWebAuthenticationSessionError)?.code
                    if code == .canceledLogin {
                        continuation.resume(throwing: OAuthError.cancelled)
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                guard let callbackURL else {
                    continuation.resume(throwing: OAuthError.noCallbackURL)
                    return
                }
                continuation.resume(returning: callbackURL)
            }
            session.presentationContextProvider = self
            // Use false so Safari remembers the Google account
            session.prefersEphemeralWebBrowserSession = false
            self.webAuthSession = session
            session.start()
        }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension GoogleOAuthHandler: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            // Provide a guaranteed active window for the presentation anchor
            if let window = self.presentingWindow, window.windowScene != nil {
                return window
            }
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene,
                   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    return keyWindow
                }
            }
            return UIWindow()
        }
    }
}
