import Foundation
import SwiftUI

// MARK: - OpenAI Service
class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    // MARK: - Helper Functions
    private func openAIKey() -> String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
            let key = dict["OPENAI_API_KEY"] as? String,
            !key.isEmpty, key != "YOUR_KEY_HERE"
        else {
            fatalError("Missing OPENAI_API_KEY. Create Secrets.plist from Secrets.template.plist")
        }
        return key
    }
    
    // MARK: - Recipe Generation
    func generateRecipe(prompt: String, dietaryRestrictions: [String]) async throws -> Recipe {
        let systemPrompt = """
        You are a professional chef and recipe creator. Generate a detailed recipe based on the user's request. 
        Include specific measurements, cooking times, and clear step-by-step instructions.
        Format your response as JSON with the following structure:
        {
            "name": "Recipe Name",
            "cookingTime": "30 minutes",
            "difficulty": "Easy/Medium/Hard",
            "ingredients": ["ingredient1", "ingredient2"],
            "ingredientAmounts": {
                "ingredient1": "1 cup",
                "ingredient2": "2 tbsp"
            },
            "instructions": ["step1", "step2"],
            "dietaryTags": ["tag1", "tag2"]
        }
        """
        
        let userPrompt = """
        Create a recipe for: \(prompt)
        Dietary restrictions: \(dietaryRestrictions.joined(separator: ", "))
        
        Please provide a complete recipe with exact measurements and clear instructions.
        """
        
        let response = try await makeAPIRequest(systemPrompt: systemPrompt, userPrompt: userPrompt)
        return try parseRecipeFromResponse(response)
    }
    
    // MARK: - Meal Planning
    func generateMealPlan(days: [String], mealsPerDay: Int, dietaryPreferences: [String], complexity: RecipeComplexity? = nil) async throws -> [String: [String]] {
        let systemPrompt = """
        You are a nutritionist and meal planning expert. Create a balanced meal plan based on the user's preferences.
        Format your response as JSON with this structure:
        {
            "Monday": ["Breakfast meal", "Lunch meal", "Dinner meal"],
            "Tuesday": ["Breakfast meal", "Lunch meal", "Dinner meal"]
        }
        Ensure meals are varied, nutritionally balanced, and follow any dietary preferences.
        """
        
        let complexityDescription = complexity?.description ?? "moderate difficulty"
        let complexityLevel = complexity?.rawValue.lowercased() ?? "basic"
        
        let userPrompt = """
        Create a meal plan for the following days: \(days.joined(separator: ", "))
        Meals per day: \(mealsPerDay)
        Dietary preferences: \(dietaryPreferences.joined(separator: ", "))
        Recipe complexity: \(complexityLevel) - \(complexityDescription)
        
        Please provide \(mealsPerDay) meals per day that are healthy, varied, and delicious.
        For \(complexityLevel) recipes, focus on \(complexityDescription).
        """
        
        let response = try await makeAPIRequest(systemPrompt: systemPrompt, userPrompt: userPrompt)
        return try parseMealPlanFromResponse(response)
    }
    
    // MARK: - Budget Meal Planning
    func generateBudgetMealPlan(budget: Double, familySize: Int, preferences: [String]) async throws -> BudgetMealPlan {
        let systemPrompt = """
        You are a budget-conscious meal planner and nutritionist. Create a cost-effective meal plan that maximizes nutrition within the given budget.
        Format your response as JSON with this structure:
        {
            "meals": [
                {"name": "Meal Name", "cost": 5.50, "servings": 4},
                {"name": "Another Meal", "cost": 3.25, "servings": 4}
            ],
            "shoppingList": [
                "Item 1: $2.50",
                "Item 2: $1.75"
            ],
            "totalEstimatedCost": 45.50,
            "savingsPercentage": 15
        }
        """
        
        let userPrompt = """
        Create a budget meal plan with the following parameters:
        Weekly budget: $\(String(format: "%.2f", budget))
        Family size: \(familySize) people
        Preferences: \(preferences.joined(separator: ", "))
        
        Focus on affordable, nutritious meals that feed \(familySize) people within the budget.
        Include a shopping list with estimated prices.
        """
        
        let response = try await makeAPIRequest(systemPrompt: systemPrompt, userPrompt: userPrompt)
        return try parseBudgetPlanFromResponse(response, budget: budget, familySize: familySize)
    }
    
    // MARK: - API Request
    private func makeAPIRequest(systemPrompt: String, userPrompt: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let apiKey = openAIKey()
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": userPrompt
                ]
            ],
            "max_tokens": 2000,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw OpenAIError.invalidResponse
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = jsonResponse?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        return content
    }
    
    // MARK: - Response Parsing
    private func parseRecipeFromResponse(_ response: String) throws -> Recipe {
        // Clean the response to extract JSON
        let cleanedResponse = extractJSONFromResponse(response)
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            throw OpenAIError.parsingError
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let name = json?["name"] as? String,
                  let cookingTime = json?["cookingTime"] as? String,
                  let difficulty = json?["difficulty"] as? String,
                  let ingredients = json?["ingredients"] as? [String],
                  let instructions = json?["instructions"] as? [String],
                  let ingredientAmounts = json?["ingredientAmounts"] as? [String: String],
                  let dietaryTags = json?["dietaryTags"] as? [String] else {
                throw OpenAIError.parsingError
            }
            
            return Recipe(
                id: UUID(),
                name: name,
                ingredients: ingredients,
                dietaryTags: dietaryTags,
                cookingTime: cookingTime,
                instructions: instructions,
                ingredientAmounts: ingredientAmounts,
                isAIGenerated: true,
                difficulty: difficulty
            )
        } catch {
            throw OpenAIError.parsingError
        }
    }
    
    private func parseMealPlanFromResponse(_ response: String) throws -> [String: [String]] {
        let cleanedResponse = extractJSONFromResponse(response)
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            throw OpenAIError.parsingError
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            return json ?? [:]
        } catch {
            throw OpenAIError.parsingError
        }
    }
    
    private func parseBudgetPlanFromResponse(_ response: String, budget: Double, familySize: Int) throws -> BudgetMealPlan {
        let cleanedResponse = extractJSONFromResponse(response)
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            throw OpenAIError.parsingError
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let mealsData = json?["meals"] as? [[String: Any]],
                  let shoppingList = json?["shoppingList"] as? [String],
                  let totalCost = json?["totalEstimatedCost"] as? Double,
                  let savingsPercentage = json?["savingsPercentage"] as? Int else {
                throw OpenAIError.parsingError
            }
            
            let meals = mealsData.compactMap { mealData -> BudgetMeal? in
                guard let name = mealData["name"] as? String,
                      let cost = mealData["cost"] as? Double,
                      let servings = mealData["servings"] as? Int else {
                    return nil
                }
                return BudgetMeal(name: name, cost: cost, servings: servings)
            }
            
            return BudgetMealPlan(
                totalBudget: budget,
                dailyBudget: budget / 7,
                meals: meals,
                shoppingList: shoppingList,
                totalEstimatedCost: totalCost,
                savingsPercentage: savingsPercentage
            )
        } catch {
            throw OpenAIError.parsingError
        }
    }
    
    private func extractJSONFromResponse(_ response: String) -> String {
        // Remove markdown code blocks if present
        var cleaned = response
        if let startRange = cleaned.range(of: "```json") {
            cleaned = String(cleaned[startRange.upperBound...])
        }
        if let endRange = cleaned.range(of: "```") {
            cleaned = String(cleaned[..<endRange.lowerBound])
        }
        
        // Find the JSON object by looking for opening and closing braces
        if let startIndex = cleaned.firstIndex(of: "{"),
           let endIndex = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[startIndex...endIndex])
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Recipe Complexity Enum
enum RecipeComplexity: String, CaseIterable {
    case basic = "Basic"
    case advanced = "Advanced"
    
    var description: String {
        switch self {
        case .basic:
            return "Simple, everyday recipes with common ingredients and easy techniques"
        case .advanced:
            return "Complex recipes with unique techniques, specialty ingredients, and sophisticated cooking methods"
        }
    }
}

// MARK: - OpenAI Errors
enum OpenAIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case parsingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid API response"
        case .parsingError:
            return "Failed to parse response"
        case .networkError:
            return "Network error occurred"
        }
    }
}
