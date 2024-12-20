//
//  Calendar.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI

struct CalendarModel: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var imagePath: String?
    
    var startDate: Date
    var endDate: Date
    
    var recipes: Dictionary<Date, Recipe>
    
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
