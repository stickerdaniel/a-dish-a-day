//
//  Calendar.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI
import SwiftData

@Model
class CalendarModel: Identifiable, Hashable {
    var id = UUID()
    var name: String
    
    var startDate: Date
    var endDate: Date
    
    var daysBetween: Int {
        get {
            var daysBetween = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            return daysBetween + 1
        }
    }
    
    var recipes: Dictionary<Date, Recipe>
    
    init(name: String, startDate: Date, endDate: Date, recipes: Dictionary<Date, Recipe> = [Date: Recipe]()) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.recipes = recipes
    }
}

extension CalendarModel {
    static var sampleCalendars = [
        CalendarModel(
            name: "Sweets Calendar",
            startDate: Date(),
            endDate: Date(),
            recipes: [Date(): Recipe.sampleRecipes[0]]
        )
    ]
}
