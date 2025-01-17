//
//  RecipeSelectionGridView.swift
//  calendar
//
//  Created by Lucy May Plassmann on 12.01.25.
//

import SwiftUI

struct RecipeSelectionGridView: View {
    let recipes: [RecipeModel]
    
    /// The currently selected recipe, if any.
    @Binding var selectedRecipe: RecipeModel?
    
    /// A callback to notify parent when a recipe is tapped.
    let onRecipeTapped: (RecipeModel) -> Void
    
    var body: some View {
        
        let columns = [GridItem(.adaptive(minimum: Card.minimumWidth), spacing: Card.spacing)]
        
        LazyVGrid(columns: columns, spacing: Card.spacing) {
            
            // Render the recipe items
            ForEach(recipes, id: \.id) { recipe in
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
        .padding()
    }
}
