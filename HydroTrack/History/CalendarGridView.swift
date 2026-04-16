import SwiftUI

struct CalendarGridView: View {
    @Binding var displayMonth: Date
    @Binding var selectedDay: Date?
    let dataStore: HydroDataStore

    private let weekdayLabels = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(spacing: 14) {
            monthNavigation
            weekdayHeader
            daysGrid
        }
        .padding(16)
        .hydroGlass(cornerRadius: 20)
    }

    // MARK: - Subviews

    private var monthNavigation: some View {
        HStack {
            Button { changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(8)
            }

            Spacer()

            Text(displayMonth.monthAndYear)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Button { changeMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(8)
            }
            .disabled(displayMonth.firstDayOfMonth() >= Date().firstDayOfMonth())
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(weekdayLabels, id: \.self) { label in
                Text(label)
                    .font(.caption2.bold())
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            // Blank offset cells for first weekday
            ForEach(0..<firstWeekdayOffset(), id: \.self) { _ in
                Color.clear.frame(height: 34)
            }

            // Day cells
            ForEach(daysInMonth(), id: \.self) { date in
                let record = dataStore.dayRecord(for: date)
                let isFuture = Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
                let isSelected = selectedDay.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false

                DayCell(
                    day: date.dayOfMonth,
                    isToday: date.isToday,
                    isSelected: isSelected,
                    isFuture: isFuture,
                    status: record.status
                )
                .onTapGesture {
                    guard !isFuture else { return }
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedDay = date
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func changeMonth(by value: Int) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: displayMonth) else { return }
        withAnimation(.easeInOut(duration: 0.25)) { displayMonth = newDate }
    }

    private func daysInMonth() -> [Date] { displayMonth.daysInMonth() }

    private func firstWeekdayOffset() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: displayMonth.firstDayOfMonth())
        return weekday - 1 // Sunday = 1 → offset 0
    }
}

// MARK: - DayCell

struct DayCell: View {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let isFuture: Bool
    let status: DayStatus

    private var bg: Color {
        if isFuture { return .clear }
        switch status {
        case .complete: return .statusGreen.opacity(0.75)
        case .partial:  return .statusYellow.opacity(0.75)
        case .behind:   return .statusRed.opacity(0.6)
        case .none:     return .white.opacity(0.08)
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color.white : (isToday ? Color.white.opacity(0.55) : .clear),
                            lineWidth: isSelected ? 2 : 1
                        )
                )

            Text("\(day)")
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundStyle(isFuture ? Color.white.opacity(0.25) : .white)
        }
        .frame(height: 34)
    }
}
