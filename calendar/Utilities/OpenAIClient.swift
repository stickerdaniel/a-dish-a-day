//
//  OpenAIIntegration.swift
//  calendar
//
//  Created by Daniel Sticker on 19.01.25.
//

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
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    func analyzeRecipeImage(imageData: Data, completion: @escaping (Result<AIRecipeData, Error>) -> Void) {
        guard let base64Image = imageData.base64EncodedString() as String? else {
            completion(.failure(NSError(domain: "Base64EncodingError", code: 0, userInfo: nil)))
            return
        }
        
    let payload: [String: Any] = [
        "model": "gpt-4o-mini",
        "messages": [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": """
                        Extract recipe details from this image and return as JSON with the following format:
                        - title: The recipe name
                        - ingredients: List each ingredient on a new line starting with "•". Always add emojis that are cooking / recipe related to each ingredient.
                        - instructions: Number each step (1. 2. ...) and put each step on a new line with an additional newline as spacing.
                        
                        Make sure to preserve all line breaks in the output.
                        NEVER use Oil Drum 🛢️ emoji. It doesn't show an edible ingredient, its commonly used for various content concerning petroleum or hazardous waste. Use 🌻 instead. Do not replace words with emojis. Add the emojis at the lineend.
                        """
                    ],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64Image)"
                        ]
                    ]
                ]
            ]
        ],
        "response_format": [
            "type": "json_schema",
            "json_schema": [
                "name": "recipe_extraction",  // <-- Add a schema name here
                "strict": true,
                "schema": [
                    "type": "object",
                    "properties": [
                        "title": ["type": "string"],
                        "ingredients": ["type": "string"],
                        "instructions": ["type": "string"]
                    ],
                    "required": ["title", "ingredients", "instructions"],
                    "additionalProperties": false
                ]
            ]
        ],
        "max_tokens": 500
    ]
        
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            var request = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestBody

            // debug print
            print("Sending request to \(apiURL)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in

                // print
                print("Response: \(String(data: data!, encoding: .utf8)!)")

                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    if let choices = jsonResponse?["choices"] as? [[String: Any]],
                    let firstChoice = choices.first,
                    let message = firstChoice["message"] as? [String: Any],
                    let content = message["content"] as? String,
                    let contentData = content.data(using: .utf8) {
                        
                        // Parse the inner JSON string
                        let decodedRecipe = try JSONDecoder().decode(AIRecipeData.self, from: contentData)
                        
                        completion(.success(decodedRecipe))
                    } else {
                        completion(.failure(NSError(domain: "ParsingError", code: 0, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
