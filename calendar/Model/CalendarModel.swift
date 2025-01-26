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
    private var _startDate: Date
    var endDate: Date
    var recipes: [RecipeData] = []
    var thumbnailData: Data?
    var source: CalendarSource?
    var adjustDatesOnImport: Bool = false

    // Computed property to expose startDate while adjusting dates if changed
    var startDate: Date {
        get { return _startDate }
        set { adjustDatesToNewStartDate(newStartDate: newValue) }
    }

    // Computed Properties
    var daysBetween: Int {
        let days = Calendar.current.dateComponents([.day], from: _startDate.midnight, to: endDate.midnight).day ?? 0
        return days + 1
    }

    var allDates: [Date] {
        _startDate.midnight.allDates(upTo: endDate.midnight)
    }

    var thumbnailImage: Image? {
        if let data = thumbnailData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    // Initializer
    init(name: String, startDate: Date, endDate: Date, recipes: [RecipeData] = [], thumbnailData: Data? = nil, source: CalendarSource? = .created, adjustDatesOnImport: Bool = false) {

        self.name = name
        self._startDate = startDate.midnight
        self.endDate = endDate.midnight
        self.recipes = recipes
        self.thumbnailData = thumbnailData
        self.source = source
        self.adjustDatesOnImport = adjustDatesOnImport
    }
    
    /// Adjusts the calendar dates based on the current time (midnight adjustment included)
    func adjustDatesToCurrent() {
        adjustDatesToNewStartDate(newStartDate: Date().midnight)
    }

    /// Adjusts calendar dates based on a new start date, preserving existing durations
    private func adjustDatesToNewStartDate(newStartDate: Date) {
        let offset = newStartDate.midnight.timeIntervalSince(_startDate.midnight)
        
        _startDate = newStartDate.midnight
        endDate = endDate.midnight.addingTimeInterval(offset)

        for i in 0..<recipes.count {
            if let unlockDate = recipes[i].unlockDate {
                recipes[i].unlockDate = unlockDate.midnight.addingTimeInterval(offset)
            }
        }
    }

    /// Assigns a recipe to the calendar.
    func assignRecipe(_ recipe: RecipeModel, unlockDate: Date? = nil) {
        print("cal assignRecipe \(recipe), \(unlockDate)")
        let recipeData = RecipeData(recipe: recipe, unlockDate: unlockDate)
        recipes.append(recipeData)
    }

    /// Check if all recipes within the date range are unlocked.
    var allRecipesUnlocked: Bool {
        recipes
            .filter { $0.isWithinDateRange(startDate: _startDate, endDate: endDate) }
            .allSatisfy { $0.isUnlocked }
    }

    /// Get the number of locked recipes within the date range.
    var lockedRecipesCount: Int {
        recipes
            .filter { $0.isWithinDateRange(startDate: _startDate, endDate: endDate) }
            .filter { !$0.isUnlocked }
            .count
    }

    /// Returns recipes within the date range sorted by unlock date (earliest to latest).
    func sortedRecipesByUnlockDate() -> [RecipeData] {
        recipes
            .filter { $0.isWithinDateRange(startDate: _startDate, endDate: endDate) }
            .sorted {
                switch ($0.unlockDate, $1.unlockDate) {
                case (nil, _): return true
                case (_, nil): return false
                case let (date1?, date2?): return date1 < date2
                }
            }
    }

    /// Get the next recipe unlock time within the date range.
    var nextUnlockTime: TimeInterval? {
        recipes
            .filter { $0.isWithinDateRange(startDate: _startDate, endDate: endDate) }
            .compactMap { $0.timeUntilUnlock }
            .filter { $0 > 0 }
            .min()
    }

    /// Checks if there are any unlocked recipes within the date range that haven't been opened yet.
    var hasNewUnlockedRecipes: Int {
        recipes
            .filter { $0.isWithinDateRange(startDate: _startDate, endDate: endDate) }
            .filter { $0.isUnlocked && !$0.hasBeenOpened }
            .count
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

    // Convenience initializer to create a copy of an existing calendar
    static func copy(from calendar: CalendarModel, setName: String? = nil, setSource source: CalendarSource? = nil) -> CalendarModel {
        let copiedCalendar = CalendarModel(
            name: setName ?? calendar.name,
            startDate: calendar._startDate,
            endDate: calendar.endDate,
            recipes: calendar.recipes,
            thumbnailData: calendar.thumbnailData,
            source: source ?? calendar.source,
            adjustDatesOnImport: calendar.adjustDatesOnImport
        )
        
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
        _startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        recipes = try container.decode([RecipeData].self, forKey: .recipes)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
        source = try container.decodeIfPresent(CalendarSource.self, forKey: .source)
        adjustDatesOnImport = try container.decodeIfPresent(Bool.self, forKey: .adjustDatesOnImport) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(_startDate, forKey: .startDate)  // Keeping coding key consistent
        try container.encode(endDate, forKey: .endDate)
        try container.encode(recipes, forKey: .recipes)
        try container.encode(thumbnailData, forKey: .thumbnailData)
        try container.encode(source, forKey: .source)
        try container.encode(adjustDatesOnImport, forKey: .adjustDatesOnImport)
    }
}
