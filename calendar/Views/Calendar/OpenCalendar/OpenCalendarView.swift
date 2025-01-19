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
            // (1) Build only the valid views for dates in [startDate ... endDate]
            let cardViews = calendar.allDates.compactMap { date -> AnyView? in
                // Convert the date to the key used in `calendar.recipes`
                let dateKey = date.midnight.description
                
                // See if there's a recipe assigned for this date
                guard let recipeData = calendar.recipes[dateKey] else {
                    // No recipe assigned => skip
                    return nil
                }
                
                // If we have a recipe, build a NavigationLink with a Card
                let unlocked = false // Your own logic here
                let dayNumber = Calendar.current.component(.day, from: date)
                
                return AnyView(
                    NavigationLink(
                        destination: SeeRecipeView(recipe: recipeData)
                    ) {
                        Card(
                            image: recipeData.thumbnailImage,
                            blurred: true,
                            badgeType: unlocked ? .none : .locked,
                            description: unlocked ? recipeData.name : "Unlocked in",
                            fallbackSymbols: RecipeModel.fallbackSymbols,
                            day: dayNumber, // Or nil, if you prefer
                            pinned: true
                        )
                        .frame(width: 96)
                        .offset(x: 0, y: 96)
                    }
                )
            }
            
            // (2) Use the built array of valid card views in your RecipesPath
            RecipesPath(views: cardViews, seed: abs(calendar.id.hashValue))
        }
        .navigationTitle(calendar.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Show the pencil Edit button if this is a user-created calendar
            if calendar.source == .created {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: EditCalendarView(calendarToEdit: calendar)) {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
    }
}
