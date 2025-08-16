import SwiftUI

struct AddListView: View {
    @Binding var newListName: String
    @Binding var selectedColor: String
    @Binding var selectedIcon: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var shoppingList: ShoppingListViewModel
    @State private var showDuplicateError = false
    @State private var isCreating = false
    
    let colors = ["red", "orange", "yellow", "green", "blue", "purple", "pink"]
    let icons = [
        // Shopping Lists
        "list.bullet", "list.clipboard", "list.dash", "person.2.badge.gearshape", "cart", "cart.fill", 
        
        // Storage & Containers
        "bag", "bag.fill", "basket", "basket.fill", "fork.knife", "cup.and.saucer", 
        
        // Food & Drinks
        "wineglass", "birthday.cake", "carrot", "apple.logo", "leaf.fill", "fish",
        
        // Places
        "flame", "house", "house.fill", "building.2", "storefront", "car", "laptopcomputer"
    ]
    
    private func colorFor(_ colorName: String) -> Color {
        switch colorName {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "indigo": return .indigo
        default: return .blue
        }
    }
    
    var body: some View {
        ZStack {
            // Adaptive background
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("New List")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button("Cancel") {
                        // Do nothing
                    }
                    .font(.body)
                    .foregroundColor(.clear)
                    .disabled(true)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Icon Display
                        VStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [colorFor(selectedColor), colorFor(selectedColor).opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 32, weight: .medium))
                                        .foregroundColor(.white)
                                )
                                .shadow(color: colorFor(selectedColor).opacity(0.3), radius: 12, y: 4)
                            
                            // List Name Input
                            TextField("List Name", text: $newListName)
                                .font(.title3.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                        }
                        
                        if showDuplicateError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("A list with this name already exists. Please choose a different name.")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 8)
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Color")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(colorFor(color))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 3)
                                                .opacity(selectedColor == color ? 1 : 0)
                                        )
                                        .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedColor = color
                                            }
                                        }
                                }
                            }
                        }
                        
                        // Icon Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Icon")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 10) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedIcon = icon
                                        }
                                    }) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                selectedIcon == icon ? 
                                                LinearGradient(
                                                    colors: [colorFor(selectedColor), colorFor(selectedColor).opacity(0.8)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    colors: [Color(.systemGray5), Color(.systemGray6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 42, height: 42)
                                            .overlay(
                                                Image(systemName: icon)
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                            )
                                            .scaleEffect(selectedIcon == icon ? 1.02 : 1.0)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                    }
                    .padding(.horizontal, 16)
                }
                
                // Create Button
                Button(action: {
                    if newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return
                    }
                    
                    // Check for duplicate names
                    if shoppingList.manualLists.contains(where: { $0.name.lowercased() == newListName.lowercased() }) {
                        showDuplicateError = true
                        return
                    }
                    
                    showDuplicateError = false
                    isCreating = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onAdd()
                        isCreating = false
                        dismiss()
                    }
                }) {
                    HStack(spacing: 8) {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.body)
                            Text("Create Shopping List")
                                .font(.body.bold())
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating
                                        ? [Color.gray, Color.gray]
                                        : [colorFor(selectedColor), colorFor(selectedColor).opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: colorFor(selectedColor).opacity(0.3), radius: 8, y: 4)
                }
                .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                .opacity(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating ? 0.6 : 1.0)
                .scaleEffect(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating ? 0.98 : 1.0)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .onChange(of: newListName) { _ in
            showDuplicateError = false
        }
    }
}

struct BudgetSettingSheet: View {
    @Binding var isPresented: Bool
    @Binding var budget: String
    let listName: String
    let onSave: (Double?) -> Void
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .blur(radius: 20)
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Set Budget")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        Text(listName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        isSaving = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSave(Double(budget))
                            isSaving = false
                            isPresented = false
                        }
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                    .disabled(isSaving)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Content area
                VStack(spacing: 24) {
                    // Budget icon and description
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.2), Color.blue.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.green, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .shadow(color: .green.opacity(0.2), radius: 12, y: 4)
                        
                        Text("Set your budget to track spending")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Budget input field
                    VStack(spacing: 12) {
                        HStack {
                            Text("Budget Amount")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "dollarsign")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.green)
                                .frame(width: 20)
                            
                            TextField("0.00", text: $budget)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    }
                    
                    // Help text
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        Text("This will help you track your spending against your budget")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct PriceInputSheet: View {
    @Binding var isPresented: Bool
    @Binding var price: String
    let itemName: String
    let onSave: (Double?) -> Void
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .blur(radius: 20)
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Set Price")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        Text(itemName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        isSaving = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSave(Double(price))
                            isSaving = false
                            isPresented = false
                        }
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                    .disabled(isSaving)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Content area
                VStack(spacing: 24) {
                    // Price icon and description
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.2), Color.pink.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "tag.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.orange, Color.pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .shadow(color: .orange.opacity(0.2), radius: 12, y: 4)
                        
                        Text("Set the price for this item to track your spending")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Price input field
                    VStack(spacing: 12) {
                        HStack {
                            Text("Price")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "dollarsign")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            
                            TextField("0.00", text: $price)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    }
                    
                    // Help text
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        Text("This price will be used to calculate your total spending")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var shoppingList: ShoppingListViewModel
    @State private var showTutorial = false
    @State private var showAddList = false
    @State private var newListName = ""
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "list.bullet"
    
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
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(radius: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Customize your app experience")
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
                    VStack(spacing: 20) {
                        // Tutorial Reset
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Show Tutorial Again")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Replay the welcome tutorial")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    UserDefaults.standard.set(false, forKey: "hasSeenTutorial")
                                    showTutorial = true
                                }) {
                                    Text("Show")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .cornerRadius(12)
                                }
                            }
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        }
                        .padding(.horizontal, 8)
                        
                        // App Version
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("App Version")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Current version information")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("v1.5")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        }
                        .padding(.horizontal, 8)
                        
                        // Support Email
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Support Email")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Get help or report issues")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("support@onsys.com.au")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView(showTutorial: $showTutorial)
        }
    }
}
