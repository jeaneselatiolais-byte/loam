//
//  XPPopupView.swift
//  Habitra
//
//  Floating "+N XP" popup that appears after completing a habit.
//  Shows base XP and optional streak/perfect day bonuses.
//

import SwiftUI

struct XPPopupView: View {
    let xpGain: XPGain
    let habitName: String
    let currentStreak: Int
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 2) {
            Text("+\(xpGain.total) XP")
                .font(HabitraFont.headline())
                .foregroundStyle(Color.habitraVital)

            Text(habitName)
                .font(HabitraFont.footnote())
                .foregroundStyle(.white.opacity(0.7))

            if xpGain.streakBonus > 0 || xpGain.perfectDayBonus > 0 {
                HStack(spacing: 6) {
                    if xpGain.streakBonus > 0 {
                        Label("Day \(currentStreak) streak", systemImage: "flame.fill")
                            .font(.system(.caption2))
                            .foregroundStyle(Color.habitraHabitOrange.opacity(0.8))
                    }
                    if xpGain.perfectDayBonus > 0 {
                        Label("Perfect day!", systemImage: "checkmark.circle.fill")
                            .font(.system(.caption2))
                            .foregroundStyle(Color.habitraHabitGreen.opacity(0.8))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.habitraSurface.opacity(0.95))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.habitraVital.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.habitraVital.opacity(0.2), radius: 12, y: 4)
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: yOffset)
        .onAppear {
            withHabitraAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withHabitraAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                yOffset = -40
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        }
        .allowsHitTesting(false)
        .accessibilityLabel("Plus \(xpGain.total) experience points earned for \(habitName)")
    }
}

#Preview {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()
        XPPopupView(
            xpGain: XPGain(base: 10, streakBonus: 14, perfectDayBonus: 25, total: 49),
            habitName: "Meditate",
            currentStreak: 7,
            onComplete: {}
        )
    }
}
