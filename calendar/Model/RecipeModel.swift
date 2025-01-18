//
//  RecipeModel.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI
import SwiftData

@Model
class RecipeModel: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var ingredients: String
    var steps: String
    var thumbnailData: Data? // Store the image data for the thumbnail
    static let fallbackSymbols = ["book.pages.fill", "carrot.fill", "fork.knife", "stove.fill"]

    // Computed property to convert thumbnail data to a SwiftUI Image
    var thumbnailImage: Image? {
        if let data = thumbnailData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil  // No image
        }
    }

    // MARK: - Initializer
    init(name: String, ingredients: String = "", steps: String = "", thumbnailData: Data? = nil) {
        self.name = name
        self.ingredients = ingredients
        self.steps = steps
        self.thumbnailData = thumbnailData
    }

    // MARK: - Copy Function
    func copy() -> RecipeModel {
        RecipeModel(
            name: self.name,
            ingredients: self.ingredients,
            steps: self.steps,
            thumbnailData: self.thumbnailData
        )
    }

    // MARK: - Codable Conformance
    private enum CodingKeys: String, CodingKey {
        case id, name, ingredients, steps, thumbnailData
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        ingredients = try container.decode(String.self, forKey: .ingredients)
        steps = try container.decode(String.self, forKey: .steps)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(steps, forKey: .steps)
        try container.encode(thumbnailData, forKey: .thumbnailData)
    }
}
