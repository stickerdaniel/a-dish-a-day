//
//  CalendarModel.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI
import SwiftData

@Model
class CalendarModel: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var recipes: [RecipeEntry] = [] // Store recipes with assigned days
    var thumbnailData: Data? // Store the image data for the thumbnail

    // Computed property to calculate days between startDate and endDate
    var daysBetween: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return days + 1 // Include the end date
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
    init(name: String, startDate: Date, endDate: Date, thumbnailData: Data? = nil) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.thumbnailData = thumbnailData
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

    // Static sample calendars
    static var sampleCalendars: [CalendarModel] = [
        CalendarModel(
            name: "German Pastries",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            thumbnailData: UIImage(named: "german-pastries")?.jpegData(compressionQuality: 0.8)
        ),
        CalendarModel(
            name: "Sushi 101",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            thumbnailData: UIImage(named: "sushi-101")?.jpegData(compressionQuality: 0.8)
        ),
        CalendarModel(
            name: "Introduction to Chinese Cuisine",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            thumbnailData: UIImage(named: "intro-chinese-cuisine")?.jpegData(compressionQuality: 0.8)
        ),
        CalendarModel(
            name: "Granny's Calendar",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            thumbnailData: nil
        )
    ]
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
