import SwiftUI

// MARK: - Brand Colors

extension Color {
    // Primary ocean blue/teal palette
    static let hydroNavy  = Color(hex: "03045E")
    static let hydroDark  = Color(hex: "023E8A")
    static let hydroDeep  = Color(hex: "0077B6")
    static let hydroMid   = Color(hex: "00B4D8")
    static let hydroLight = Color(hex: "90E0EF")
    static let hydroFoam  = Color(hex: "CAF0F8")

    // Status colors
    static let statusGreen  = Color(hex: "2DC653")
    static let statusYellow = Color(hex: "FFB703")
    static let statusRed    = Color(hex: "E63946")

    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradients

extension LinearGradient {
    /// Deep navy → blue → teal. Used as the primary app background.
    static var hydroGradient: LinearGradient {
        LinearGradient(
            colors: [.hydroNavy, .hydroDeep, .hydroMid],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Lighter teal gradient used on cards and widgets.
    static var hydroLightGradient: LinearGradient {
        LinearGradient(
            colors: [.hydroDeep, .hydroMid, .hydroLight],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Glass Effect Modifier

extension View {
    /// Frosted glass card using ultraThinMaterial (iOS 17+).
    /// When building with Xcode 26 / iOS 26 SDK, replace the body with:
    ///   self.glassEffect(.regular)
    @ViewBuilder
    func hydroGlass(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    /// Full-screen gradient background.
    @ViewBuilder
    func hydroBackground() -> some View {
        self.background(
            LinearGradient.hydroGradient
                .ignoresSafeArea()
        )
    }
}

// MARK: - DayStatus → Color

extension DayStatus {
    var statusColor: Color {
        switch self {
        case .complete: return .statusGreen
        case .partial:  return .statusYellow
        case .behind:   return .statusRed
        case .none:     return Color(.systemGray4)
        }
    }
}
