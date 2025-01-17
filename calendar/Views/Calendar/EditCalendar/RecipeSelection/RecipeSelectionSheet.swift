//
//  RecipeSelectionSheet.swift
//  calendar
//
//  Created by Daniel Sticker on 17.01.25.
//

import SwiftUI

struct RecipeSelectionSheet: View {
    /// Controls whether this sheet is presented
    @Binding var isPresented: Bool
    
    /// All possible recipes the user can pick from
    let recipes: [RecipeModel]
    
    /// The recipe that might be selected initially
    @State private var selectedRecipe: RecipeModel? = nil

    /// Called when the user taps on a recipe.
    let onRecipeSelected: (RecipeModel) -> Void

    var body: some View {
        NavigationStack {
            RecipeSelectionGridView(
                recipes: recipes,
                selectedRecipe: $selectedRecipe, // local state for highlighting
                onRecipeTapped: { chosen in
                    onRecipeSelected(chosen)
                    isPresented = false
                },
                addButton: AnyView(EmptyView())  // Or pass a "create new recipe" button if desired
            )
            .navigationTitle("Select a Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
