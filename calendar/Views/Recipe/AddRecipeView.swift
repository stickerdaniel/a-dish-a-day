//
//  AddRecipeView.swift
//  calendar
//
//  Created by Daniel Sticker on 15.01.25.
//

import SwiftUI

struct AddRecipeView: View {
    @State private var name = ""
    @State private var ingredients = ""
    @State private var anleitung = ""
    @State private var thumbnailImage: UIImage?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter recipe name", text: $name)
                }
                
                // Upload Thumbnail image Section
                Section(header: Text("Thumbnail Image")) {
                    PhotoPicker(
                        title: "Select Image",
                        selectedImage: $thumbnailImage
                    ).padding(.top, 4)
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
                        text: $anleitung,
                        minHeight: 120
                    )
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: openAIScan) {
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
                    }.disabled(name.isEmpty) // At least a name is required
                }
            }
        }
    }

    // MARK: - Actions

    private func addRecipe() {
        let newRecipe = RecipeModel(
            name: name,
            text: anleitung,
            ingredients: ingredients,
            thumbnailData: thumbnailImage?.jpegData(compressionQuality: 0.8) // Optional
        )
        context.insert(newRecipe)
        dismiss()
    }


    private func openAIScan() {
        // Add camera opening logic here
        print("Scan button tapped")
    }
}
