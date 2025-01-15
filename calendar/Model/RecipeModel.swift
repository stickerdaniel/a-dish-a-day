//
//  RecipeModel.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI
import SwiftData

@Model
class RecipeModel: Identifiable {
    var id: UUID = UUID()
    var name: String
    var text: String
    var ingredients: String
    var thumbnailData: Data? // Store the image data for the thumbnail

    // Computed property to convert thumbnail data to a SwiftUI Image
    var thumbnailImage: Image? {
        if let data = thumbnailData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil  // No image
        }
    }

    init(name: String, text: String, ingredients: String = "", thumbnailData: Data? = nil) {
        self.name = name
        self.text = text
        self.ingredients = ingredients
        self.thumbnailData = thumbnailData
    }
}
