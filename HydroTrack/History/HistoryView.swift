import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataStore: HydroDataStore
    @State private var displayMonth = Date()
    @State private var selectedDay: Date? = Date()

    var body: some View {
        ZStack {
            LinearGradient.hydroGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    streakBanner
                        .padding(.top, 8)

                    CalendarGridView(
                        displayMonth: $displayMonth,
                        selectedDay:  $selectedDay,
                        dataStore:    dataStore
                    )

                    if let day = selectedDay {
                        DayDetailCard(record: dataStore.dayRecord(for: day))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    WeeklyBarChart()

                    legend
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .animation(.easeInOut(duration: 0.25), value: selectedDay)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundStyle(.statusYellow)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(dataStore.streak())-day streak")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(dataStore.streak() == 0 ? "Start your streak today!" : "Keep it flowing!")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding(16)
        .hydroGlass(cornerRadius: 20)
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 16) {
            LegendItem(color: .statusGreen,  label: "Goal met")
            LegendItem(color: .statusYellow, label: "Partial")
            LegendItem(color: .statusRed,    label: "Missed")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .hydroGlass(cornerRadius: 14)
    }
}

// MARK: - DayDetailCard

struct DayDetailCard: View {
    let record: DayRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(record.date, style: .date)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                StatusBadge(status: record.status)
            }

            HStack(spacing: 0) {
                DetailStat(value: "\(Int(record.totalOz))", unit: "oz", label: "consumed")
                Divider().background(Color.white.opacity(0.25)).frame(height: 40)
                DetailStat(value: "\(Int(record.percentComplete * 100))", unit: "%", label: "of goal")
                Divider().background(Color.white.opacity(0.25)).frame(height: 40)
                DetailStat(value: "\(record.logs.count)", unit: "", label: "logs")
            }

            if let last = record.logs.sorted(by: { $0.timestamp < $1.timestamp }).last {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Last logged at \(last.timestamp, style: .time)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(16)
        .hydroGlass(cornerRadius: 20)
    }
}

// MARK: - Supporting views

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

private struct DetailStat: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value).font(.title3.bold()).foregroundStyle(.white)
                Text(unit).font(.caption).foregroundStyle(.white.opacity(0.6))
            }
            Text(label).font(.caption2).foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StatusBadge: View {
    let status: DayStatus

    var label: String {
        switch status {
        case .complete: return "Complete"
        case .partial:  return "Partial"
        case .behind:   return "Missed"
        case .none:     return "No data"
        }
    }

    var body: some View {
        Text(label)
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.statusColor.opacity(0.8))
            .clipShape(Capsule())
    }
}
