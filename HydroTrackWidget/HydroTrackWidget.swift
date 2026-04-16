import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct HydroWidgetEntry: TimelineEntry {
    let date: Date
    let profile: UserProfile?
    let todayOz: Double
    let bottleStates: [BottleState]
    let progressPercent: Int
    let streakDays: Int
}

// MARK: - Timeline Provider

struct HydroWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> HydroWidgetEntry {
        HydroWidgetEntry(
            date: Date(),
            profile: nil,
            todayOz: 48,
            bottleStates: [
                BottleState(fillFraction: 1.0),
                BottleState(fillFraction: 1.0),
                BottleState(fillFraction: 0.5),
                BottleState(fillFraction: 0.0),
            ],
            progressPercent: 62,
            streakDays: 4
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HydroWidgetEntry) -> Void) {
        completion(buildEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HydroWidgetEntry>) -> Void) {
        let entry = buildEntry()
        // Refresh at midnight (daily reset) or in 30 minutes, whichever is sooner.
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86_400))
        let nextRefresh = min(midnight, Date().addingTimeInterval(1_800))
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    // MARK: Private

    private func buildEntry() -> HydroWidgetEntry {
        let store = HydroDataStore.shared
        let goal  = store.profile?.dailyGoalOz ?? 64
        let total = store.todayTotalOz
        let pct   = goal > 0 ? Int(min(total / goal, 1.0) * 100) : 0

        return HydroWidgetEntry(
            date: Date(),
            profile: store.profile,
            todayOz: total,
            bottleStates: store.bottleStates,
            progressPercent: pct,
            streakDays: store.streak()
        )
    }
}

// MARK: - Lock Screen Widget

/// Rectangular accessory widget for the lock screen (iOS 16+).
/// Displays a row of interactive water bottle icons + percentage.
struct HydroLockScreenWidget: Widget {
    let kind = "HydroLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HydroWidgetProvider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("HydroTrack")
        .description("Track hydration right from your lock screen.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Home Screen Widget

/// Small and medium home screen widgets.
struct HydroHomeScreenWidget: Widget {
    let kind = "HydroHomeScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HydroWidgetProvider()) { entry in
            HomeScreenWidgetView(entry: entry)
                .containerBackground(LinearGradient.hydroGradient, for: .widget)
        }
        .configurationDisplayName("HydroTrack")
        .description("Your hydration progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
