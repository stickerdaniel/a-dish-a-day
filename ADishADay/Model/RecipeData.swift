//
//  RecipeData.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//  Why not use RecipeModel? RecipeModel is used to store the saved Recipes in the Recipes tab. Here we store the recipes that are saved (and auto-serialized) in the Calendars. We also have an unlock date set, that is not needed in RecipeModel

import SwiftDate
import SwiftUI

struct RecipeData: Codable, Identifiable {
  var id: UUID = UUID()
  var name: String
  var ingredients: String
  var steps: String
  var thumbnailData: Data?
  var unlockDate: Date?
  var hasBeenOpened: Bool = false

  // Computed property to convert thumbnail data to a SwiftUI Image
  var thumbnailImage: Image? {
    if let data = thumbnailData, let uiImage = UIImage(data: data) {
      return Image(uiImage: uiImage)
    } else {
      return nil  // No image
    }
  }

  // Computed property to determine if the recipe is unlocked
  var isUnlocked: Bool {
    guard let unlockDate = unlockDate else {
      return true  // If no unlock date is set, assume it's unlocked
    }
    return Date() >= unlockDate
  }

  // Computed property to get the remaining time until the recipe is unlocked
  var timeUntilUnlock: TimeInterval? {
    guard let unlockDate = unlockDate else { return nil }
    let remainingTime = unlockDate.timeIntervalSinceNow
    return remainingTime > 0 ? remainingTime : nil
  }

  // Computed property to get a formatted string for time remaining until unlock
  var formattedTimeUntilUnlock: String {
    guard let unlockDate = unlockDate, unlockDate > Date() else { return name }
    let relative = unlockDate.in(region: .current).toRelative(since: Date().in(region: .current))
    return "Unlock \(relative)"
  }

  // Helper function to check if the recipe is within the given date range
  func isWithinDateRange(startDate: Date, endDate: Date) -> Bool {
    guard let unlockDate = unlockDate else { return false }
    return unlockDate >= startDate && unlockDate <= endDate
  }

  init(recipe: RecipeModel, unlockDate: Date? = nil) {
    self.name = recipe.name
    self.ingredients = recipe.ingredients
    self.steps = recipe.steps
    self.thumbnailData = recipe.thumbnailData
    self.unlockDate = unlockDate
    self.hasBeenOpened = false
  }
}
