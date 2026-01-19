//
//  ConvexClientManager.swift
//  A Dish A Day
//
//  Minimal test to check if ConvexMobile loads on iOS 26

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

  private init() {}

  func initialize() {
    _ = client  // Force lazy initialization
    print("[Convex] Client initialized successfully")
  }

  func disconnect() {
    _client = nil
  }
}
