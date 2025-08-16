// HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appData: AppDataModel
    @EnvironmentObject var shoppingList: ShoppingListViewModel
    @State private var newIngredient = ""
    @State private var showExpiryPicker = false
    @State private var tempExpiry: Date?
    
    @State private var showSuggestedRecipes = false
    @State private var showRecipeDetail: Recipe?
    @State private var showAchievements = false
    @State private var showSettings = false
    @State private var showProPreview = false
    @State private var settingsButtonPressed = false
    @State private var proButtonPressed = false
    @State private var suggestButtonScale: CGFloat = 1.0
    @State private var lastSuggestedIngredients: [String] = []
    @State private var showIngredientScanner = false
    
    var currentIngredients: [String] {
        appData.ingredients.map { $0.name.lowercased() }
    }
    
    var suggestedRecipes: [Recipe] {
        let userIngredients = appData.ingredients.map { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        
        return appData.recipes.filter { recipe in
            let recipeIngredients = recipe.ingredients.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            
            // Check if any user ingredient matches any recipe ingredient
            return userIngredients.contains { userIngredient in
                recipeIngredients.contains { recipeIngredient in
                    recipeIngredient.contains(userIngredient) || userIngredient.contains(recipeIngredient)
                }
            }
        }
    }
    
    var canSuggest: Bool {
        !appData.ingredients.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Full-screen gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // App Title with Pro and Settings Buttons
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fridge to Recipe")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color.primary)
                            Text("What can I make today?")
                                .font(.title3.weight(.medium))
                                .foregroundColor(Color.secondary)
                        }
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Experimental Features Button - Star icon only
                            Button(action: {
                                showProPreview = true
                            }) {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple], 
                                            startPoint: .topLeading, 
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .scaleEffect(proButtonPressed ? 0.95 : 1.0)
                                    .animation(.spring(), value: proButtonPressed)
                            }
                            .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { pressing in
                                proButtonPressed = pressing
                            })
                            
                            // Settings Button
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .scaleEffect(settingsButtonPressed ? 0.95 : 1.0)
                                    .animation(.spring(), value: settingsButtonPressed)
                            }
                            .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { pressing in
                                settingsButtonPressed = pressing
                            })
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 48)
                    .onLongPressGesture(minimumDuration: 2.0) {
                        // Show tutorial for testing
                        UserDefaults.standard.set(false, forKey: "hasSeenTutorial")
                        // This will trigger the tutorial to show on next app launch
                    }
                    
                    Spacer().frame(height: 16)
                    
                    // Ingredient Input Card (now at the top)
                    VStack(spacing: 20) {
                        // Input Field with Barcode Scanner
                        HStack(spacing: 8) {
                            TextField("Enter ingredient", text: $newIngredient)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(16)
                                .foregroundColor(.primary)
                                .font(.headline)
                            
                            // Barcode Scanner Button
                            Button(action: {
                                showIngredientScanner = true
                            }) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: .blue.opacity(0.4), radius: 8, y: 4)
                            }
                            
                            Button(action: addIngredient) {
                                Image(systemName: "plus")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                                    .scaleEffect(newIngredient.isEmpty ? 1.0 : 1.1)
                                    .animation(.spring(), value: newIngredient)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Add Expiry Date Button
                        Button(action: { showExpiryPicker = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                if let expiry = tempExpiry {
                                    Text("Expires: \(expiry, style: .date)")
                                } else {
                                    Text("Add expiry date (optional)")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(32)
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    
                    // Ingredients Card (below input)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients in your fridge")
                            .font(.headline.bold())
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                            .padding(.horizontal)
                        if appData.ingredients.isEmpty {
                            Text("No ingredients yet. Add some above!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(appData.ingredients) { ingredient in
                                        RevampedIngredientChip(ingredient: ingredient, onRemove: {
                                            removeIngredient(ingredient)
                                        })
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(28)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .shadow(color: .black.opacity(0.10), radius: 12, y: 4)
                    
                    // Swipeable Card Carousel for Suggested Recipes
                    if showSuggestedRecipes {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suggested Recipes")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 24) {
                                    ForEach(suggestedRecipes) { recipe in
                                        RevampedRecipeCard(recipe: recipe, onTap: {
                                            showRecipeDetail = recipe
                                        })
                                        .transition(.scale(scale: 0.8, anchor: .bottom).combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .transition(.asymmetric(insertion: .scale(scale: 0.8, anchor: .bottom).combined(with: .opacity).animation(.spring(response: 0.5, dampingFraction: 0.6)), removal: .opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuggestedRecipes)
                    }
                    
                    Spacer()
                    
                    // Suggest Recipes Button (now at the very bottom)
                    Button(action: {
                        guard canSuggest else { return }
                        
                        // Animate button press
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            suggestButtonScale = 1.15
                        }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1)) {
                            suggestButtonScale = 1.0
                        }
                        
                        // Show suggested recipes
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            showSuggestedRecipes = true
                            lastSuggestedIngredients = currentIngredients
                        }
                        
                        print("Suggest Recipes pressed. Found \(suggestedRecipes.count) recipes for \(appData.ingredients.count) ingredients")
                    }) {
                        Text("Suggest Recipes")
                            .font(.headline.bold())
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [Color.orange, Color.pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(24)
                            .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                    }
                    .scaleEffect(suggestButtonScale)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                    .disabled(!canSuggest)
                    .opacity(canSuggest ? 1.0 : 0.5)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Align content to top
        .sheet(isPresented: $showExpiryPicker) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Set Expiry Date")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    DatePicker("Expiry Date", selection: Binding(
                        get: { tempExpiry ?? Date() },
                        set: { tempExpiry = $0 }
                    ), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    
                    HStack(spacing: 16) {
                        Button("Clear") {
                            tempExpiry = nil
                            showExpiryPicker = false
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        
                        Button("Done") {
                            showExpiryPicker = false
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(10)
                    }
                }
                .padding()
                .navigationBarHidden(true)
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $showRecipeDetail) { recipe in
            RecipeDetailView(recipe: recipe)
                .environmentObject(appData)
                .environmentObject(shoppingList)
        }
        .sheet(isPresented: $showAchievements) {
            // Achievements Modal
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showProPreview) {
            ExperimentalFeaturesPreviewView()
        }
        .sheet(isPresented: $showIngredientScanner) {
            IngredientBarcodeScannerSheet(
                isPresented: $showIngredientScanner
            ) { ingredientName in
                // Add the scanned ingredient to the fridge
                withAnimation(.spring()) {
                    let entry = IngredientEntry(name: ingredientName, expiry: tempExpiry)
                    appData.ingredients.append(entry)
                    if let _ = entry.expiry {
                        appData.scheduleExpiryNotification(for: entry)
                    }
                }
                tempExpiry = nil
            }
        }
    }
    
    private func addIngredient() {
        guard !newIngredient.isEmpty else { return }
        withAnimation(.spring()) {
            let entry = IngredientEntry(name: newIngredient, expiry: tempExpiry)
            appData.ingredients.append(entry)
            if let _ = entry.expiry {
                appData.scheduleExpiryNotification(for: entry)
            }
        }
        newIngredient = ""
        tempExpiry = nil
    }
    
    private func removeIngredient(_ ingredient: IngredientEntry) {
        withAnimation(.spring()) {
            appData.ingredients.removeAll { $0.id == ingredient.id }
            appData.cancelExpiryNotification(for: ingredient)
        }
    }
}

var isPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

// MARK: - Revamped Ingredient Chip
struct RevampedIngredientChip: View {
    let ingredient: IngredientEntry
    let onRemove: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 8) {
            Text(ingredient.name)
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Capsule())
                .shadow(color: .red.opacity(0.2), radius: 4, y: 2)
            
            if let expiry = ingredient.expiry {
                Text(expiry, style: .date)
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundColor(.red)
                    .padding(6)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
        .background(Color.clear)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
}

// MARK: - Revamped Recipe Card
struct RevampedRecipeCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    @State private var isPressed = false
    @State private var showCookNow = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background card (no Unsplash image)
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color.orange, Color.pink], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 260, height: 360)
                .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
            VStack(alignment: .leading, spacing: 12) {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(recipe.dietaryTags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                            .foregroundColor(.primary)
                    }
                }
                Text(recipe.name)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text(recipe.cookingTime)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 8)
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
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(16)
                        .shadow(color: Color.red.opacity(0.3), radius: 6, y: 2)
                    }
                    .fullScreenCover(isPresented: $showCookNow) {
                        CookNowView(timerManager: CookNowTimerManager(steps: recipe.steps, recipeName: recipe.name))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Glassmorphic overlay for card info
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: 260, height: 120)
                .offset(y: 120)
                .blur(radius: 0.5)
        }
        .frame(width: 260, height: 360)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(), value: isPressed)
        .onTapGesture(perform: onTap)
        .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
} 
