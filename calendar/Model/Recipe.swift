//
//  Recipe.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//
import SwiftUI
import SwiftData

@Model
class Recipe: Identifiable, Hashable, Codable {
    enum CodingKeys: CodingKey {
        case name
        case text
    }
    var id = UUID()
    var name: String
    var text: String
    
    init(name: String, text: String) {
        self.name = name
        self.text = text
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        text = try container.decode(String.self, forKey: .text)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(text, forKey: .text)
    }

}

extension Recipe {
    

    static let sampleRecipes: [Recipe] = [
        Recipe(
            name: "Baklawa",
            text: "Tastes good"
        ),
        Recipe(
            name: "Peking Duck",
            text: "Available in all Chinese restaurants"
        ),
        Recipe(
            name: "Schwarma",
            text: "How fatty do you want it? Yes!"
        )


    ]
}
