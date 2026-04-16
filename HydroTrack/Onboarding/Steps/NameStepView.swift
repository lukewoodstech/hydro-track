import SwiftUI

struct NameStepView: View {
    @Binding var name: String
    let onNext: () -> Void
    @FocusState private var focused: Bool

    private var canAdvance: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "drop.fill")
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .padding(.bottom, 24)

            Text("Welcome to HydroTrack")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Let's personalize your hydration plan")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 8)
                .padding(.bottom, 40)

            TextField("Your first name", text: $name)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundStyle(.white)
                .tint(.white)
                .hydroGlass(cornerRadius: 16)
                .focused($focused)
                .submitLabel(.next)
                .onSubmit { if canAdvance { onNext() } }
                .padding(.horizontal, 24)

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
                .background(canAdvance ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!canAdvance)
    }
}
