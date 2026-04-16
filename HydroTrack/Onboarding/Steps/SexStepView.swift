import SwiftUI

struct SexStepView: View {
    @Binding var sex: Sex
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Biological Sex")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Helps fine-tune your hydration recommendation")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 40)

            VStack(spacing: 14) {
                ForEach(Sex.allCases) { option in
                    OptionRow(
                        emoji: option.emoji,
                        title: option.rawValue,
                        subtitle: nil,
                        isSelected: sex == option
                    ) {
                        sex = option
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
