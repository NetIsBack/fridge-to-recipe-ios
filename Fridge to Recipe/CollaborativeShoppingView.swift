//
//  CollaborativeShoppingView.swift
//  Fridge to Recipe
//
//  Main collaborative shopping list view
//

import SwiftUI

struct CollaborativeShoppingView: View {
    @StateObject private var collaborativeService = CollaborativeService()
    @State private var showAuthSheet = false
    @State private var showCreateList = false
    @State private var showJoinList = false
    @State private var selectedListId: String?
    @State private var newItem = ""
    @State private var inviteCode = ""
    @State private var showInviteSheet = false
    @State private var showAccountSheet = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if collaborativeService.isAuthenticated {
                authenticatedView
            } else {
                unauthenticatedView
            }
        }
        .sheet(isPresented: $showAuthSheet) {
            CollaborativeAuthView(collaborativeService: collaborativeService)
        }
        .sheet(isPresented: $showCreateList) {
            CreateCollaborativeListView(collaborativeService: collaborativeService)
        }
        .sheet(isPresented: $showJoinList) {
            JoinListSheet(
                inviteCode: $inviteCode,
                collaborativeService: collaborativeService,
                onJoin: {
                    showJoinList = false
                    inviteCode = ""
                },
                onCancel: {
                    showJoinList = false
                    inviteCode = ""
                }
            )
        }
        .sheet(isPresented: $showInviteSheet) {
            if let listId = selectedListId,
               let list = collaborativeService.collaborativeLists.first(where: { $0.id == listId }) {
                InviteCollaboratorsView(list: list, collaborativeService: collaborativeService)
            }
        }
        .sheet(isPresented: $showAccountSheet) {
            AccountManagementView(collaborativeService: collaborativeService)
        }
    }
    
    private var syncStatusButton: some View {
        Button(action: {}) {
            HStack(spacing: 4) {
                switch collaborativeService.syncStatus {
                case .synced:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                case .syncing:
                    ProgressView()
                        .scaleEffect(0.8)
                case .offline:
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.orange)
                case .error:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .disabled(true)
    }
    
    private var authenticatedView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header matching main shopping list
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.primary)
                        .shadow(radius: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Collaborative Lists")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Shop together in real-time.")
                            .font(.title3.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 48)
                
                // Action Buttons aligned to left under header like Recipes Cooked button
                HStack(spacing: 16) {
                    // Create List Button
                    Button(action: {
                        showCreateList = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                                .font(.headline)
                            Text("Create")
                                .font(.headline.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(22)
                        .shadow(color: .blue.opacity(0.3), radius: 5, y: 2)
                    }
                    
                    // Join List Button
                    Button(action: {
                        showJoinList = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .font(.headline)
                            Text("Join")
                                .font(.headline.weight(.semibold))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Menu Button with Account and Sign Out
                    Menu {
                        Button("Account Settings") {
                            showAccountSheet = true
                        }
                        if selectedListId != nil {
                            Button("Invite Others") {
                                showInviteSheet = true
                            }
                        }
                        Divider()
                        Button("Sign Out", role: .destructive) {
                            try? collaborativeService.signOut()
                        }
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .cornerRadius(22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // User Info
                if let user = collaborativeService.currentUser {
                    HStack {
                        Circle()
                            .fill(user.colorValue)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(user.initials)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Welcome, \(user.displayName)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(collaborativeService.collaborativeLists.count) collaborative lists")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                
                // Lists
                if collaborativeService.collaborativeLists.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(collaborativeService.collaborativeLists) { list in
                            CollaborativeListCard(
                                list: list,
                                items: collaborativeService.listItems[list.id] ?? [],
                                collaborativeService: collaborativeService,
                                isSelected: selectedListId == list.id,
                                onSelect: {
                                    selectedListId = selectedListId == list.id ? nil : list.id
                                },
                                onInvite: {
                                    selectedListId = list.id
                                    showInviteSheet = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private var unauthenticatedView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "person.2.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                
                VStack(spacing: 12) {
                    Text("Collaborate with Others")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    Text("Create shared shopping lists that sync in real-time with your friends and family")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            Button(action: {
                showAuthSheet = true
            }) {
                Text("Get Started")
                    .font(.headline)
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
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 5, y: 3)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Collaborative Lists")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text("Create your first collaborative shopping list or join one using an invite code")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            HStack(spacing: 16) {
                Button("Create List") {
                    showCreateList = true
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Join List") {
                    showJoinList = true
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private var listsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(collaborativeService.collaborativeLists) { list in
                    CollaborativeListCard(
                        list: list,
                        items: collaborativeService.listItems[list.id] ?? [],
                        collaborativeService: collaborativeService,
                        isSelected: selectedListId == list.id,
                        onSelect: {
                            selectedListId = selectedListId == list.id ? nil : list.id
                        },
                        onInvite: {
                            selectedListId = list.id
                            showInviteSheet = true
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
}

struct CollaborativeListCard: View {
    let list: CollaborativeShoppingList
    let items: [CollaborativeShoppingItem]
    @ObservedObject var collaborativeService: CollaborativeService
    let isSelected: Bool
    let onSelect: () -> Void
    let onInvite: () -> Void
    @State private var newItem = ""
    @State private var showItemDetail = false
    @State private var selectedItem: CollaborativeShoppingItem?
    
    private var completedItems: Int {
        items.filter { $0.isChecked }.count
    }
    
    private var totalItems: Int {
        items.count
    }
    
    private var currentUserRole: CollaborativeShoppingList.CollaboratorRole? {
        guard let userId = collaborativeService.currentUser?.id else { return nil }
        return list.collaborators[userId]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // List Header - matches main shopping list style
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    onSelect()
                }
            }) {
                HStack {
                    // List Icon and Info
                    HStack(spacing: 12) {
                        Image(systemName: list.icon)
                            .font(.title2)
                            .foregroundColor(list.colorValue)
                            .frame(width: 40, height: 40)
                            .background(list.colorValue.opacity(0.1))
                            .cornerRadius(10)
                            .scaleEffect(isSelected ? 1.05 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(list.name)
                                .font(.headline.bold())
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Text("\(completedItems)/\(totalItems) completed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if list.collaborators.count > 1 {
                                    Text("• \(list.collaborators.count) collaborators")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Expand/Collapse Icon
                        Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(isSelected ? 180 : 0))
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
                    }
                }
                .padding(20)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded Content - matches main shopping list structure
            if isSelected {
                VStack(spacing: 12) {
                    // Add Item Input - exactly like main shopping list
                    if currentUserRole?.canEdit == true {
                        HStack(spacing: 12) {
                            TextField("Add item", text: $newItem)
                                .padding(14)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                                .foregroundColor(.primary)
                                .font(.headline)
                            Button(action: { addItem() }) {
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
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    
                    // Items List
                    ForEach(items) { item in
                        CollaborativeItemRow(
                            item: item,
                            collaborativeService: collaborativeService,
                            listId: list.id,
                            canEdit: currentUserRole?.canEdit == true
                        )
                    }
                    
                    // Invite People Button
                    Button(action: onInvite) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .font(.caption)
                            Text("Invite People")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    // Collaborators
                    if list.collaborators.count > 1 {
                        collaboratorsView
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(28)
        .shadow(color: .black.opacity(0.10), radius: 12, y: 4)
    }
    
    private var collaboratorsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Collaborators")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(list.collaborators.keys), id: \.self) { userId in
                        if let role = list.collaborators[userId] {
                            CollaboratorAvatarView(
                                userId: userId,
                                role: role,
                                collaborativeService: collaborativeService
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private func addItem() {
        guard !newItem.isEmpty else { return }
        
        Task {
            try? await collaborativeService.addItem(name: newItem, to: list.id)
            DispatchQueue.main.async {
                self.newItem = ""
            }
        }
    }
}

struct CollaborativeItemRow: View {
    let item: CollaborativeShoppingItem
    @ObservedObject var collaborativeService: CollaborativeService
    let listId: String
    let canEdit: Bool
    @State private var showPriceSheet = false
    @State private var isPressed = false
    @State private var isDeleting = false
    
    var body: some View {
        HStack {
            // Check button
            if canEdit {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        toggleItemChecked()
                    }
                }) {
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(item.isChecked ? .green : .gray)
                        .scaleEffect(item.isChecked ? 1.1 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: item.isChecked)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .strikethrough(item.isChecked)
                    .animation(.easeInOut(duration: 0.2), value: item.isChecked)
                
                Text("Added by \(collaborativeService.getUserDisplayName(userId: item.addedBy))")
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
            }
            .padding(.leading, 6)
            
            Spacer()
            
            // Price button
            if canEdit {
                Button(action: {
                    showPriceSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 11))
                        if let price = item.price {
                            Text(String(format: "$%.2f", price))
                                .font(.system(size: 11, weight: .bold))
                        } else {
                            Text("Set Price")
                                .font(.system(size: 11))
                        }
                    }
                    .foregroundColor(item.price != nil ? .green : .blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(6)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            
            // Delete button
            if canEdit {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isDeleting = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            removeItem()
                        }
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Color.white.opacity(0.7))
                        .clipShape(Circle())
                        .scaleEffect(isDeleting ? 0.8 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(colors: [Color.orange.opacity(0.15), Color.pink.opacity(0.15)], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(Capsule())
        .shadow(color: Color.orange.opacity(0.08), radius: 4, y: 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .opacity(isDeleting ? 0.5 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isDeleting)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .sheet(isPresented: $showPriceSheet) {
            PriceInputSheetForCollaborative(
                item: item,
                listId: listId,
                collaborativeService: collaborativeService
            )
        }
    }
    
    private func toggleItemChecked() {
        Task {
            try? await collaborativeService.toggleItemChecked(itemId: item.id, in: listId)
        }
    }
    
    private func removeItem() {
        Task {
            try? await collaborativeService.removeItem(itemId: item.id, from: listId)
        }
    }
}

struct CollaboratorAvatarView: View {
    let userId: String
    let role: CollaborativeShoppingList.CollaboratorRole
    @ObservedObject var collaborativeService: CollaborativeService
    @State private var user: UserProfile?
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(user?.colorValue ?? Color.blue)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(user?.initials ?? "?")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 1) {
                Text(user?.displayName.components(separatedBy: " ").first ?? "User")
                    .font(.caption2.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(role.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            Task {
                user = await collaborativeService.getUserProfile(userId: userId)
            }
        }
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    let isCompact: Bool
    
    init(isCompact: Bool = false) {
        self.isCompact = isCompact
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(isCompact ? .caption.bold() : .headline)
            .foregroundColor(.white)
            .padding(.horizontal, isCompact ? 12 : 20)
            .padding(.vertical, isCompact ? 6 : 12)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(isCompact ? 8 : 12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    CollaborativeShoppingView()
}
