//
//  BadgeDetailView.swift
//  Habitra
//
//  Detail sheet for an earned badge — shows tier, rarity, and share option.
//

import SwiftUI

struct BadgeDetailView: View {
    let earnedBadge: EarnedBadge
    let onShare: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var def: BadgeDefinition? { earnedBadge.definition }
    private var badgeColor: Color { Color(hex: def?.colorHex ?? "6C63FF") }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        // Badge hero
                        ZStack {
                            // Tier ring
                            if let def, def.tier != .none {
                                Circle()
                                    .stroke(
                                        Color(hex: def.tier.colorHex).opacity(0.5),
                                        lineWidth: def.tier == .diamond ? 4 : 3
                                    )
                                    .frame(width: 140, height: 140)
                            }

                            Circle()
                                .fill(badgeColor.opacity(0.08))
                                .frame(width: 160, height: 160)
                            Circle()
                                .fill(badgeColor.opacity(0.14))
                                .frame(width: 120, height: 120)
                            Circle()
                                .fill(badgeColor.opacity(0.22))
                                .frame(width: 88, height: 88)

                            Image(systemName: def?.icon ?? "star.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(badgeColor)
                        }
                        .padding(.top, HabitraTheme.spacingLarge)

                        // Tier badge
                        if let def, def.tier != .none {
                            Text(def.tier.displayName.uppercased())
                                .font(.system(.caption2))
                                .tracking(1.5)
                                .foregroundStyle(Color(hex: def.tier.colorHex))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: def.tier.colorHex).opacity(0.15))
                                .clipShape(Capsule())
                        }

                        // Name + description
                        VStack(spacing: 8) {
                            Text(def?.name ?? "Badge")
                                .font(HabitraFont.title())
                                .foregroundStyle(Color.habitraTextPrimary)
                                .multilineTextAlignment(.center)

                            Text(def?.description ?? "")
                                .font(HabitraFont.body())
                                .foregroundStyle(Color.habitraTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        // Habit context pill
                        if let habitName = earnedBadge.habitName,
                           let icon = earnedBadge.habitIcon,
                           let colorHex = earnedBadge.habitColorHex {
                            HStack(spacing: 6) {
                                Image(systemName: icon)
                                    .font(.system(size: 12))
                                Text(habitName)
                                    .font(HabitraFont.footnote())
                            }
                            .foregroundStyle(Color(hex: colorHex))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color(hex: colorHex).opacity(0.12))
                            .clipShape(Capsule())
                        }

                        // Stats row
                        HStack(spacing: HabitraTheme.spacingLarge) {
                            VStack(spacing: 4) {
                                Text(formattedDate(earnedBadge.earnedAt))
                                    .font(HabitraFont.caption())
                                    .foregroundStyle(Color.habitraTextPrimary)
                                Text("Earned")
                                    .font(HabitraFont.footnote())
                                    .foregroundStyle(Color.habitraTextTertiary)
                            }
                            .frame(maxWidth: .infinity)

                            if let def {
                                Divider().frame(height: 30)

                                VStack(spacing: 4) {
                                    Text("~\(Int(def.simulatedRarity * 100))%")
                                        .font(HabitraFont.caption())
                                        .foregroundStyle(rarityColor(def.simulatedRarity))
                                    Text("of users")
                                        .font(HabitraFont.footnote())
                                        .foregroundStyle(Color.habitraTextTertiary)
                                }
                                .frame(maxWidth: .infinity)

                                if def.category != .secret {
                                    Divider().frame(height: 30)

                                    VStack(spacing: 4) {
                                        Image(systemName: def.category.icon)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.habitraTextPrimary)
                                        Text(def.category.rawValue)
                                            .font(HabitraFont.footnote())
                                            .foregroundStyle(Color.habitraTextTertiary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .habitraCard()
                        .padding(.horizontal, HabitraTheme.screenPadding)

                        // Tier progress (for tiered badges)
                        if let def, let tierGroup = def.tierGroup {
                            tierProgressSection(tierGroup: tierGroup, currentTier: def.tier)
                                .padding(.horizontal, HabitraTheme.screenPadding)
                        }

                        // Share button
                        HabitraButton("Share Badge", icon: "square.and.arrow.up") {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onShare()
                            }
                        }
                        .padding(.horizontal, HabitraTheme.screenPadding)
                        .padding(.bottom, HabitraTheme.spacingLarge)
                    }
                }
            }
            .navigationTitle("Badge Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.habitraAccent)
                }
            }
        }
    }

    private func tierProgressSection(tierGroup: String, currentTier: BadgeTier) -> some View {
        let tiersInGroup = BadgeCatalog.all.filter { $0.tierGroup == tierGroup }.sorted { $0.tier < $1.tier }

        return VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
            Text("TIER PROGRESS")
                .habitraCaption()
                .sectionHeaderAccessibility()

            HStack(spacing: 12) {
                ForEach(tiersInGroup, id: \.id) { tierDef in
                    let isUnlocked = tierDef.tier <= currentTier
                    VStack(spacing: 6) {
                        Circle()
                            .fill(isUnlocked ? Color(hex: tierDef.tier.colorHex).opacity(0.2) : Color.habitraSurfaceLight)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: tierDef.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(
                                        isUnlocked ? Color(hex: tierDef.tier.colorHex) : Color.habitraTextTertiary.opacity(0.3)
                                    )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: tierDef.tier.colorHex).opacity(isUnlocked ? 0.5 : 0.1), lineWidth: 2)
                            )

                        Text(tierDef.tier.displayName)
                            .font(.system(.caption2))
                            .foregroundStyle(isUnlocked ? Color(hex: tierDef.tier.colorHex) : Color.habitraTextTertiary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .habitraCard()
        }
    }

    private func rarityColor(_ rarity: Double) -> Color {
        if rarity <= 0.05 { return Color(hex: "F59E0B") } // Gold — legendary
        if rarity <= 0.15 { return Color(hex: "A89AFF") } // Purple — rare
        if rarity <= 0.30 { return Color(hex: "3B82F6") } // Blue — uncommon
        return Color.habitraTextPrimary // Common
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }
}

#Preview {
    BadgeDetailView(
        earnedBadge: EarnedBadge(
            badgeID: "streak_30",
            habitName: "Morning Run",
            habitIcon: "figure.run",
            habitColorHex: "FB923C"
        ),
        onShare: {}
    )
}
