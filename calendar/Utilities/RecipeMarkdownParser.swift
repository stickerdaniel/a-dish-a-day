//
//  RecipeMarkdownParser.swift
//  calendar
//
//  Created by Daniel Sticker on 24.01.25.
//

import Foundation

struct RecipeMarkdownParser {
    enum ParsingError: Error {
        case noTitle
        case noIngredients
        case noInstructions
        case invalidFormat
    }
    
    static func parse(markdown: String) throws -> (name: String, ingredients: String, instructions: String) {
        let lines = markdown.components(separatedBy: .newlines)
        
        // Parse title (starts with single #)
        guard let titleLine = lines.first(where: { $0.hasPrefix("# ") }),
              let name = titleLine.dropFirst(2).takeWhile({ $0 != "\n" }) else {
            throw ParsingError.noTitle
        }
        
        // Find section markers
        guard let ingredientsIndex = lines.firstIndex(where: { $0.hasPrefix("## Ingredients") }),
              let instructionsIndex = lines.firstIndex(where: { $0.hasPrefix("## Instructions") }) else {
            throw ParsingError.invalidFormat
        }
        
        // Extract ingredients (everything between ## Ingredients and ## Instructions)
        let ingredientsStart = lines.index(after: ingredientsIndex)
        let ingredientsEnd = instructionsIndex
        let ingredients = lines[ingredientsStart..<ingredientsEnd]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        
        guard !ingredients.isEmpty else {
            throw ParsingError.noIngredients
        }
        
        // Extract instructions (everything after ## Instructions)
        let instructionsStart = lines.index(after: instructionsIndex)
        let instructions = lines[instructionsStart...]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        
        guard !instructions.isEmpty else {
            throw ParsingError.noInstructions
        }
        
        return (
            name: String(name).trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.trimmingCharacters(in: .whitespacesAndNewlines),
            instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

// Helper extension for String.SubSequence
private extension String.SubSequence {
    func takeWhile(_ predicate: (Character) -> Bool) -> String.SubSequence? {
        guard let endIndex = self.firstIndex(where: { !predicate($0) }) else {
            return self
        }
        return self[..<endIndex]
    }
}