//
//  RecipeData.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//

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
            return true // If no unlock date is set, assume it's unlocked
        }
        return Date() >= unlockDate
    }

    // Computed property to get the remaining time until the recipe is unlocked
    var timeUntilUnlock: TimeInterval? {
        guard let unlockDate = unlockDate else { return nil }
        let remainingTime = unlockDate.timeIntervalSinceNow
        return remainingTime > 0 ? remainingTime : nil
    }

    // Computed property to get a formatted string "18:49h" for time remaining until unlock
    var formattedTimeUntilUnlock: String {
        guard let remaining = timeUntilUnlock else { return self.name }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        
        return String(format: "Unlock in %02d:%02dh", hours, minutes)
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
