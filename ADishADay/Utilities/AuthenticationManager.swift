//
//  AuthenticationManager.swift
//  A Dish A Day
//
//  Manages Auth0 authentication state with custom email/password login.

import Auth0
import Foundation

// MARK: - Auth State

/// Authentication state for the app
enum AuthState: Equatable {
  case unknown  // Initial state, checking cached credentials
  case loading  // Auth operation in progress
  case authenticated(email: String?)
  case unauthenticated

  var isAuthenticated: Bool {
    if case .authenticated = self { return true }
    return false
  }

  var userEmail: String? {
    if case .authenticated(let email) = self { return email }
    return nil
  }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
  case invalidCredentials
  case emailNotVerified
  case networkError(String)
  case signupFailed(String)
  case unknown(String)

  var errorDescription: String? {
    switch self {
    case .invalidCredentials:
      return "Invalid email or password"
    case .emailNotVerified:
      return "Please verify your email address"
    case .networkError(let message):
      return "Network error: \(message)"
    case .signupFailed(let message):
      return "Sign up failed: \(message)"
    case .unknown(let message):
      return message
    }
  }
}

// MARK: - Authentication Manager

/// Singleton manager for Auth0 authentication using custom email/password forms.
@MainActor
final class AuthenticationManager: ObservableObject {
  static let shared = AuthenticationManager()

  // MARK: - Configuration

  private static let domain = AppConfiguration.auth0Domain
  private static let clientId = AppConfiguration.auth0ClientId
  private static let connection = AppConfiguration.auth0Connection

  // MARK: - Published State

  @Published private(set) var authState: AuthState = .unknown
  @Published private(set) var isInitialized = false

  // MARK: - Private Properties

  private let credentialsManager: CredentialsManager
  private let auth0: Authentication

  // MARK: - Initialization

  init() {
    self.auth0 = Auth0.authentication(
      clientId: Self.clientId,
      domain: Self.domain
    )
    self.credentialsManager = CredentialsManager(authentication: auth0)
  }

  // MARK: - Public Methods

  /// Check for cached credentials on app launch.
  /// Call this once at app startup.
  func initialize() async {
    guard !isInitialized else { return }

    print("[Auth] Initializing authentication...")

    if credentialsManager.canRenew() {
      do {
        let credentials = try await credentialsManager.credentials()

        // Verify email is still verified in cached credentials
        guard isEmailVerified(in: credentials.idToken) else {
          print("[Auth] Cached credentials rejected: email not verified")
          _ = credentialsManager.clear()
          authState = .unauthenticated
          isInitialized = true
          return
        }

        let email = extractEmail(from: credentials.idToken)
        authState = .authenticated(email: email)
        print("[Auth] Restored cached session for: \(email ?? "unknown")")
      } catch {
        print("[Auth] Failed to restore cached credentials: \(error.localizedDescription)")
        authState = .unauthenticated
      }
    } else {
      print("[Auth] No cached credentials available")
      authState = .unauthenticated
    }

    isInitialized = true
  }

  /// Log in with email and password.
  func login(email: String, password: String) async throws {
    authState = .loading

    do {
      let credentials =
        try await auth0
        .login(
          usernameOrEmail: email,
          password: password,
          realmOrConnection: Self.connection,
          scope: "openid profile email offline_access"
        )
        .start()

      // Check if email is verified before accepting login
      guard isEmailVerified(in: credentials.idToken) else {
        print("[Auth] Login rejected: email not verified for \(email)")
        authState = .unauthenticated
        throw AuthError.emailNotVerified
      }

      _ = credentialsManager.store(credentials: credentials)

      let userEmail = extractEmail(from: credentials.idToken) ?? email
      authState = .authenticated(email: userEmail)
      print("[Auth] Logged in as: \(userEmail)")
    } catch let error as Auth0.AuthenticationError {
      authState = .unauthenticated
      throw mapAuth0Error(error)
    } catch let error as AuthError {
      // Re-throw our own errors (like emailNotVerified)
      throw error
    } catch {
      authState = .unauthenticated
      throw AuthError.unknown(error.localizedDescription)
    }
  }

  /// Sign up with email and password.
  /// Note: After signup, user needs to verify their email before logging in.
  func signup(email: String, password: String) async throws {
    authState = .loading

    do {
      _ =
        try await auth0
        .signup(
          email: email,
          password: password,
          connection: Self.connection
        )
        .start()

      // Signup successful - user needs to verify email
      // Don't change auth state yet, wait for verification
      authState = .unauthenticated
      print("[Auth] Signup successful for: \(email). Verification email sent.")
    } catch let error as Auth0.AuthenticationError {
      authState = .unauthenticated
      throw mapAuth0Error(error)
    } catch {
      authState = .unauthenticated
      throw AuthError.signupFailed(error.localizedDescription)
    }
  }

  /// Log out and clear stored credentials.
  func logout() async {
    authState = .loading
    _ = credentialsManager.clear()
    authState = .unauthenticated
    print("[Auth] Logged out")
  }

  /// Request a password reset email.
  func resetPassword(email: String) async throws {
    do {
      try await auth0
        .resetPassword(email: email, connection: Self.connection)
        .start()
      print("[Auth] Password reset email sent to: \(email)")
    } catch let error as Auth0.AuthenticationError {
      throw mapAuth0Error(error)
    } catch {
      throw AuthError.unknown(error.localizedDescription)
    }
  }

  /// Get the current ID token for Convex authentication.
  func getIdToken() async throws -> String? {
    guard authState.isAuthenticated else { return nil }

    do {
      let credentials = try await credentialsManager.credentials()
      return credentials.idToken
    } catch {
      print("[Auth] Failed to get ID token: \(error.localizedDescription)")
      return nil
    }
  }

  /// Check if user has cached credentials (for determining if login prompt should show on launch).
  var hasCachedCredentials: Bool {
    credentialsManager.canRenew()
  }

  // MARK: - Private Helpers

  private func extractEmail(from idToken: String) -> String? {
    guard let claims = decodeJWT(idToken) else { return nil }
    return claims["email"] as? String
  }

  private func isEmailVerified(in idToken: String) -> Bool {
    guard let claims = decodeJWT(idToken) else { return false }
    return claims["email_verified"] as? Bool ?? false
  }

  private func decodeJWT(_ token: String) -> [String: Any]? {
    let parts = token.split(separator: ".")
    guard parts.count >= 2 else { return nil }

    var base64 = String(parts[1])
    // Convert Base64URL to standard Base64 (JWT uses URL-safe encoding)
    base64 =
      base64
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    // Add padding if needed
    while base64.count % 4 != 0 {
      base64 += "="
    }

    guard let data = Data(base64Encoded: base64),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      return nil
    }

    return json
  }

  private func mapAuth0Error(_ error: Auth0.AuthenticationError) -> AuthError {
    let description = error.localizedDescription
    let code = error.code

    print("[Auth] Auth0 error - code: \(code), description: \(description)")

    // Check for email verification required FIRST (before access_denied catch-all)
    if description.lowercased().contains("verify")
      || description.lowercased().contains("verification")
      || description.lowercased().contains("email") && code == "access_denied"
    {
      return .emailNotVerified
    }

    // Check for invalid credentials
    if code == "invalid_grant" || description.lowercased().contains("wrong email or password")
      || description.lowercased().contains("invalid credentials")
    {
      return .invalidCredentials
    }

    // Generic access denied (after specific checks)
    if code == "access_denied" {
      return .emailNotVerified
    }

    return .unknown(description)
  }
}
