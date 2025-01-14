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

    var body: some View {
        CardGridView(
            items: recipes,
            addButton: addButton
        ) { recipe in
            RecipeGridItem(recipe: recipe)
        }
    }
}
