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
                    )
                }

                Section(header: Text("Instructions")) {
                    DynamicTextEditor(
                        placeholder: "Write instructions here...",
                        text: $anleitung,
                        minHeight: 120 // Larger default height for longer instructions
                    )
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: openCamera) {
                        Image(systemName: "camera")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", action: addRecipe)
                        .disabled(name.isEmpty)
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
        print("Camera button tapped")
    }
}
