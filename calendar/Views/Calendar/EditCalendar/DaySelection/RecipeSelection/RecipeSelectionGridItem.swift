//
//  RecipeSelectionGridItem.swift
//  calendar
//
//  Created by Daniel Sticker on 17.01.25.
//

import SwiftUI

struct RecipeSelectionGridItem: View {
    let recipe: RecipeModel
    let isSelected: Bool
    let onTap: (RecipeModel) -> Void
    
    var body: some View {
        // We can apply a subtle highlight if `isSelected` is true
        Card(
            image: recipe.thumbnailImage,
            description: recipe.name,
            fallbackSymbols: RecipeModel.fallbackSymbols
        )
        .onTapGesture {
            onTap(recipe)
        }
        // Alternatively, you can change the background color or border to highlight selection:
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
        )
    }
}
