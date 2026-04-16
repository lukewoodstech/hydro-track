import SwiftUI
import WidgetKit

// MARK: - HomeScreenWidgetView

struct HomeScreenWidgetView: View {
    let entry: HydroWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  smallView
        case .systemMedium: mediumView
        default:            smallView
        }
    }

    // MARK: - Small (2×2)

    private var smallView: some View {
        VStack(spacing: 6) {
            // Icon + percentage
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundStyle(.hydroMid)
                Text("HydroTrack")
                    .font(.caption2.bold())
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Big percentage
            Text("\(entry.progressPercent)%")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("\(Int(entry.todayOz)) oz today")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            // Mini bottle row
            HStack(spacing: 3) {
                ForEach(Array(entry.bottleStates.prefix(6).enumerated()), id: \.offset) { index, state in
                    Button(intent: LogBottleIntent(bottleIndex: index)) {
                        Image(systemName: state.fillFraction >= 1.0 ? "waterbottle.fill" : "waterbottle")
                            .font(.system(size: 11))
                            .foregroundStyle(state.fillFraction >= 1.0 ? Color.hydroMid : Color.white.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
    }

    // MARK: - Medium (4×2)

    private var mediumView: some View {
        HStack(spacing: 0) {
            // Left: progress + stats
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                        .foregroundStyle(.hydroMid)
                    Text("HydroTrack")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Text("\(entry.progressPercent)%")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(Int(entry.todayOz)) oz · \(entry.streakDays)🔥")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()
            }
            .padding(.leading, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1)
                .padding(.vertical, 14)

            // Right: bottle grid (2 rows × 3 cols max)
            let bottles = Array(entry.bottleStates.prefix(6))
            let rows    = bottles.chunked(into: 3)

            VStack(spacing: 10) {
                ForEach(rows.indices, id: \.self) { rowIdx in
                    HStack(spacing: 10) {
                        ForEach(Array(rows[rowIdx].enumerated()), id: \.offset) { colIdx, state in
                            let globalIdx = rowIdx * 3 + colIdx
                            Button(intent: LogBottleIntent(bottleIndex: globalIdx)) {
                                WidgetBottleIcon(fillFraction: state.fillFraction)
                                    .scaleEffect(1.4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Custom quick-add buttons
                HStack(spacing: 8) {
                    quickAdd(oz: 8)
                    quickAdd(oz: 16)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
        }
    }

    private func quickAdd(oz: Double) -> some View {
        Button(intent: LogCustomAmountIntent(amountOz: oz)) {
            Text("+\(Int(oz)) oz")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.2), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Array chunk helper

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
