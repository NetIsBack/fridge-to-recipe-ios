//
//  Fridge_to_RecipeApp.swift
//  Fridge to Recipe
//
//  Created by Ranil Perera on 6/7/2025.
//

import SwiftUI
import UserNotifications
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct Fridge_to_RecipeApp: App {
    @StateObject private var appData = AppDataModel()
    @StateObject private var shoppingListVM = ShoppingListViewModel()
    @State private var didFetchImages = false
    @State private var showTutorial = false
    @State private var showSplashScreen = true
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Enable Firestore offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        
        // Optional: Enable Firebase Auth debugging
        #if DEBUG
        print("Firebase configured successfully")
        if let app = FirebaseApp.app() {
            print("Firebase app name: \(app.name)")
            print("Firebase project ID: \(app.options.projectID ?? "Unknown")")
        }
        #endif
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        // Request notification permission on app launch
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // Handle permission
        }
        
        
        // Check if tutorial has been shown before
        showTutorial = !UserDefaults.standard.bool(forKey: "hasSeenTutorial")
    }
    
    static func loadSampleRecipes(completion: @escaping ([Recipe]) -> Void) {
        // Simply return the sample recipes without fetching images
        DispatchQueue.main.async {
            completion(sampleRecipes)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplashScreen {
                    SplashScreen {
                        withAnimation(.interpolatingSpring(stiffness: 60, damping: 8, initialVelocity: 0.5)) {
                            showSplashScreen = false
                        }
                    }
                } else {
                    ContentView()
                        .environmentObject(appData)
                        .environmentObject(shoppingListVM)
                        .onAppear {
                            if appData.recipes.isEmpty {
                                Fridge_to_RecipeApp.loadSampleRecipes { recipes in
                                    appData.recipes = recipes
                                }
                            }
                        }
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .opacity
                            )
                        )
                        .onOpenURL { url in
                            handleIncomingURL(url)
                        }
                    
                    if showTutorial {
                        TutorialView(showTutorial: $showTutorial)
                            .onDisappear {
                                UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - URL Handling for Spotify OAuth
    private func handleIncomingURL(_ url: URL) {
        print("🔗 App received URL: \(url)")
        print("🔗 URL scheme: \(url.scheme ?? "none"), host: \(url.host ?? "none")")
        
        // Handle Spotify OAuth callback
        if url.scheme == "fridgetorecipe" && url.host == "spotify-callback" {
            print("✅ App: Handling Spotify OAuth callback")
            
            // Close Safari by bringing our app to foreground
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: "fridgetorecipe://")!)
            }
            
            // Post notification for SpotifyService to handle
            NotificationCenter.default.post(
                name: NSNotification.Name("SpotifyOAuthCallback"),
                object: url
            )
        }
    }
}

