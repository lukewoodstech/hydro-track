import SwiftUI
import Charts

struct WeeklyBarChart: View {
    @EnvironmentObject var dataStore: HydroDataStore

    private struct DayData: Identifiable {
        let id = UUID()
        let label: String
        let oz: Double
        let goal: Double
    }

    private var weekData: [DayData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let calendar = Calendar.current

        return (0..<7).reversed().compactMap { offset -> DayData? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let record = dataStore.dayRecord(for: date)
            return DayData(
                label: formatter.string(from: date),
                oz: record.totalOz,
                goal: record.goalOz
            )
        }
    }

    private var goalOz: Double {
        weekData.first?.goal ?? 64
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.headline)
                .foregroundStyle(.white)

            Chart {
                // Bars
                ForEach(weekData) { data in
                    BarMark(
                        x: .value("Day", data.label),
                        y: .value("oz",  data.oz)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.hydroDeep, .hydroMid],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }

                // Goal reference line
                RuleMark(y: .value("Goal", goalOz))
                    .foregroundStyle(Color.white.opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Goal")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisValueLabel()
                        .foregroundStyle(Color.white.opacity(0.6))
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.white.opacity(0.1))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.white.opacity(0.6))
                }
            }
            .frame(height: 160)
        }
        .padding(16)
        .hydroGlass(cornerRadius: 20)
    }
}
