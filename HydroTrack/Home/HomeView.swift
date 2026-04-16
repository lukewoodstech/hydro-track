import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataStore: HydroDataStore
    @State private var showQuickLog = false

    private var greeting: String {
        "\(Date().timeGreeting), \(dataStore.profile?.name ?? "there")!"
    }

    private var progressPercent: Int {
        Int(dataStore.todayProgress * 100)
    }

    private var remainingOz: Double {
        max(0, (dataStore.profile?.dailyGoalOz ?? 64) - dataStore.todayTotalOz)
    }

    var body: some View {
        ZStack {
            LinearGradient.hydroGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerView
                        .padding(.top, 8)

                    ProgressRingView(progress: dataStore.todayProgress)
                        .frame(width: 220, height: 220)

                    statsRow

                    bottleSection

                    logButton

                    if !dataStore.todayLogs.isEmpty {
                        recentLogsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("HydroTrack")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showQuickLog) {
            QuickLogView()
                .presentationDetents([.height(340)])
                .presentationCornerRadius(28)
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(progressPercent >= 100
                 ? "Goal complete — great work today."
                 : "You're \(progressPercent)% to your daily goal")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(Int(dataStore.todayTotalOz))", unit: "oz",  label: "consumed")
            StatCard(value: "\(Int(remainingOz))",            unit: "oz",  label: "remaining")
            StatCard(value: "\(dataStore.streak())",          unit: "days", label: "streak")
        }
    }

    private var bottleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Bottles")
                .font(.headline)
                .foregroundStyle(.white)

            let states = dataStore.bottleStates
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: min(max(states.count, 1), 5))

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Array(states.enumerated()), id: \.offset) { _, state in
                    WaterBottleIcon(fillFraction: state.fillFraction, size: 40)
                }
            }
            .padding(16)
            .hydroGlass(cornerRadius: 20)
        }
    }

    private var logButton: some View {
        Button { showQuickLog = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Log Water")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.hydroDeep.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .hydroDeep.opacity(0.4), radius: 8, y: 4)
        }
    }

    private var recentLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Log")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                ForEach(dataStore.todayLogs.reversed()) { log in
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(.hydroMid)
                            .frame(width: 20)
                        Text("\(Int(log.amountOz)) oz")
                            .foregroundStyle(.white)
                        Spacer()
                        Text(log.timestamp, style: .time)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    if log.id != dataStore.todayLogs.first?.id {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .hydroGlass(cornerRadius: 16)
        }
    }
}

// MARK: - StatCard

struct StatCard: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .hydroGlass(cornerRadius: 14)
    }
}
