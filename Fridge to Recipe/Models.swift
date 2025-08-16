//
//  Models.swift
//  Fridge to Recipe
//
//  Created by Ranil Perera on 6/7/2025.
//

import Foundation
import SwiftUI
import UserNotifications
import Vision
import VisionKit

// MARK: - Models
struct IngredientEntry: Identifiable, Equatable, Codable {
    let id = UUID()
    var name: String
    var expiry: Date?
}

struct RecipeStep: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let duration: TimeInterval // seconds
    
    init(id: UUID = UUID(), name: String, duration: TimeInterval) {
        self.id = id
        self.name = name
        self.duration = duration
    }
}

struct Recipe: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let ingredients: [String]
    let dietaryTags: [String]
    let cookingTime: String
    let instructions: [String]
    let ingredientAmounts: [String: String]
    var isAIGenerated: Bool
    let difficulty: String
    var imageURL: String? // Unsplash image URL
    var photographerName: String?
    var photographerURL: String?
    var downloadLocation: String?
    var steps: [RecipeStep] = [] // Add this property for Cook Now steps
    
    // MARK: - Recipe Sharing
    func shareableText() -> String {
        var text = "🍽️ \(name)\n\n"
        
        // Add cooking time and difficulty
        text += "⏱️ Time: \(cookingTime)\n"
        text += "📊 Difficulty: \(difficulty)\n\n"
        
        // Add dietary tags if any
        if !dietaryTags.isEmpty {
            text += "🏷️ Tags: \(dietaryTags.joined(separator: ", "))\n\n"
        }
        
        // Add ingredients
        text += "📝 Ingredients:\n"
        for (index, ingredient) in ingredients.enumerated() {
            let amount = ingredientAmounts[ingredient] ?? "to taste"
            text += "\(index + 1). \(ingredient) - \(amount)\n"
        }
        text += "\n"
        
        // Add instructions
        text += "👨‍🍳 Instructions:\n"
        for (index, instruction) in instructions.enumerated() {
            text += "\(index + 1). \(instruction)\n"
        }
        text += "\n"
        
        // Add footer
        text += "📱 Shared from Fridge to Recipe"
        
        return text
    }
    
    func shareableURL() -> URL? {
        // Create a deep link URL for the recipe
        let urlString = "fridgetorecipe://recipe/\(id.uuidString)"
        return URL(string: urlString)
    }
    
    func shareableImage() -> UIImage? {
        // For now, return nil. In the future, this could generate a recipe card image
        return nil
    }
}

struct RecipeMatch: Identifiable, Equatable {
    let id = UUID()
    let recipe: Recipe
    let isExact: Bool
}

struct ShoppingListItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var isChecked: Bool
    var expiryDate: Date?
    var price: Double? // Price tracking
    var estimatedPrice: Double? // Estimated price for budget planning
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
}

// MARK: - App Data Model
class AppDataModel: ObservableObject {
    @Published var ingredients: [IngredientEntry] = [] {
        didSet { saveIngredients() }
    }
    @Published var suggestedRecipes: [RecipeMatch] = []
    @Published var achievements: [Achievement] = []
    @Published var shoppingListItems: [ShoppingListItem] = []
    @Published var recipes: [Recipe] = [] // All recipes, including image URLs
    @Published var favouriteRecipeIDs: [UUID] = [] {
        didSet { saveFavourites() }
    }

    init() {
        // Load ingredients
        if let data = UserDefaults.standard.data(forKey: "ingredients"),
           let saved = try? JSONDecoder().decode([IngredientEntry].self, from: data) {
            self.ingredients = saved
        }
        // Load favourites
        if let data = UserDefaults.standard.data(forKey: "favouriteRecipeIDs"),
           let saved = try? JSONDecoder().decode([UUID].self, from: data) {
            self.favouriteRecipeIDs = saved
        }
    }
    
    func scheduleExpiryNotification(for ingredient: IngredientEntry) {
        guard let expiry = ingredient.expiry else { return }
        let content = UNMutableNotificationContent()
        content.title = "Ingredient Expiry Reminder"
        let ingredientName = ingredient.name.capitalized
        content.body = "Your ingredient \(ingredientName) is expiring today!"
        content.sound = .default
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day], from: expiry)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "expiry-\(ingredient.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelExpiryNotification(for ingredient: IngredientEntry) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["expiry-\(ingredient.id)"])
    }
    
    private func saveIngredients() {
        // Save ingredients asynchronously to avoid blocking UI
        let currentIngredients = ingredients // Capture current state
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? JSONEncoder().encode(currentIngredients) {
                UserDefaults.standard.set(data, forKey: "ingredients")
            }
        }
    }
    private func saveFavourites() {
        // Save favorites synchronously for immediate persistence and data reliability
        if let data = try? JSONEncoder().encode(favouriteRecipeIDs) {
            UserDefaults.standard.set(data, forKey: "favouriteRecipeIDs")
            // Force synchronization to ensure data is written immediately
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Optimized Favorite Methods
    func toggleFavorite(recipeID: UUID) {
        // Immediate UI update
        if let index = favouriteRecipeIDs.firstIndex(of: recipeID) {
            favouriteRecipeIDs.remove(at: index)
        } else {
            favouriteRecipeIDs.append(recipeID)
        }
        // Async saving happens automatically via didSet
    }
    
    func addToFavorites(recipeID: UUID) {
        guard !favouriteRecipeIDs.contains(recipeID) else { return }
        favouriteRecipeIDs.append(recipeID)
    }
    
    func removeFromFavorites(recipeID: UUID) {
        favouriteRecipeIDs.removeAll { $0 == recipeID }
    }
}

struct ShoppingList: Identifiable, Codable {
    var id = UUID()
    var name: String
    var color: String // Store as string for Codable
    var icon: String
    var items: [String]
    var itemPrices: [String: Double] = [:] // Track prices for each item
    var totalBudget: Double? // Optional budget limit

    init(name: String, color: String, icon: String, items: [String] = [], itemPrices: [String: Double] = [:], totalBudget: Double? = nil) {
        self.name = name
        self.color = color
        self.icon = icon
        self.items = items
        self.itemPrices = itemPrices
        self.totalBudget = totalBudget
    }
    
    var colorValue: Color {
        switch color {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "gray": return .gray
        default: return .blue
        }
    }
}

class ShoppingListViewModel: ObservableObject {
    @Published var selectedList: String = "Smart List"
    @Published var cookedRecipes: [UUID] = [] {
        didSet { saveCookedRecipes() }
    }
    @Published var smartListItems: [String] = [] {
        didSet { saveSmartListItems() }
    }
    @Published var manualLists: [ShoppingList] = [] {
        didSet { saveManualLists() }
    }
    init() {
        // Load cooked recipes
        if let data = UserDefaults.standard.data(forKey: "cookedRecipes"),
           let saved = try? JSONDecoder().decode([UUID].self, from: data) {
            self.cookedRecipes = saved
        }
        // Load smart list
        if let data = UserDefaults.standard.data(forKey: "smartListItems"),
           let saved = try? JSONDecoder().decode([String].self, from: data) {
            self.smartListItems = saved
        }
        // Load manual lists
        if let data = UserDefaults.standard.data(forKey: "manualLists"),
           let saved = try? JSONDecoder().decode([ShoppingList].self, from: data) {
            self.manualLists = saved
        }
    }
    
    private func saveCookedRecipes() {
        // Save cooked recipes synchronously for immediate persistence and data reliability
        if let data = try? JSONEncoder().encode(cookedRecipes) {
            UserDefaults.standard.set(data, forKey: "cookedRecipes")
            // Force synchronization to ensure data is written immediately
            UserDefaults.standard.synchronize()
        }
    }
    
    private func saveSmartListItems() {
        if let data = try? JSONEncoder().encode(smartListItems) {
            UserDefaults.standard.set(data, forKey: "smartListItems")
        }
    }
    
    private func saveManualLists() {
        if let data = try? JSONEncoder().encode(manualLists) {
            UserDefaults.standard.set(data, forKey: "manualLists")
        }
    }
    
    // MARK: - Price Tracking Methods
    func getTotalPrice(for listName: String) -> Double {
        if listName == "Smart List" {
            return 0.0 // Smart list doesn't track prices
        }
        
        if let list = manualLists.first(where: { $0.name == listName }) {
            return list.itemPrices.values.reduce(0, +)
        }
        return 0.0
    }
    
    func getBudgetRemaining(for listName: String) -> Double? {
        if listName == "Smart List" {
            return nil
        }
        
        if let list = manualLists.first(where: { $0.name == listName }),
           let budget = list.totalBudget {
            return budget - getTotalPrice(for: listName)
        }
        return nil
    }
    
    func setPrice(for item: String, price: Double, in listName: String) {
        if let index = manualLists.firstIndex(where: { $0.name == listName }) {
            manualLists[index].itemPrices[item] = price
        }
    }
    
    func setBudget(for listName: String, budget: Double?) {
        if let index = manualLists.firstIndex(where: { $0.name == listName }) {
            manualLists[index].totalBudget = budget
        }
    }
    
    func clearBudgetData(for listName: String) {
        if let index = manualLists.firstIndex(where: { $0.name == listName }) {
            manualLists[index].totalBudget = nil
            manualLists[index].itemPrices.removeAll()
        }
    }
}

// MARK: - Shopping List Scanner
class ShoppingListScanner: ObservableObject {
    @Published var isScanning = false
    @Published var scannedItems: [String] = []
    @Published var showScanner = false
    
    func scanImage(_ image: UIImage) async {
        await MainActor.run {
            isScanning = true
        }
        
        do {
            let items = try await extractTextFromImage(image)
            await MainActor.run {
                self.scannedItems = processShoppingItems(items)
                self.isScanning = false
            }
        } catch {
            await MainActor.run {
                self.isScanning = false
            }
            print("Error scanning image: \(error)")
        }
    }
    
    private func extractTextFromImage(_ image: UIImage) async throws -> [String] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Vision error: \(error)")
            }
        }
        
        // Enhanced configuration for better handwritten text recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        request.minimumTextHeight = 0.01 // Better for smaller text
        request.customWords = [
            // Common shopping items for better recognition
            "milk", "bread", "eggs", "cheese", "butter", "yogurt", "apple", "banana", "orange",
            "tomato", "lettuce", "carrot", "onion", "potato", "chicken", "beef", "pork", "fish",
            "rice", "pasta", "sauce", "oil", "salt", "pepper", "sugar", "flour", "cereal",
            "juice", "water", "soda", "beer", "wine", "coffee", "tea", "chips", "cookies",
            "candy", "chocolate", "ice cream", "frozen", "fresh", "organic", "whole", "skim",
            "low fat", "fat free", "gluten free", "dairy free", "vegan", "vegetarian"
        ]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        guard let observations = request.results else {
            return []
        }
        
        var extractedText: [String] = []
        for observation in observations {
            // Get multiple candidates for better accuracy
            let candidates = observation.topCandidates(3)
            for candidate in candidates {
                let confidence = candidate.confidence
                if confidence > 0.3 { // Lower threshold to catch more items
                    extractedText.append(candidate.string)
                }
            }
        }
        
        return extractedText
    }
    
    private func processShoppingItems(_ rawItems: [String]) -> [String] {
        var processedItems: [String] = []
        var seenItems: Set<String> = []
        
        for item in rawItems {
            let cleanedItem = cleanShoppingItem(item)
            let normalizedItem = normalizeItem(cleanedItem)
            
            if !normalizedItem.isEmpty && !seenItems.contains(normalizedItem) {
                processedItems.append(normalizedItem)
                seenItems.insert(normalizedItem)
            }
        }
        
        // Sort items for better presentation
        return processedItems.sorted()
    }
    
    private func normalizeItem(_ item: String) -> String {
        var normalized = item.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Common item variations and corrections
        let itemCorrections: [String: String] = [
            "milk": "milk",
            "mil": "milk",
            "mlk": "milk",
            "bread": "bread",
            "bred": "bread",
            "brd": "bread",
            "eggs": "eggs",
            "egg": "eggs",
            "cheese": "cheese",
            "chz": "cheese",
            "butter": "butter",
            "but": "butter",
            "yogurt": "yogurt",
            "yoghurt": "yogurt",
            "apple": "apple",
            "appl": "apple",
            "banana": "banana",
            "ban": "banana",
            "orange": "orange",
            "orng": "orange",
            "tomato": "tomato",
            "tom": "tomato",
            "lettuce": "lettuce",
            "let": "lettuce",
            "carrot": "carrot",
            "car": "carrot",
            "onion": "onion",
            "on": "onion",
            "potato": "potato",
            "pot": "potato",
            "chicken": "chicken",
            "chk": "chicken",
            "beef": "beef",
            "pork": "pork",
            "fish": "fish",
            "rice": "rice",
            "pasta": "pasta",
            "sauce": "sauce",
            "oil": "oil",
            "salt": "salt",
            "pepper": "pepper",
            "sugar": "sugar",
            "flour": "flour",
            "cereal": "cereal",
            "juice": "juice",
            "water": "water",
            "soda": "soda",
            "beer": "beer",
            "wine": "wine",
            "coffee": "coffee",
            "tea": "tea",
            "chips": "chips",
            "cookies": "cookies",
            "candy": "candy",
            "chocolate": "chocolate",
            "ice cream": "ice cream",
            "frozen": "frozen",
            "fresh": "fresh",
            "organic": "organic"
        ]
        
        // Apply corrections
        for (incorrect, correct) in itemCorrections {
            if normalized.contains(incorrect) {
                normalized = normalized.replacingOccurrences(of: incorrect, with: correct)
            }
        }
        
        return normalized
    }
    
    private func cleanShoppingItem(_ item: String) -> String {
        var cleaned = item.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove common quantities and measurements with better patterns
        let quantityPatterns = [
            "\\b\\d+\\s*", // numbers
            "\\b\\d+\\s*kg\\b", "\\b\\d+\\s*lb\\b", "\\b\\d+\\s*oz\\b", // weights
            "\\b\\d+\\s*ml\\b", "\\b\\d+\\s*l\\b", "\\b\\d+\\s*gal\\b", // volumes
            "\\b\\d+\\s*pcs\\b", "\\b\\d+\\s*pieces\\b", // pieces
            "\\b\\d+\\s*packs?\\b", "\\b\\d+\\s*bags?\\b", // packs/bags
            "\\b\\d+\\s*cans?\\b", "\\b\\d+\\s*jars?\\b", // cans/jars
            "\\b\\d+\\s*bottles?\\b", "\\b\\d+\\s*boxes?\\b", // bottles/boxes
            "\\b\\d+\\s*dozen\\b", "\\b\\d+\\s*dz\\b", // dozen
            "\\b\\d+\\s*pounds?\\b", "\\b\\d+\\s*lbs?\\b", // pounds
            "\\b\\d+\\s*ounces?\\b", "\\b\\d+\\s*oz\\b", // ounces
            "\\b\\d+\\s*grams?\\b", "\\b\\d+\\s*g\\b", // grams
            "\\b\\d+\\s*kilos?\\b", "\\b\\d+\\s*kg\\b" // kilos
        ]
        
        for pattern in quantityPatterns {
            cleaned = cleaned.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        
        // Remove common prefixes/suffixes and action words
        let commonWords = [
            "buy", "get", "need", "want", "add", "pick up", "grab", "purchase",
            "check", "find", "look for", "remember", "don't forget", "must get",
            "to buy", "to get", "to pick up", "shopping", "list", "items"
        ]
        
        for word in commonWords {
            cleaned = cleaned.replacingOccurrences(of: word, with: "", options: [.caseInsensitive, .regularExpression])
        }
        
        // Remove common punctuation and symbols
        let punctuationPatterns = [
            "[-_•·]", // dashes, underscores, bullets
            "[✓✔☑]", // checkmarks
            "[✗✘☒]", // x marks
            "[()]", // parentheses
            "[\\[\\]]", // brackets
            "[{}]", // braces
        ]
        
        for pattern in punctuationPatterns {
            cleaned = cleaned.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        
        // Clean up extra spaces and normalize
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove items that are too short or too long
        if cleaned.count < 2 || cleaned.count > 50 {
            return ""
        }
        
        return cleaned
    }
    
    func addScannedItemsToShoppingList(_ items: [String], shoppingList: ShoppingListViewModel) {
        for item in items {
            if !item.isEmpty {
                shoppingList.smartListItems.append(item)
            }
        }
    }
}

enum VisionError: Error {
    case invalidImage
}

// MARK: - AI Cleanup
class AICleanupManager: ObservableObject {
    @Published var isProcessing = false
    @Published var cleanedItems: [String] = []
    @Published var showCleanupResults = false
    
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
    
    func cleanupItems(_ items: [String]) async {
        await MainActor.run {
            isProcessing = true
        }
        
        do {
            let cleanedItems = try await performAICleanup(items)
            await MainActor.run {
                self.cleanedItems = cleanedItems
                self.isProcessing = false
                self.showCleanupResults = true
            }
        } catch {
            await MainActor.run {
                self.isProcessing = false
            }
            print("AI Cleanup error: \(error)")
        }
    }
    
    private func performAICleanup(_ items: [String]) async throws -> [String] {
        let prompt = """
        Analyze this shopping list and clean it up. Remove duplicates, fix misspellings, correct inaccurate items, and organize it properly. Return only the cleaned items as a simple list, one item per line, without numbers or bullet points.
        
        Shopping list items:
        \(items.joined(separator: "\n"))
        
        Instructions:
        1. Remove duplicates
        2. Fix misspellings (e.g., "mil" → "milk", "bred" → "bread")
        3. Correct inaccurate items
        4. Remove non-food items unless they're clearly household essentials
        5. Standardize item names
        6. Remove quantities and measurements
        7. Return only the cleaned items, one per line
        """
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let apiKey = openAIKey()
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that cleans up shopping lists. Return only the cleaned items, one per line, without any formatting, numbers, or bullet points."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 500,
            "temperature": 0.3
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = response?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AICleanupError.invalidResponse
        }
        
        // Parse the cleaned items from the response
        let cleanedItems = content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
        
        return cleanedItems
    }
}

enum AICleanupError: Error {
    case invalidResponse
    case networkError
}


// MARK: - Tip Row Component
struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Scanned Items Preview View
struct ScannedItemsPreviewView: View {
    @ObservedObject var scanner: ShoppingListScanner
    @ObservedObject var shoppingList: ShoppingListViewModel
    @StateObject private var aiCleanup = AICleanupManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Items Found!")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("Select the items you want to add to your shopping list")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Items List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(scanner.scannedItems, id: \.self) { item in
                            HStack {
                                Button(action: {
                                    if selectedItems.contains(item) {
                                        selectedItems.remove(item)
                                    } else {
                                        selectedItems.insert(item)
                                    }
                                }) {
                                    Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedItems.contains(item) ? .green : .gray)
                                        .font(.title3)
                                }
                                
                                Text(item.capitalized)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: {
                            selectedItems = Set(scanner.scannedItems)
                        }) {
                            Text("Select All")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange, lineWidth: 2)
                                )
                        }
                        
                        Button(action: {
                            Task {
                                await aiCleanup.cleanupItems(Array(selectedItems))
                            }
                        }) {
                            HStack(spacing: 8) {
                                if aiCleanup.isProcessing {
                                    // Loading animation
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                
                                Text(aiCleanup.isProcessing ? "Processing..." : "AI Cleanup")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(
                                ZStack {
                                    // Base gradient
                                    LinearGradient(
                                        colors: [Color.purple.opacity(aiCleanup.isProcessing ? 0.7 : 1.0), 
                                               Color.blue.opacity(aiCleanup.isProcessing ? 0.7 : 1.0)], 
                                        startPoint: .leading, 
                                        endPoint: .trailing
                                    )
                                    
                                    // Loading bar overlay when processing
                                    if aiCleanup.isProcessing {
                                        VStack {
                                            Spacer()
                                            Rectangle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(height: 3)
                                                .animation(
                                                    Animation.easeInOut(duration: 1.5)
                                                        .repeatForever(autoreverses: true),
                                                    value: aiCleanup.isProcessing
                                                )
                                        }
                                    }
                                }
                            )
                            .cornerRadius(12)
                            .shadow(color: aiCleanup.isProcessing ? .clear : .purple.opacity(0.3), radius: 4, y: 2)
                        }
                        .disabled(selectedItems.isEmpty || aiCleanup.isProcessing)
                        .animation(.easeInOut(duration: 0.3), value: aiCleanup.isProcessing)
                    }
                    
                    Button(action: {
                        addSelectedItems()
                        dismiss()
                    }) {
                        Text("Add \(selectedItems.count) Items to Shopping List")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(selectedItems.isEmpty)
                    .opacity(selectedItems.isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $aiCleanup.showCleanupResults) {
            AICleanupResultsView(
                originalItems: Array(selectedItems),
                cleanedItems: aiCleanup.cleanedItems,
                shoppingList: shoppingList
            )
        }
        .onAppear {
            selectedItems = Set(scanner.scannedItems)
        }
    }
    
    private func addSelectedItems() {
        for item in selectedItems {
            let capitalizedItem = item.capitalized
            
            // Check if item already exists in the current list
            let currentItems = shoppingList.selectedList == "Smart List" 
                ? shoppingList.smartListItems 
                : shoppingList.manualLists.first(where: { $0.name == shoppingList.selectedList })?.items ?? []
            
            if !currentItems.contains(capitalizedItem) {
                if shoppingList.selectedList == "Smart List" {
                    shoppingList.smartListItems.append(capitalizedItem)
                } else {
                    if let index = shoppingList.manualLists.firstIndex(where: { $0.name == shoppingList.selectedList }) {
                        shoppingList.manualLists[index].items.append(capitalizedItem)
                    }
                }
            }
        }
    }
}

// MARK: - AI Cleanup Results View
struct AICleanupResultsView: View {
    let originalItems: [String]
    let cleanedItems: [String]
    @ObservedObject var shoppingList: ShoppingListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)
                    
                    Text("AI Cleanup Complete!")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("AI has analyzed and cleaned up your shopping list")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Results Summary
                VStack(spacing: 8) {
                    HStack {
                        Text("Original Items:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(originalItems.count)")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("Cleaned Items:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(cleanedItems.count)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 20)
                
                // Cleaned Items List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(cleanedItems, id: \.self) { item in
                            HStack {
                                Button(action: {
                                    if selectedItems.contains(item) {
                                        selectedItems.remove(item)
                                    } else {
                                        selectedItems.insert(item)
                                    }
                                }) {
                                    Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedItems.contains(item) ? .green : .gray)
                                        .font(.title3)
                                }
                                
                                Text(item.capitalized)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        selectedItems = Set(cleanedItems)
                    }) {
                        Text("Select All Cleaned Items")
                            .font(.headline)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        addSelectedItems()
                        dismiss()
                    }) {
                        Text("Add \(selectedItems.count) Cleaned Items to Shopping List")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(selectedItems.isEmpty)
                    .opacity(selectedItems.isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
        .onAppear {
            selectedItems = Set(cleanedItems)
        }
    }
    
    private func addSelectedItems() {
        for item in selectedItems {
            let capitalizedItem = item.capitalized
            
            // Check if item already exists in the current list
            let currentItems = shoppingList.selectedList == "Smart List" 
                ? shoppingList.smartListItems 
                : shoppingList.manualLists.first(where: { $0.name == shoppingList.selectedList })?.items ?? []
            
            if !currentItems.contains(capitalizedItem) {
                if shoppingList.selectedList == "Smart List" {
                    shoppingList.smartListItems.append(capitalizedItem)
                } else {
                    if let index = shoppingList.manualLists.firstIndex(where: { $0.name == shoppingList.selectedList }) {
                        shoppingList.manualLists[index].items.append(capitalizedItem)
                    }
                }
            }
        }
    }
}

// MARK: - Scanner Image Picker
struct ScannerImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ScannerImagePicker
        
        init(_ parent: ScannerImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

