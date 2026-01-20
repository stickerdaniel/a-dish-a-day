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
/// Uses cached credentials from our password-based auth flow instead of webAuth.
public class CustomAuth0Provider: AuthProvider {
  private let credentialsManager: CredentialsManager

  public init() {
    // Use the same credentials manager configuration as AuthenticationManager
    let auth0 = Auth0.authentication(
      clientId: AppConfiguration.auth0ClientId,
      domain: AppConfiguration.auth0Domain
    )
    self.credentialsManager = CredentialsManager(authentication: auth0)
  }

  /// Returns cached credentials for Convex, refreshing the token if expired (may make network call).
  ///
  /// Login is handled externally by AuthenticationManager - this method only retrieves
  /// existing credentials. Both `login()` and `loginFromCache()` share identical implementations
  /// because Auth0's CredentialsManager transparently handles cached retrieval and token refresh.
  /// Both methods are required by the AuthProvider protocol.
  public func login() async throws -> Credentials {
    do {
      return try await credentialsManager.credentials()
    } catch {
      print("[CustomAuth0Provider] Failed to get credentials: \(error.localizedDescription)")
      throw error
    }
  }

  /// Returns credentials for Convex authentication, refreshing the token if expired (may make network call).
  ///
  /// Note: This implementation is identical to `login()` because Auth0's CredentialsManager
  /// handles both cached retrieval and token refresh transparently. Both methods are required
  /// by the AuthProvider protocol.
  public func loginFromCache() async throws -> Credentials {
    do {
      return try await credentialsManager.credentials()
    } catch {
      print("[CustomAuth0Provider] Failed to get cached credentials: \(error.localizedDescription)")
      throw error
    }
  }

  /// Extracts the ID token for Convex to verify.
  public func extractIdToken(from authResult: Credentials) -> String {
    authResult.idToken
  }

  // swiftlint:disable:next type_name
  public typealias T = Credentials

  /// Logout is handled externally by AuthenticationManager.
  public func logout() async throws {
    // Credentials are cleared by AuthenticationManager.logout()
    // We just need to clear any cached state here
    _ = credentialsManager.clear()
  }
}
