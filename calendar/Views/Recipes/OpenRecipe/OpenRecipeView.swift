//
//  OpenRecipeView.swift
//  calendar
//
//  Created by Daniel Sticker on 19.01.25.
//

import SwiftUI

struct OpenRecipeView: View {
    var recipe: RecipeModel
    
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            DisplayRecipeDataView(thumbnailImage: recipe.thumbnailImage, name: recipe.name, ingredients: recipe.ingredients, steps: recipe.steps)
        }
        .frame(maxWidth: .infinity) // Ensure full width
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: EditRecipeView(recipeToEdit: recipe)) {
                    Image(systemName: "pencil")
                }
            }
        }
    }
}
