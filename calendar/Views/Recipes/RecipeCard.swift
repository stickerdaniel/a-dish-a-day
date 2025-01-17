//
//  RecipeCard.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct RecipeCard: View {
    var recipe: RecipeModel
    @State private var showDeleteConfirmation = false // Trigger for delete confirmation dialog
    @State private var navigateToEditRecipe = false // Trigger for editing recipe
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationLink(value: recipe) {
            Card(
                image: recipe.thumbnailImage, // Computed property to handle thumbnail
                description: recipe.name,
                fallbackSymbols: RecipeModel.fallbackSymbols
            )
        }
        .contextMenu {
            Button(action: { navigateToEditRecipe = true }) {
                Label("Edit", systemImage: "pencil")
            }

            Button(action: duplicateRecipe) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }

            Divider() // Divider before the destructive delete option

            Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this recipe?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: deleteRecipe)
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Context Menu Actions

    /// Duplicates the recipe and adds it to the context
    private func duplicateRecipe() {
        let duplicatedRecipe = RecipeModel(
            name: "\(recipe.name) (Copy)",
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            thumbnailData: recipe.thumbnailData
        )
        context.insert(duplicatedRecipe)
    }

    /// Deletes the recipe from the context
    private func deleteRecipe() {
        context.delete(recipe)
    }
}
