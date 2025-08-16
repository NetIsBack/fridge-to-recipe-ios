//
//  CollaborativeSupportingViews.swift
//  Fridge to Recipe
//
//  Supporting views for collaborative shopping lists
//

import SwiftUI

// MARK: - Create Collaborative List View
struct CreateCollaborativeListView: View {
    @ObservedObject var collaborativeService: CollaborativeService
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "list.bullet"
    @State private var isLoading = false
    
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
                                        colors: [colorForName(selectedColor), colorForName(selectedColor).opacity(0.7)],
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
                                .shadow(color: colorForName(selectedColor).opacity(0.3), radius: 12, y: 4)
                            
                            // List Name Input
                            TextField("List Name", text: $name)
                                .font(.title3.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                        }
                
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Color")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(colorForName(color))
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
                                                    colors: [colorForName(selectedColor), colorForName(selectedColor).opacity(0.8)],
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
                Button(action: createList) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.body)
                            Text("Create Collaborative List")
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
                                    colors: [colorForName(selectedColor), colorForName(selectedColor).opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: colorForName(selectedColor).opacity(0.3), radius: 8, y: 4)
                }
                .disabled(name.isEmpty || isLoading)
                .opacity(name.isEmpty || isLoading ? 0.6 : 1.0)
                .scaleEffect(name.isEmpty || isLoading ? 0.98 : 1.0)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        default: return .blue
        }
    }
    
    private func createList() {
        isLoading = true
        
        Task {
            do {
                try await collaborativeService.createCollaborativeList(
                    name: name,
                    color: selectedColor,
                    icon: selectedIcon
                )
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Handle error - could show alert
                    print("Error creating list: \(error)")
                }
            }
        }
    }
}

// MARK: - Invite Collaborators View
struct InviteCollaboratorsView: View {
    let list: CollaborativeShoppingList
    @ObservedObject var collaborativeService: CollaborativeService
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(list.colorValue)
                    
                    Text("Invite Collaborators")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    Text("Share this list with friends and family so you can shop together")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Invite Code
                VStack(spacing: 16) {
                    Text("Invite Code")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(list.inviteCode)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(list.colorValue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(list.colorValue.opacity(0.1))
                            .cornerRadius(15)
                        
                        Button(action: {
                            UIPasteboard.general.string = list.inviteCode
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.title2)
                                .foregroundColor(list.colorValue)
                        }
                    }
                    
                    Text("Others can join by entering this code in the app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Share Button
                Button(action: {
                    showShareSheet = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                        Text("Share List")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [list.colorValue, list.colorValue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
                
                // Current Collaborators
                if list.collaborators.count > 1 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Collaborators (\(list.collaborators.count))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(Array(list.collaborators.keys), id: \.self) { userId in
                            if let role = list.collaborators[userId] {
                                HStack {
                                    Circle()
                                        .fill(list.colorValue)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Text("?") // Would show user initials
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("User") // Would show actual name
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)
                                        Text(role.rawValue.capitalized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationTitle(list.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [generateInviteText()])
        }
    }
    
    private func generateInviteText() -> String {
        return """
        🛒 Join my shopping list: \(list.name)
        
        Use invite code: \(list.inviteCode)
        
        Download "Fridge to Recipe" and enter this code to start collaborating!
        """
    }
}

// MARK: - Price Input Sheet for Collaborative
struct PriceInputSheetForCollaborative: View {
    let item: CollaborativeShoppingItem
    let listId: String
    @ObservedObject var collaborativeService: CollaborativeService
    @Environment(\.dismiss) private var dismiss
    @State private var priceText = ""
    @State private var isLoading = false
    
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
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Set Price")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        Text(item.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        savePrice()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(priceText.isEmpty || isLoading ? .gray : .blue)
                    .disabled(priceText.isEmpty || isLoading)
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
                                        colors: [Color.green.opacity(0.2), Color.blue.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.2.badge.plus")
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
                        
                        Text("Set the price for this collaborative item")
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
                                .foregroundColor(.green)
                                .frame(width: 20)
                            
                            TextField("0.00", text: $priceText)
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
                        Text("This price will be shared with all collaborators")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    // Remove price button if price exists
                    if item.price != nil {
                        Button(action: removePrice) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Remove Price")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.2)
                    
                    Text("Updating price...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
            }
        }
        .onAppear {
            if let price = item.price {
                priceText = String(format: "%.2f", price)
            }
        }
    }
    
    private func savePrice() {
        guard let price = Double(priceText) else { return }
        
        isLoading = true
        
        Task {
            do {
                try await collaborativeService.updateItemPrice(itemId: item.id, price: price, in: listId)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Error updating price: \(error)")
                }
            }
        }
    }
    
    private func removePrice() {
        Task {
            try? await collaborativeService.updateItemPrice(itemId: item.id, price: 0, in: listId)
            DispatchQueue.main.async {
                self.dismiss()
            }
        }
    }
}

// MARK: - Join List Sheet
struct JoinListSheet: View {
    @Binding var inviteCode: String
    @ObservedObject var collaborativeService: CollaborativeService
    let onJoin: () -> Void
    let onCancel: () -> Void
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text("Join Shopping List")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Text("Enter the invite code shared by your friend or family member")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Invite Code")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter 6-character code", text: $inviteCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.characters)
                        .onSubmit {
                            joinList()
                        }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: joinList) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "person.badge.plus")
                                    .font(.headline)
                            }
                            Text(isLoading ? "Joining..." : "Join List")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(inviteCode.isEmpty || isLoading)
                    
                    Button("Cancel", action: onCancel)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium])
    }
    
    private func joinList() {
        guard !inviteCode.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await collaborativeService.joinListWithCode(inviteCode: inviteCode)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.onJoin()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = self.getErrorMessage(from: error)
                }
            }
        }
    }
    
    private func getErrorMessage(from error: Error) -> String {
        if error is CollaborationError {
            switch error as! CollaborationError {
            case .invalidInviteCode:
                return "Invalid invite code. Please check and try again."
            case .notAuthenticated:
                return "Please sign in to join lists."
            default:
                return "An error occurred. Please try again."
            }
        } else {
            return "Network error. Please check your connection."
        }
    }
}


#Preview {
    CreateCollaborativeListView(collaborativeService: CollaborativeService())
}
