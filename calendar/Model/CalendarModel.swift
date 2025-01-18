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
    var recipes: [String: RecipeData] = [:]
    var thumbnailData: Data?
    var source: CalendarSource?

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
    init(name: String, startDate: Date, endDate: Date, thumbnailData: Data? = nil, source: CalendarSource? = .created) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.thumbnailData = thumbnailData
        self.source = source
    }

    // Convenience initializer to create a copy of an existing calendar
    static func copy(from calendar: CalendarModel) -> CalendarModel {
        let copiedCalendar = CalendarModel(
            name: calendar.name,
            startDate: calendar.startDate,
            endDate: calendar.endDate,
            thumbnailData: calendar.thumbnailData,
            source: calendar.source
        )
        // Copy recipes
        copiedCalendar.recipes = calendar.recipes.mapValues { $0 }
        return copiedCalendar
    }

    // Codable Conformance
    private enum CodingKeys: String, CodingKey {
        case id, name, startDate, endDate, recipes, thumbnailData, source
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        recipes = try container.decode([String: RecipeData].self, forKey: .recipes)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
        source = try container.decodeIfPresent(CalendarSource.self, forKey: .source)
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
    }
}
