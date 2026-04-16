import AppIntents
import WidgetKit

// MARK: - LogBottleIntent

/// Logs one full bottle of water when the user taps a bottle icon in the widget.
struct LogBottleIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Full Bottle"
    static var description = IntentDescription("Logs one full bottle of water.")

    /// Index of the tapped bottle (unused for logic, kept for future animation hooks).
    @Parameter(title: "Bottle Index")
    var bottleIndex: Int

    init() { self.bottleIndex = 0 }
    init(bottleIndex: Int) { self.bottleIndex = bottleIndex }

    func perform() async throws -> some IntentResult {
        let store = HydroDataStore.shared
        guard let bottleSize = store.profile?.bottleSizeOz, bottleSize > 0 else {
            return .result()
        }
        store.logWater(bottleSize)
        // Reschedule notifications from the widget context
        if let profile = store.profile {
            NotificationService.shared.rescheduleNotifications(
                for: profile,
                todayOz: store.todayTotalOz
            )
        }
        return .result()
    }
}
