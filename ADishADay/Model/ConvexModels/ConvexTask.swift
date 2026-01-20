//
//  ConvexTask.swift
//  ADishADay
//
//  Convex task model for real-time sync demonstration.

import Foundation

/// A task item synced from Convex backend.
/// Mirrors the `tasks` table schema in convex/tasks.ts
/// Named `ConvexTask` to avoid conflict with Swift's built-in `Task` type.
struct ConvexTask: Decodable, Identifiable {
  // swiftlint:disable:next identifier_name
  let _id: String
  let text: String
  let isCompleted: Bool

  var id: String { _id }
}
