//
//  RecipeSelectionGridView.swift
//  calendar
//
//  Created by Daniel Sticker on 17.01.25.
//

import SwiftUI

struct RecipeSelectionGridView: View {
    let recipes: [RecipeModel]
    
    /// The currently selected recipe, if any.
    @Binding var selectedRecipe: RecipeModel?
    
    /// A callback to notify parent when a recipe is tapped.
    let onRecipeTapped: (RecipeModel) -> Void
    
    /// Optionally you can pass an 'addButton' if you want to allow new recipe creation,
    /// or you can pass `AnyView(EmptyView())` if you don't need that.
    let addButton: AnyView

    var body: some View {
        CardGridView(
            items: recipes,
            addButton: addButton
        ) { recipe in
            RecipeSelectionGridItem(
                recipe: recipe,
                isSelected: recipe.id == selectedRecipe?.id, // Compare IDs to check selection
                onTap: { tappedRecipe in
                    // Update selection and trigger callback
                    selectedRecipe = tappedRecipe
                    onRecipeTapped(tappedRecipe)
                }
            )
        }
    }
}
