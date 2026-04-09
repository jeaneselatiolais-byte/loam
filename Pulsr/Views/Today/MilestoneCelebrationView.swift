//
//  MilestoneCelebrationView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI

struct MilestoneCelebrationView: View {
    let habitName: String
    let habitIcon: String
    let habitColorHex: String
    let streakCount: Int
    let completionRate: Double
    let totalCompletions: Int
    let longestStreak: Int
    let onDismiss: () -> Void

    // MARK: - Milestone Data

    static let milestones: [Int] = [7, 14, 21, 30, 50, 100, 365]

    static func isMilestone(_ count: Int) -> Bool {
        milestones.contains(count)
    }

    // MARK: - State

    @State private var showContent = false
    @State private var numberScale: CGFloat = 0.3
    @State private var confettiActive = false
    @State private var autoDismissTask: DispatchWorkItem?

    // MARK: - Computed

    private var habitColor: Color {
        Color(hex: habitColorHex)
    }

    private var milestoneMessage: String {
        switch streakCount {
        case 7:   return "First week! You're building momentum."
        case 14:  return "Two weeks strong! This is becoming a habit."
        case 21:  return "Three weeks! Scientists say you're hooked."
        case 30:  return "One month! You're officially unstoppable."
        case 50:  return "50 days! You're in elite territory."
        case 100: return "100 days! Legendary discipline."
        case 365: return "ONE YEAR! You've mastered this habit."
        default:  return "Amazing streak! Keep going!"
        }
    }

    // Confetti colors
    private let confettiColors: [Color] = [
        .habitraAccent, .habitraAccentGlow, .habitraAccentBright,
        .habitraHabitYellow, .habitraHabitGreen, .habitraHabitOrange
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            // Semi-transparent dark background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
                .accessibilityLabel("Dismiss milestone celebration")
                .accessibilityAddTraits(.isButton)

            // Confetti particles
            if confettiActive {
                ConfettiLayer(colors: confettiColors)
            }

            // Main content
            VStack(spacing: HabitraTheme.spacingLarge) {
                Spacer()

                // Habit icon
                ZStack {
                    Circle()
                        .fill(habitColor.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: habitIcon)
                        .font(.system(size: 36))
                        .foregroundStyle(habitColor)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.5)

                // Milestone number
                Text("\(streakCount)")
                    .font(HabitraFont.stat())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.habitraAccentBright, .habitraAccentGlow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(numberScale)
                    .shadow(color: .habitraAccent.opacity(0.5), radius: 20, y: 4)

                // "day streak" label
                Text("day streak")
                    .font(HabitraFont.title())
                    .foregroundStyle(Color.habitraAccentGlow)
                    .opacity(showContent ? 1 : 0)

                // Congratulatory message
                Text(milestoneMessage)
                    .font(HabitraFont.headline())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                // Habit name
                Text(habitName)
                    .font(HabitraFont.body())
                    .foregroundStyle(habitColor)
                    .opacity(showContent ? 1 : 0)

                // Stats row
                HStack(spacing: 16) {
                    Label("\(Int(completionRate * 100))% this week", systemImage: "chart.bar.fill")
                    Label("\(totalCompletions) completions", systemImage: "checkmark.circle")
                }
                .font(HabitraFont.footnote())
                .foregroundStyle(.white.opacity(0.55))
                .opacity(showContent ? 1 : 0)

                // Personal best indicator
                if streakCount >= longestStreak {
                    Label("New personal best!", systemImage: "trophy.fill")
                        .font(HabitraFont.caption())
                        .foregroundStyle(Color.habitraHabitYellow)
                        .opacity(showContent ? 1 : 0)
                }

                Spacer()

                // Dismiss button
                Button(action: { dismiss() }) {
                    Text("Keep it up!")
                        .font(HabitraFont.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                                .fill(
                                    LinearGradient(
                                        colors: [.habitraAccent, .habitraAccentBright],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .padding(.horizontal, HabitraTheme.screenPadding)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
        .accessibilityLabel("\(habitName) milestone! \(streakCount) day streak. \(milestoneMessage)")
    }

    // MARK: - Animations

    private func startAnimations() {
        // Haptic feedback
        HapticManager.streakMilestone()

        // Confetti burst
        withHabitraAnimation(.easeOut(duration: 0.3)) {
            confettiActive = true
        }

        // Number spring scale
        withHabitraAnimation(HabitraTheme.springAnimation.delay(0.1)) {
            numberScale = 1.0
        }

        // Content fade in
        withHabitraAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            showContent = true
        }

        // Auto-dismiss after 4 seconds
        let task = DispatchWorkItem { dismiss() }
        autoDismissTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: task)
    }

    private func dismiss() {
        autoDismissTask?.cancel()
        onDismiss()
    }
}

// MARK: - Confetti Layer

private struct ConfettiLayer: View {
    let colors: [Color]

    private let particleCount = 30

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                ConfettiParticle(
                    color: colors[index % colors.count],
                    index: index,
                    total: particleCount
                )
            }
        }
    }
}

private struct ConfettiParticle: View {
    let color: Color
    let index: Int
    let total: Int

    @State private var animate = false

    private var randomAngle: Double {
        Double(index) / Double(total) * 360.0
    }

    private var randomDistance: CGFloat {
        CGFloat.random(in: 120...300)
    }

    private var randomSize: CGFloat {
        CGFloat.random(in: 6...14)
    }

    private var duration: Double {
        Double.random(in: 1.2...2.0)
    }

    private var isCircle: Bool {
        index % 3 != 0
    }

    var body: some View {
        Group {
            if isCircle {
                Circle()
                    .fill(color)
                    .frame(width: randomSize, height: randomSize)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: randomSize, height: randomSize * 0.5)
            }
        }
        .offset(
            x: animate ? cos(randomAngle * .pi / 180) * randomDistance : 0,
            y: animate ? sin(randomAngle * .pi / 180) * randomDistance + 100 : 0
        )
        .scaleEffect(animate ? 0.3 : 1.0)
        .opacity(animate ? 0 : 1)
        .rotationEffect(.degrees(animate ? Double.random(in: -180...180) : 0))
        .onAppear {
            withHabitraAnimation(
                .easeOut(duration: duration)
                .delay(Double.random(in: 0...0.3))
            ) {
                animate = true
            }
        }
    }
}

// MARK: - Preview

#Preview("7-day milestone") {
    MilestoneCelebrationView(
        habitName: "Meditate",
        habitIcon: "brain.head.profile",
        habitColorHex: "6C63FF",
        streakCount: 7,
        completionRate: 0.86,
        totalCompletions: 12,
        longestStreak: 7,
        onDismiss: {}
    )
}

#Preview("30-day milestone") {
    MilestoneCelebrationView(
        habitName: "Exercise",
        habitIcon: "figure.run",
        habitColorHex: "4ADE80",
        streakCount: 30,
        completionRate: 0.93,
        totalCompletions: 45,
        longestStreak: 30,
        onDismiss: {}
    )
}

#Preview("365-day milestone") {
    MilestoneCelebrationView(
        habitName: "Read",
        habitIcon: "book.fill",
        habitColorHex: "3B82F6",
        streakCount: 365,
        completionRate: 1.0,
        totalCompletions: 380,
        longestStreak: 365,
        onDismiss: {}
    )
}
