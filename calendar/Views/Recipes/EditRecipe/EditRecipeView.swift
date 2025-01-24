//
//  EditRecipeView.swift
//  calendar
//
//  Created by Daniel Sticker on 15.01.25.
//

import SwiftUI

struct EditRecipeView: View {
    var recipeToEdit: RecipeModel?
    
    enum InputMethod {
        case markdown
        case aiScan
    }
    
    @State private var selectedInputMethod: InputMethod = .markdown
    @State private var name: String = ""
    @State private var ingredients: String = ""
    @State private var instructions: String = ""
    @State private var thumbnailImage: UIImage?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Add input method picker
                Section(header: Text("Import Options")) {
                    HStack(spacing: 16) {
                        Button(action: { /* Add markdown action */ }) {
                            VStack(spacing: 8) {
                                Image(systemName: "tray.and.arrow.down")
                                    .font(.system(size: 24))
                                Text("Markdown")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        Button(action: { /* Add AI scan action */ }) {
                            VStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 24))
                                Text("AI Scan")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
                
                Section(header: Text("Name")) {
                    TextField("Enter recipe name", text: $name)
                }

                Section(header: Text("Thumbnail Image")) {
                    PhotoPicker(
                        title: "Select Image",
                        selectedImage: $thumbnailImage
                    )
                }

                Section(header: Text("Ingredients")) {
                    DynamicTextEditor(
                        placeholder: "List ingredients here...",
                        text: $ingredients
                    )
                }

                Section(header: Text("Instructions")) {
                    DynamicTextEditor(
                        placeholder: "Write instructions here...",
                        text: $instructions
                    )
                }
            }
            .navigationTitle(recipeToEdit == nil ? "New Recipe" : "Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveRecipe) {
                        HStack {
                            Text(recipeToEdit == nil ? "Add" : "Save")
                            Image(systemName: recipeToEdit == nil ? "plus" : "checkmark")
                        }
                    }
                    .disabled(name.isEmpty) // Require a name
                }
            }
            .onAppear(perform: populateFields)
        }
    }

    // MARK: - Actions

    private func populateFields() {
        if let recipe = recipeToEdit {
            name = recipe.name
            ingredients = recipe.ingredients
            instructions = recipe.steps
            if let data = recipe.thumbnailData {
                thumbnailImage = UIImage(data: data)
            }
        }
    }

    private func saveRecipe() {
        if let recipe = recipeToEdit {
            recipe.name = name
            recipe.ingredients = ingredients
            recipe.steps = instructions
            recipe.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        } else {
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
}
