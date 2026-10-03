//
//  AuthenticationManager.swift
//  A Dish A Day
//
//  Manages Auth0 authentication state with custom email/password login and owns the
//  Convex auth lifecycle (connect, token renewal, logout).

// The single auth lifecycle owner is kept in one file on purpose.
// swiftlint:disable file_length

import Auth0
import Combine
import ConvexMobile
import Foundation
import SimpleKeychain

// MARK: - Auth State

/// Authentication state for the app
enum AuthState: Equatable {
  case unknown  // Initial state, checking cached credentials
  case loading  // Auth operation in progress
  case authenticated(email: String?)
  case offline(email: String?)  // Stored session kept, but Auth0 was unreachable to restore it
  case unauthenticated

  var isAuthenticated: Bool {
    if case .authenticated = self { return true }
    return false
  }

  /// Signed in as far as navigation is concerned, including a session waiting for the network.
  var isSignedInForNavigation: Bool {
    switch self {
    case .authenticated, .offline: return true
    case .unknown, .loading, .unauthenticated: return false
    }
  }

  var userEmail: String? {
    if case .authenticated(let email) = self { return email }
    return nil
  }
}

/// Why the last session ended. The root view asks for a new login after an invalidation.
enum SignOutReason: Equatable {
  case userLogout
  case sessionInvalidated
}

/// Convex WebSocket state as last observed; `unknown` until the first event arrives.
enum ConvexTransport: Equatable {
  case unknown
  case connecting
  case connected
}

/// How a failed Auth0 credentials call affects the session.
enum CredentialFailure: Equatable {
  case terminal  // Auth0 rejected the refresh token
  case offline  // Auth0 was unreachable
  case other
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
  case invalidCredentials
  case emailNotVerified
  case networkError(String)
  case signupFailed(String)
  case sessionNotSaved
  case logoutFailed
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
    case .sessionNotSaved:
      return "Could not save your session on this device. Please try again."
    case .logoutFailed:
      return "Logout failed, try again"
    case .unknown(let message):
      return message
    }
  }
}

// MARK: - Boundaries

/// The `CredentialsManager` calls the owner makes, so a test harness can replace the Keychain.
protocol CredentialsStoring {
  func canRenew() -> Bool
  func credentials(minTTL: Int) async throws -> Credentials
  func renew() async throws -> Credentials
  func store(credentials: Credentials) -> Bool
  func clear() -> Bool
  /// True only when storage reports the entry as not found. A read error is not absence.
  func credentialsDefinitelyAbsent() -> Bool
}

/// The app's store: a `CredentialsManager` over a Keychain the owner can also ask whether the
/// entry is gone, because `clear()` reports deleting a missing entry as a failure.
struct KeychainCredentialsStore: CredentialsStoring {
  /// `CredentialsManager`'s default key; with its default Keychain, stored sessions stay readable.
  private static let storeKey = "credentials"
  private let keychain: SimpleKeychain
  private let manager: CredentialsManager

  init(authentication: Authentication, keychain: SimpleKeychain = SimpleKeychain()) {
    self.keychain = keychain
    manager = CredentialsManager(
      authentication: authentication,
      storeKey: Self.storeKey,
      storage: keychain
    )
  }

  func canRenew() -> Bool { manager.canRenew() }
  func credentials(minTTL: Int) async throws -> Credentials {
    try await manager.credentials(minTTL: minTTL)
  }
  func renew() async throws -> Credentials { try await manager.renew() }
  func store(credentials: Credentials) -> Bool { manager.store(credentials: credentials) }
  func clear() -> Bool { manager.clear() }

  /// `hasItem` returns false only for `errSecItemNotFound` and throws for any other status.
  func credentialsDefinitelyAbsent() -> Bool {
    (try? keychain.hasItem(forKey: Self.storeKey)) == false
  }
}

/// The `ConvexClientWithAuth` calls the owner makes.
protocol ConvexAuthClient: AnyObject {
  var authState: AnyPublisher<ConvexMobile.AuthState<Credentials>, Never> { get }
  func loginFromCache() async -> Result<Credentials, Error>
  func logout() async
  func watchWebSocketState() -> AnyPublisher<WebSocketState, Never>
}

// MARK: - Authentication Manager

/// Singleton owner of the Auth0 session and the Convex auth lifecycle.
///
/// Every `credentials`, `renew` and `store` call passes an admission gate. Logout and session
/// invalidation share one teardown that closes the gate, waits for admitted calls, detaches
/// Convex and only then clears the Keychain, so a late renewal cannot restore a session.
@MainActor
final class AuthenticationManager: ObservableObject {
  static let shared = AuthenticationManager()

  // MARK: - Configuration

  private static let domain = AppConfiguration.auth0Domain
  private static let clientId = AppConfiguration.auth0ClientId
  private static let connection = AppConfiguration.auth0Connection
  /// Convex validates the ID token, but Auth0 only renews on access-token expiry.
  private static let idTokenRenewalGrace: TimeInterval = 300
  private static let detachDeadline: Duration = .seconds(5)

  // MARK: - Published State

  @Published private(set) var authState: AuthState = .unknown
  @Published private(set) var isInitialized = false
  @Published private(set) var lastSignOutReason: SignOutReason?
  /// Set only by a successful Convex login of the current session; reset when teardown starts.
  @Published private(set) var convexAuthInstalled = false
  @Published private(set) var convexAuthFailure: String?
  @Published private(set) var transport: ConvexTransport = .unknown
  #if DEBUG
    /// Debug-only: treat every ID token as expiring so the next Convex login renews it.
    @Published var debugForceRenewal = false
  #endif

  // MARK: - Private Properties

  private enum Phase {
    case active
    case tearingDown
  }

  private let credentialsStore: CredentialsStoring
  private let auth0: Authentication
  private let convex: ConvexAuthClient
  private var transportObserver: AnyCancellable?
  private var phase = Phase.active
  private var generation = 0
  /// Identifies the newest password login; an older response must not touch the session.
  private var loginAttempt = 0
  /// Auth0 rejected the session the running teardown is draining.
  private var drainedSessionRejected = false
  private var inFlight = 0
  private var drainWaiters: [CheckedContinuation<Void, Never>] = []
  private var connectTask: Task<Void, Never>?
  private var teardownTask: Task<Bool, Never>?

  // MARK: - Initialization

  /// The parameters replace Auth0 and Convex in a test harness; the app uses the defaults.
  init(
    authentication: Authentication? = nil,
    credentialsStore: CredentialsStoring? = nil,
    convex: ConvexAuthClient? = nil
  ) {
    let auth0 =
      authentication
      ?? Auth0.authentication(
        clientId: Self.clientId,
        domain: Self.domain
      )
    self.auth0 = auth0
    self.credentialsStore = credentialsStore ?? KeychainCredentialsStore(authentication: auth0)
    self.convex = convex ?? ConvexClientManager.client
    transportObserver = self.convex.watchWebSocketState()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.transport = state == .connected ? .connected : .connecting
      }
  }

  // MARK: - Public Methods

  /// Check for cached credentials on app launch.
  /// Call this once at app startup.
  func initialize() async {
    guard !isInitialized else { return }

    print("[Auth] Initializing authentication...")

    if credentialsStore.canRenew() {
      if await restoreSession(generation: generation) {
        startConnect()
      }
    } else {
      print("[Auth] No cached credentials available")
      authState = .unauthenticated
    }

    isInitialized = true
  }

  /// Restores an offline session if needed, then installs Convex auth. Concurrent callers join
  /// the running attempt. Success means local auth is installed, not that data has arrived.
  func connectConvex() async {
    guard phase == .active else { return }
    if let connectTask {
      await connectTask.value
      return
    }
    let connectGeneration = generation
    let task = Task { await runConnect(generation: connectGeneration) }
    connectTask = task
    await task.value
  }

  /// Subscriptions may start: Convex auth is installed for the current, verified session.
  var isConvexReady: Bool {
    convexAuthInstalled && authState.isAuthenticated && phase == .active
  }

  /// A query result proves data is flowing even if the first WebSocket event was missed.
  func noteQueryResult() {
    if transport != .connected {
      transport = .connected
    }
  }

  /// Log in with email and password.
  func login(email: String, password: String) async throws {
    guard phase == .active else { throw AuthError.unknown("Signing out, please try again.") }
    // A response that arrives after a logout or a newer login belongs to an old attempt.
    loginAttempt += 1
    let attempt = loginAttempt
    let loginGeneration = generation
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

      guard isCurrentLogin(attempt, generation: loginGeneration) else {
        print("[Auth] Dropped a login response from an earlier attempt")
        throw AuthError.unknown("Login was interrupted. Please try again.")
      }

      // Check if email is verified before accepting login
      guard isEmailVerified(in: credentials.idToken) else {
        print("[Auth] Login rejected: email not verified for \(email)")
        authState = .unauthenticated
        throw AuthError.emailNotVerified
      }

      let stored = try await withCredentialOperation(generation: loginGeneration) {
        $0.store(credentials: credentials)
      }
      guard isCurrentLogin(attempt, generation: loginGeneration) else {
        print("[Auth] Dropped a login response from an earlier attempt")
        throw AuthError.unknown("Login was interrupted. Please try again.")
      }
      guard stored else {
        print("[Auth] Login rejected: credentials could not be stored")
        authState = .unauthenticated
        throw AuthError.sessionNotSaved
      }

      let userEmail = extractEmail(from: credentials.idToken) ?? email
      authState = .authenticated(email: userEmail)
      lastSignOutReason = nil
      print("[Auth] Logged in as: \(userEmail)")
      startConnect()
    } catch let error as Auth0.AuthenticationError {
      if isCurrentLogin(attempt, generation: loginGeneration) { authState = .unauthenticated }
      throw mapAuth0Error(error)
    } catch let error as AuthError {
      // Re-throw our own errors (like emailNotVerified)
      throw error
    } catch {
      if isCurrentLogin(attempt, generation: loginGeneration) { authState = .unauthenticated }
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

  /// Log out of Convex and clear stored credentials. Throws when Convex did not confirm the
  /// detach or the Keychain entry survived; the session then stays signed in so Retry works.
  func logout() async throws {
    let completed = await teardown(reason: .userLogout)
    if !completed && authState.isSignedInForNavigation {
      throw AuthError.logoutFailed
    }
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

  /// Credentials for the Convex provider. Renews when the ID token's `exp` is missing or within
  /// the grace period. A rejected refresh token schedules the session teardown.
  func validCredentials() async throws -> Credentials {
    let operationGeneration = generation
    do {
      let cached = try await withCredentialOperation(generation: operationGeneration) {
        try await $0.credentials(minTTL: 0)
      }
      let cachedExpiry = expiryDescription(cached.idToken)
      guard idTokenExpiresSoon(cached.idToken, within: idTokenRenewalGrace) else {
        print("[Auth] Convex token: cached, exp \(cachedExpiry)")
        return cached
      }
      // renew() stores the result itself
      let renewed = try await withCredentialOperation(generation: operationGeneration) {
        try await $0.renew()
      }
      print(
        "[Auth] Convex token: renewed, exp \(cachedExpiry) -> \(expiryDescription(renewed.idToken))"
      )
      return renewed
    } catch {
      let failure = classifyCredentialError(error)
      print("[Auth] Convex token: failed (\(failure))")
      if failure == .terminal {
        scheduleTerminal(generation: operationGeneration)
      }
      throw error
    }
  }

  /// Check if user has cached credentials (for determining if login prompt should show on launch).
  var hasCachedCredentials: Bool {
    credentialsStore.canRenew()
  }

  // MARK: - Private Helpers

  private var idTokenRenewalGrace: TimeInterval {
    #if DEBUG
      if debugForceRenewal { return .infinity }
    #endif
    return Self.idTokenRenewalGrace
  }

  /// No teardown and no newer password login started since this attempt.
  private func isCurrentLogin(_ attempt: Int, generation loginGeneration: Int) -> Bool {
    phase == .active && generation == loginGeneration && loginAttempt == attempt
  }

  private func extractEmail(from idToken: String) -> String? {
    guard let claims = decodeJWTClaims(idToken) else { return nil }
    return claims["email"] as? String
  }

  private func isEmailVerified(in idToken: String) -> Bool {
    guard let claims = decodeJWTClaims(idToken) else { return false }
    return claims["email_verified"] as? Bool ?? false
  }

  private func expiryDescription(_ idToken: String) -> String {
    idTokenExpiry(idToken).map { String(Int($0.timeIntervalSince1970)) } ?? "none"
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

// MARK: - Lifecycle

extension AuthenticationManager {
  /// The only path to `credentials`, `renew` and `store`. The admission check and the in-flight
  /// count happen in one main-actor turn; the count drops only after the Auth0 call returned,
  /// because a renewal stores before it returns.
  private func withCredentialOperation<Value>(
    generation expected: Int,
    _ operation: (CredentialsStoring) async throws -> Value
  ) async throws -> Value {
    guard phase == .active, generation == expected else { throw CancellationError() }
    inFlight += 1
    defer { finishCredentialOperation() }
    let value = try await operation(credentialsStore)
    guard generation == expected else { throw CancellationError() }
    return value
  }

  private func finishCredentialOperation() {
    inFlight -= 1
    guard inFlight == 0 else { return }
    let waiters = drainWaiters
    drainWaiters = []
    waiters.forEach { $0.resume() }
  }

  private func drainCredentialOperations() async {
    while inFlight > 0 {
      await withCheckedContinuation { drainWaiters.append($0) }
    }
  }

  /// Reads the stored session through the gate and publishes it after the `email_verified` check.
  private func restoreSession(generation restoreGeneration: Int) async -> Bool {
    do {
      let credentials = try await withCredentialOperation(generation: restoreGeneration) {
        try await $0.credentials(minTTL: 0)
      }

      // Verify email is still verified in cached credentials
      guard isEmailVerified(in: credentials.idToken) else {
        print("[Auth] Cached credentials rejected: email not verified")
        if !credentialsStore.clear() {
          print("[Auth] Failed to clear unverified credentials")
        }
        authState = .unauthenticated
        return false
      }

      let email = extractEmail(from: credentials.idToken)
      authState = .authenticated(email: email)
      lastSignOutReason = nil
      print("[Auth] Restored cached session for: \(email ?? "unknown")")
      return true
    } catch is CancellationError {
      return false
    } catch {
      switch classifyCredentialError(error) {
      case .terminal:
        print("[Auth] Stored session rejected by Auth0")
        scheduleTerminal(generation: restoreGeneration)
      case .offline:
        print("[Auth] Auth0 unreachable, keeping the stored session")
        authState = .offline(email: nil)
      case .other:
        print("[Auth] Failed to restore cached credentials: \(error.localizedDescription)")
        authState = .unauthenticated
      }
      return false
    }
  }

  private func startConnect() {
    Task { await connectConvex() }
  }

  /// Must not await teardown: teardown joins this task.
  private func runConnect(generation connectGeneration: Int) async {
    defer { connectTask = nil }
    if case .offline = authState {
      guard await restoreSession(generation: connectGeneration) else { return }
    }
    guard authState.isAuthenticated, phase == .active, generation == connectGeneration else {
      return
    }

    let result = await convex.loginFromCache()
    // A stale result is left to the teardown that changed the generation, which detaches it.
    guard phase == .active, generation == connectGeneration else { return }
    switch result {
    case .success:
      print("[Convex] Auth installed")
      convexAuthInstalled = true
      convexAuthFailure = nil
    case .failure(let error):
      let failure = classifyCredentialError(error)
      print("[Convex] Login failed (\(failure))")
      convexAuthFailure =
        failure == .offline
        ? "No connection to the server. Check your network and try again."
        : "Could not sign in to the server."
    }
  }

  /// Credential operations and the connect task report an invalid session this way, because
  /// the teardown waits for both.
  private func scheduleTerminal(generation terminalGeneration: Int) {
    guard !recordForRunningTeardown(generation: terminalGeneration) else { return }
    Task { await handleTerminal(generation: terminalGeneration) }
  }

  private func handleTerminal(generation terminalGeneration: Int) async {
    guard !recordForRunningTeardown(generation: terminalGeneration) else { return }
    guard phase == .active, generation == terminalGeneration else { return }
    _ = await teardown(reason: .sessionInvalidated)
  }

  /// A rejection of the session that the running teardown drains makes that teardown end it as
  /// invalidated. The teardown advanced `generation` by one; older sessions stay ignored.
  private func recordForRunningTeardown(generation terminalGeneration: Int) -> Bool {
    guard phase == .tearingDown, terminalGeneration == generation - 1 else { return false }
    drainedSessionRejected = true
    return true
  }

  /// Runs one teardown at a time; a second request waits for the running one.
  private func teardown(reason: SignOutReason) async -> Bool {
    if let teardownTask {
      return await teardownTask.value
    }
    let task = Task { await performTeardown(reason: reason) }
    teardownTask = task
    return await task.value
  }

  private func performTeardown(reason: SignOutReason) async -> Bool {
    print("[Auth] Teardown started (\(reason))")
    phase = .tearingDown
    generation += 1
    drainedSessionRejected = false
    convexAuthInstalled = false
    convexAuthFailure = nil

    if let connectTask {
      await connectTask.value
    }
    await drainCredentialOperations()
    let detached = await detachConvex()
    // Also true when an operation of the drained session reported `invalid_grant`
    let invalidated = reason == .sessionInvalidated || drainedSessionRejected
    // A user logout keeps the credentials when Convex stayed attached, so Retry can repeat it.
    // Auth0 reports deleting a missing entry as a failure, so the Keychain is asked directly.
    let cleared =
      (detached || invalidated)
      && (credentialsStore.clear() || credentialsStore.credentialsDefinitelyAbsent())
    phase = .active
    teardownTask = nil
    print("[Auth] Teardown finished (detached: \(detached), cleared: \(cleared))")

    guard (detached && cleared) || invalidated else {
      // Keep the session and reconnect the data it had before the failed logout
      startConnect()
      return false
    }
    authState = .unauthenticated
    lastSignOutReason = invalidated ? .sessionInvalidated : reason
    return detached && cleared
  }

  /// `ConvexClientWithAuth.logout()` hides its errors and publishes `.unauthenticated` only after
  /// a successful detach, before it returns. The observer is armed first and skips the
  /// current-value replay, which can be left over from an earlier failed login.
  ///
  /// The SDK call itself has no deadline; admission stays closed until it returns. The 5 s
  /// deadline bounds only the wait for the acknowledgement after it returned.
  private func detachConvex() async -> Bool {
    let (acknowledgements, continuation) = AsyncStream<Void>.makeStream()
    let observer = convex.authState
      .dropFirst()
      .sink { @Sendable state in
        if case .unauthenticated = state {
          continuation.yield()
        }
      }
    defer {
      observer.cancel()
      continuation.finish()
    }

    await convex.logout()
    // Starts only now that the SDK call returned
    let deadline = Self.detachDeadline
    return await withTaskGroup(of: Bool.self) { group in
      group.addTask {
        for await _ in acknowledgements {
          return true
        }
        return false
      }
      group.addTask {
        try? await Task.sleep(for: deadline)
        return false
      }
      let acknowledged = await group.next() ?? false
      group.cancelAll()
      return acknowledged
    }
  }
}

// MARK: - Production Conformances

extension CredentialsManager: CredentialsStoring {
  func credentials(minTTL: Int) async throws -> Credentials {
    try await credentials(withScope: nil, minTTL: minTTL, parameters: [:], headers: [:])
  }

  func renew() async throws -> Credentials {
    try await renew(parameters: [:], headers: [:])
  }

  /// Its storage API returns nil for a read error too, so it can never prove absence.
  func credentialsDefinitelyAbsent() -> Bool { false }
}

extension ConvexClientWithAuth: ConvexAuthClient where T == Credentials {}

// MARK: - Token Helpers

/// Classifies errors from `CredentialsStoring`. Renewal failures nest as
/// `CredentialsManagerError -> AuthenticationError -> URLError`. Only `invalid_grant` ends the
/// session; storage errors never do.
func classifyCredentialError(_ error: Error) -> CredentialFailure {
  guard
    let authError = (error as? CredentialsManagerError)?.cause as? Auth0.AuthenticationError
  else {
    return .other
  }
  if authError.code == "invalid_grant" {
    return .terminal
  }
  // Covers the codes of `isNetworkError` and other transport failures
  if authError.isNetworkError || authError.cause is URLError {
    return .offline
  }
  return .other
}

/// Whether the ID token expires within `grace` seconds of `now`. A missing or non-numeric `exp`
/// counts as expiring, so the caller renews instead of sending a token of unknown age.
func idTokenExpiresSoon(_ idToken: String, within grace: TimeInterval, now: Date = Date()) -> Bool {
  guard let expiry = idTokenExpiry(idToken) else { return true }
  return expiry.timeIntervalSince(now) <= grace
}

func idTokenExpiry(_ idToken: String) -> Date? {
  guard let exp = decodeJWTClaims(idToken)?["exp"] as? TimeInterval else { return nil }
  return Date(timeIntervalSince1970: exp)
}

/// Decodes a JWT payload without verifying it. The claims only drive local decisions.
func decodeJWTClaims(_ token: String) -> [String: Any]? {
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
