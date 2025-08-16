import SwiftUI

struct CookNowView: View {
    @ObservedObject var timerManager: CookNowTimerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var timerScale: CGFloat = 1.0
    @State private var buttonPressed: String? = nil
    @State private var lastRemaining: TimeInterval = 0
    @State private var showCelebration = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                Spacer()
                // Removed extra Cook Now text
                Spacer().frame(width: 32)
            }
            .padding(.top)
            
            // Main Content
            if showCelebration || timerManager.isComplete {
                CelebrationView(onDone: { presentationMode.wrappedValue.dismiss() })
            } else if let step = timerManager.currentStep {
                CookNowStepView(
                    step: step,
                    timerManager: timerManager,
                    timerScale: $timerScale,
                    buttonPressed: $buttonPressed,
                    lastRemaining: $lastRemaining
                )
            } else {
                // When all steps are complete, show celebration
                CelebrationView(onDone: { presentationMode.wrappedValue.dismiss() })
            }
            
            // Music Player Integration
            if !(showCelebration || timerManager.isComplete) {
                MusicPlayerView()
                    .padding(.horizontal)
            }
            
            // Upcoming Steps
            if !(showCelebration || timerManager.isComplete), timerManager.currentStepIndex + 1 < timerManager.steps.count {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upcoming Steps:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    ForEach(timerManager.steps.dropFirst(timerManager.currentStepIndex + 1)) { step in
                        HStack {
                            Text(step.name)
                            Spacer()
                            Text(timeString(from: step.duration))
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .onAppear {
            print("CookNowView: View appeared, starting timer...")
            timerManager.start()
            lastRemaining = timerManager.currentStep?.remaining ?? 0
        }
        .onDisappear {
            timerManager.stop()
        }
        .onChange(of: timerManager.isComplete) { _, complete in
            if complete {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showCelebration = true
                }
            }
        }
    }
    
    func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CookNowStepView: View {
    @ObservedObject var step: CookNowStep
    var timerManager: CookNowTimerManager
    @Binding var timerScale: CGFloat
    @Binding var buttonPressed: String?
    @Binding var lastRemaining: TimeInterval
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Step \(timerManager.currentStepIndex + 1) of \(timerManager.steps.count)")
                .font(.headline)
                .foregroundColor(.secondary)
                        Text(step.name)
                .font(.title).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            // Timer Display
            Text(timeString(from: step.remaining))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.accentColor)
                .onChange(of: step.remaining) { newValue in
                    if newValue != lastRemaining {
                        lastRemaining = newValue
                    }
                }
            
            // Animated Progress Bar
            ProgressView(value: step.remaining, total: step.duration)
                .accentColor(.accentColor)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: step.remaining)
            // Controls
            HStack(spacing: 24) {
                if timerManager.isPaused {
                    Button(action: {
                        buttonPressed = "resume"
                        timerManager.resume()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { buttonPressed = nil }
                    }) {
                        Label("Resume", systemImage: "play.fill")
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [Color.orange, Color.pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                            .scaleEffect(buttonPressed == "resume" ? 1.1 : 1.0)
                            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: buttonPressed)
                    }
                } else {
                    Button(action: {
                        buttonPressed = "pause"
                        timerManager.pause()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { buttonPressed = nil }
                    }) {
                        Label("Pause", systemImage: "pause.fill")
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [Color.orange, Color.pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                            .scaleEffect(buttonPressed == "pause" ? 1.1 : 1.0)
                            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: buttonPressed)
                    }
                }
                Button(action: {
                    buttonPressed = "skip"
                    timerManager.skip()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { buttonPressed = nil }
                }) {
                    Label("Skip", systemImage: "forward.fill")
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .foregroundColor(.accentColor)
                        .scaleEffect(buttonPressed == "skip" ? 1.1 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: buttonPressed)
                }
            }
        }
    }
    
    func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CelebrationView: View {
    var onDone: () -> Void
    @State private var showCheck = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()
                Text("🎉 Recipe Complete! 🎉")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                    .scaleEffect(showCheck ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 10), value: showCheck)
                if showCheck {
                    Image(systemName: "checkmark.seal.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                        .scaleEffect(showCheck ? 1.2 : 0.8)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 10), value: showCheck)
                }
                Text("You finished all the steps! Great job.")
                    .font(.title2)
                    .foregroundColor(.primary)
                Button("Done") {
                    onDone()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [Color.orange, Color.pink], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(Capsule())
                .foregroundColor(.white)
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCheck = true
            }
        }
    }
}

struct ConfettiView: View {
    @State private var animate = false
    let confettiColors: [Color] = [.orange, .pink, .yellow, .green, .blue, .purple]
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<20) { i in
                    Circle()
                        .fill(confettiColors[i % confettiColors.count])
                        .frame(width: 12, height: 12)
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: animate ? geo.size.height + 20 : CGFloat.random(in: 0...geo.size.height/2)
                        )
                        .opacity(0.8)
                        .animation(
                            .interpolatingSpring(stiffness: 80, damping: 8)
                                .delay(Double(i) * 0.05),
                            value: animate
                        )
                }
            }
            .onAppear {
                animate = true
            }
        }
        .allowsHitTesting(false)
    }
}

// Preview
struct CookNowView_Previews: PreviewProvider {
    static var previews: some View {
        let steps = [
            RecipeStep(name: "Chop Vegetables", duration: 180),
            RecipeStep(name: "Sauté Ingredients", duration: 300),
            RecipeStep(name: "Simmer Sauce", duration: 600)
        ]
        CookNowView(timerManager: CookNowTimerManager(steps: steps, recipeName: "Sample Recipe"))
    }
} 
