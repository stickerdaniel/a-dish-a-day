//
//  OpenRecipeView.swift
//  calendar
//
//  Created by Daniel Sticker on 19.01.25.
//

import SwiftUI

struct OpenRecipeView: View {
    var recipe: RecipeModel

    var body: some View {
        ScrollView {
            DisplayRecipeDataView(thumbnailImage: recipe.thumbnailImage, name: recipe.name, ingredients: recipe.ingredients, steps: recipe.steps)
        }
        .frame(maxWidth: .infinity) // Ensure full width
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
