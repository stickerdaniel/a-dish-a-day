//
//  ConvexClientManager.swift
//  A Dish A Day
//
//  Singleton manager for Convex backend connection.

import ConvexMobile
import Foundation

/// Singleton manager for Convex backend connection.
class ConvexClientManager {
  static let shared = ConvexClientManager()

  static let deploymentUrl = "https://jovial-firefly-799.convex.cloud"

  private var _client: ConvexClient?

  var client: ConvexClient {
    if _client == nil {
      _client = ConvexClient(deploymentUrl: Self.deploymentUrl)
    }
    // swiftlint:disable:next force_unwrapping
    return _client!
  }

  /// Convenience method to get the shared client instance.
  static var client: ConvexClient {
    shared.client
  }

  private init() {}

  func initialize() {
    _ = client  // Force lazy initialization
    print("[Convex] Client initialized successfully")
  }

  func disconnect() {
    _client = nil
  }
}
