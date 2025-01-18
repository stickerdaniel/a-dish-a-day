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
            RecipesPath(
                views: calendar.recipes.values.map { recipeData in
                    NavigationLink(destination: OpenRecipeView(
                        thumbnailImage: recipeData.thumbnailImage,
                        name: recipeData.name,
                        ingredients: recipeData.ingredients,
                        steps: recipeData.steps
                    )) {
                        let unlocked = false
                        Card(
                            image: recipeData.thumbnailImage,
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
                },
                seed: abs(calendar.id.hashValue)
            )
        }
        .navigationTitle(calendar.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Only show the edit button if this is a user-created calendar
            if calendar.isUserCreated {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: EditCalendarView(calendarToEdit: calendar)) {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
    }
}
