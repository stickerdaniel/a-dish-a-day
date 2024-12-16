//
//  Recipe.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//
import SwiftUI

struct Recipe: Identifiable, Hashable {
    let id = UUID()
    var date: Date
    var name: String
    var description: String
    var imagePath: String?
    
    
    
    var day: String {
        date.formatted(Date.FormatStyle().day(.defaultDigits))
    }
    var month: String {
        date.formatted(Date.FormatStyle().month(.defaultDigits))
    }
    var monthName: String {
        date.formatted(Date.FormatStyle().month(.wide))
    }

    var daySuffix: String {
        
        switch(Int(day)) {
        case 1, 11, 21: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }

}

extension Recipe {
    

    static let sampleRecipes: [Recipe] = [
        Recipe(
            date: Date.now,
            name: "Baklawa",
            description: "Tastes good"
        ),
        Recipe(
            date: Helper.getDate("2024/10/23"),
            name: "Peking Duck",
            description: "Available in all Chinese restaurants"
        ),
        Recipe(
            date: Helper.getDate("2024/10/24"),
            name: "Schwarma",
            description: "How fatty do you want it? Yes!"
        )


    ]
}
