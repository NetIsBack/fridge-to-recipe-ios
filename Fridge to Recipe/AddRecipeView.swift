//
//  AddRecipeView.swift
//  Fridge to Recipe
//
//  View for adding custom recipes
//

import SwiftUI

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appData: AppDataModel
    
    @State private var recipeName = ""
    @State private var cookingTime = ""
    @State private var difficulty = "Easy"
    @State private var ingredients: [String] = [""]
    @State private var instructions: [String] = [""]
    @State private var steps: [RecipeStepInput] = [RecipeStepInput()]
    @State private var selectedTags: Set<String> = []
    @State private var ingredientAmounts: [String: String] = [:]
    
    private let availableTags = ["vegetarian", "vegan", "gluten-free", "dairy-free", "healthy", "quick", "comfort-food", "spicy", "sweet"]
    private let difficulties = ["Easy", "Medium", "Hard"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Basic Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recipe Details")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recipe Name")
                                .font(.headline)
                            TextField("Enter recipe name", text: $recipeName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cooking Time")
                                    .font(.headline)
                                TextField("e.g., 30 minutes", text: $cookingTime)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Difficulty")
                                    .font(.headline)
                                Picker("Difficulty", selection: $difficulty) {
                                    ForEach(difficulties, id: \.self) { level in
                                        Text(level).tag(level)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    // Dietary Tags Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dietary Tags")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(availableTags, id: \.self) { tag in
                                Button(action: {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }) {
                                    Text(tag)
                                        .font(.caption.bold())
                                        .foregroundColor(selectedTags.contains(tag) ? .white : .orange)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedTags.contains(tag) ? Color.orange : Color.orange.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Ingredients")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Spacer()
                            Button("Add Ingredient") {
                                ingredients.append("")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        ForEach(ingredients.indices, id: \.self) { index in
                            HStack {
                                TextField("Ingredient name", text: Binding(
                                    get: { ingredients.indices.contains(index) ? ingredients[index] : "" },
                                    set: { newValue in
                                        if ingredients.indices.contains(index) {
                                            ingredients[index] = newValue
                                        }
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Amount", text: Binding(
                                    get: { ingredientAmounts[ingredients.indices.contains(index) ? ingredients[index] : ""] ?? "" },
                                    set: { newValue in
                                        if ingredients.indices.contains(index) && !ingredients[index].isEmpty {
                                            ingredientAmounts[ingredients[index]] = newValue
                                        }
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                                
                                if ingredients.count > 1 {
                                    Button(action: {
                                        if ingredients.indices.contains(index) {
                                            let ingredient = ingredients[index]
                                            ingredientAmounts.removeValue(forKey: ingredient)
                                            ingredients.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Instructions")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Spacer()
                            Button("Add Step") {
                                instructions.append("")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        ForEach(instructions.indices, id: \.self) { index in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 25)
                                
                                TextField("Instruction step", text: Binding(
                                    get: { instructions.indices.contains(index) ? instructions[index] : "" },
                                    set: { newValue in
                                        if instructions.indices.contains(index) {
                                            instructions[index] = newValue
                                        }
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                if instructions.count > 1 {
                                    Button(action: {
                                        if instructions.indices.contains(index) {
                                            instructions.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    // Cook Now Steps Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cook Now Steps")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                                Text("Add timed steps for guided cooking")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Add Step") {
                                steps.append(RecipeStepInput())
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        ForEach(steps.indices, id: \.self) { index in
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Step \(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    if steps.count > 1 {
                                        Button(action: {
                                            if steps.indices.contains(index) {
                                                steps.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                
                                TextField("Step description", text: Binding(
                                    get: { steps.indices.contains(index) ? steps[index].name : "" },
                                    set: { newValue in
                                        if steps.indices.contains(index) {
                                            steps[index].name = newValue
                                        }
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                HStack {
                                    Text("Duration:")
                                        .font(.subheadline)
                                    TextField("Minutes", value: Binding(
                                        get: { steps.indices.contains(index) ? Int(steps[index].duration / 60) : 0 },
                                        set: { newValue in
                                            if steps.indices.contains(index) {
                                                steps[index].duration = TimeInterval(newValue * 60)
                                            }
                                        }
                                    ), formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                    Text("minutes")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveRecipe()
                }
                .disabled(recipeName.isEmpty || ingredients.filter { !$0.isEmpty }.isEmpty || instructions.filter { !$0.isEmpty }.isEmpty)
            )
        }
    }
    
    private func saveRecipe() {
        let filteredIngredients = ingredients.filter { !$0.isEmpty }
        let filteredInstructions = instructions.filter { !$0.isEmpty }
        let filteredSteps = steps.filter { !$0.name.isEmpty }
        
        let recipeSteps = filteredSteps.map { step in
            RecipeStep(name: step.name, duration: step.duration)
        }
        
        let newRecipe = Recipe(
            id: UUID(),
            name: recipeName,
            ingredients: filteredIngredients,
            dietaryTags: Array(selectedTags),
            cookingTime: cookingTime,
            instructions: filteredInstructions,
            ingredientAmounts: ingredientAmounts,
            isAIGenerated: false,
            difficulty: difficulty,
            steps: recipeSteps
        )
        
        appData.recipes.append(newRecipe)
        dismiss()
    }
}

struct RecipeStepInput {
    var name: String = ""
    var duration: TimeInterval = 300 // Default 5 minutes
}

#Preview {
    AddRecipeView()
        .environmentObject(AppDataModel())
}
