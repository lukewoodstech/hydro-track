import SwiftUI

struct BottleSizeStepView: View {
    @Binding var bottleSizeText: String
    let onNext: () -> Void
    @FocusState private var focused: Bool

    private var isValid: Bool {
        guard let s = Double(bottleSizeText) else { return false }
        return s > 4 && s <= 256
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "waterbottle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .padding(.bottom, 24)

            Text("Bottle Size")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("How many oz does your water bottle hold?")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 40)

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                TextField("32", text: $bottleSizeText)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .focused($focused)
                    .frame(width: 160)

                Text("oz")
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
