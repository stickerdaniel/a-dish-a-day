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
    var recipes: [RecipeEntry] = [] // Store recipes with assigned days
    var thumbnailData: Data? // Store the image data for the thumbnail
    var source: CalendarSource? // Optional source (nil defaults to .imported)

    // Computed property to calculate days between startDate and endDate
    var daysBetween: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate.midnight, to: endDate.midnight).day ?? 0
        return days + 1
    }

    // Returns an array of daily dates in [startDate, endDate].
    // date extension function used here
    var allDates: [Date] {
        startDate.midnight.allDates(upTo: endDate.midnight)
    }

    // Computed property to convert thumbnail data to a SwiftUI Image
    var thumbnailImage: Image? {
        if let data = thumbnailData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil // No image
        }
    }

    // MARK: - Initializer
    init(name: String, startDate: Date, endDate: Date, thumbnailData: Data? = nil, source: CalendarSource? = .created) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.thumbnailData = thumbnailData
        self.source = source
    }

    // MARK: - Codable Conformance
    private enum CodingKeys: String, CodingKey {
        case id, name, startDate, endDate, recipes, thumbnailData
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        recipes = try container.decode([RecipeEntry].self, forKey: .recipes)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
        source = .imported // Default to imported for backward compatibility
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(recipes, forKey: .recipes)
        try container.encode(thumbnailData, forKey: .thumbnailData)
    }
}



// Model for storing recipe entries with assigned dates
@Model
class RecipeEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date // The assigned date for the recipe
    @Relationship var recipe: RecipeModel // The recipe assigned to this date

    // MARK: - Initializer
    init(date: Date, recipe: RecipeModel) {
        self.date = date
        self.recipe = recipe
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
