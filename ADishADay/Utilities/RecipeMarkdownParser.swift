//
//  RecipeMarkdownParser.swift
//  calendar
//
//  Created by Daniel Sticker on 24.01.25.
//  Here we parse the markdown file and extract the name, ingredients and instructions. We return the result and missing elements for good user feedback.

import Foundation

struct RecipeMarkdownParser {
  struct ParseResult {
    var name: String
    var ingredients: String
    var instructions: String
    var missingElements: [String]

    var errorMessage: String? {
      guard !missingElements.isEmpty else { return nil }
      return "Missing sections in markdown:\n"
        + missingElements.map { "\($0)" }.joined(separator: "\n")
    }
  }

  static func parse(markdown: String) -> ParseResult {
    let lines = markdown.components(separatedBy: .newlines)
    var missingElements: [String] = []

    // Parse title (starts with single #)
    let name: String
    if let titleLine = lines.first(where: { $0.hasPrefix("# ") }),
      let extractedName = titleLine.dropFirst(2).takeWhile({ $0 != "\n" })
    {
      name = String(extractedName).trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      name = ""
      missingElements.append("Title (# Recipe Name)")
    }

    // Find section markers and extract content
    let ingredients: String
    let instructions: String

    // Extract ingredients
    if let ingredientsIndex = lines.firstIndex(where: { $0.hasPrefix("## Ingredients") }) {
      let nextSectionIndex = lines[ingredientsIndex...].firstIndex(where: {
        $0.hasPrefix("## ") && !$0.hasPrefix("## Ingredients")
      })
      let endIndex = nextSectionIndex ?? lines.endIndex
      let content = lines[lines.index(after: ingredientsIndex)..<endIndex]
        .filter { !$0.isEmpty }
        .joined(separator: "\n")

      ingredients = content.trimmingCharacters(in: .whitespacesAndNewlines)
      if ingredients.isEmpty {
        missingElements.append("Ingredients content after ## Ingredients")
      }
    } else {
      ingredients = ""
      missingElements.append("Ingredients (## Ingredients)")
    }

    // Extract instructions
    if let instructionsIndex = lines.firstIndex(where: { $0.hasPrefix("## Instructions") }) {
      let content = lines[lines.index(after: instructionsIndex)...]
        .filter { !$0.isEmpty }
        .joined(separator: "\n")

      instructions = content.trimmingCharacters(in: .whitespacesAndNewlines)
      if instructions.isEmpty {
        missingElements.append("Instructions content after ##Instructions")
      }
    } else {
      instructions = ""
      missingElements.append("Instructions (## Instructions)")
    }

    return ParseResult(
      name: name,
      ingredients: ingredients,
      instructions: instructions,
      missingElements: missingElements
    )
  }
}

// Helper extension for String.SubSequence
extension String.SubSequence {
  fileprivate func takeWhile(_ predicate: (Character) -> Bool) -> String.SubSequence? {
    guard let endIndex = self.firstIndex(where: { !predicate($0) }) else {
      return self
    }
    return self[..<endIndex]
  }
}
