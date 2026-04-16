import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: HydroDataStore
    @State private var selectedTab = 0

    var body: some View {
        if dataStore.isOnboardingComplete {
            mainTabView
        } else {
            OnboardingView()
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Today", systemImage: "drop.fill") }
            .tag(0)

            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("History", systemImage: "calendar") }
            .tag(1)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(2)
        }
        .tint(.hydroMid)
        .onAppear {
            if let profile = dataStore.profile {
                NotificationService.shared.rescheduleNotifications(
                    for: profile,
                    todayOz: dataStore.todayTotalOz
                )
            }
        }
    }
}
