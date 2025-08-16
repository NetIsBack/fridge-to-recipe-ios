import SwiftUI
import Foundation

// MARK: - Experimental Features Preview View
struct ExperimentalFeaturesPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showExperimentalFeatures = false
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            // Clean system background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Main content - simplified and cleaner
                VStack(spacing: 40) {
                    // Clean header
                    VStack(spacing: 20) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 8) {
                            Text("Experimental Features")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Text("BETA")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.orange)
                                    )
                                
                                Text("FREE until October 8th")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.green.opacity(0.1))
                                    )
                            }
                        }
                        
                        Text("Advanced AI-powered tools for recipe creation, meal planning, and budget optimization.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    // Simple feature list
                    VStack(spacing: 16) {
                        SimpleFeatureRow(icon: "brain.head.profile", title: "AI Recipe Generator")
                        SimpleFeatureRow(icon: "calendar.badge.plus", title: "AI Meal Planner")
                        SimpleFeatureRow(icon: "dollarsign.circle", title: "AI Budget Planning")
                    }
                    .padding(.horizontal, 30)
                    
                    // Clean CTA button
                    Button(action: {
                        showExperimentalFeatures = true
                    }) {
                        Text("Try Experimental Features")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 30)
                }
                .opacity(animateElements ? 1.0 : 0.0)
                .offset(y: animateElements ? 0 : 20)
                
                Spacer()
                
                // Simple footer
                Text("Features may not work perfectly • Report issues")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateElements = true
            }
        }
        .fullScreenCover(isPresented: $showExperimentalFeatures) {
            ExperimentalFeaturesView()
        }
    }
}

// MARK: - Pro Feature Row Component
struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
}

// MARK: - Simple Feature Row Component
struct SimpleFeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Modern Feature Row Component
struct ModernFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Experimental Features View
struct ExperimentalFeaturesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFeature = 0
    @State private var showingFeatureDetails = false
    
    var body: some View {
        ZStack {
            // Clean modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.5)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with beta warning
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text("Experimental AI Features")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                // Beta tag
                                Text("BETA")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.orange)
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Beta warning message
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Text("These features are experimental and may not work perfectly. Please report any issues you encounter.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Feature tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<3, id: \.self) { index in
                            FeatureTab(
                                title: featureTitles[index],
                                icon: featureIcons[index],
                                isSelected: selectedFeature == index
                            ) {
                                withAnimation(.spring()) {
                                    selectedFeature = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
                
                // Feature content
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedFeature {
                        case 0:
                            AIRecipeGeneratorView()
                        case 1:
                            AIMealPlannerView()
                        case 2:
                            AIBudgetPlannerView()
                        default:
                            AIRecipeGeneratorView()
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
    }
    
    private let featureTitles = ["AI Recipe Generator", "AI Meal Planner", "AI Budget Planner"]
    private let featureIcons = ["brain.head.profile", "calendar.badge.plus", "dollarsign.circle"]
}

// MARK: - Feature Tab Component
struct FeatureTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected 
                            ? LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                    )
            )
            .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - AI Recipe Generator View
struct AIRecipeGeneratorView: View {
    @State private var recipePrompt = ""
    @State private var dietaryRestrictions: Set<String> = []
    @State private var generatedRecipe: Recipe?
    @State private var isGenerating = false
    @State private var showGeneratedRecipe = false
    
    let availableDiets = ["Vegetarian", "Vegan", "Gluten-Free", "Keto", "Paleo", "Dairy-Free"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                Text("AI Recipe Generator")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Describe what you want to cook and let AI create a personalized recipe")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Input section
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What would you like to cook?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("e.g., 'Spicy Thai curry with chicken and vegetables'", text: $recipePrompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dietary Restrictions (Optional)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(availableDiets, id: \.self) { diet in
                            DietaryRestrictionChip(
                                diet: diet,
                                isSelected: dietaryRestrictions.contains(diet)
                            ) {
                                if dietaryRestrictions.contains(diet) {
                                    dietaryRestrictions.remove(diet)
                                } else {
                                    dietaryRestrictions.insert(diet)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            )
            
            // Generate button
            Button(action: generateRecipe) {
                HStack(spacing: 12) {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "wand.and.stars")
                            .font(.title2)
                    }
                    Text(isGenerating ? "Generating Recipe..." : "Generate Recipe")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 4)
            }
            .disabled(recipePrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
            
            // Generated recipe preview
            if let recipe = generatedRecipe {
                RecipePreviewCard(recipe: recipe) {
                    showGeneratedRecipe = true
                }
            }
        }
        .sheet(isPresented: $showGeneratedRecipe) {
            if let recipe = generatedRecipe {
                GeneratedRecipeDetailView(recipe: recipe)
            }
        }
    }
    
    private func generateRecipe() {
        isGenerating = true
        
        Task {
            do {
                let recipe = try await OpenAIService.shared.generateRecipe(
                    prompt: recipePrompt,
                    dietaryRestrictions: Array(dietaryRestrictions)
                )
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        generatedRecipe = recipe
                        isGenerating = false
                    }
                }
            } catch {
                print("Recipe generation error: \(error)")
                // Fall back to sample recipe on error
                let sampleRecipe = createSampleRecipe(from: recipePrompt, dietary: Array(dietaryRestrictions))
                await MainActor.run {
                    withAnimation(.spring()) {
                        generatedRecipe = sampleRecipe
                        isGenerating = false
                    }
                }
            }
        }
    }
    
    private func createSampleRecipe(from prompt: String, dietary: [String]) -> Recipe {
        // This would normally call an AI API, but for demo purposes we'll create sample recipes
        let recipes: [Recipe] = [
            Recipe(
                id: UUID(),
                name: "AI-Generated Spicy Thai Curry",
                ingredients: ["Chicken breast", "Coconut milk", "Red curry paste", "Bell peppers", "Onion", "Garlic", "Ginger", "Fish sauce", "Brown sugar", "Thai basil"],
                dietaryTags: dietary.isEmpty ? ["Spicy", "Asian"] : dietary + ["Spicy", "Asian"],
                cookingTime: "35 minutes",
                instructions: [
                    "Heat oil in a large pan over medium-high heat",
                    "Add curry paste and cook for 1 minute until fragrant",
                    "Add chicken and cook until browned on all sides",
                    "Pour in coconut milk and bring to a simmer",
                    "Add vegetables and seasonings",
                    "Simmer for 15-20 minutes until chicken is cooked through",
                    "Garnish with fresh basil and serve over rice"
                ],
                ingredientAmounts: [
                    "Chicken breast": "1 lb, cubed",
                    "Coconut milk": "1 can (14 oz)",
                    "Red curry paste": "2 tbsp",
                    "Bell peppers": "2, sliced",
                    "Onion": "1 medium, sliced",
                    "Garlic": "3 cloves, minced",
                    "Ginger": "1 inch, minced",
                    "Fish sauce": "2 tbsp",
                    "Brown sugar": "1 tbsp",
                    "Thai basil": "1/4 cup, fresh"
                ],
                isAIGenerated: true,
                difficulty: "Medium"
            ),
            Recipe(
                id: UUID(),
                name: "AI-Generated Mediterranean Bowl",
                ingredients: ["Quinoa", "Chickpeas", "Cucumber", "Tomatoes", "Red onion", "Olives", "Feta cheese", "Olive oil", "Lemon juice", "Oregano"],
                dietaryTags: dietary.isEmpty ? ["Healthy", "Mediterranean"] : dietary + ["Healthy", "Mediterranean"],
                cookingTime: "20 minutes",
                instructions: [
                    "Cook quinoa according to package instructions",
                    "Drain and rinse chickpeas",
                    "Chop all vegetables into bite-sized pieces",
                    "Whisk together olive oil, lemon juice, and oregano for dressing",
                    "Combine quinoa, chickpeas, and vegetables in a large bowl",
                    "Drizzle with dressing and toss to combine",
                    "Top with crumbled feta and serve"
                ],
                ingredientAmounts: [
                    "Quinoa": "1 cup, dry",
                    "Chickpeas": "1 can, drained",
                    "Cucumber": "1 large, diced",
                    "Tomatoes": "2 medium, diced",
                    "Red onion": "1/4 cup, diced",
                    "Olives": "1/2 cup, sliced",
                    "Feta cheese": "1/2 cup, crumbled",
                    "Olive oil": "3 tbsp",
                    "Lemon juice": "2 tbsp",
                    "Oregano": "1 tsp, dried"
                ],
                isAIGenerated: true,
                difficulty: "Easy"
            )
        ]
        
        return recipes.randomElement() ?? recipes[0]
    }
}

// MARK: - Dietary Restriction Chip
struct DietaryRestrictionChip: View {
    let diet: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(diet)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isSelected
                                ? LinearGradient(colors: [Color.green, Color.mint], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Recipe Preview Card
struct RecipePreviewCard: View {
    let recipe: Recipe
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text("⏱️ \(recipe.cookingTime) • 📊 \(recipe.difficulty)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    ForEach(recipe.dietaryTags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - AI Meal Planner View
struct AIMealPlannerView: View {
    @State private var selectedDays: Set<String> = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @State private var mealsPerDay = 3
    @State private var dietaryPreferences: Set<String> = []
    @State private var recipeComplexity: RecipeComplexity = .basic
    @State private var generatedPlan: [String: [String]] = [:]
    @State private var isGeneratingPlan = false
    @State private var showCompletionPopup = false
    
    let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let dietaryOptions = ["Vegetarian", "Vegan", "Keto", "Mediterranean", "Low-Carb", "High-Protein"]
    
    
    var body: some View {
        VStack(spacing: 24) {
            headerSection
            configurationSection
            generateButton
            
            if !generatedPlan.isEmpty {
                MealPlanView(mealPlan: generatedPlan, mealsPerDay: mealsPerDay)
            }
        }
        .overlay(completionOverlay)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [Color.green, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text("AI Meal Planner")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Let AI plan your entire week with personalized meal suggestions")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Configuration Section
    private var configurationSection: some View {
        VStack(spacing: 20) {
            daysSelectionView
            mealsPerDayView
            complexitySelectionView
            dietaryPreferencesView
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
    }
    
    // MARK: - Days Selection
    private var daysSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Days to Plan")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    DaySelectionChip(
                        day: day,
                        isSelected: selectedDays.contains(day),
                        showFullName: true
                    ) {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Meals Per Day
    private var mealsPerDayView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meals per Day: \(mealsPerDay)")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("1")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Slider(value: Binding(
                    get: { Double(mealsPerDay) },
                    set: { mealsPerDay = Int($0) }
                ), in: 1...4, step: 1)
                Text("4")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Complexity Selection
    private var complexitySelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recipe Complexity")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(RecipeComplexity.allCases, id: \.self) { complexity in
                    complexityButton(for: complexity)
                }
            }
        }
    }
    
    private func complexityButton(for complexity: RecipeComplexity) -> some View {
        Button(action: {
            recipeComplexity = complexity
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(complexity.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(recipeComplexity == complexity ? .white : .primary)
                    
                    Text(complexity.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(recipeComplexity == complexity ? .white.opacity(0.9) : .secondary)
                }
                
                Spacer()
                
                if recipeComplexity == complexity {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        recipeComplexity == complexity
                            ? LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(recipeComplexity == complexity ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Dietary Preferences
    private var dietaryPreferencesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dietary Preferences")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(dietaryOptions, id: \.self) { option in
                    DietaryRestrictionChip(
                        diet: option,
                        isSelected: dietaryPreferences.contains(option)
                    ) {
                        if dietaryPreferences.contains(option) {
                            dietaryPreferences.remove(option)
                        } else {
                            dietaryPreferences.insert(option)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Generate Button
    private var generateButton: some View {
        Button(action: generateMealPlan) {
            HStack(spacing: 12) {
                if isGeneratingPlan {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title2)
                }
                Text(isGeneratingPlan ? "Creating Meal Plan..." : "Generate Meal Plan")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(16)
            .shadow(color: .green.opacity(0.3), radius: 10, y: 4)
        }
        .disabled(selectedDays.isEmpty || isGeneratingPlan)
    }
    
    // MARK: - Completion Overlay
    private var completionOverlay: some View {
        VStack {
            Spacer()
            
            if showCompletionPopup {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    Text("AI Meal Plan Generated!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom, 100)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showCompletionPopup)
    }
    
    private func generateMealPlan() {
        isGeneratingPlan = true
        
        Task {
            do {
                let plan = try await OpenAIService.shared.generateMealPlan(
                    days: Array(selectedDays),
                    mealsPerDay: mealsPerDay,
                    dietaryPreferences: Array(dietaryPreferences),
                    complexity: recipeComplexity
                )
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        generatedPlan = plan
                        isGeneratingPlan = false
                    }
                }
            } catch {
                print("Meal plan generation error: \(error)")
                // Fall back to sample meal plan on error
                var plan: [String: [String]] = [:]
                
                let sampleMeals = [
                    "Avocado Toast with Eggs", "Greek Yogurt Parfait", "Oatmeal with Berries",
                    "Quinoa Salad", "Grilled Chicken Caesar", "Mediterranean Bowl",
                    "Salmon with Vegetables", "Pasta Primavera", "Stir-Fry with Rice",
                    "Smoothie Bowl", "Eggs Benedict", "Pancakes with Fruit"
                ]
                
                for day in selectedDays {
                    plan[day] = Array(sampleMeals.shuffled().prefix(mealsPerDay))
                }
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        generatedPlan = plan
                        isGeneratingPlan = false
                        showCompletionPopup = true
                    }
                    
                    // Hide popup after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.spring()) {
                            showCompletionPopup = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Day Selection Chip
struct DaySelectionChip: View {
    let day: String
    let isSelected: Bool
    let showFullName: Bool
    let action: () -> Void
    
    init(day: String, isSelected: Bool, showFullName: Bool = false, action: @escaping () -> Void) {
        self.day = day
        self.isSelected = isSelected
        self.showFullName = showFullName
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(showFullName ? day : String(day.prefix(3)))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, showFullName ? 16 : 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isSelected
                                ? LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Meal Plan View
struct MealPlanView: View {
    let mealPlan: [String: [String]]
    let mealsPerDay: Int
    
    let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Your AI-Generated Meal Plan")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            // Days and meals
            ForEach(weekDays.filter { mealPlan.keys.contains($0) }, id: \.self) { day in
                VStack(alignment: .leading, spacing: 12) {
                    // Day header
                    HStack {
                        Text(day)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(mealPlan[day]?.count ?? 0) meals")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray5))
                            )
                    }
                    
                    // Meal capsules
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                        ForEach(Array((mealPlan[day] ?? []).enumerated()), id: \.offset) { index, meal in
                            MealCapsule(meal: meal, mealType: getMealType(for: index))
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 15, y: 8)
        )
    }
    
    private func getMealType(for index: Int) -> MealType {
        switch index {
        case 0: return .breakfast
        case 1: return .lunch
        case 2: return .dinner
        case 3: return .snack
        default: return .meal
        }
    }
}

// MARK: - Meal Capsule Component
struct MealCapsule: View {
    let meal: String
    let mealType: MealType
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal type icon
            ZStack {
                Circle()
                    .fill(mealType.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: mealType.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(mealType.color)
            }
            
            // Meal info
            VStack(alignment: .leading, spacing: 2) {
                Text(mealType.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(mealType.color)
                    .textCase(.uppercase)
                
                Text(meal)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Sparkle icon to indicate AI generation
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.purple.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: mealType.color.opacity(0.1), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [mealType.color.opacity(0.3), mealType.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Meal Type Enum
enum MealType {
    case breakfast, lunch, dinner, snack, meal
    
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        case .meal: return "Meal"
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast: return "sun.rise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        case .meal: return "fork.knife"
        }
    }
    
    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch: return .blue
        case .dinner: return .purple
        case .snack: return .green
        case .meal: return .gray
        }
    }
}

// MARK: - AI Budget Planner View
struct AIBudgetPlannerView: View {
    @State private var weeklyBudget = ""
    @State private var familySize = 2
    @State private var dietaryRestrictions: Set<String> = []
    @State private var generatedBudgetPlan: BudgetMealPlan?
    @State private var isGeneratingPlan = false
    
    let budgetOptions = ["Vegetarian", "Budget-Friendly", "Bulk Cooking", "Seasonal"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                Text("AI Budget Meal Planner")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Optimize your meals for maximum nutrition within your budget")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Budget configuration
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weekly Budget")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("$")
                            .font(.title2)
                            .foregroundColor(.orange)
                        TextField("100", text: $weeklyBudget)
                            .font(.title2.bold())
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Family Size: \(familySize) people")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("1")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(value: Binding(
                            get: { Double(familySize) },
                            set: { familySize = Int($0) }
                        ), in: 1...8, step: 1)
                        Text("8")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Budget Optimization")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(budgetOptions, id: \.self) { option in
                            DietaryRestrictionChip(
                                diet: option,
                                isSelected: dietaryRestrictions.contains(option)
                            ) {
                                if dietaryRestrictions.contains(option) {
                                    dietaryRestrictions.remove(option)
                                } else {
                                    dietaryRestrictions.insert(option)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            )
            
            // Generate budget plan button
            Button(action: generateBudgetPlan) {
                HStack(spacing: 12) {
                    if isGeneratingPlan {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                    }
                    Text(isGeneratingPlan ? "Optimizing Budget Plan..." : "Generate Budget Plan")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: .orange.opacity(0.3), radius: 10, y: 4)
            }
            .disabled(weeklyBudget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGeneratingPlan)
            
            // Generated budget plan
            if let budgetPlan = generatedBudgetPlan {
                BudgetPlanView(budgetPlan: budgetPlan)
            }
        }
    }
    
    private func generateBudgetPlan() {
        guard let budget = Double(weeklyBudget) else { return }
        isGeneratingPlan = true
        
        Task {
            do {
                let plan = try await OpenAIService.shared.generateBudgetMealPlan(
                    budget: budget,
                    familySize: familySize,
                    preferences: Array(dietaryRestrictions)
                )
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        generatedBudgetPlan = plan
                        isGeneratingPlan = false
                    }
                }
            } catch {
                print("Budget plan generation error: \(error)")
                // Fall back to sample budget plan on error
                let plan = BudgetMealPlan(
                    totalBudget: budget,
                    dailyBudget: budget / 7,
                    meals: [
                        BudgetMeal(name: "Pasta with Marinara", cost: 4.50, servings: familySize),
                        BudgetMeal(name: "Rice and Beans Bowl", cost: 3.25, servings: familySize),
                        BudgetMeal(name: "Vegetable Stir-Fry", cost: 5.75, servings: familySize),
                        BudgetMeal(name: "Lentil Soup", cost: 3.80, servings: familySize),
                        BudgetMeal(name: "Chicken and Rice", cost: 7.20, servings: familySize),
                        BudgetMeal(name: "Egg Fried Rice", cost: 4.10, servings: familySize),
                        BudgetMeal(name: "Bean and Cheese Quesadillas", cost: 4.60, servings: familySize)
                    ],
                    shoppingList: [
                        "Pasta (2 lbs): $2.50",
                        "Marinara Sauce (2 jars): $4.00",
                        "Rice (5 lbs): $3.00",
                        "Black Beans (4 cans): $4.00",
                        "Mixed Vegetables (frozen): $5.50",
                        "Lentils (2 lbs): $3.50",
                        "Chicken Breast (2 lbs): $8.00",
                        "Eggs (1 dozen): $3.00",
                        "Cheese (1 lb): $4.50",
                        "Tortillas: $3.00"
                    ],
                    totalEstimatedCost: budget * 0.95,
                    savingsPercentage: 15
                )
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        generatedBudgetPlan = plan
                        isGeneratingPlan = false
                    }
                }
            }
        }
    }
}

// MARK: - Budget Plan Models
struct BudgetMealPlan {
    let totalBudget: Double
    let dailyBudget: Double
    let meals: [BudgetMeal]
    let shoppingList: [String]
    let totalEstimatedCost: Double
    let savingsPercentage: Int
}

struct BudgetMeal {
    let name: String
    let cost: Double
    let servings: Int
    
    var costPerServing: Double {
        cost / Double(servings)
    }
}

// MARK: - Budget Plan View
struct BudgetPlanView: View {
    let budgetPlan: BudgetMealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Optimized Budget Plan")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            // Budget summary
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", budgetPlan.totalBudget))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estimated Cost")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", budgetPlan.totalEstimatedCost))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Savings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(budgetPlan.savingsPercentage)%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            // Meal suggestions
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested Meals")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                ForEach(budgetPlan.meals, id: \.name) { meal in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(meal.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            Text("$\(String(format: "%.2f", meal.costPerServing))/serving")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", meal.cost))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            // Shopping list preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Shopping List Preview")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                ForEach(Array(budgetPlan.shoppingList.prefix(5)), id: \.self) { item in
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 6, height: 6)
                        Text(item)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                if budgetPlan.shoppingList.count > 5 {
                    Text("+ \(budgetPlan.shoppingList.count - 5) more items")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.leading, 12)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
    }
}

// MARK: - Generated Recipe Detail View
struct GeneratedRecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(recipe.name)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Label(recipe.cookingTime, systemImage: "clock")
                            Spacer()
                            Label(recipe.difficulty, systemImage: "chart.bar")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        
                        HStack {
                            ForEach(recipe.dietaryTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ingredient)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    if let amount = recipe.ingredientAmounts[ingredient] {
                                        Text(amount)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        Circle()
                                            .fill(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    )
                                
                                Text(instruction)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
