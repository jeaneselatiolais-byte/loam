//
//  BadgeCelebrationView.swift
//  Habitra
//
//  Full-screen overlay that appears when a new badge is earned.
//  Supports a queue of multiple badges earned simultaneously.
//

import SwiftUI

struct BadgeCelebrationView: View {
    let badge: EarnedBadge
    let onDismiss: () -> Void
    let onShare: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    private var def: BadgeDefinition? { badge.definition }
    private var badgeColor: Color { Color(hex: def?.colorHex ?? "6C63FF") }

    var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
                .accessibilityAddTraits(.isButton)

            VStack(spacing: HabitraTheme.spacingLarge) {
                // Category label
                if let def {
                    Text(def.isSecret ? "SECRET BADGE UNLOCKED" : "BADGE UNLOCKED")
                        .font(HabitraFont.footnote())
                        .tracking(2)
                        .foregroundStyle(badgeColor.opacity(0.8))
                }

                // Badge icon with glow
                ZStack {
                    // Tier ring
                    if let def, def.tier != .none {
                        Circle()
                            .stroke(
                                Color(hex: def.tier.colorHex).opacity(0.4),
                                lineWidth: def.tier == .diamond ? 4 : 3
                            )
                            .frame(width: 190, height: 190)
                    }

                    Circle()
                        .fill(badgeColor.opacity(0.08))
                        .frame(width: 180, height: 180)
                    Circle()
                        .fill(badgeColor.opacity(0.14))
                        .frame(width: 130, height: 130)
                    Circle()
                        .fill(badgeColor.opacity(0.22))
                        .frame(width: 92, height: 92)

                    Image(systemName: def?.icon ?? "star.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                }

                // Tier label
                if let def, def.tier != .none {
                    Text(def.tier.displayName.uppercased())
                        .font(.system(.caption2))
                        .tracking(1.5)
                        .foregroundStyle(Color(hex: def.tier.colorHex))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: def.tier.colorHex).opacity(0.2))
                        .clipShape(Capsule())
                }

                // Name + description
                VStack(spacing: 8) {
                    Text(def?.name ?? "Achievement")
                        .font(HabitraFont.title())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(def?.description ?? "")
                        .font(HabitraFont.body())
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // XP reward
                    Text("+100 XP")
                        .font(HabitraFont.caption())
                        .foregroundStyle(Color.habitraVital)
                        .padding(.top, 4)

                    // Rarity context
                    if let def {
                        let pct = Int(def.simulatedRarity * 100)
                        Text("Earned by \(pct)% of users")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    // Habit pill
                    if let habitName = badge.habitName, let icon = badge.habitIcon,
                       let colorHex = badge.habitColorHex {
                        HStack(spacing: 6) {
                            Image(systemName: icon)
                                .font(.system(size: 12))
                            Text(habitName)
                                .font(HabitraFont.footnote())
                        }
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color(hex: colorHex).opacity(0.25))
                        .clipShape(Capsule())
                    }
                }

                // Actions
                HStack(spacing: HabitraTheme.spacing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Nice!")
                            .font(HabitraFont.headline())
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onShare()
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Share")
                                .font(HabitraFont.headline())
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(badgeColor)
                        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, HabitraTheme.screenPadding)
            }
            .padding(HabitraTheme.spacingLarge)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .celebrationAccessibility(message: "Badge unlocked: \(def?.name ?? "Achievement"). \(def?.description ?? "")")
        .onAppear {
            withHabitraAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private func dismiss() {
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
    BadgeCelebrationView(
        badge: EarnedBadge(
            badgeID: "streak_30",
            habitName: "Morning Run",
            habitIcon: "figure.run",
            habitColorHex: "FB923C"
        ),
        onDismiss: {},
        onShare: {}
    )
}
