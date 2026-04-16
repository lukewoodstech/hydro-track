import SwiftUI

struct QuickLogView: View {
    @EnvironmentObject var dataStore: HydroDataStore
    @Environment(\.dismiss) var dismiss

    @State private var customOz: Double = 8

    var body: some View {
        ZStack {
            LinearGradient.hydroGradient.ignoresSafeArea()

            VStack(spacing: 28) {
                // Handle bar
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                Text("Log Water")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                // Full bottle quick-log
                if let bottleSize = dataStore.profile?.bottleSizeOz {
                    Button {
                        log(dataStore.profile!.bottleSizeOz)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "waterbottle.fill")
                                .font(.title3)
                            Text("Full Bottle — \(Int(bottleSize)) oz")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.hydroDeep.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                }

                // Custom amount stepper
                VStack(spacing: 16) {
                    Text("Custom Amount")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))

                    HStack(spacing: 28) {
                        stepperButton(symbol: "minus.circle.fill") {
                            customOz = max(4, customOz - 4)
                        }

                        Text("\(Int(customOz)) oz")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(minWidth: 110)
                            .contentTransition(.numericText())
                            .animation(.spring(duration: 0.25), value: customOz)

                        stepperButton(symbol: "plus.circle.fill") {
                            customOz = min(256, customOz + 4)
                        }
                    }

                    Button {
                        log(customOz)
                    } label: {
                        Text("Log \(Int(customOz)) oz")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(20)
                .hydroGlass(cornerRadius: 20)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    // MARK: - Helpers

    private func log(_ oz: Double) {
        dataStore.logWater(oz)
        if let profile = dataStore.profile {
            NotificationService.shared.rescheduleNotifications(
                for: profile,
                todayOz: dataStore.todayTotalOz
            )
        }
        dismiss()
    }

    private func stepperButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 36))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}
