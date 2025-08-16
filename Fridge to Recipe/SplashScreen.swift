import SwiftUI

struct SplashScreen: View {
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 1.0
    
    let onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Clean background that matches launch screen
            Color(.systemBackground)
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
            
            // Simple, elegant icon
            Image("transparent-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1: Gentle fade in with subtle bounce (0.0 - 0.6s)
        withAnimation(.easeOut(duration: 0.4)) {
            iconOpacity = 1.0
        }
        
        withAnimation(.interpolatingSpring(stiffness: 80, damping: 10, initialVelocity: 0)) {
            iconScale = 1.0
        }
        
        // Phase 2: Brief pause to appreciate the icon (0.6 - 1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Subtle breathing effect
            withAnimation(.easeInOut(duration: 0.6)) {
                iconScale = 1.05
            }
        }
        
        // Phase 3: Clean fade out (1.2 - 1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                iconScale = 1.1
                iconOpacity = 0.0
                backgroundOpacity = 0.0
            }
            
            // Phase 4: Transition to main app (1.5s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onAnimationComplete()
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen {
            print("Animation complete")
        }
    }
}
