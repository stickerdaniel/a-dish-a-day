//
//  CalendarModel.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI
import SwiftData

enum CalendarSource: String, Codable {
    case created
    case imported
}

@Model
class CalendarModel: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var recipes: [RecipeData] = []  // list of RecipeData
    var thumbnailData: Data?
    var source: CalendarSource?
    var adjustDatesOnImport: Bool = false  // Automatically adjust dates upon import

    // Computed Properties
    var daysBetween: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate.midnight, to: endDate.midnight).day ?? 0
        return days + 1
    }

    var allDates: [Date] {
        startDate.midnight.allDates(upTo: endDate.midnight)
    }

    var thumbnailImage: Image? {
        if let data = thumbnailData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }

    // Initializer
    init(name: String, startDate: Date, endDate: Date, thumbnailData: Data? = nil, source: CalendarSource? = .created, adjustDatesOnImport: Bool = false) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.thumbnailData = thumbnailData
        self.source = source
        self.adjustDatesOnImport = adjustDatesOnImport

        if adjustDatesOnImport {
            adjustDatesToCurrent()
        }

        print("start: \(startDate)")
    }
    
    /// Adjusts the calendar dates based on the current time
    private func adjustDatesToCurrent() {
        let now = Date()
        let offset = now.timeIntervalSince(startDate)
        self.startDate = now
        self.endDate = endDate.addingTimeInterval(offset)

        for i in 0..<recipes.count {
            if let unlockDate = recipes[i].unlockDate {
                recipes[i].unlockDate = unlockDate.addingTimeInterval(offset)
            }
        }
    }

    /// Assigns a recipe to the calendar.
    func assignRecipe(_ recipe: RecipeModel, unlockDate: Date? = nil) {
        let recipeData = RecipeData(recipe: recipe, unlockDate: unlockDate)
        recipes.append(recipeData)
    }

    /// Returns recipes sorted by unlock date (earliest to latest), placing unlocked ones first.
    func sortedRecipesByUnlockDate() -> [RecipeData] {
        recipes.sorted {
            switch ($0.unlockDate, $1.unlockDate) {
            case (nil, _): return true   // Recipes without unlock dates come first (already unlocked)
            case (_, nil): return false  // Recipes without unlock dates come first
            case let (date1?, date2?): return date1 < date2
            }
        }
    }

    /// Get the next recipe unlock time (earliest future unlock).
    var nextUnlockTime: TimeInterval? {
        recipes
            .compactMap { $0.timeUntilUnlock }
            .filter { $0 > 0 }
            .min()
    }

    /// Check if all recipes are unlocked.
    var allRecipesUnlocked: Bool {
        recipes.allSatisfy { $0.isUnlocked }
    }

    /// Get the number of locked recipes.
    var lockedRecipesCount: Int {
        recipes.filter { !$0.isUnlocked }.count
    }
    
    /// Returns the recipe assigned for a specific date, if available.
    func getRecipe(for date: Date) -> RecipeData? {
        return recipes.first { recipe in
            guard let unlockDate = recipe.unlockDate else { return false }
            return Calendar.current.isDate(unlockDate, inSameDayAs: date)
        }
    }
    
    /// Marks a recipe as opened by updating the `hasBeenOpened` flag
    func markRecipeAsOpened(for recipeID: UUID) {
        if let index = recipes.firstIndex(where: { $0.id == recipeID }) {
            recipes[index].hasBeenOpened = true
        }
    }
    
    /// Checks if there are any unlocked recipes that haven't been opened yet
    var hasNewUnlockedRecipes: Int {
        recipes.filter { $0.isUnlocked && !$0.hasBeenOpened }.count
    }

    // Convenience initializer to create a copy of an existing calendar
    static func copy(from calendar: CalendarModel) -> CalendarModel {
        let copiedCalendar = CalendarModel(
            name: calendar.name,
            startDate: calendar.startDate,
            endDate: calendar.endDate,
            thumbnailData: calendar.thumbnailData,
            source: calendar.source,
            adjustDatesOnImport: calendar.adjustDatesOnImport
        )
        copiedCalendar.recipes = calendar.recipes.map { $0 }
        return copiedCalendar
    }

    // Codable Conformance
    private enum CodingKeys: String, CodingKey {
        case id, name, startDate, endDate, recipes, thumbnailData, source, adjustDatesOnImport
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        recipes = try container.decode([RecipeData].self, forKey: .recipes)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
        source = try container.decodeIfPresent(CalendarSource.self, forKey: .source)
        adjustDatesOnImport = try container.decodeIfPresent(Bool.self, forKey: .adjustDatesOnImport) ?? false

        if adjustDatesOnImport {
            adjustDatesToCurrent()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(recipes, forKey: .recipes)
        try container.encode(thumbnailData, forKey: .thumbnailData)
        try container.encode(source, forKey: .source)
        try container.encode(adjustDatesOnImport, forKey: .adjustDatesOnImport)
    }
}
