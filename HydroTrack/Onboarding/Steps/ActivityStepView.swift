import SwiftUI

struct ActivityStepView: View {
    @Binding var activityLevel: ActivityLevel
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Activity Level")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("How active are you on a typical day?")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 40)

            VStack(spacing: 14) {
                ForEach(ActivityLevel.allCases) { level in
                    OptionRow(
                        emoji: level.emoji,
                        title: level.rawValue,
                        subtitle: level.subtitle,
                        isSelected: activityLevel == level
                    ) {
                        activityLevel = level
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()

            Button(action: onNext) {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Shared Option Row (used by Sex + Activity steps)

struct OptionRow: View {
    let emoji: String
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.title2)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(.white)
                    .font(.title3)
            }
            .padding()
            .background(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
