import SwiftUI

struct WeightStepView: View {
    @Binding var weightText: String
    let onNext: () -> Void
    @FocusState private var focused: Bool

    private var isValid: Bool {
        guard let w = Double(weightText) else { return false }
        return w > 50 && w < 700
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "scalemass.fill")
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .padding(.bottom, 24)

            Text("What's your weight?")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Used to calculate your ideal daily intake")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 40)

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                TextField("150", text: $weightText)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .focused($focused)
                    .frame(width: 160)

                Text("lbs")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(20)
            .hydroGlass(cornerRadius: 20)
            .padding(.horizontal, 48)

            Spacer()
            Spacer()

            continueButton
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
        }
        .onAppear { focused = true }
    }

    private var continueButton: some View {
        Button(action: onNext) {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isValid)
    }
}
