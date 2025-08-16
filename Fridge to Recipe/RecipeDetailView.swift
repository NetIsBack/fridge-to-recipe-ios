// RecipeDetailView.swift
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appData: AppDataModel
    @EnvironmentObject var shoppingList: ShoppingListViewModel
    @State private var showCookNow = false
    @State private var heartBounce = false
    @State private var showShareSheet = false
    @State private var checkmarkAnimations: [String: Bool] = [:]
    
    var isCooked: Bool {
        shoppingList.cookedRecipes.contains(recipe.id)
    }
    var isFavourite: Bool {
        appData.favouriteRecipeIDs.contains(recipe.id)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .blur(radius: 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with improved layout
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recipe.name)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                // Recipe metadata
                                HStack(spacing: 16) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(recipe.cookingTime)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "chart.bar")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(recipe.difficulty)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Action buttons
                            VStack(spacing: 12) {
                                // Share button
                                Button(action: { showShareSheet = true }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                        .padding(12)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                
                                // Favourite button
                                Button(action: {
                                    // Immediate UI feedback with animation
                                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                                        heartBounce = true
                                    }
                                    
                                    // Use optimized toggle method for instant update
                                    appData.toggleFavorite(recipeID: recipe.id)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        heartBounce = false
                                    }
                                }) {
                                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                                        .font(.system(size: 20))
                                        .foregroundColor(isFavourite ? .red : .secondary)
                                        .padding(12)
                                        .background(Color.black.opacity(0.15))
                                        .clipShape(Circle())
                                        .scaleEffect(heartBounce ? 1.2 : 1.0)
                                        .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: heartBounce)
                                }
                            }
                        }
                        
                        // Dietary tags
                        if !recipe.dietaryTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(recipe.dietaryTags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Capsule())
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 32)
                    .padding(.horizontal)

                    // Ingredients Card with improved layout
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Ingredients")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(recipe.ingredients.count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack {
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                                                checkmarkAnimations[ingredient] = true
                                            }
                                            
                                            // Toggle ingredient availability
                                            if appData.ingredients.contains(where: { $0.name.lowercased() == ingredient.lowercased() }) {
                                                // Remove ingredient
                                                if let index = appData.ingredients.firstIndex(where: { $0.name.lowercased() == ingredient.lowercased() }) {
                                                    appData.ingredients.remove(at: index)
                                                }
                                            } else {
                                                // Add ingredient
                                                let newIngredient = IngredientEntry(name: ingredient.capitalized)
                                                appData.ingredients.append(newIngredient)
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                checkmarkAnimations[ingredient] = false
                                            }
                                        }) {
                                            if appData.ingredients.contains(where: { $0.name.lowercased() == ingredient.lowercased() }) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 16))
                                                    .scaleEffect(checkmarkAnimations[ingredient] == true ? 1.3 : 1.0)
                                                    .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: checkmarkAnimations[ingredient])
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 16))
                                                    .scaleEffect(checkmarkAnimations[ingredient] == true ? 1.3 : 1.0)
                                                    .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: checkmarkAnimations[ingredient])
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Text(ingredient.capitalized)
                                            .foregroundColor(.primary)
                                            .font(.body)
                                        
                                        if let amount = recipe.ingredientAmounts[ingredient] {
                                            Text("(\(amount))")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Missing ingredients section
                        let missingIngredients = recipe.ingredients.filter { ingredient in
                            !appData.ingredients.contains(where: { $0.name.lowercased() == ingredient.lowercased() })
                        }
                        
                        if !missingIngredients.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Missing Ingredients")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                }
                                
                                ForEach(missingIngredients, id: \.self) { ingredient in
                                    HStack {
                                        Image(systemName: "circle")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 14))
                                        Text(ingredient.capitalized)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.10), radius: 10, y: 4)
                    .padding(.horizontal)

                    // Instructions Card with improved layout
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Instructions")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(recipe.instructions.count) steps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        
                        VStack(spacing: 16) {
                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(
                                            LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .clipShape(Circle())
                                    
                                    Text(instruction)
                                        .foregroundColor(.primary)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.10), radius: 10, y: 4)
                    .padding(.horizontal)

                    // Action Buttons with improved layout
                    VStack(spacing: 12) {
                        // Mark as Cooked Button
                        Button(action: {
                            if !isCooked {
                                shoppingList.cookedRecipes.append(recipe.id)
                            }
                        }) {
                            HStack {
                                Image(systemName: isCooked ? "checkmark.seal.fill" : "star.fill")
                                    .foregroundColor(isCooked ? .green : .yellow)
                                Text(isCooked ? "Cooked!" : "Mark as Cooked")
                                    .font(.headline.bold())
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [Color.orange, Color.pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(24)
                            .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(isCooked)
                        
                        // Cook Now Button
                        if !recipe.steps.isEmpty {
                            Button(action: { showCookNow = true }) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.white)
                                    Text("Cook Now")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(colors: [Color.pink, Color.orange], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(24)
                                .shadow(color: .pink.opacity(0.3), radius: 10, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showCookNow) {
            CookNowView(timerManager: CookNowTimerManager(steps: recipe.steps, recipeName: recipe.name))
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [recipe.shareableText()])
        }
        .onAppear {
            print("RecipeDetailView appeared for recipe: \(recipe.name)")
            if shoppingList.selectedList == "Smart List" {
                let userIngredients = Set(appData.ingredients.map { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
                let missing = recipe.ingredients.filter { ingredient in
                    !userIngredients.contains(ingredient.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                }
                print("Missing ingredients: \(missing)")
                for ingredient in missing {
                    let clean = ingredient.capitalized
                    if !shoppingList.smartListItems.contains(where: { $0.caseInsensitiveCompare(clean) == .orderedSame }) {
                        shoppingList.smartListItems.append(clean)
                        print("Added to smart list: \(clean)")
                    }
                }
                print("Smart list now: \(shoppingList.smartListItems)")
            }
        }
    }
}

 