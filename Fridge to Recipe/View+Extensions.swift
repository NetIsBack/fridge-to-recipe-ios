import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Device Detection
extension View {
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }
    
    var isPortrait: Bool {
        UIDevice.current.orientation.isPortrait
    }
}

// MARK: - iPhone Layout (Default - No scaling)
extension View {
    // iPhone-optimized padding (no scaling)
    func iPhonePadding(_ horizontal: CGFloat = 20, _ vertical: CGFloat = 0) -> some View {
        self.padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
    }
    
    // iPhone-optimized font (no scaling)
    func iPhoneFont(_ size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.font(.system(size: size, weight: weight, design: design))
    }
    
    // iPhone-optimized spacing (no scaling)
    func iPhoneSpacing(_ spacing: CGFloat) -> some View {
        self.padding(.vertical, spacing)
    }
    
    // iPhone-optimized corner radius (no scaling)
    func iPhoneCornerRadius(_ radius: CGFloat) -> some View {
        self.cornerRadius(radius)
    }
    
    // iPhone-optimized shadow (no scaling)
    func iPhoneShadow(color: Color = .black, radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 5) -> some View {
        self.shadow(color: color.opacity(0.3), radius: radius, x: x, y: y)
    }
    
    // iPhone-optimized background (no scaling)
    func iPhoneBackground(_ color: Color) -> some View {
        self.background(color)
    }
    
    // iPhone-optimized gradient background (no scaling)
    func iPhoneGradientBackground(startColor: Color, endColor: Color) -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: [startColor, endColor]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - iPad Layout (Only applies on iPad)
extension View {
    // iPad-optimized padding (only on iPad)
    func iPadPadding(_ horizontal: CGFloat = 20, _ vertical: CGFloat = 0) -> some View {
        if isPad {
            return self.padding(.horizontal, horizontal * 2)
                .padding(.vertical, vertical * 1.5)
        } else {
            return self.padding(.horizontal, horizontal)
                .padding(.vertical, vertical)
        }
    }
    
    // iPad-optimized font (only on iPad)
    func iPadFont(_ size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        if isPad {
            return self.font(.system(size: size * 1.2, weight: weight, design: design))
        } else {
            return self.font(.system(size: size, weight: weight, design: design))
        }
    }
    
    // iPad-optimized spacing (only on iPad)
    func iPadSpacing(_ spacing: CGFloat) -> some View {
        if isPad {
            return self.padding(.vertical, spacing * 1.3)
        } else {
            return self.padding(.vertical, spacing)
        }
    }
    
    // iPad-optimized corner radius (only on iPad)
    func iPadCornerRadius(_ radius: CGFloat) -> some View {
        if isPad {
            return self.cornerRadius(radius * 1.2)
        } else {
            return self.cornerRadius(radius)
        }
    }
    
    // iPad-optimized shadow (only on iPad)
    func iPadShadow(color: Color = .black, radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 5) -> some View {
        if isPad {
            return self.shadow(color: color.opacity(0.3), radius: radius * 1.3, x: x * 1.2, y: y * 1.2)
        } else {
            return self.shadow(color: color.opacity(0.3), radius: radius, x: x, y: y)
        }
    }
    
    // iPad-optimized background (only on iPad)
    func iPadBackground(_ color: Color) -> some View {
        if isPad {
            return self.background(color.opacity(0.95))
        } else {
            return self.background(color)
        }
    }
    
    // iPad-optimized material background (only on iPad)
    func iPadMaterialBackground(_ material: Material) -> some View {
        return self.background(material)
    }
    
    // iPad-optimized gradient background (only on iPad)
    func iPadGradientBackground(startColor: Color, endColor: Color) -> some View {
        if isPad {
            return self.background(
                LinearGradient(
                    gradient: Gradient(colors: [startColor.opacity(0.98), endColor.opacity(0.98)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            return self.background(
                LinearGradient(
                    gradient: Gradient(colors: [startColor, endColor]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // iPad-optimized content width (only on iPad)
    func iPadContentWidth() -> some View {
        if isPad {
            return self.frame(maxWidth: 900)
                .padding(.horizontal, 60)
        } else {
            return self.frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
        }
    }
    
    // iPad-optimized card style (only on iPad)
    func iPadCardStyle() -> some View {
        if isPad {
            return self
                .background(.ultraThinMaterial)
                .cornerRadius(20 * 1.2)
                .shadow(color: .black.opacity(0.3), radius: 12 * 1.3, x: 0, y: 5 * 1.2)
                .padding(.horizontal, 20 * 2)
                .padding(.vertical, 16 * 1.5)
        } else {
            return self
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 5)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
    }
    
    // iPad-optimized button style (only on iPad)
    func iPadButtonStyle() -> some View {
        if isPad {
            return self
                .padding(.horizontal, 24 * 1.5)
                .padding(.vertical, 16 * 1.5)
                .cornerRadius(16 * 1.2)
                .shadow(color: .blue.opacity(0.3), radius: 8 * 1.3, x: 0, y: 4 * 1.2)
        } else {
            return self
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - iPad Layout Constants
struct iPadLayout {
    static let maxContentWidth: CGFloat = 900
    static let maxCardWidth: CGFloat = 400
    static let horizontalPadding: CGFloat = 60
    static let verticalPadding: CGFloat = 40
    static let cardSpacing: CGFloat = 24
    static let sectionSpacing: CGFloat = 32
    static let buttonHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 20
    static let shadowRadius: CGFloat = 12
    
    // iPad-specific spacing
    static let iPadSpacing: CGFloat = 1.3
    static let iPadFontScale: CGFloat = 1.2
    static let iPadPaddingScale: CGFloat = 1.5
    static let iPadCornerRadiusScale: CGFloat = 1.2
    static let iPadShadowScale: CGFloat = 1.3
    
    // Responsive breakpoints
    static let compactWidth: CGFloat = 768
    static let regularWidth: CGFloat = 1024
    static let largeWidth: CGFloat = 1366
}

// MARK: - iPad Responsive Grid
struct iPadResponsiveGrid<Content: View>: View {
    let content: Content
    let columns: [GridItem]
    
    init(columns: [GridItem] = [], @ViewBuilder content: () -> Content) {
        self.columns = columns.isEmpty ? [
            GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
        ] : columns
        self.content = content()
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            content
        }
        .iPadPadding()
    }
}

// MARK: - iPad Responsive Container
struct iPadResponsiveContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .iPadContentWidth()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 
