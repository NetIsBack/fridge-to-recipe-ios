//
//  CollaborativeModels.swift
//  Fridge to Recipe
//
//  Created for collaborative shopping list functionality
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

// MARK: - Collaborative Shopping List Models
struct CollaborativeShoppingList: Identifiable, Codable {
    let id: String
    var name: String
    var color: String
    var icon: String
    var ownerId: String
    var collaborators: [String: CollaboratorRole] // userId: role
    var isPublic: Bool
    var createdAt: Date
    var updatedAt: Date
    var inviteCode: String // For easy sharing
    
    enum CollaboratorRole: String, Codable, CaseIterable {
        case owner = "owner"
        case editor = "editor"
        case viewer = "viewer"
        
        var canEdit: Bool {
            return self == .owner || self == .editor
        }
        
        var canDelete: Bool {
            return self == .owner
        }
        
        var canInvite: Bool {
            return self == .owner || self == .editor
        }
    }
    
    init(name: String, color: String, icon: String, ownerId: String) {
        self.id = UUID().uuidString
        self.name = name
        self.color = color
        self.icon = icon
        self.ownerId = ownerId
        self.collaborators = [ownerId: .owner]
        self.isPublic = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.inviteCode = String.randomString(length: 6).uppercased()
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

struct CollaborativeShoppingItem: Identifiable, Codable {
    let id: String
    var name: String
    var isChecked: Bool
    var addedBy: String
    var addedAt: Date
    var checkedBy: String?
    var checkedAt: Date?
    var price: Double?
    var notes: String?
    
    init(name: String, addedBy: String) {
        self.id = UUID().uuidString
        self.name = name
        self.isChecked = false
        self.addedBy = addedBy
        self.addedAt = Date()
        self.checkedBy = nil
        self.checkedAt = nil
        self.price = nil
        self.notes = nil
    }
}

struct ActivityLogEntry: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let action: ActivityAction
    let timestamp: Date
    let itemName: String?
    let oldValue: String?
    let newValue: String?
    
    enum ActivityAction: String, Codable {
        case addedItem = "added_item"
        case removedItem = "removed_item"
        case checkedItem = "checked_item"
        case uncheckedItem = "unchecked_item"
        case updatedPrice = "updated_price"
        case joinedList = "joined_list"
        case leftList = "left_list"
        case renamedList = "renamed_list"
        
        var description: String {
            switch self {
            case .addedItem: return "added"
            case .removedItem: return "removed"
            case .checkedItem: return "checked"
            case .uncheckedItem: return "unchecked"
            case .updatedPrice: return "updated price for"
            case .joinedList: return "joined the list"
            case .leftList: return "left the list"
            case .renamedList: return "renamed the list"
            }
        }
    }
    
    init(userId: String, userName: String, action: ActivityAction, itemName: String? = nil, oldValue: String? = nil, newValue: String? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.userName = userName
        self.action = action
        self.timestamp = Date()
        self.itemName = itemName
        self.oldValue = oldValue
        self.newValue = newValue
    }
}

struct UserProfile: Identifiable, Codable {
    let id: String
    var displayName: String
    var email: String
    var avatarColor: String
    var profileImageURL: String? // URL to profile image
    var profileImageData: Data? // For local storage if needed
    var joinedAt: Date
    var updatedAt: Date
    var invitedLists: [String] // List IDs user has been invited to
    
    init(id: String, displayName: String, email: String, profileImageURL: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarColor = ["red", "orange", "yellow", "green", "blue", "purple", "pink"].randomElement() ?? "blue"
        self.profileImageURL = profileImageURL
        self.profileImageData = nil
        self.joinedAt = Date()
        self.updatedAt = Date()
        self.invitedLists = []
    }
    
    var colorValue: Color {
        switch avatarColor {
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
    
    var initials: String {
        let components = displayName.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            return String(displayName.prefix(2)).uppercased()
        }
    }
}

// MARK: - String Extension for Random String Generation
extension String {
    static func randomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

// MARK: - Error Types
enum CollaborationError: Error, LocalizedError {
    case notAuthenticated
    case listNotFound
    case insufficientPermissions
    case invalidInviteCode
    case networkError(String)
    case networkUnavailable
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You need to be signed in to use collaborative features"
        case .listNotFound:
            return "Shopping list not found"
        case .insufficientPermissions:
            return "You don't have permission to perform this action"
        case .invalidInviteCode:
            return "Invalid invite code"
        case .networkError(let message):
            return "Network error: \(message)"
        case .networkUnavailable:
            return "Network error. Please check your connection."
        case .userNotFound:
            return "User not found"
        }
    }
}

// MARK: - Offline Change Tracking
struct PendingChange: Codable {
    let id: String
    let listId: String
    let changeType: ChangeType
    let data: Data
    let timestamp: Date
    
    enum ChangeType: String, Codable {
        case addItem
        case removeItem
        case updateItem
        case checkItem
        case updatePrice
    }
    
    init(listId: String, changeType: ChangeType, data: Data) {
        self.id = UUID().uuidString
        self.listId = listId
        self.changeType = changeType
        self.data = data
        self.timestamp = Date()
    }
}
