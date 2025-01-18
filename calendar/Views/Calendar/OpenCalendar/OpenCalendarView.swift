//
//  OpenCalendarView.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//

import SwiftUI

struct OpenCalendarView: View {
    var calendar: CalendarModel
    
    var body: some View {
        ScrollView {
            RecipesPath(views: calendar.recipes.values.map { recipeData in
                // Create a Card for each recipe
                NavigationLink(destination: OpenRecipeView(thumbnailImage: recipeData.thumbnailImage, name: recipeData.name, ingredients: recipeData.ingredients, steps: recipeData.steps)) {
                    
                    var unlocked = false
                    
                    Card(
                        image: recipeData.thumbnailImage ?? Image(systemName: "photo"),
                        blurred: true,
                        badgeType: unlocked ? .none : .locked,
                        description: unlocked ? recipeData.name : "Unlocked in",
                        fallbackSymbols: RecipeModel.fallbackSymbols,
                        day: 15,
                        pinned: true
                    )
                    .frame(width: 96)
                    .offset(x: 0, y: 96)
                }
            }, seed: abs(calendar.id.hashValue))
        }
        .navigationTitle("Calendar Details")
        .navigationBarTitleDisplayMode(.inline)  // Adjust the navigation bar display mode
    }
}
