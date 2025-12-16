//
//  OpenAIIntegration.swift
//  calendar
//
//  Created by Daniel Sticker on 19.01.25.
//  Here we handle the API calls to OpenAI. The custom promt ensures correct parsing and a consistent
//  output format. We get a JSON back with the title, ingredients and instructions (structured output)

import Foundation

struct AIRecipeData: Codable {
  let title: String
  let ingredients: String
  let instructions: String
}

enum OpenAIError: Error {
  case missingAPIKey
  case requestFailed(Int)
  case invalidData
}

class OpenAIIntegration {
  private var apiKey: String {
    UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
  }

  // swiftlint:disable:next force_unwrapping
  private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!

  private let recipePrompt = """
    Task: Analyze the image.
    - If it shows an actual recipe, use its exact title, ingredients (with amounts), and instructions.
    - If it's just a meal photo (no real recipe text), invent plausible amounts/steps but:
        1. Preface ingredients with "🎲 AI suggested 🎲"
        2. Use "✨⚠" instead of "•" before each item e.g., "✨⚠ 3 Teaspoons of salt 🧂 3tsp."
        ONLY DO THIS IF THE IMAGE IS NOT A REAL RECIPE.

    Output: Return JSON with three fields:
        {
        "title": "...",
        "ingredients": "...",
        "instructions": "..."
        }

    Ingredients Formatting:
    - Each ingredient on a new line, always starting with "• " (or "✨⚠ " if it's AI-suggested).
    - Add cooking/recipe emojis at ech line end (never replace words just append).
    - Never use the oil-drum emoji (🛢️). Use 🌻 for oil, 🧈 for butter.
    - If there are fewer than 4 units of something (e.g., 3 eggs), show that many emojis: "🥚🥚🥚".
    - For 4 or more, show the number instead (e.g., "4 eggs 🥚").
    - For cups/teaspoons or amounts like 2 1/3, always use just one emoji (e.g., "• 2 cups of flour 🌾").

    Instructions Formatting:
    - Number steps (1., 2., 3....), each on its own line with an extra blank line between steps.
    - No emojis in the instructions themselves.
    - You may add brief helpful parentheses (e.g., "(While the pasta boils, prepare the sauce)").
    - Include exactly one short motivational note somewhere (e.g., "You're going to love the result!"). \
    Do not use this exact note in the recipe, be creative.

    Language:
    - Use the same language found in the recipe text.

    Line Breaks:
    - Preserve all line breaks in your final JSON output.
    """

  func analyzeRecipeImage(
    imageData: Data, completion: @escaping (Result<AIRecipeData, Error>) -> Void
  ) {
    let base64Image = imageData.base64EncodedString()
    let payload = buildPayload(base64Image: base64Image)

    do {
      let requestBody = try JSONSerialization.data(withJSONObject: payload, options: [])
      var request = URLRequest(url: apiURL)
      request.httpMethod = "POST"
      request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = requestBody

      URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error {
          completion(.failure(error))
          return
        }
        guard let data = data else {
          completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: nil)))
          return
        }
        self.parseResponse(data: data, completion: completion)
      }.resume()
    } catch {
      completion(.failure(error))
    }
  }

  private func buildPayload(base64Image: String) -> [String: Any] {
    [
      "model": "gpt-4o-mini",
      "messages": [
        [
          "role": "user",
          "content": [
            ["type": "text", "text": recipePrompt],
            ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]],
          ],
        ]
      ],
      "response_format": [
        "type": "json_schema",
        "json_schema": [
          "name": "recipe_extraction",
          "strict": true,
          "schema": [
            "type": "object",
            "properties": [
              "title": ["type": "string"],
              "ingredients": ["type": "string"],
              "instructions": ["type": "string"],
            ],
            "required": ["title", "ingredients", "instructions"],
            "additionalProperties": false,
          ],
        ],
      ],
      "max_tokens": 500,
    ]
  }

  private func parseResponse(
    data: Data, completion: @escaping (Result<AIRecipeData, Error>) -> Void
  ) {
    do {
      let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

      if let choices = jsonResponse?["choices"] as? [[String: Any]],
        let firstChoice = choices.first,
        let message = firstChoice["message"] as? [String: Any],
        let content = message["content"] as? String,
        let contentData = content.data(using: .utf8)
      {
        let decodedRecipe = try JSONDecoder().decode(AIRecipeData.self, from: contentData)
        completion(.success(decodedRecipe))
      } else {
        completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: nil)))
      }
    } catch {
      completion(.failure(error))
    }
  }
}
