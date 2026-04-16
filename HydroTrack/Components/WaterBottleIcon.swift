import SwiftUI

// MARK: - WaterBottleIcon

/// A single water bottle icon that visually fills from the bottom up
/// according to `fillFraction` (0 = empty, 1 = full).
///
/// Uses the SF Symbol `waterbottle` / `waterbottle.fill` (iOS 17+).
/// The fill is achieved by masking the filled symbol with a bottom-aligned
/// rectangle whose height equals `fillFraction × totalHeight`.
struct WaterBottleIcon: View {
    /// 0.0 (empty) → 1.0 (full)
    let fillFraction: Double
    /// Width of the icon; height is 1.8× width for a natural bottle proportion.
    let size: CGFloat

    private var fillColor: Color {
        if fillFraction >= 1.0 { return .hydroMid }
        if fillFraction > 0    { return .hydroLight }
        return .white.opacity(0.25)
    }

    var body: some View {
        ZStack {
            // Outline (always shown)
            Image(systemName: "waterbottle")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.white.opacity(0.25))

            // Filled layer, clipped from the bottom up
            Image(systemName: "waterbottle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(fillColor)
                .mask(alignment: .bottom) {
                    Rectangle()
                        .frame(height: size * 1.8 * fillFraction)
                }
        }
        .frame(width: size, height: size * 1.8)
        .animation(.easeOut(duration: 0.4), value: fillFraction)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        WaterBottleIcon(fillFraction: 0.0,  size: 32)
        WaterBottleIcon(fillFraction: 0.33, size: 32)
        WaterBottleIcon(fillFraction: 0.66, size: 32)
        WaterBottleIcon(fillFraction: 1.0,  size: 32)
    }
    .padding()
    .background(LinearGradient.hydroGradient)
}
