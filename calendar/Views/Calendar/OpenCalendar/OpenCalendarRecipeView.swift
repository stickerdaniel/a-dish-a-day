//
//  SeeRecipeView.swift
//  calendar
//
//  Created by Daniel Sticker on 19.01.25.
//

import SwiftUI

struct OpenCalendarRecipeView: View {
    var recipe: RecipeData

    @Environment(\.modelContext) private var context
    @State private var showSaveAlert = false // State for showing the alert

    var body: some View {
        ScrollView {
            DisplayRecipeDataView(
                thumbnailImage: recipe.thumbnailImage,
                name: recipe.name,
                ingredients: recipe.ingredients,
                steps: recipe.steps
            )
        }
        .frame(maxWidth: .infinity) // Ensure full width
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Create a model for the recipe
                    let newRecipe = RecipeModel(
                        name: recipe.name,
                        ingredients: recipe.ingredients,
                        steps: recipe.steps,
                        thumbnailData: recipe.thumbnailData
                    )
                    context.insert(newRecipe)
                    
                    // Show success alert
                    showSaveAlert = true
                }) {
                    Image(systemName: "square.and.arrow.down.on.square")
                        .foregroundColor(.blue) // Blue color
                }
            }
        }
        // Success alert dialog
        .alert("Recipe Saved", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The recipe was successfully added to your saved recipes.")
        }
    }
}
