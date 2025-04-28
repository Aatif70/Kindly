import SwiftUI

// MARK: - View Extensions
extension View {
    // Apply soft neumorphic shadow to any view
    func neuShadow() -> some View {
        self
            .shadow(color: Color.black.opacity(0.07), radius: 5, x: 2, y: 2)
            .shadow(color: Color.white.opacity(0.8), radius: 5, x: -2, y: -2)
    }
    
    // Common button style for the app
    func kindlyButtonStyle(backgroundColor: Color = KindlyColors.primaryPink, textColor: Color = .white) -> some View {
        self
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if backgroundColor == KindlyColors.primaryPink {
                        KindlyColors.primaryGradient
                    } else {
                        backgroundColor
                    }
                }
            )
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
    
    // Outlined button style
    func kindlyOutlinedButtonStyle(textColor: Color = KindlyColors.primaryPink) -> some View {
        self
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(KindlyColors.warmWhite)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(KindlyColors.primaryPink, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // Card style for various cards in the app
    func kindlyCardStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(KindlyColors.warmWhite)
                    .shadow(color: Color.black.opacity(0.04), radius: 7, x: 0, y: 3)
            )
            .padding(.horizontal)
    }
    
    // Add a gentle hover effect
    func kindlyHoverEffect() -> some View {
        self.scaleEffect(1.02)
            .animation(.kindlyBounce, value: true)
    }
    
    // Add a gentle appear effect
    func kindlyAppearEffect() -> some View {
        self.transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity).animation(.kindlySpring),
            removal: .scale(scale: 0.95).combined(with: .opacity).animation(.easeOut(duration: 0.2))
        ))
    }
}

// MARK: - Date Extensions
extension Date {
    // Format date to a readable string
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: self)
    }
    
    // Check if date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    // Get start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

// MARK: - String Extensions
extension String {
    // Validate if string is not empty or just whitespace
    var isNotEmpty: Bool {
        return !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Animation Extensions
extension Animation {
    // Standard animation for the app
    static var kindlySpring: Animation {
        return .spring(response: 0.4, dampingFraction: 0.7)
    }
    
    // Bouncy animation for playful elements
    static var kindlyBounce: Animation {
        return .spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0.3)
    }
    
    // Gentle animation for transitions
    static var kindlyGently: Animation {
        return .easeInOut(duration: 0.5)
    }
    
    // Quick animation for small UI elements
    static var kindlyQuick: Animation {
        return .easeOut(duration: 0.2)
    }
    
    // Playful animation for calendar items
    static var kindlyPop: Animation {
        return .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2)
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 