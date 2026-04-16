import AppIntents
import WidgetKit

// MARK: - LogCustomAmountIntent

/// Logs a specific oz amount when the user taps a custom-amount button in the widget.
struct LogCustomAmountIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Custom Amount"
    static var description = IntentDescription("Logs a specified amount of water in oz.")

    @Parameter(title: "Amount (oz)")
    var amountOz: Double

    init() { self.amountOz = 8 }
    init(amountOz: Double) { self.amountOz = amountOz }

    func perform() async throws -> some IntentResult {
        let store = HydroDataStore.shared
        guard amountOz > 0 else { return .result() }
        store.logWater(amountOz)
        if let profile = store.profile {
            NotificationService.shared.rescheduleNotifications(
                for: profile,
                todayOz: store.todayTotalOz
            )
        }
        return .result()
    }
}
