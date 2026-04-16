import Foundation

extension Date {

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    /// e.g. "April 2026"
    var monthAndYear: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: self)
    }

    /// e.g. "Tue"
    var shortWeekday: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: self)
    }

    /// All calendar dates in the same month as self.
    func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: self) else { return [] }
        var comps = calendar.dateComponents([.year, .month], from: self)
        return range.compactMap { day -> Date? in
            comps.day = day
            return calendar.date(from: comps)
        }
    }

    /// The first day of the month containing self.
    func firstDayOfMonth() -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: comps) ?? self
    }

    /// Time-of-day greeting string.
    var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default:      return "Hey"
        }
    }
}
