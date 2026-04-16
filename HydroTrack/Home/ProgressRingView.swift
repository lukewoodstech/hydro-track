import SwiftUI

struct ProgressRingView: View {
    /// 0.0 → 1.0
    let progress: Double

    @State private var animated: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 18)

            // Fill
            Circle()
                .trim(from: 0, to: animated)
                .stroke(
                    AngularGradient(
                        colors: [.hydroLight, .hydroMid, .hydroDeep, .hydroLight],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle:   .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                // Subtle glow on the leading tip
                .shadow(color: .hydroMid.opacity(0.6), radius: 6)

            // Center label
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("hydrated")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
                animated = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animated = newValue
            }
        }
    }
}
