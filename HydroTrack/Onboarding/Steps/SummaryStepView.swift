import SwiftUI

struct SummaryStepView: View {
    let profile: UserProfile
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.hydroMid)
                .padding(.bottom, 20)

            Text("You're all set, \(profile.name)!")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Here's your personalized hydration plan")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 8)
                .padding(.bottom, 40)

            VStack(spacing: 0) {
                SummaryRow(icon: "drop.fill",          label: "Daily Goal",       value: "\(Int(profile.dailyGoalOz)) oz")
                Divider().background(Color.white.opacity(0.2)).padding(.horizontal)
                SummaryRow(icon: "waterbottle.fill",   label: "Bottle Size",      value: "\(Int(profile.bottleSizeOz)) oz")
                Divider().background(Color.white.opacity(0.2)).padding(.horizontal)
                SummaryRow(icon: "number.circle.fill", label: "Bottles Per Day",  value: "\(profile.bottlesPerDay)")
                Divider().background(Color.white.opacity(0.2)).padding(.horizontal)
                SummaryRow(icon: "figure.walk",        label: "Activity Level",   value: profile.activityLevel.rawValue)
            }
            .hydroGlass(cornerRadius: 10)
            .padding(.horizontal, 24)

            Spacer()
            Spacer()

            Button(action: onFinish) {
                HStack {
                    Image(systemName: "drop.fill")
                    Text("Start Tracking")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - SummaryRow

private struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.hydroMid)
                .frame(width: 28)
            Text(label)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
