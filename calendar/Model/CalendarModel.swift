//
//  Calendar.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI
import SwiftData

@Model
class CalendarModel: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case id, name, startDate, endDate, recipes
    }

    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var recipes: [Date: Recipe]

    // Computed property to calculate days between startDate and endDate
    var daysBetween: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return days + 1 // Include the end date
    }

    init(id: UUID = UUID(), name: String, startDate: Date, endDate: Date, recipes: [Date: Recipe] = [:]) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.recipes = recipes
    }

    // Codable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)

        // Decode recipes with Date as a string key
        let recipesDict = try container.decode([String: Recipe].self, forKey: .recipes)
        recipes = recipesDict.reduce(into: [Date: Recipe]()) { result, entry in
            if let date = Helper.getDate(entry.key) {
                result[date] = entry.value
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)

        // Encode recipes with Date as a string key
        let recipesDict = recipes.reduce(into: [String: Recipe]()) { result, entry in
            result[Helper.formatDate(entry.key)] = entry.value
        }
        try container.encode(recipesDict, forKey: .recipes)
    }
}

