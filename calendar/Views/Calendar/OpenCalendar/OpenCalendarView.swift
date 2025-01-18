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
            ZigZagLineView(
                views: calendar.recipes.values.map { recipeData in
                    // Create a Card for each recipe
                    NavigationLink(destination: OpenRecipeView(thumbnailImage: recipeData.thumbnailImage, name: recipeData.name, ingredients: recipeData.ingredients, steps: recipeData.steps)) {
                        Card(
                            image: recipeData.thumbnailImage ?? Image(systemName: "photo"),
                            description: recipeData.name,
                            fallbackSymbols: RecipeModel.fallbackSymbols
                        ).frame(width: 96)
                    }
                }
            )
        }
        .frame(maxWidth: .infinity) // Ensure full width
        .navigationTitle("Calendar Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
