//
//  CollaborativeService.swift
//  Fridge to Recipe
//
//  Firebase service for collaborative shopping lists
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine
import Network

class CollaborativeService: ObservableObject {
    @Published var collaborativeLists: [CollaborativeShoppingList] = []
    @Published var listItems: [String: [CollaborativeShoppingItem]] = [:] // listId: items
    @Published var activityLogs: [String: [ActivityLogEntry]] = [:] // listId: activities
    @Published var currentUser: UserProfile?
    @Published var cachedUsers: [String: UserProfile] = [:] // userId: profile
    @Published var isAuthenticated = false
    @Published var isOnline = true
    @Published var syncStatus: SyncStatus = .synced
    
    private let db = Firestore.firestore()
    private var listListeners: [String: ListenerRegistration] = [:]
    private var itemListeners: [String: ListenerRegistration] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var pendingChanges: [PendingChange] = []
    
    enum SyncStatus {
        case syncing
        case synced
        case offline
        case error(String)
    }
    
    init() {
        setupNetworkMonitoring()
        setupAuthListener()
        loadPendingChanges()
        testFirebaseConnection()
    }
    
    // MARK: - Firebase Connection Test
    private func testFirebaseConnection() {
        #if DEBUG
        print("Testing Firebase connection...")
        
        // Test Firestore connectivity
        db.collection("test").document("connection").getDocument { document, error in
            if let error = error {
                print("❌ Firebase connection test failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.syncStatus = .error("Firebase connection failed: \(error.localizedDescription)")
                }
            } else {
                print("✅ Firebase connection successful")
            }
        }
        #endif
    }
    
    // MARK: - Network Monitoring
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                if path.status == .satisfied {
                    self?.syncStatus = .synced
                    self?.syncPendingChanges()
                } else {
                    self?.syncStatus = .offline
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    // MARK: - User Management
    func getUserProfile(userId: String) async -> UserProfile? {
        if let cached = cachedUsers[userId] {
            return cached
        }
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data(),
               let user = try? Firestore.Decoder().decode(UserProfile.self, from: data) {
                DispatchQueue.main.async {
                    self.cachedUsers[userId] = user
                }
                return user
            }
        } catch {
            print("Error fetching user profile: \(error)")
        }
        return nil
    }
    
    func getUserDisplayName(userId: String) -> String {
        if let user = cachedUsers[userId] {
            return user.displayName
        }
        return "User"
    }
    
    // MARK: - Authentication
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let user = user {
                    self?.loadUserProfile(userId: user.uid)
                    self?.loadUserLists()
                } else {
                    self?.currentUser = nil
                    self?.collaborativeLists = []
                    self?.listItems = [:]
                    self?.removeAllListeners()
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String, displayName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = UserProfile(id: result.user.uid, displayName: displayName, email: email)
        try await createUserProfile(user: user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - User Profile Management
    private func loadUserProfile(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error loading user profile: \(error)")
                return
            }
            
            if let data = snapshot?.data(),
               let user = try? Firestore.Decoder().decode(UserProfile.self, from: data) {
                DispatchQueue.main.async {
                    self?.currentUser = user
                }
            } else {
                // Create profile if it doesn't exist
                if let authUser = Auth.auth().currentUser {
                    let newUser = UserProfile(
                        id: authUser.uid,
                        displayName: authUser.displayName ?? "Unknown User",
                        email: authUser.email ?? ""
                    )
                    Task {
                        try? await self?.createUserProfile(user: newUser)
                    }
                }
            }
        }
    }
    
    private func createUserProfile(user: UserProfile) async throws {
        let data = try Firestore.Encoder().encode(user)
        try await db.collection("users").document(user.id).setData(data)
        
        DispatchQueue.main.async {
            self.currentUser = user
        }
    }
    
    func updateUserProfile(displayName: String, email: String, profileImage: UIImage?, currentPassword: String?, newPassword: String?) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              let currentUser = currentUser else {
            throw CollaborationError.notAuthenticated
        }
        
        // Update Firebase Auth email if changed
        if email != currentUser.email {
            if let currentPassword = currentPassword {
                // Re-authenticate before changing email
                let credential = EmailAuthProvider.credential(withEmail: currentUser.email, password: currentPassword)
                try await Auth.auth().currentUser?.reauthenticate(with: credential)
            }
            try await Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email)
        }
        
        // Update password if provided
        if let newPassword = newPassword, !newPassword.isEmpty {
            if let currentPassword = currentPassword {
                // Re-authenticate before changing password
                let credential = EmailAuthProvider.credential(withEmail: currentUser.email, password: currentPassword)
                try await Auth.auth().currentUser?.reauthenticate(with: credential)
            }
            try await Auth.auth().currentUser?.updatePassword(to: newPassword)
        }
        
        // Process profile image
        var profileImageData: Data?
        if let profileImage = profileImage {
            profileImageData = profileImage.jpegData(compressionQuality: 0.8)
        }
        
        // Create updated user profile
        var updatedUser = currentUser
        updatedUser.displayName = displayName
        updatedUser.email = email
        updatedUser.profileImageData = profileImageData
        updatedUser.updatedAt = Date()
        
        // Update Firestore document
        let data = try Firestore.Encoder().encode(updatedUser)
        try await db.collection("users").document(userId).setData(data)
        
        // Update local state
        DispatchQueue.main.async {
            self.currentUser = updatedUser
            self.cachedUsers[userId] = updatedUser
        }
    }
    
    // MARK: - List Management
    func createCollaborativeList(name: String, color: String, icon: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CollaborationError.notAuthenticated
        }
        
        let list = CollaborativeShoppingList(name: name, color: color, icon: icon, ownerId: userId)
        let data = try Firestore.Encoder().encode(list)
        
        if isOnline {
            try await db.collection("shopping_lists").document(list.id).setData(data)
            await logActivity(
                listId: list.id,
                action: .joinedList,
                itemName: nil
            )
        } else {
            // Store for offline sync
            let changeData = try JSONEncoder().encode(list)
            let change = PendingChange(listId: list.id, changeType: .addItem, data: changeData)
            pendingChanges.append(change)
            savePendingChanges()
        }
        
        DispatchQueue.main.async {
            self.collaborativeLists.append(list)
        }
    }
    
    func joinListWithCode(inviteCode: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ User not authenticated")
            throw CollaborationError.notAuthenticated
        }
        
        print("🔍 Attempting to join list with code: \(inviteCode)")
        print("👤 User ID: \(userId)")
        
        // Check network connectivity first
        guard isOnline else {
            print("❌ Device is offline")
            throw CollaborationError.networkUnavailable
        }
        
        do {
            print("📡 Querying Firebase for invite code: \(inviteCode.uppercased())")
            let query = db.collection("shopping_lists").whereField("inviteCode", isEqualTo: inviteCode.uppercased())
            let snapshot = try await query.getDocuments()
            
            print("📋 Found \(snapshot.documents.count) documents")
            
            guard let document = snapshot.documents.first else {
                print("❌ No list found with invite code: \(inviteCode)")
                throw CollaborationError.invalidInviteCode
            }
            
            print("📄 Document data: \(document.data())")
            
            guard var list = try? Firestore.Decoder().decode(CollaborativeShoppingList.self, from: document.data()) else {
                print("❌ Failed to decode list data")
                throw CollaborationError.invalidInviteCode
            }
            
            print("✅ Successfully decoded list: \(list.name)")
            
            // Add user as editor
            list.collaborators[userId] = .editor
            list.updatedAt = Date()
            
            let data = try Firestore.Encoder().encode(list)
            try await db.collection("shopping_lists").document(list.id).setData(data)
            
            print("✅ Successfully updated list with new collaborator")
            
            await logActivity(
                listId: list.id,
                action: .joinedList,
                itemName: nil
            )
            
            DispatchQueue.main.async {
                self.collaborativeLists.append(list)
                self.setupListListener(for: list.id)
            }
            
            print("✅ Successfully joined list: \(list.name)")
        } catch {
            print("❌ Firebase error joining list: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error details: \(error.localizedDescription)")
            throw CollaborationError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Test Functions
    func createTestList() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CollaborationError.notAuthenticated
        }
        
        var testList = CollaborativeShoppingList(name: "Test List", color: "blue", icon: "list.bullet", ownerId: userId)
        // Manually set the invite code to match what you're testing with
        testList.inviteCode = "PEUZYQ"
        
        let data = try Firestore.Encoder().encode(testList)
        try await db.collection("shopping_lists").document(testList.id).setData(data)
        
        print("✅ Created test list with invite code: \(testList.inviteCode)")
    }
    
    // MARK: - Authentication Testing
    func checkAuthenticationStatus() {
        if let user = Auth.auth().currentUser {
            print("✅ User is authenticated:")
            print("   - UID: \(user.uid)")
            print("   - Email: \(user.email ?? "No email")")
            print("   - Display Name: \(user.displayName ?? "No display name")")
            print("   - Email Verified: \(user.isEmailVerified)")
        } else {
            print("❌ User is NOT authenticated")
        }
    }
    
    // MARK: - Sign in anonymously for testing
    func signInAnonymouslyForTesting() async throws {
        try await Auth.auth().signInAnonymously()
        print("✅ Signed in anonymously for testing")
    }
    
    private func loadUserLists() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("shopping_lists")
            .whereField("collaborators.\(userId)", isNotEqualTo: NSNull())
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading user lists: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let lists = documents.compactMap { document -> CollaborativeShoppingList? in
                    try? Firestore.Decoder().decode(CollaborativeShoppingList.self, from: document.data())
                }
                
                DispatchQueue.main.async {
                    self?.collaborativeLists = lists
                    // Setup listeners for each list
                    lists.forEach { list in
                        self?.setupListListener(for: list.id)
                        // Preload user profiles for collaborators
                        self?.preloadUserProfiles(for: list)
                    }
                }
            }
    }
    
    // MARK: - Real-time Item Management
    private func setupListListener(for listId: String) {
        // Remove existing listener if any
        itemListeners[listId]?.remove()
        
        let listener = db.collection("shopping_lists")
            .document(listId)
            .collection("items")
            .order(by: "addedAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error listening to list items: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let items = documents.compactMap { document -> CollaborativeShoppingItem? in
                    try? Firestore.Decoder().decode(CollaborativeShoppingItem.self, from: document.data())
                }
                
                DispatchQueue.main.async {
                    self?.listItems[listId] = items
                    self?.syncStatus = .synced
                }
            }
        
        itemListeners[listId] = listener
    }
    
    func addItem(name: String, to listId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CollaborationError.notAuthenticated
        }
        
        let item = CollaborativeShoppingItem(name: name, addedBy: userId)
        
        if isOnline {
            let data = try Firestore.Encoder().encode(item)
            try await db.collection("shopping_lists")
                .document(listId)
                .collection("items")
                .document(item.id)
                .setData(data)
            
            await logActivity(
                listId: listId,
                action: .addedItem,
                itemName: name
            )
        } else {
            // Store for offline sync
            let changeData = try JSONEncoder().encode(item)
            let change = PendingChange(listId: listId, changeType: .addItem, data: changeData)
            pendingChanges.append(change)
            savePendingChanges()
            
            // Update local state immediately
            DispatchQueue.main.async {
                if self.listItems[listId] == nil {
                    self.listItems[listId] = []
                }
                self.listItems[listId]?.append(item)
            }
        }
    }
    
    func removeItem(itemId: String, from listId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              let list = collaborativeLists.first(where: { $0.id == listId }),
              let role = list.collaborators[userId],
              role.canEdit else {
            throw CollaborationError.insufficientPermissions
        }
        
        if isOnline {
            try await db.collection("shopping_lists")
                .document(listId)
                .collection("items")
                .document(itemId)
                .delete()
            
            if let item = listItems[listId]?.first(where: { $0.id == itemId }) {
                await logActivity(
                    listId: listId,
                    action: .removedItem,
                    itemName: item.name
                )
            }
        } else {
            // Store for offline sync
            let changeData = itemId.data(using: .utf8) ?? Data()
            let change = PendingChange(listId: listId, changeType: .removeItem, data: changeData)
            pendingChanges.append(change)
            savePendingChanges()
            
            // Update local state immediately
            DispatchQueue.main.async {
                self.listItems[listId]?.removeAll { $0.id == itemId }
            }
        }
    }
    
    func toggleItemChecked(itemId: String, in listId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              let list = collaborativeLists.first(where: { $0.id == listId }),
              let role = list.collaborators[userId],
              role.canEdit else {
            throw CollaborationError.insufficientPermissions
        }
        
        guard var item = listItems[listId]?.first(where: { $0.id == itemId }) else {
            throw CollaborationError.listNotFound
        }
        
        item.isChecked.toggle()
        if item.isChecked {
            item.checkedBy = userId
            item.checkedAt = Date()
        } else {
            item.checkedBy = nil
            item.checkedAt = nil
        }
        
        if isOnline {
            let data = try Firestore.Encoder().encode(item)
            try await db.collection("shopping_lists")
                .document(listId)
                .collection("items")
                .document(itemId)
                .setData(data)
            
            await logActivity(
                listId: listId,
                action: item.isChecked ? .checkedItem : .uncheckedItem,
                itemName: item.name
            )
        } else {
            // Store for offline sync
            let changeData = try JSONEncoder().encode(item)
            let change = PendingChange(listId: listId, changeType: .updateItem, data: changeData)
            pendingChanges.append(change)
            savePendingChanges()
            
            // Update local state immediately
            DispatchQueue.main.async {
                if let index = self.listItems[listId]?.firstIndex(where: { $0.id == itemId }) {
                    self.listItems[listId]?[index] = item
                }
            }
        }
    }
    
    func updateItemPrice(itemId: String, price: Double, in listId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              let list = collaborativeLists.first(where: { $0.id == listId }),
              let role = list.collaborators[userId],
              role.canEdit else {
            throw CollaborationError.insufficientPermissions
        }
        
        guard var item = listItems[listId]?.first(where: { $0.id == itemId }) else {
            throw CollaborationError.listNotFound
        }
        
        let oldPrice = item.price
        item.price = price
        
        if isOnline {
            try await db.collection("shopping_lists")
                .document(listId)
                .collection("items")
                .document(itemId)
                .updateData(["price": price])
            
            await logActivity(
                listId: listId,
                action: .updatedPrice,
                itemName: item.name,
                oldValue: oldPrice != nil ? String(format: "%.2f", oldPrice!) : nil,
                newValue: String(format: "%.2f", price)
            )
        } else {
            // Store for offline sync
            let changeData = try JSONEncoder().encode(["price": price])
            let change = PendingChange(listId: listId, changeType: .updatePrice, data: changeData)
            pendingChanges.append(change)
            savePendingChanges()
            
            // Update local state immediately
            DispatchQueue.main.async {
                if let index = self.listItems[listId]?.firstIndex(where: { $0.id == itemId }) {
                    self.listItems[listId]?[index].price = price
                }
            }
        }
    }
    
    
    // MARK: - Performance Optimization
    private func preloadUserProfiles(for list: CollaborativeShoppingList) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for userId in list.collaborators.keys {
                    if cachedUsers[userId] == nil {
                        group.addTask {
                            _ = await self.getUserProfile(userId: userId)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - User Profile Helper Methods
    private func createPlaceholderUser(userId: String) async -> UserProfile {
        // Create a more user-friendly placeholder
        var displayName = "User"
        var email = ""
        
        // Try to make a reasonable display name from userId if it looks like an email
        if userId.contains("@") {
            displayName = userId.components(separatedBy: "@").first?.capitalized ?? "User"
            email = userId
        } else if userId.count > 8 {
            // For Firebase UIDs, create a shorter, friendlier identifier
            displayName = "User \(userId.suffix(4))"
        }
        
        return UserProfile(
            id: userId,
            displayName: displayName,
            email: email
        )
    }
    
    // MARK: - Cache Management
    func clearUserCache() {
        DispatchQueue.main.async {
            self.cachedUsers.removeAll()
            // Trigger UI update to reload all user names
            self.objectWillChange.send()
        }
        
        // Reload user profiles for all current collaborative lists
        for list in collaborativeLists {
            preloadUserProfiles(for: list)
        }
    }
    
    func refreshUserProfile(userId: String) async {
        // Remove from cache to force fresh fetch
        DispatchQueue.main.async {
            self.cachedUsers.removeValue(forKey: userId)
        }
        
        // Fetch fresh data
        _ = await getUserProfile(userId: userId)
        
        // Trigger UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Activity Logging
    private func logActivity(
        listId: String,
        action: ActivityLogEntry.ActivityAction,
        itemName: String? = nil,
        oldValue: String? = nil,
        newValue: String? = nil
    ) async {
        guard let userId = Auth.auth().currentUser?.uid,
              let userName = currentUser?.displayName else { return }
        
        let activity = ActivityLogEntry(
            userId: userId,
            userName: userName,
            action: action,
            itemName: itemName,
            oldValue: oldValue,
            newValue: newValue
        )
        
        do {
            let data = try Firestore.Encoder().encode(activity)
            try await db.collection("shopping_lists")
                .document(listId)
                .collection("activity_log")
                .document(activity.id)
                .setData(data)
        } catch {
            print("Error logging activity: \(error)")
        }
    }
    
    // MARK: - Offline Support
    private func loadPendingChanges() {
        if let data = UserDefaults.standard.data(forKey: "pendingChanges"),
           let changes = try? JSONDecoder().decode([PendingChange].self, from: data) {
            self.pendingChanges = changes
        }
    }
    
    private func savePendingChanges() {
        if let data = try? JSONEncoder().encode(pendingChanges) {
            UserDefaults.standard.set(data, forKey: "pendingChanges")
        }
    }
    
    private func syncPendingChanges() {
        guard isOnline && !pendingChanges.isEmpty else { return }
        
        syncStatus = .syncing
        
        Task {
            for change in pendingChanges {
                do {
                    try await processPendingChange(change)
                } catch {
                    print("Error syncing change: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.pendingChanges.removeAll()
                self.savePendingChanges()
                self.syncStatus = .synced
            }
        }
    }
    
    private func processPendingChange(_ change: PendingChange) async throws {
        switch change.changeType {
        case .addItem:
            if let item = try? JSONDecoder().decode(CollaborativeShoppingItem.self, from: change.data) {
                let data = try Firestore.Encoder().encode(item)
                try await db.collection("shopping_lists")
                    .document(change.listId)
                    .collection("items")
                    .document(item.id)
                    .setData(data)
            }
        case .removeItem:
            let itemId = String(data: change.data, encoding: .utf8) ?? ""
            try await db.collection("shopping_lists")
                .document(change.listId)
                .collection("items")
                .document(itemId)
                .delete()
        case .updateItem:
            if let item = try? JSONDecoder().decode(CollaborativeShoppingItem.self, from: change.data) {
                let data = try Firestore.Encoder().encode(item)
                try await db.collection("shopping_lists")
                    .document(change.listId)
                    .collection("items")
                    .document(item.id)
                    .setData(data)
            }
        case .checkItem:
            // Handle check/uncheck updates
            break
        case .updatePrice:
            if let priceData = try? JSONDecoder().decode([String: Double].self, from: change.data),
               let price = priceData["price"] {
                // This would need the item ID, which we'd need to include in the change data
                // For now, this is a simplified implementation
            }
        }
    }
    
    // MARK: - Cleanup
    private func removeAllListeners() {
        listListeners.values.forEach { $0.remove() }
        itemListeners.values.forEach { $0.remove() }
        listListeners.removeAll()
        itemListeners.removeAll()
    }
    
    deinit {
        removeAllListeners()
        monitor.cancel()
    }
}
