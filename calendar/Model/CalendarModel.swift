//
//  CalendarModel.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI
import SwiftData

@Model
class CalendarModel: Identifiable {
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

    init(name: String, startDate: Date, endDate: Date, thumbnailData: Data? = nil) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.thumbnailData = thumbnailData
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
                name: "Grannys Calendar",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
                thumbnailData: nil
            )
        ]
}


// Model for storing recipe entries with assigned dates
@Model
class RecipeEntry: Identifiable {
    var id: UUID = UUID()
    var date: Date // The assigned date for the recipe
    @Relationship var recipe: RecipeModel // The recipe assigned to this date

    init(date: Date, recipe: RecipeModel) {
        self.date = date
        self.recipe = recipe
    }
}
