import SwiftUI

// These view declarations have been moved to be after all other view declarations to prevent redeclaration issues

// MARK: - Tab Bar Container
struct MainTabView: View {
    @StateObject private var appData = AppDataModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                .environmentObject(appData)
            
            ShoppingListView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shopping List")
                }
                .tag(1)
                .environmentObject(appData)
            
            FavouritesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favourites")
                }
                .tag(2)
                .environmentObject(appData)

            MealPlannerView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Planner")
                }
                .tag(3)
                .environmentObject(appData)

            CollaborativeShoppingView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Collaborate")
                }
                .tag(4)
                .environmentObject(appData)
        }
        .accentColor(.blue)
        .onAppear {
            if appData.recipes.isEmpty {
                appData.recipes = sampleRecipes
                print("Loaded sample recipes: \(appData.recipes.count)")
            } else {
                print("Recipes already loaded: \(appData.recipes.count)")
            }
        }
    }
}

// MARK: - Placeholder Tab Views
struct ShoppingListView: View {
    @EnvironmentObject var appData: AppDataModel
    @EnvironmentObject var shoppingList: ShoppingListViewModel
    @StateObject private var scanner = ShoppingListScanner()
    @State private var isPressed = false
    @State private var newItem = ""
    @State private var showAddList = false
    @State private var newListName = ""
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "list.bullet"
    @State private var listToDelete: String?
    @State private var showDuplicateError = false
    @State private var showShareSheet = false
    @State private var showShoppingListScanner = false
    @State private var showBudgetSheet = false
    @State private var budgetText = ""
    
    var allLists: [String] {
        var lists = ["Smart List"]
        lists.append(contentsOf: shoppingList.manualLists.map { $0.name })
        return lists
    }
    
    var body: some View {
        ZStack {
            shoppingListBackground
            ScrollView {
                VStack(spacing: 0) {
                    shoppingListHeader
                    shoppingListToggle
                    shoppingListInput
                    shoppingListItemsCard
                    
                    // Scanner Button - Only show for non-Smart Lists
                    if shoppingList.selectedList != "Smart List" {
                        Button(action: {
                            showShoppingListScanner = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.title3)
                                Text("Scan Shopping List")
                                    .font(.headline)
                                
                                // Beta tag
                                Text("BETA")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .cornerRadius(4)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 4, y: 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    
                    
                    Spacer(minLength: 20)
                }
            }
        }
        .sheet(isPresented: $showAddList) {
            AddListView(
                newListName: $newListName,
                selectedColor: $selectedColor,
                selectedIcon: $selectedIcon,
                onAdd: {
                    let trimmedName = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let newList = ShoppingList(
                        name: trimmedName,
                        color: selectedColor,
                        icon: selectedIcon
                    )
                    shoppingList.manualLists.append(newList)
                    shoppingList.selectedList = trimmedName
                    newListName = ""
                    selectedColor = "blue"
                    selectedIcon = "list.bullet"
                    showAddList = false
                }
            )
            .environmentObject(shoppingList)
        }
        .sheet(isPresented: $showShoppingListScanner) {
            ShoppingListBarcodeScannerSheet(
                isPresented: $showShoppingListScanner
            ) { scannedItem in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    if shoppingList.selectedList == "Smart List" {
                        shoppingList.smartListItems.append(scannedItem)
                    } else {
                        if let index = shoppingList.manualLists.firstIndex(where: { $0.name == shoppingList.selectedList }) {
                            shoppingList.manualLists[index].items.append(scannedItem)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showBudgetSheet) {
            BudgetSettingSheet(
                isPresented: $showBudgetSheet,
                budget: $budgetText,
                listName: shoppingList.selectedList,
                onSave: { newBudget in
                    shoppingList.setBudget(for: shoppingList.selectedList, budget: newBudget)
                }
            )
        }
        .confirmationDialog(
            "Delete List",
            isPresented: .constant(listToDelete != nil),
            titleVisibility: .visible
        ) {
            Button("Delete '\(listToDelete ?? "")'", role: .destructive) {
                if let listName = listToDelete {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        shoppingList.manualLists.removeAll { $0.name == listName }
                        if shoppingList.selectedList == listName {
                            shoppingList.selectedList = "Smart List"
                        }
                    }
                }
                listToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                listToDelete = nil
            }
        } message: {
            Text("This will permanently delete the list and all its items.")
        }
        .alert("List Already Exists", isPresented: $showDuplicateError) {
            Button("OK") {
                showDuplicateError = false
            }
        } message: {
            Text("A list with this name already exists. Please choose a different name.")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [generateShoppingListText()])
        }
    }
    
    private func generateShoppingListText() -> String {
        let listItems = shoppingList.selectedList == "Smart List" 
            ? shoppingList.smartListItems 
            : shoppingList.manualLists.first { $0.name == shoppingList.selectedList }?.items ?? []
        
        var text = "🛒 Shopping List: \(shoppingList.selectedList)\n\n"
        
        if listItems.isEmpty {
            text += "No items in this list yet.\n"
        } else {
            text += "Items:\n"
            for (index, item) in listItems.enumerated() {
                text += "\(index + 1). \(item)\n"
            }
        }
        
        // Add budget information if available
        if shoppingList.selectedList != "Smart List" {
            if let list = shoppingList.manualLists.first(where: { $0.name == shoppingList.selectedList }) {
                if let budget = list.totalBudget {
                    text += "\n💰 Budget: $\(String(format: "%.2f", budget))\n"
                }
                
                let totalSpent = list.itemPrices.values.reduce(0, +)
                if totalSpent > 0 {
                    text += "💸 Total Spent: $\(String(format: "%.2f", totalSpent))\n"
                    
                    if let budget = list.totalBudget {
                        let remaining = budget - totalSpent
                        text += "💳 Remaining: $\(String(format: "%.2f", remaining))\n"
                    }
                }
            }
        }
        
        text += "\n📱 Shared from Fridge to Recipe"
        return text
    }
    
    private var shoppingListBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .blur(radius: 20)
    }
    
    private var shoppingListHeader: some View {
        HStack {
            Image(systemName: "cart.fill")
                .font(.system(size: 44))
                .foregroundColor(.primary)
                .shadow(radius: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text("Shopping List")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Keep track of what you need to buy.")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 48)
        .padding(.bottom, 8)
    }
    
    private var shoppingListToggle: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Shopping Lists")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 48)
            
            // Category Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Smart List
                    shoppingListToggleItem(for: "Smart List", color: .orange, icon: "brain.head.profile")
                    
                    // Manual Lists
                    ForEach(shoppingList.manualLists) { list in
                        shoppingListToggleItem(for: list.name, color: list.colorValue, icon: list.icon)
                    }
                    
                    // Add List Button
                    Button(action: { showAddList = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                            Text("Add List")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .blue.opacity(0.2), radius: 2, y: 1)
                    }
                    .scaleEffect(showAddList ? 0.95 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showAddList)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 12)
    }
    
    private func shoppingListToggleItem(for listName: String, color: Color, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(shoppingList.selectedList == listName ? .white : .primary)
            Text(listName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(shoppingList.selectedList == listName ? .white : .primary)
            
            // Delete button for manual lists (not Smart List)
            if listName != "Smart List" {
                Button(action: {
                    listToDelete = listName
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(shoppingList.selectedList == listName ? .white.opacity(0.8) : .red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            shoppingList.selectedList == listName 
                ? LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                : LinearGradient(colors: [Color(.systemGray6), Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(shoppingList.selectedList == listName ? color.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .shadow(color: shoppingList.selectedList == listName ? color.opacity(0.2) : .clear, radius: 2, y: 1)
        .onTapGesture { 
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { 
                shoppingList.selectedList = listName 
            } 
        }
    }
    
    private var shoppingListInput: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField("Add item", text: $newItem)
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .foregroundColor(.primary)
                    .font(.headline)
                
                // Only show barcode scanner for manual lists (not Smart List)
                if shoppingList.selectedList != "Smart List" {
                    Button(action: {
                        showShoppingListScanner = true
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                    }
                }
                
                Button(action: {
                    guard !newItem.isEmpty else { return }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        if shoppingList.selectedList == "Smart List" {
                            shoppingList.smartListItems.append(newItem.capitalized)
                        } else {
                            if let index = shoppingList.manualLists.firstIndex(where: { $0.name == shoppingList.selectedList }) {
                                shoppingList.manualLists[index].items.append(newItem.capitalized)
                            }
                        }
                    }
                    newItem = ""
                }) {
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())
                        .shadow(color: .orange.opacity(0.3), radius: 8, y: 4)
                        .scaleEffect(newItem.isEmpty ? 1.0 : 1.1)
                        .animation(.spring(), value: newItem)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
    
    
    private var shoppingListItemsCard: some View {
        let items = shoppingList.selectedList == "Smart List" 
            ? shoppingList.smartListItems 
            : shoppingList.manualLists.first(where: { $0.name == shoppingList.selectedList })?.items ?? []
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(shoppingList.selectedList == "Smart List" ? "Suggested Items" : "Your Items")
                    .font(.headline.bold())
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Share button for current list
                if !items.isEmpty {
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                // Budget display for manual lists - only show when there are items
                if shoppingList.selectedList != "Smart List" {
                    let manualListItems = shoppingList.manualLists.first(where: { $0.name == shoppingList.selectedList })?.items ?? []
                    if !manualListItems.isEmpty {
                        let totalPrice = shoppingList.getTotalPrice(for: shoppingList.selectedList)
                        let budgetRemaining = shoppingList.getBudgetRemaining(for: shoppingList.selectedList)
                        let currentBudget = shoppingList.manualLists.first(where: { $0.name == shoppingList.selectedList })?.totalBudget
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 8) {
                                Text(String(format: "Total: $%.2f", totalPrice))
                                    .font(.caption.bold())
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    budgetText = currentBudget != nil ? String(format: "%.2f", currentBudget!) : ""
                                    showBudgetSheet = true
                                }) {
                                    Image(systemName: "dollarsign.circle")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            if let remaining = budgetRemaining {
                                Text(String(format: "Remaining: $%.2f", remaining))
                                    .font(.caption2)
                                    .foregroundColor(remaining >= 0 ? .green : .red)
                            } else if let budget = currentBudget {
                                Text(String(format: "Budget: $%.2f", budget))
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            } else {
                                Button("Set Budget") {
                                    budgetText = ""
                                    showBudgetSheet = true
                                }
                                .font(.caption2)
                                .foregroundColor(.blue)
                            }
                        }
                    } else {
                        // Show "Set Budget" button when list is empty
                        Button("Set Budget") {
                            budgetText = ""
                            showBudgetSheet = true
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.horizontal)
            if shoppingList.selectedList == "Smart List" {
                Text("Smart List automatically suggests missing ingredients for recipes you view. Only adds when you open a recipe.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
            }
            
            if items.isEmpty {
                Text(shoppingList.selectedList == "Smart List" ? "No suggestions!" : "No items yet. Add some above!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(items, id: \.self) { item in
                            ShoppingListRow(
                                item: item, 
                                isSmart: shoppingList.selectedList == "Smart List",
                                onRemove: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        if shoppingList.selectedList == "Smart List" {
                                            shoppingList.smartListItems.removeAll { $0 == item }
                                        } else {
                                            if let index = shoppingList.manualLists.firstIndex(where: { $0.name == shoppingList.selectedList }) {
                                                shoppingList.manualLists[index].items.removeAll { $0 == item }
                                                // Also remove the price when item is deleted
                                                shoppingList.manualLists[index].itemPrices.removeValue(forKey: item)
                                                
                                                // If this was the last item, reset the budget
                                                if shoppingList.manualLists[index].items.isEmpty {
                                                    shoppingList.clearBudgetData(for: shoppingList.selectedList)
                                                }
                                            }
                                        }
                                    }
                                },
                                price: shoppingList.selectedList == "Smart List" ? nil : shoppingList.manualLists.first(where: { $0.name == shoppingList.selectedList })?.itemPrices[item],
                                onPriceTap: {
                                    // Price will be saved in the PriceInputSheet
                                },
                                onPriceSave: { newPrice in
                                    // Save the price when user confirms
                                    if shoppingList.selectedList != "Smart List" {
                                        shoppingList.setPrice(for: item, price: newPrice ?? 0.0, in: shoppingList.selectedList)
                                    }
                                }
                            )
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
    }
}

struct ShoppingListRow: View {
    let item: String
    let isSmart: Bool
    let onRemove: () -> Void
    let price: Double?
    let onPriceTap: () -> Void
    let onPriceSave: (Double?) -> Void
    @State private var showPriceInput = false
    @State private var priceText = ""
    
    var body: some View {
        HStack {
            Text(item)
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .padding(.leading, 18)
            
            Spacer()
            
            // Price display/button
            if !isSmart {
                Button(action: {
                    priceText = price != nil ? String(format: "%.2f", price!) : ""
                    showPriceInput = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.caption)
                        if let price = price {
                            Text(String(format: "$%.2f", price))
                                .font(.caption.bold())
                        } else {
                            Text("Set Price")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(price != nil ? .green : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                }
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.headline.bold())
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }
            .padding(.trailing, 10)
        }
        .background(
            LinearGradient(colors: isSmart ? [Color.purple.opacity(0.18), Color.pink.opacity(0.18)] : [Color.orange.opacity(0.18), Color.pink.opacity(0.18)], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(Capsule())
        .shadow(color: (isSmart ? Color.purple : Color.orange).opacity(0.08), radius: 4, y: 2)
        .sheet(isPresented: $showPriceInput) {
            PriceInputSheet(
                isPresented: $showPriceInput,
                price: $priceText,
                itemName: item,
                onSave: { newPrice in
                    onPriceSave(newPrice)
                }
            )
        }
    }
}

struct RecipeCardView: View {
    let recipe: Recipe
    let isCooked: Bool
    let isFavourite: Bool
    var onDelete: (() -> Void)?
    var onToggleFavourite: (() -> Void)?
    var deleteBounce: Bool = false
    @State private var cookedBounce = false
    @State private var showShareSheet = false
    
    var body: some View {
        HStack {
            // Content section
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Tags - show first tag only for cleaner look
                if let firstTag = recipe.dietaryTags.first {
                    Text(firstTag.lowercased())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                        )
                }
                
                Spacer(minLength: 4)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Text(recipe.cookingTime)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    // Difficulty or servings indicator
                    if !recipe.ingredients.isEmpty {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(min(recipe.ingredients.count, 8)) ingredients")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action buttons section
            VStack(spacing: 8) {
                // Share button
                Button(action: {
                    shareRecipe(recipe)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        )
                }
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(width: 34, height: 34)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.95))
                                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                            )
                            .scaleEffect(deleteBounce ? 1.1 : 1.0)
                            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: deleteBounce)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100, maxHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.95), Color.pink.opacity(0.9), Color.red.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [recipe.shareableText()])
        }
    }
    
    func shareRecipe(_ recipe: Recipe) {
        showShareSheet = true
    }
}

struct FavouritesView: View {
    @State private var showCookedRecipes = false
    @State private var isPressed = false
    @State private var selectedRecipe: Recipe?
    @EnvironmentObject var shoppingList: ShoppingListViewModel
    @EnvironmentObject var appData: AppDataModel
    @State private var cookedBounce: [UUID: Bool] = [:]
    @State private var deleteBounce: [UUID: Bool] = [:]
    @State private var deleteScale: [UUID: CGFloat] = [:]
    @State private var deleteRotation: [UUID: Double] = [:]
    @State private var deleteOpacity: [UUID: Double] = [:]
    
    // Refresh trigger to force UI updates
    @State private var refreshTrigger = UUID()
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Real-time favorite recipes computation with refresh trigger dependency
    private var favouriteRecipes: [Recipe] {
        let _ = refreshTrigger // Force dependency on refresh trigger
        return appData.recipes.filter { recipe in
            appData.favouriteRecipeIDs.contains(recipe.id)
        }.sorted { $0.name < $1.name } // Sort for consistent display
    }
    
    // Real-time cooked recipes computation with refresh trigger dependency
    private var cookedRecipes: [Recipe] {
        let _ = refreshTrigger // Force dependency on refresh trigger
        return appData.recipes.filter { recipe in
            shoppingList.cookedRecipes.contains(recipe.id)
        }.sorted { $0.name < $1.name } // Sort for consistent display
    }
    
    var body: some View {
        Group {
            if isPad {
                // iPad: Full screen without sidebar
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .blur(radius: 20)
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.primary)
                                .shadow(radius: 8)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Favourites")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("Your saved recipes for quick access.")
                                    .font(.title3.weight(.medium))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 48)
                        
                        // iPad: Recipes Cooked button under header - aligned left
                        HStack(spacing: 16) {
                        Button(action: { showCookedRecipes = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Recipes Cooked")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(cookedRecipes.count)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.25))
                                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                                    )
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.95), Color.red.opacity(0.9)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .orange.opacity(0.3), radius: 15, x: 0, y: 6)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.3), Color.clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .scaleEffect(isPressed ? 0.96 : 1.0)
                            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isPressed)
                            .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { pressing in
                                isPressed = pressing
                            })
                        }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        // Favourite or Cooked Recipes List
                        ScrollView {
                            VStack(spacing: 12) {
                                if showCookedRecipes {
                                    ForEach(cookedRecipes) { recipe in
                                        RecipeCardView(
                                            recipe: recipe,
                                            isCooked: true,
                                            isFavourite: appData.favouriteRecipeIDs.contains(recipe.id),
                                            onDelete: nil,
                                            onToggleFavourite: nil
                                        )
                                        .padding(.horizontal, 16)
                                    }
                                } else {
                                    if favouriteRecipes.isEmpty {
                                        // Empty State
                                        VStack(spacing: 24) {
                                            VStack(spacing: 16) {
                                                Image(systemName: "heart")
                                                    .font(.system(size: 80))
                                                    .foregroundColor(.secondary.opacity(0.6))
                                                
                                                VStack(spacing: 8) {
                                                    Text("No Favourite Recipes Yet")
                                                        .font(.system(size: 24, weight: .bold, design: .default))
                                                        .foregroundColor(.primary)
                                                    Text("Heart recipes you love to save them here for quick access")
                                                        .font(.system(size: 16, weight: .medium, design: .default))
                                                        .foregroundColor(.secondary)
                                                        .multilineTextAlignment(.center)
                                                        .padding(.horizontal)
                                                }
                                            }
                                            .padding(32)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(24)
                                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 60)
                                    } else {
                                        ForEach(favouriteRecipes) { recipe in
                                            RecipeCardView(
                                                recipe: recipe,
                                                isCooked: shoppingList.cookedRecipes.contains(recipe.id),
                                                isFavourite: true,
                                                onDelete: {
                                                    performSmoothDeleteAnimation(for: recipe.id)
                                                },
                                                onToggleFavourite: nil,
                                                deleteBounce: deleteBounce[recipe.id] ?? false
                                            )
                                            .padding(.horizontal, 16)
                                            .scaleEffect(
                                                deleteScale[recipe.id] ?? 1.0
                                            )
                                            .rotationEffect(
                                                .degrees(deleteRotation[recipe.id] ?? 0)
                                            )
                                            .opacity(deleteOpacity[recipe.id] ?? 1.0)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 16)
                        }
                        Spacer()
                    }
                }
            } else {
                // iPhone: Keep NavigationView for consistency
                NavigationView {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        .blur(radius: 20)
                        
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.primary)
                                    .shadow(radius: 8)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Favourites")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Your saved recipes for quick access.")
                                        .font(.title3.weight(.medium))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 48)
                            
                            // Controls - aligned left
                            HStack(spacing: 16) {
                            Button(action: { showCookedRecipes = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Recipes Cooked")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("\(cookedRecipes.count)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white.opacity(0.25))
                                                .shadow(color: .black.opacity(0.1), radius: 1.5, y: 1)
                                        )
                                }
                                .padding(.horizontal, 22)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.orange.opacity(0.95), Color.red.opacity(0.9)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .orange.opacity(0.35), radius: 12, x: 0, y: 4)
                                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.25), Color.clear],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 1.2
                                        )
                                )
                                .scaleEffect(isPressed ? 0.96 : 1.0)
                                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isPressed)
                                .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { pressing in
                                    isPressed = pressing
                                })
                            }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)
                            
                            // Favourite or Cooked Recipes List
                            ScrollView {
                                VStack(spacing: 12) {
                                    if showCookedRecipes {
                                        ForEach(cookedRecipes) { recipe in
                                            RecipeCardView(
                                                recipe: recipe,
                                                isCooked: true,
                                                isFavourite: appData.favouriteRecipeIDs.contains(recipe.id),
                                                onDelete: nil,
                                                onToggleFavourite: nil
                                            )
                                            .padding(.horizontal, 16)
                                        }
                                    } else {
                                        if favouriteRecipes.isEmpty {
                                            // Empty State
                                            VStack(spacing: 24) {
                                                VStack(spacing: 16) {
                                                    Image(systemName: "heart")
                                                        .font(.system(size: 80))
                                                        .foregroundColor(.secondary.opacity(0.6))
                                                    
                                                    VStack(spacing: 8) {
                                                        Text("No Favourite Recipes Yet")
                                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                                            .foregroundColor(.primary)
                                                        Text("Heart recipes you love to save them here for quick access")
                                                            .font(.system(size: 16, weight: .medium))
                                                            .foregroundColor(.secondary)
                                                            .multilineTextAlignment(.center)
                                                            .padding(.horizontal)
                                                    }
                                                }
                                                .padding(32)
                                                .background(.ultraThinMaterial)
                                                .cornerRadius(24)
                                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.top, 60)
                                        } else {
                                            ForEach(favouriteRecipes) { recipe in
                                                RecipeCardView(
                                                    recipe: recipe,
                                                    isCooked: shoppingList.cookedRecipes.contains(recipe.id),
                                                    isFavourite: true,
                                                    onDelete: {
                                                        performSmoothDeleteAnimation(for: recipe.id)
                                                    },
                                                    onToggleFavourite: nil,
                                                    deleteBounce: deleteBounce[recipe.id] ?? false
                                                )
                                                .padding(.horizontal, 16)
                                                .scaleEffect(
                                                    deleteScale[recipe.id] ?? 1.0
                                                )
                                                .rotationEffect(
                                                    .degrees(deleteRotation[recipe.id] ?? 0)
                                                )
                                                .opacity(deleteOpacity[recipe.id] ?? 1.0)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 16)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCookedRecipes) {
            CookedRecipesSheet()
                .environmentObject(shoppingList)
                .environmentObject(appData)
        }
        .onAppear {
            // Refresh data when view appears to ensure it's current
            refreshTrigger = UUID()
        }
        .onChange(of: showCookedRecipes) { _ in
            // Refresh when toggling between favorites and cooked recipes views
            refreshTrigger = UUID()
        }
    }
    
    // MARK: - Enhanced Delete Animation
    private func performSmoothDeleteAnimation(for recipeID: UUID) {
        // Initialize animation states
        deleteScale[recipeID] = 1.0
        deleteRotation[recipeID] = 0
        deleteOpacity[recipeID] = 1.0
        deleteBounce[recipeID] = true
        
        // Stage 1: Initial bounce and scale up (0.0-0.2s)
        withAnimation(.interpolatingSpring(stiffness: 500, damping: 25, initialVelocity: 5)) {
            deleteScale[recipeID] = 1.15
            deleteRotation[recipeID] = 2
        }
        
        // Stage 2: Bounce back with slight rotation (0.2-0.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 400, damping: 20)) {
                deleteScale[recipeID] = 0.95
                deleteRotation[recipeID] = -3
            }
        }
        
        // Stage 3: Second bounce up (0.4-0.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.interpolatingSpring(stiffness: 450, damping: 22)) {
                deleteScale[recipeID] = 1.08
                deleteRotation[recipeID] = 1
            }
        }
        
        // Stage 4: Final dramatic shrink with rotation and fade (0.6-1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 18, initialVelocity: 2)) {
                deleteScale[recipeID] = 0.01
                deleteRotation[recipeID] = 15
                deleteOpacity[recipeID] = 0.0
            }
            
            // Actually remove from favorites after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if let idx = appData.favouriteRecipeIDs.firstIndex(of: recipeID) {
                    appData.favouriteRecipeIDs.remove(at: idx)
                }
                
                // Clean up animation states
                deleteScale.removeValue(forKey: recipeID)
                deleteRotation.removeValue(forKey: recipeID)
                deleteOpacity.removeValue(forKey: recipeID)
                deleteBounce.removeValue(forKey: recipeID)
            }
        }
    }
}

struct CookedRecipesSheet: View {
    @EnvironmentObject var shoppingList: ShoppingListViewModel
    @EnvironmentObject var appData: AppDataModel
    @Environment(\.dismiss) private var dismiss
    
    var cookedRecipes: [Recipe] {
        appData.recipes.filter { shoppingList.cookedRecipes.contains($0.id) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(radius: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Recipes Cooked")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("See what recipes you've cooked")
                            .font(.title3.weight(.medium))
                            .foregroundColor(.secondary)
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
                .padding(.horizontal)
                .padding(.top, 48)
                .padding(.bottom, 8)
                
                ScrollView {
                    if cookedRecipes.isEmpty {
                        // Empty State
                        VStack(spacing: 24) {
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(LinearGradient(colors: [.orange.opacity(0.3), .pink.opacity(0.3)], 
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "star")
                                            .font(.system(size: 60))
                                            .foregroundColor(.secondary.opacity(0.6))
                                    )
                                
                                VStack(spacing: 8) {
                                    Text("No Recipes Cooked Yet")
                                        .font(.title2.bold())
                                        .foregroundColor(.primary)
                                    Text("Start cooking recipes to see your mastery progress here")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(32)
                            .background(.ultraThinMaterial)
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    } else {
                        // Recipe List
                        LazyVStack(spacing: 12) {
                            ForEach(cookedRecipes) { recipe in
                                RecipeCardView(
                                    recipe: recipe,
                                    isCooked: true,
                                    isFavourite: appData.favouriteRecipeIDs.contains(recipe.id),
                                    onDelete: nil,
                                    onToggleFavourite: nil
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
        }
    }
}
