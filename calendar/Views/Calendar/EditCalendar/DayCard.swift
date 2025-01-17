//
//  DayCard.swift
//  calendar
//
//  Created by Daniel Sticker on 17.01.25.
//

import SwiftUI

struct DayCard: View {
    let date: Date
    let recipeAssigned: RecipeModel? // Optional currently assigned recipe
    let onTap: () -> Void            // Action when user taps this card

    var body: some View {
        // Day number as the overlay
        Card(
            image: nil,
            icon: nil,
            badgeType: .none,            // Or logic to show a badge if needed
            description: recipeAssigned?.name ?? "Tap to pick recipe",
            fallbackSymbols: [],
            day: date.dayOfMonth
        )
        .onTapGesture {
            onTap()
        }
    }
}
