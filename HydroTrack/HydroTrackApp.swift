import SwiftUI

@main
struct HydroTrackApp: App {
    @StateObject private var dataStore = HydroDataStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    /// Handles deep links from the lock screen widget custom-amount button.
    /// URL scheme: hydrotrack://log?amount=16
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "hydrotrack", url.host == "log",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let amountStr = components.queryItems?.first(where: { $0.name == "amount" })?.value,
              let amount = Double(amountStr) else { return }

        dataStore.logWater(amount)
        if let profile = dataStore.profile {
            NotificationService.shared.rescheduleNotifications(
                for: profile,
                todayOz: dataStore.todayTotalOz
            )
        }
    }
}
