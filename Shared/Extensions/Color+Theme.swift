import SwiftUI

// MARK: - Brand Colors (on Color)

extension Color {
    static let hydroNavy    = Color(hex: "03045E")
    static let hydroDark    = Color(hex: "023E8A")
    static let hydroDeep    = Color(hex: "0077B6")
    static let hydroMid     = Color(hex: "00B4D8")
    static let hydroLight   = Color(hex: "90E0EF")
    static let hydroFoam    = Color(hex: "CAF0F8")
    static let statusGreen  = Color(hex: "2DC653")
    static let statusYellow = Color(hex: "FFB703")
    static let statusRed    = Color(hex: "E63946")

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

// MARK: - Brand Colors (on ShapeStyle — required for dot-syntax in iOS 26 SwiftUI)

extension ShapeStyle where Self == Color {
    static var hydroNavy:    Color { Color(hex: "03045E") }
    static var hydroDark:    Color { Color(hex: "023E8A") }
    static var hydroDeep:    Color { Color(hex: "0077B6") }
    static var hydroMid:     Color { Color(hex: "00B4D8") }
    static var hydroLight:   Color { Color(hex: "90E0EF") }
    static var hydroFoam:    Color { Color(hex: "CAF0F8") }
    static var statusGreen:  Color { Color(hex: "2DC653") }
    static var statusYellow: Color { Color(hex: "FFB703") }
    static var statusRed:    Color { Color(hex: "E63946") }
}

// MARK: - Gradients

extension LinearGradient {
    static var hydroGradient: LinearGradient {
        LinearGradient(
            colors: [.hydroNavy, .hydroDeep, .hydroMid],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

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
    /// Applies Liquid Glass on iOS 26+, falls back to ultraThinMaterial on iOS 17–25.
    /// Default corner radius is intentionally small — use the parameter to override.
    @ViewBuilder
    func hydroGlass(cornerRadius: CGFloat = 10) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

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
