import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var dataStore: HydroDataStore
    @State private var step = 0

    // Collected inputs
    @State private var name = ""
    @State private var weightText = ""
    @State private var sex: Sex = .preferNotToSay
    @State private var activityLevel: ActivityLevel = .moderate
    @State private var bottleSizeText = ""

    var body: some View {
        ZStack {
            LinearGradient.hydroGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                progressDots
                    .padding(.top, 56)
                    .padding(.bottom, 8)

                Group {
                    switch step {
                    case 0: NameStepView(name: $name, onNext: advance)
                    case 1: WeightStepView(weightText: $weightText, onNext: advance)
                    case 2: SexStepView(sex: $sex, onNext: advance)
                    case 3: ActivityStepView(activityLevel: $activityLevel, onNext: advance)
                    case 4: BottleSizeStepView(bottleSizeText: $bottleSizeText, onNext: advance)
                    case 5: SummaryStepView(profile: buildProfile(), onFinish: finish)
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(duration: 0.4), value: step)
            }
        }
    }

    // MARK: - Progress indicator

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? Color.white : Color.white.opacity(0.3))
                    .frame(width: i == step ? 24 : 8, height: 8)
                    .animation(.spring(duration: 0.35), value: step)
            }
        }
    }

    // MARK: - Helpers

    private func advance() {
        withAnimation { step = min(step + 1, 5) }
    }

    private func buildProfile() -> UserProfile {
        UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            weightLbs: Double(weightText) ?? 150,
            sex: sex,
            activityLevel: activityLevel,
            bottleSizeOz: Double(bottleSizeText) ?? 32
        )
    }

    private func finish() {
        let profile = buildProfile()
        dataStore.completeOnboarding(with: profile)
        Task {
            let granted = await NotificationService.shared.requestPermission()
            if granted {
                NotificationService.shared.rescheduleNotifications(for: profile, todayOz: 0)
            }
        }
    }
}
