import Foundation
import WidgetKit

// MARK: - HydroDataStore

/// Shared data store using an App Group UserDefaults container so both the
/// main app and the widget extension read/write the same data.
///
/// Add the App Group "group.com.hydrotrack.app" to both targets in Xcode
/// under Signing & Capabilities → App Groups.
class HydroDataStore: ObservableObject {

    // MARK: Singleton
    static let shared = HydroDataStore()

    // MARK: Constants
    static let appGroupID = "group.com.hydrotrack.app"
    private let profileKey   = "hydro_userProfile"
    private let logsKey      = "hydro_waterLogs"
    private let onboardingKey = "hydro_onboardingComplete"

    // MARK: Storage
    private let defaults: UserDefaults

    // MARK: Published state
    @Published var profile: UserProfile?
    @Published var allLogs: [WaterLog] = []
    @Published var isOnboardingComplete: Bool = false

    // MARK: Init
    init() {
        self.defaults = UserDefaults(suiteName: HydroDataStore.appGroupID) ?? UserDefaults.standard
        load()
    }

    // MARK: - Computed

    var todayLogs: [WaterLog] {
        logsForDate(Date())
    }

    var todayTotalOz: Double {
        todayLogs.reduce(0) { $0 + $1.amountOz }
    }

    var todayProgress: Double {
        guard let goal = profile?.dailyGoalOz, goal > 0 else { return 0 }
        return min(todayTotalOz / goal, 1.0)
    }

    /// Returns an array of BottleState values representing how full each
    /// bottle is for today, based on cumulative oz logged.
    var bottleStates: [BottleState] {
        guard let profile else { return [] }
        let total = todayTotalOz
        let size = profile.bottleSizeOz
        let count = profile.bottlesPerDay

        return (0..<count).map { index in
            let bottleStart = Double(index) * size
            let bottleEnd   = bottleStart + size

            if total >= bottleEnd {
                return BottleState(fillFraction: 1.0)
            } else if total > bottleStart {
                return BottleState(fillFraction: (total - bottleStart) / size)
            } else {
                return BottleState(fillFraction: 0.0)
            }
        }
    }

    // MARK: - Actions

    func logWater(_ oz: Double) {
        guard oz > 0 else { return }
        allLogs.append(WaterLog(amountOz: oz))
        saveLogs()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func logFullBottle() {
        guard let size = profile?.bottleSizeOz else { return }
        logWater(size)
    }

    func completeOnboarding(with profile: UserProfile) {
        self.profile = profile
        isOnboardingComplete = true
        saveProfile(profile)
        defaults.set(true, forKey: onboardingKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateProfile(_ profile: UserProfile) {
        self.profile = profile
        saveProfile(profile)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func resetToday() {
        let calendar = Calendar.current
        allLogs.removeAll { calendar.isDateInToday($0.timestamp) }
        saveLogs()
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Queries

    func logsForDate(_ date: Date) -> [WaterLog] {
        let calendar = Calendar.current
        return allLogs.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }

    func dayRecord(for date: Date) -> DayRecord {
        DayRecord(
            date: date,
            logs: logsForDate(date),
            goalOz: profile?.dailyGoalOz ?? 64
        )
    }

    /// Returns day records for the past `count` days, newest first.
    func recentDays(count: Int) -> [DayRecord] {
        let calendar = Calendar.current
        return (0..<count).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            return dayRecord(for: date)
        }
    }

    /// Consecutive days the user has met their goal (includes today if complete).
    func streak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Count today only if goal is met
        if dayRecord(for: checkDate).percentComplete >= 1.0 {
            streak += 1
        }

        // Walk backwards through previous days
        while let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) {
            checkDate = prev
            let record = dayRecord(for: checkDate)
            if record.logs.isEmpty || record.percentComplete < 1.0 { break }
            streak += 1
        }

        return streak
    }

    // MARK: - Persistence

    private func load() {
        isOnboardingComplete = defaults.bool(forKey: onboardingKey)

        if let data = defaults.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        }

        if let data = defaults.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([WaterLog].self, from: data) {
            allLogs = decoded
        }
    }

    private func saveLogs() {
        if let data = try? JSONEncoder().encode(allLogs) {
            defaults.set(data, forKey: logsKey)
        }
    }

    private func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: profileKey)
        }
    }
}
