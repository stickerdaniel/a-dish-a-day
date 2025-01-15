//
//  File.swift
//  calendar
//
//  Created by Lucy May Plassmann on 12.01.25.
//

import SwiftUI

struct AddRecipeView: View {
    @State private var name = ""
    @State private var ingredients = ""
    @State private var anleitung = ""

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter recipe name", text: $name)
                }

                Section(header: Text("Ingredients")) {
                    DynamicTextEditor(
                        placeholder: "List ingredients here...",
                        text: $ingredients,
                        minHeight: 80 // Larger default height for longer inputs
                    ).offset(x: -4, y: -6) // Align with other text fields
                }

                Section(header: Text("Instructions")) {
                    DynamicTextEditor(
                        placeholder: "Write instructions here...",
                        text: $anleitung,
                        minHeight: 120 // Larger default height for longer instructions
                    ).offset(x: -4, y: -6) // Align with other text fields
                }
            }
            .navigationTitle("Create Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: openCamera) {
                        Image(systemName: "document.viewfinder.fill")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    // Add button with plus icon and "Create Recipe" text
                    Button(action: addRecipe) {
                        HStack {
                            Text("Add")
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func addRecipe() {
        let newRecipe = RecipeModel(name: name, text: anleitung, ingredients: ingredients)
        context.insert(newRecipe)
        dismiss()
    }

    private func openCamera() {
        // Add camera opening logic here
        print("Scan button tapped")
    }
}
