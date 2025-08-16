import SwiftUI

struct TutorialView: View {
    @Binding var showTutorial: Bool
    @State private var currentPage = 0
    @State private var animateContent = false
    
    let features = [
        TutorialFeature(
            icon: "plus.circle.fill",
            title: "Add Ingredients",
            description: "Start by adding ingredients to your virtual fridge. The app will suggest recipes based on what you have!",
            color: .red
        ),
        TutorialFeature(
            icon: "fork.knife.circle.fill",
            title: "Discover Recipes",
            description: "Get personalized recipe suggestions that match your available ingredients. Find new dishes to try!",
            color: .orange
        ),
        TutorialFeature(
            icon: "timer.circle.fill",
            title: "Cook Now",
            description: "Use our step-by-step timer feature for hands-free cooking. Perfect timing for every recipe!",
            color: .red
        ),
        TutorialFeature(
            icon: "heart.circle.fill",
            title: "Save Favourites",
            description: "Heart your favourite recipes to save them for later. Build your personal cookbook!",
            color: .pink
        ),
        TutorialFeature(
            icon: "list.bullet.circle.fill",
            title: "Smart Shopping",
            description: "Automatically generate shopping lists for missing ingredients. Never forget what to buy!",
            color: .green
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "refrigerator.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animateContent ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateContent)
                    
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)
                    
                    Text("Fridge to Recipe")
                        .font(.largeTitle.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    
                    Text("Your smart cooking companion")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.6), value: animateContent)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Feature cards
                TabView(selection: $currentPage) {
                    ForEach(0..<features.count, id: \.self) { index in
                        FeatureCard(feature: features[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 300)
                .opacity(animateContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(0.8), value: animateContent)
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<features.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.top, 20)
                .opacity(animateContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(1.0), value: animateContent)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring()) {
                            showTutorial = false
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.red, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(1.2), value: animateContent)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showTutorial = false
                        }
                    }) {
                        Text("Skip Tutorial")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(1.4), value: animateContent)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            animateContent = true
        }
    }
}

struct FeatureCard: View {
    let feature: TutorialFeature
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: feature.icon)
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [feature.color, feature.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(), value: isPressed)
            
            VStack(spacing: 12) {
                Text(feature.title)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
            }
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
        .padding(.horizontal, 20)
        .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
}

struct TutorialFeature {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

#Preview {
    TutorialView(showTutorial: .constant(true))
} 