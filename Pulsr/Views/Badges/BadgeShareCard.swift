//
//  BadgeShareCard.swift
//  Habitra
//
//  Branded share card and share sheet for a single earned badge.
//

import SwiftUI

// MARK: - Share Card

struct BadgeShareCard: View {
    let earnedBadge: EarnedBadge

    private var def: BadgeDefinition? { earnedBadge.definition }
    private var badgeColor: Color { Color(hex: def?.colorHex ?? "6C63FF") }

    var body: some View {
        VStack(spacing: 0) {
            // Branding strip
            HStack(spacing: 6) {
                HabitraWordmark(size: 18, style: .light)
                Spacer()
                Text("ACHIEVEMENT UNLOCKED")
                    .font(.system(.caption2))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)

            // Badge hero
            ZStack {
                // Tier ring
                if let def, def.tier != .none {
                    Circle()
                        .stroke(Color(hex: def.tier.colorHex).opacity(0.5), lineWidth: 3)
                        .frame(width: 170, height: 170)
                }

                // Glow rings
                Circle()
                    .fill(badgeColor.opacity(0.06))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(badgeColor.opacity(0.10))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(badgeColor.opacity(0.18))
                    .frame(width: 88, height: 88)

                // Icon
                Image(systemName: def?.icon ?? "star.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
            .padding(.vertical, 8)

            // Badge name
            Text(def?.name ?? "Badge")
                .font(HabitraFont.title())
                .foregroundStyle(.white)
                .padding(.top, 12)

            // Description
            if let desc = def?.description {
                Text(desc)
                    .font(HabitraFont.body())
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.top, 6)
            }

            // Habit context
            if let habitName = earnedBadge.habitName,
               let habitIcon = earnedBadge.habitIcon,
               let habitColorHex = earnedBadge.habitColorHex {
                HStack(spacing: 8) {
                    Image(systemName: habitIcon)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(habitName)
                        .font(HabitraFont.body())
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: habitColorHex).opacity(0.2))
                .clipShape(Capsule())
                .padding(.top, 12)
            }

            // Rarity
            if let def {
                Text("Earned by ~\(Int(def.simulatedRarity * 100))% of Habitra users")
                    .font(.system(.caption2))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 12)
            }

            // Earned date
            Text("Earned \(formattedDate(earnedBadge.earnedAt))")
                .font(HabitraFont.footnote())
                .foregroundStyle(.white.opacity(0.6))
                .padding(.top, 4)
                .padding(.bottom, 24)
        }
        .frame(width: 340)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
    }

    private var cardBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "0D0D14"),
                    badgeColor.opacity(0.5),
                    Color(hex: "0D0D14"),
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            // Subtle noise texture via overlay
            badgeColor.opacity(0.05)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

// MARK: - Share Sheet

struct BadgeShareSheet: View {
    let earnedBadge: EarnedBadge
    @Environment(\.dismiss) private var dismiss

    @State private var renderedImage: UIImage?
    @State private var showingActivitySheet = false

    private var shareCard: BadgeShareCard { BadgeShareCard(earnedBadge: earnedBadge) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                VStack(spacing: HabitraTheme.spacingLarge) {
                    Spacer()

                    shareCard
                        .shadow(color: .black.opacity(0.4), radius: 24, y: 12)

                    Spacer()

                    VStack(spacing: HabitraTheme.spacing) {
                        HabitraButton("Share Badge", icon: "square.and.arrow.up") {
                            renderAndShare()
                        }

                        if let def = earnedBadge.definition, let habitName = earnedBadge.habitName {
                            Text("\(def.name) · \(habitName)")
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary)
                        } else if let def = earnedBadge.definition {
                            Text(def.name)
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary)
                        }
                    }
                    .padding(.horizontal, HabitraTheme.screenPadding)
                    .padding(.bottom, HabitraTheme.spacingLarge)
                }
            }
            .navigationTitle("Share Badge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.habitraAccent)
                }
            }
            .sheet(isPresented: $showingActivitySheet) {
                if let image = renderedImage {
                    BadgeActivityView(items: [image])
                }
            }
        }
    }

    @MainActor
    private func renderAndShare() {
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = 3.0
        renderer.proposedSize = .unspecified
        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
            showingActivitySheet = true
        }
    }
}

private struct BadgeActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview("Badge Share Card") {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()
        BadgeShareCard(earnedBadge: {
            let b = EarnedBadge(
                badgeID: "streak_30",
                habitName: "Morning Run",
                habitIcon: "figure.run",
                habitColorHex: "FB923C"
            )
            return b
        }())
    }
}
