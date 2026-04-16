import SwiftUI
import WidgetKit

// MARK: - LockScreenWidgetView
//
// Displayed in .accessoryRectangular (lock screen / StandBy).
// Layout:
//   ┌─────────────────────────────────────────┐
//   │  62% hydrated                           │
//   │  🍶 🍶 🍶 🍶 🍶 🍶  [+8oz] [+16oz]   │
//   └─────────────────────────────────────────┘

struct LockScreenWidgetView: View {
    let entry: HydroWidgetEntry

    /// Cap displayed bottles at 8 to avoid crowding the small widget.
    private var displayedBottles: [BottleState] {
        Array(entry.bottleStates.prefix(8))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Progress label
            Text("\(entry.progressPercent)% hydrated")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            // Bottle icons + custom-amount buttons
            HStack(spacing: 5) {
                ForEach(Array(displayedBottles.enumerated()), id: \.offset) { index, state in
                    Button(intent: LogBottleIntent(bottleIndex: index)) {
                        WidgetBottleIcon(fillFraction: state.fillFraction)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 4)

                // Quick-add buttons: +8 oz and +16 oz
                quickAddButton(oz: 8)
                quickAddButton(oz: 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
    }

    private func quickAddButton(oz: Double) -> some View {
        Button(intent: LogCustomAmountIntent(amountOz: oz)) {
            Text("+\(Int(oz))")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.75))
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(.tertiary, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - WidgetBottleIcon

/// Minimal bottle icon for use inside widgets where SwiftUI drawing is constrained.
struct WidgetBottleIcon: View {
    let fillFraction: Double

    var body: some View {
        ZStack {
            // Outline
            Image(systemName: "waterbottle")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.primary.opacity(0.25))

            // Fill (bottom-up mask)
            Image(systemName: "waterbottle.fill")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(fillFraction >= 1.0 ? Color.primary : Color.primary.opacity(0.6))
                .mask(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 15 * fillFraction)
                }
        }
        .frame(width: 16, height: 20)
    }
}
