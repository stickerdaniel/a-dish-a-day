//
//  AppConfiguration.swift
//  A Dish A Day
//
//  Centralized configuration for Auth0 and Convex with environment-based switching.

import Foundation

enum AppEnvironment {
  case development
  case production

  static var current: AppEnvironment {
    #if DEBUG
      return .development
    #else
      return .production
    #endif
  }
}

enum AppConfiguration {
  // MARK: - Auth0

  static let auth0Domain = "auth0.daniel.sticker.name"
  static let auth0ClientId = "kmAFHhrNLBgilsZyfcqbnmVdzx4RU9vh"
  static let auth0Connection = "Username-Password-Authentication"

  // MARK: - Convex

  static var convexDeploymentUrl: String {
    switch AppEnvironment.current {
    case .development:
      return "https://jovial-firefly-799.convex.cloud"
    case .production:
      return "https://ardent-porpoise-884.convex.cloud"
    }
  }
}
