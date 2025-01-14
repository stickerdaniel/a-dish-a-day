//
//  RecipeGridItem.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct RecipeGridItem: View {
    var recipe: RecipeModel

    var body: some View {
        NavigationLink(destination: OpenRecipeView(recipe: recipe)) {
            Card(
                image: recipe.thumbnailImage, // Computed property to handle thumbnail
                description: recipe.name
            )
        }
    }
}

