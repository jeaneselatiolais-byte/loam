//
//  HabitraComponents.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI

// MARK: - Primary Button
struct HabitraButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(HabitraFont.headline())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.habitraAccent)
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
        }
    }
}

// MARK: - Secondary Button
struct HabitraSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(HabitraFont.body())
            }
            .foregroundStyle(Color.habitraAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.habitraAccent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                    .stroke(Color.habitraAccent.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Circular Progress Ring
struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 6
    var size: CGFloat = 60
    var color: Color = .habitraAccent

    /// When progress reaches 1.0, the arc transitions to the vital warm color.
    private var arcColors: [Color] {
        if progress >= 1.0 {
            return [color.opacity(0.7), Color.habitraVital]
        }
        return [color.opacity(0.7), color]
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    LinearGradient(
                        colors: arcColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(min(progress, 1.0) * 100)) percent")
    }
}

// MARK: - Pulse Dot (animated glow)
/// Respects Reduce Motion — shows a static dot when enabled.
struct PulseDot: View {
    let color: Color
    var size: CGFloat = 10
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if !reduceMotion {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: size * 2, height: size * 2)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0.0 : 0.5)
            }

            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Empty State View
struct HabitraEmptyState: View {
    let icon: String
    let title: String
    let message: String

    @State private var floatOffset: CGFloat = 0
    @State private var glowOpacity: Double = 0.3
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: HabitraTheme.spacing) {
            ZStack {
                Circle()
                    .fill(Color.habitraAccent.opacity(glowOpacity))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)

                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(Color.habitraAccentMuted)
            }
            .offset(y: floatOffset)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .easeInOut(duration: 2.2)
                    .repeatForever(autoreverses: true)
                ) {
                    floatOffset = -10
                    glowOpacity = 0.6
                }
            }

            Text(title)
                .font(HabitraFont.headline())
                .foregroundStyle(Color.habitraTextPrimary)

            Text(message)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Completion Checkmark with Pulse
struct CompletionCheckmark: View {
    let isCompleted: Bool
    let color: Color
    /// Color used for the filled/completed state. Defaults to habitraVital (warm amber)
    /// so every habit shows the same satisfying "done" reward color regardless of habit color.
    var completedColor: Color = .habitraVital
    var size: CGFloat = 28

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.0

    private var activeColor: Color { isCompleted ? completedColor : color }

    var body: some View {
        ZStack {
            // Pulse ring
            Circle()
                .stroke(activeColor.opacity(0.4), lineWidth: 2)
                .frame(width: size + 12, height: size + 12)
                .scaleEffect(pulseScale)
                .opacity(pulseOpacity)

            // Base circle
            Circle()
                .stroke(
                    isCompleted ? completedColor : Color.habitraTextTertiary.opacity(0.3),
                    lineWidth: 2
                )
                .frame(width: size, height: size)

            // Filled state
            if isCompleted {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [completedColor, completedColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .transition(.scale.combined(with: .opacity))

                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale)
            }
        }
        .animation(HabitraTheme.springAnimation, value: isCompleted)
        .onChange(of: isCompleted) { wasCompleted, nowCompleted in
            if nowCompleted && !wasCompleted {
                triggerPulse()
            }
        }
    }

    private func triggerPulse() {
        pulseScale = 1.0
        pulseOpacity = 0.8

        withHabitraAnimation(.easeOut(duration: 0.6)) {
            pulseScale = 1.8
            pulseOpacity = 0.0
        }
    }
}

// MARK: - Streak Badge
struct StreakBadge: View {
    let count: Int
    var color: Color = .habitraAccent

    private var isHot: Bool { count >= 7 }
    private var badgeColor: Color { isHot ? .habitraGold : color }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12))
            Text("\(count)")
                .font(HabitraFont.caption())
                .tracking(0)
                .textCase(.none)
        }
        .foregroundStyle(count > 0 ? badgeColor : Color.habitraTextTertiary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (count > 0 ? badgeColor : Color.habitraTextTertiary).opacity(0.12)
        )
        .clipShape(Capsule())
        .shadow(
            color: isHot ? Color.habitraGold.opacity(0.55) : .clear,
            radius: isHot ? 8 : 0,
            x: 0, y: 0
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(count > 0 ? "\(count) day streak" : "No streak")
    }
}
