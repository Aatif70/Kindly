import SwiftUI

struct KindlyColors {
    // Main colors
    static let primaryPink = Color(hex: "FF92BB")  // Deeper, more vibrant pink
    static let secondaryPink = Color(hex: "FFB0CF") // More saturated lighter pink
    static let subtlePink = Color(hex: "FFE6F0")    // Slightly more vibrant light pink
    static let warmWhite = Color(hex: "FFFCFC")     // Slightly warm white
    static let accentRed = Color(hex: "FF7A95")     // More vivid touch of red
    
    // Gradient combinations
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [primaryPink, accentRed.opacity(0.9)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let subtleGradient = LinearGradient(
        gradient: Gradient(colors: [warmWhite, subtlePink.opacity(0.7)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Background style
    static func cardBackground() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(warmWhite)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
} 