//
//  RecipeGridView.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct RecipeGridView: View {
    let recipes: [RecipeModel]
    let addButton: AnyView

    /// Optional closure to handle tapping a recipe
    var onSelect: ((RecipeModel) -> Void)? = nil

    var body: some View {
        CardsView(
            items: recipes,
            addButton: addButton
        ) { recipe in
            // Each item in the grid is a RecipeGridItem
            // We attach an onTapGesture if `onSelect` is provided.
            RecipeGridItem(recipe: recipe)
                .onTapGesture {
                    onSelect?(recipe)
                }
        }
    }
}
