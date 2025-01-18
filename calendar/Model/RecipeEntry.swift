//
//  RecipeEntry.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//

import SwiftData
import Foundation

// Model for storing recipe entries with assigned dates
@Model
class RecipeEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date // The assigned date for the recipe
    var recipe: RecipeModel // Store a hard copy of the recipe

    // MARK: - Initializer
    init(date: Date, recipe: RecipeModel) {
        self.date = date
        self.recipe = recipe.copy() // Use a hard copy of the recipe
    }

    // MARK: - Copy Function
    func copy() -> RecipeEntry {
        RecipeEntry(date: self.date, recipe: self.recipe.copy())
    }

    // MARK: - Codable Conformance
    private enum CodingKeys: String, CodingKey {
        case id, date, recipe
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        recipe = try container.decode(RecipeModel.self, forKey: .recipe)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(recipe, forKey: .recipe)
    }
}
