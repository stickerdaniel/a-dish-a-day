//
//  SeeRecipeView.swift
//  calendar
//
//  Created by Daniel Sticker on 19.01.25.
//


import SwiftUI

struct SeeRecipeView: View {
    var recipe: RecipeData

    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView {
            DisplayRecipeDataView(thumbnailImage: recipe.thumbnailImage, name: recipe.name, ingredients: recipe.ingredients, steps: recipe.steps)
        }
        .frame(maxWidth: .infinity) // Ensure full width
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        // toolbar save to my recipes btn
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // create a model for the recipe
                    let newRecipe = RecipeModel(
                        name: recipe.name,
                        ingredients: recipe.ingredients,
                        steps: recipe.steps,
                        thumbnailData: recipe.thumbnailData
                    )
                    context.insert(newRecipe)
                    
                    // alert dialog
                        
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.blue) // Blue color
                }
            }
        }
    }
}
