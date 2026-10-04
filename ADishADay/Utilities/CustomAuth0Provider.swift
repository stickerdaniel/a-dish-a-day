//
//  CustomAuth0Provider.swift
//  A Dish A Day
//
//  Custom AuthProvider for Convex that works with our manual email/password auth flow
//  instead of Auth0 Universal Login (webAuth).

import Auth0
import ConvexMobile
import Foundation

/// Custom Auth0 provider that bridges our AuthenticationManager to Convex.
/// Hands Convex the owner's credentials and never touches the Keychain itself.
final class CustomAuth0Provider: AuthProvider {
  private let owner: @MainActor () -> AuthenticationManager

  /// The owner is resolved on each call, so the shared manager can create the client that
  /// holds this provider.
  init(owner: @escaping @MainActor () -> AuthenticationManager = { AuthenticationManager.shared }) {
    self.owner = owner
  }

  /// Login is handled externally by AuthenticationManager, which already stored the
  /// credentials, so this is the same as `loginFromCache`.
  func login(onIdToken: @Sendable @escaping (String?) -> Void) async throws -> Credentials {
    try await loginFromCache(onIdToken: onIdToken)
  }

  /// Returns credentials for Convex, renewing them when the ID token is about to expire.
  /// Convex calls this on login and on every forced token refresh.
  ///
  /// `onIdToken` is not retained: Convex caches the returned token itself, and its nil path
  /// detaches in an unscoped task that could hit a newer session. The owner tears down
  /// invalid sessions instead.
  func loginFromCache(onIdToken: @Sendable @escaping (String?) -> Void) async throws -> Credentials
  {
    try await owner().validCredentials()
  }

  /// Extracts the ID token for Convex to verify.
  func extractIdToken(from authResult: Credentials) -> String {
    authResult.idToken
  }

  // swiftlint:disable:next type_name
  typealias T = Credentials

  /// No-op. `ConvexClientWithAuth.logout()` calls this during the owner's own teardown, which
  /// also clears the credentials.
  func logout() async throws {}
}
