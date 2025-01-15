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

    // MARK: - Initializer
    init(name: String, text: String, ingredients: String = "", thumbnailData: Data? = nil) {
        self.name = name
        self.text = text
        self.ingredients = ingredients
        self.thumbnailData = thumbnailData
    }

    // MARK: - Codable Conformance
    private enum CodingKeys: String, CodingKey {
        case id, name, text, ingredients, thumbnailData
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        text = try container.decode(String.self, forKey: .text)
        ingredients = try container.decode(String.self, forKey: .ingredients)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(text, forKey: .text)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(thumbnailData, forKey: .thumbnailData)
    }
}
