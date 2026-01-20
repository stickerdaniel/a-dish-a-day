//
//  ConvexClientManager.swift
//  A Dish A Day
//
//  Singleton manager for Convex backend connection.

import Auth0
import ConvexMobile
import Foundation

/// Singleton manager for Convex backend connection with Auth0 authentication.
class ConvexClientManager {
  static let shared = ConvexClientManager()

  static let deploymentUrl = AppConfiguration.convexDeploymentUrl

  private var _client: ConvexClientWithAuth<Credentials>?

  var client: ConvexClientWithAuth<Credentials> {
    if _client == nil {
      let authProvider = CustomAuth0Provider()
      _client = ConvexClientWithAuth(deploymentUrl: Self.deploymentUrl, authProvider: authProvider)
    }
    // swiftlint:disable:next force_unwrapping
    return _client!
  }

  /// Convenience method to get the shared client instance.
  static var client: ConvexClientWithAuth<Credentials> {
    shared.client
  }

  private init() {}

  func initialize() {
    _ = client  // Force lazy initialization
    print("[Convex] Client initialized successfully with Auth0")
  }

  func disconnect() {
    _client = nil
  }
}
