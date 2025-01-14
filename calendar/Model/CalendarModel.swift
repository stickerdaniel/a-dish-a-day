//
//  CalendarModel.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI
import SwiftData

@Model
class CalendarModel: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case id, name, startDate, endDate, recipes, thumbnailData
    }

    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var recipes: [Date: RecipeModel]
    var thumbnailData: Data? // Store the image data for the thumbnail

    // Computed property to calculate days between startDate and endDate
    var daysBetween: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return days + 1 // Include the end date
    }

    // Computed property to convert thumbnail data to a SwiftUI Image
    var thumbnailImage: Image {
        if let data = thumbnailData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return Image("calendar-default-thumbnail") // Default image
        }
    }

    init(id: UUID = UUID(), name: String, startDate: Date, endDate: Date, recipes: [Date: RecipeModel] = [:], thumbnailData: Data? = nil) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.recipes = recipes
        self.thumbnailData = thumbnailData
    }

    // Codable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)

        // Decode recipes with Date as a string key
        let recipesDict = try container.decode([String: RecipeModel].self, forKey: .recipes)
        recipes = recipesDict.reduce(into: [Date: RecipeModel]()) { result, entry in
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
        try container.encode(thumbnailData, forKey: .thumbnailData)

        // Encode recipes with Date as a string key
        let recipesDict = recipes.reduce(into: [String: RecipeModel]()) { result, entry in
            result[Helper.formatDate(entry.key)] = entry.value
        }
        try container.encode(recipesDict, forKey: .recipes)
    }
    
    // Static array of sample calendars
    static var sampleCalendars: [CalendarModel] = [
        CalendarModel(
            name: "German Pastries",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            recipes: [:],
            thumbnailData: UIImage(named: "german-pastries")?.jpegData(compressionQuality: 0.8) // Example image
        ),
        CalendarModel(
            name: "Sushi 101",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            recipes: [:],
            thumbnailData: UIImage(named: "sushi-101")?.jpegData(compressionQuality: 0.8) // Example image
        ),
        CalendarModel(
            name: "Introduction to Chinese Cuisine",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            recipes: [:],
            thumbnailData: UIImage(named: "intro-chinese-cuisine")?.jpegData(compressionQuality: 0.8) // Example image
        ),
        CalendarModel(
            name: "Grannys Calendar",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            recipes: [:],
            thumbnailData: nil // fallback image
        )
    ]
}
