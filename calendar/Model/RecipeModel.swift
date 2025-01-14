//
//  RecipeModel.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI
import SwiftData

@Model
class RecipeModel: Identifiable, Hashable, Codable {
    enum CodingKeys: CodingKey {
        case name
        case text
        case ingredients
        case thumbnailData
    }

    var id = UUID()
    var name: String
    var text: String
    var ingredients: String
    var thumbnailData: Data? // Store the image data for the thumbnail

    // Computed property to convert thumbnail data to a SwiftUI Image
    var thumbnailImage: Image {
        if let data = thumbnailData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return Image("recipe-default-thumbnail") // Default image
        }
    }

    init(name: String, text: String, ingredients: String = "", thumbnailData: Data? = nil) {
        self.name = name
        self.text = text
        self.ingredients = ingredients
        self.thumbnailData = thumbnailData
    }

    // Codable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        text = try container.decode(String.self, forKey: .text)
        ingredients = try container.decode(String.self, forKey: .ingredients)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(text, forKey: .text)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(thumbnailData, forKey: .thumbnailData)
    }
}

extension RecipeModel {
    static let sampleRecipes: [RecipeModel] = [
        RecipeModel(
            name: "Baklawa",
            text: "Tastes good",
            thumbnailData: UIImage(named: "baklawa")?.jpegData(compressionQuality: 0.8)
        ),
        RecipeModel(
            name: "Peking Duck",
            text: "Available in all Chinese restaurants",
            thumbnailData: UIImage(named: "peking-duck")?.jpegData(compressionQuality: 0.8)
        ),
        RecipeModel(
            name: "Schwarma",
            text: "How fatty do you want it? Yes!",
            thumbnailData: nil // Fallback to default recipe thumbnail
        )
    ]
}
