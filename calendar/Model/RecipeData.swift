//
//  RecipeData.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//

import SwiftUI

struct RecipeData: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var ingredients: String
    var steps: String
    var thumbnailData: Data?

    // Computed property to convert thumbnail data to a SwiftUI Image
    var thumbnailImage: Image? {
        if let data = thumbnailData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil  // No image
        }
    }
    
    init(recipe: RecipeModel) {
        self.name = recipe.name
        self.ingredients = recipe.ingredients
        self.steps = recipe.steps
        self.thumbnailData = recipe.thumbnailData
    }
}
