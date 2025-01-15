//
//  DateView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//
import SwiftUI

struct DateRecipe: Hashable {
    var date: Date
    var recipe: RecipeModel
}

struct DateView: View {
    var calendar: CalendarModel
    var recipes: [DateRecipe]
    @State private var selected = 0

    // Initialize `recipes` by sorting `calendar.recipes` by date
    init(calendar: CalendarModel) {
        self.calendar = calendar
        self.recipes = calendar.recipes
            .sorted { $0.date < $1.date } // Sort by date
            .map { DateRecipe(date: $0.date, recipe: $0.recipe) } // Map to `DateRecipe`
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                ZStack(alignment: .center) {
                    // Navigation buttons
                    HStack {
                        Button(action: { selected = max(0, selected - 1) }) {
                            Label("Left", systemImage: "chevron.left")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .disabled(selected == 0)

                        Spacer()

                        Button(action: { selected = min(recipes.count - 1, selected + 1) }) {
                            Label("Right", systemImage: "chevron.right")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .disabled(selected == recipes.count - 1)
                    }
                    .padding()

                    // Display selected recipe card
                    if !recipes.isEmpty {
                        CardView(recipe: recipes[selected].recipe, date: recipes[selected].date)
                            .padding()
                            .zIndex(1) // Ensure it's on top
                    } else {
                        Text("No recipes available")
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Display the selected index
                Text("Selected Index: \(selected + 1) of \(recipes.count)")
                    .font(.caption)
                    .padding(.bottom)
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }
}
