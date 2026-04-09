//
//  LevelUpView.swift
//  Habitra
//
//  Full-screen celebration shown when user levels up via XP.
//  Auto-dismisses after 3 seconds.
//

import SwiftUI

struct LevelUpView: View {
    let newLevel: Int
    let totalXP: Int
    let xpToNextLevel: Int
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var numberScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { dismissAnimated() }
                .accessibilityLabel("Dismiss level up celebration")
                .accessibilityAddTraits(.isButton)

            VStack(spacing: 16) {
                Text("LEVEL UP!")
                    .font(HabitraFont.footnote())
                    .tracking(3)
                    .foregroundStyle(Color.habitraVital)

                ZStack {
                    // Glow rings
                    Circle()
                        .fill(Color.habitraVital.opacity(0.06))
                        .frame(width: 160, height: 160)
                    Circle()
                        .fill(Color.habitraVital.opacity(0.12))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(Color.habitraVital.opacity(0.20))
                        .frame(width: 88, height: 88)

                    Text("\(newLevel)")
                        .font(HabitraFont.stat())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.habitraVital, Color.habitraVitalGlow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(numberScale)
                }

                Text("You reached Level \(newLevel)")
                    .font(HabitraFont.headline())
                    .foregroundStyle(.white.opacity(0.8))

                Text("\(totalXP) XP total")
                    .font(HabitraFont.caption())
                    .foregroundStyle(Color.habitraVital.opacity(0.7))

                Text("\(xpToNextLevel) XP to Level \(newLevel + 1)")
                    .font(HabitraFont.body())
                    .foregroundStyle(.white.opacity(0.5))

                Button {
                    dismissAnimated()
                } label: {
                    Text("Continue")
                        .font(HabitraFont.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 14)
                        .background(Color.habitraVital)
                        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withHabitraAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withHabitraAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
                numberScale = 1.0
            }
            HapticManager.levelUp()

            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                dismissAnimated()
            }
        }
        .accessibilityLabel("Level up! You reached level \(newLevel)")
    }

    private func dismissAnimated() {
        withHabitraAnimation(.easeOut(duration: 0.25)) {
            scale = 0.85
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

#Preview {
    LevelUpView(newLevel: 5, totalXP: 1250, xpToNextLevel: 150, onDismiss: {})
}
