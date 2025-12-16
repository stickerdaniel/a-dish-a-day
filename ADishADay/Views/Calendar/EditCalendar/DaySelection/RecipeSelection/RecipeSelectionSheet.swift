//
//  RecipeSelectionSheet.swift
//  calendar
//
//  Created by Daniel Sticker on 17.01.25.
//  A component to select a recipe from a grid of recipes

import SwiftUI

struct RecipeSelectionSheet: View {
  /// Controls whether this sheet is presented
  @Binding var isPresented: Bool

  /// All possible recipes the user can pick from
  let recipes: [RecipeModel]

  /// The recipe that might be selected initially
  @State private var selectedRecipe: RecipeModel? = nil

  /// Called when the user taps on a recipe
  let onRecipeSelected: (RecipeModel) -> Void

  var body: some View {
    NavigationStack {
      Group {
        if recipes.isEmpty {
          VStack {
            Spacer()
            Text("No recipes available.\nPlease create or save recipes first.")
              .multilineTextAlignment(.center)
              .foregroundColor(.secondary)
            Spacer()
          }
          .padding()
        } else {
          RecipeSelectionGridView(
            recipes: recipes,
            selectedRecipe: $selectedRecipe,  // Local state for highlighting
            onRecipeTapped: { chosen in
              onRecipeSelected(chosen)
              isPresented = false
            }
          )
        }
      }
      .navigationTitle("Select a Recipe")
      .navigationBarTitleDisplayMode(.inline)  // Inline title display mode
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {  // Cancel button in the top-right
          Button("Cancel") {
            isPresented = false
          }
        }
      }
    }
  }
}
