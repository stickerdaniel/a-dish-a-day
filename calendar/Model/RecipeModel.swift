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
    }
    var id = UUID()
    var name: String
    var text: String
    var ingredients: String
    
    init(name: String, text: String, ingredients: String = "") {
        self.name = name
        self.text = text
        self.ingredients = ingredients
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        text = try container.decode(String.self, forKey: .text)
        ingredients = try container.decode(String.self, forKey: .ingredients)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(text, forKey: .text)
        try container.encode(ingredients, forKey: .ingredients)
    }

}

extension RecipeModel {
    

    static let sampleRecipes: [RecipeModel] = [
        RecipeModel(
            name: "Baklawa",
            text: "Tastes good"
        ),
        RecipeModel(
            name: "Peking Duck",
            text: "Available in all Chinese restaurants"
        ),
        RecipeModel(
            name: "Schwarma",
            text: "How fatty do you want it? Yes!"
        )


    ]
}
