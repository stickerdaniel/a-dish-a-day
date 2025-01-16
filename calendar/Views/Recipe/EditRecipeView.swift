//
//  AddRecipeView.swift
//  calendar
//
//  Created by Daniel Sticker on 15.01.25.
//

import SwiftUI

struct EditRecipeView: View {
    var recipeToEdit: RecipeModel? // Optional recipe for editing

    @State private var name = ""
    @State private var ingredients = ""
    @State private var instructions = ""
    @State private var thumbnailImage: UIImage?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter recipe name", text: $name)
                }

                // Upload Thumbnail Image Section
                Section(header: Text("Thumbnail Image")) {
                    PhotoPicker(
                        title: "Select Image",
                        selectedImage: $thumbnailImage
                    )
                    .padding(.top, 4)
                }

                Section(header: Text("Ingredients")) {
                    DynamicTextEditor(
                        placeholder: "List ingredients here...",
                        text: $ingredients,
                        minHeight: 80
                    )
                }

                Section(header: Text("Instructions")) {
                    DynamicTextEditor(
                        placeholder: "Write instructions here...",
                        text: $instructions,
                        minHeight: 120
                    )
                }
            }
            .navigationTitle(recipeToEdit == nil ? "New Recipe" : "Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if recipeToEdit == nil { // Show "Scan" button only for new recipes
                        Button(action: openAIScan) {
                            Image(systemName: "document.viewfinder.fill")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveRecipe) {
                        HStack {
                            Text(recipeToEdit == nil ? "Add" : "Save")
                            Image(systemName: recipeToEdit == nil ? "plus" : "checkmark")
                        }
                    }
                    .disabled(name.isEmpty) // At least a name is required
                }
            }
            .onAppear {
                if let recipe = recipeToEdit {
                    name = recipe.name
                    ingredients = recipe.ingredients
                    instructions = recipe.steps
                    if let data = recipe.thumbnailData {
                        thumbnailImage = UIImage(data: data)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func saveRecipe() {
        if let recipe = recipeToEdit {
            // Update existing recipe
            recipe.name = name
            recipe.ingredients = ingredients
            recipe.steps = instructions
            recipe.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        } else {
            // Create a new recipe
            let newRecipe = RecipeModel(
                name: name,
                ingredients: ingredients,
                steps: instructions,
                thumbnailData: thumbnailImage?.jpegData(compressionQuality: 0.8)
            )
            context.insert(newRecipe)
        }

        dismiss()
    }

    private func openAIScan() {
        // Add camera opening logic here
        print("Scan button tapped")
    }
}
