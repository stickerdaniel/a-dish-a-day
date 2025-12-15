//
//  RecipeCard.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//  This is a custom recipe card view for displaying a recipe in a list. We use the card component and specify some context menu actions.

import SwiftUI

struct RecipeCard: View {
    var recipe: RecipeModel
    @State private var showDeleteConfirmation = false
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationLink(destination: OpenRecipeView(recipe: recipe)) {
            Card(
                image: recipe.thumbnailImage,
                description: recipe.name,
                fallbackSymbols: RecipeModel.fallbackSymbols
            )
        }
        .contextMenu {
            NavigationLink(destination: EditRecipeView(recipeToEdit: recipe)) {
                Label("Edit", systemImage: "pencil")
            }

            Button(action: duplicateRecipe) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }

            Divider()

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

    private func duplicateRecipe() {
        let duplicatedRecipe = RecipeModel(
            name: "\(recipe.name) (Copy)",
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            thumbnailData: recipe.thumbnailData
        )
        context.insert(duplicatedRecipe)
    }

    private func deleteRecipe() {
        context.delete(recipe)
    }
}
