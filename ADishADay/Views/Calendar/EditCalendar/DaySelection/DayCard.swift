//
//  DayCard.swift
//  calendar
//
//  Created by Daniel Sticker on 17.01.25.
//  This Card component wrapper is used for the day selection in the edit calendar view

import SwiftDate
import SwiftUI

struct DayCard: View {
  let date: Date
  let recipeAssigned: RecipeData?  // Optional currently assigned recipe
  let onTap: () -> Void  // Action when user taps this card

  var body: some View {
    // Day number as the overlay
    Card(
      image: recipeAssigned?.thumbnailImage,
      badgeType: recipeAssigned == nil ? .warning : .none,
      description: recipeAssigned?.name ?? "Tap to pick recipe",
      fallbackSymbols: RecipeModel.fallbackSymbols,
      day: date.day
    )
    .onTapGesture {
      onTap()
    }
  }
}
