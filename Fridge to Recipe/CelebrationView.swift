import SwiftUI

/// Displayed when all cooking steps are complete.
struct CelebrationView: View {
    var onDone: () -> Void
    @State private var showCheck = false

    var body: some View {
        ZStack {
            ConfettiView()
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

/// Simple confetti animation used by ``CelebrationView``.
struct ConfettiView: View {
    @State private var animate = false
    let confettiColors: [Color] = [.orange, .pink, .yellow, .green, .blue, .purple]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(confettiColors[i % confettiColors.count])
                        .frame(width: 12, height: 12)
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: animate ? geo.size.height + 20 : CGFloat.random(in: 0...geo.size.height / 2)
                        )
                        .opacity(0.8)
                        .animation(
                            .interpolatingSpring(stiffness: 80, damping: 8)
                                .delay(Double(i) * 0.05),
                            value: animate
                        )
                }
            }
            .onAppear { animate = true }
        }
        .allowsHitTesting(false)
    }
}
