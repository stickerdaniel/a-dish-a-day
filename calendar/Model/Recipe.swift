//
//  Recipe.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//
import SwiftUI

struct Recipe: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var imagePath: String?
    
    
    
    

}

extension Recipe {
    

    static let sampleRecipes: [Recipe] = [
        Recipe(
            name: "Baklawa",
            description: "Tastes good"
        ),
        Recipe(
            name: "Peking Duck",
            description: "Available in all Chinese restaurants"
        ),
        Recipe(
            name: "Schwarma",
            description: "How fatty do you want it? Yes!"
        )


    ]
}
