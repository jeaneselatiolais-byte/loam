//
//  BadgeShelfView.swift
//  Habitra
//
//  The badge collection screen — shows all earned badges and locked/secret badges.
//  Tap any earned badge to open a detail view.
//

import SwiftUI
import SwiftData

struct BadgeShelfView: View {
    @Query(sort: \EarnedBadge.earnedAt, order: .reverse)
    private var earnedBadges: [EarnedBadge]

    @State private var sharingBadge: EarnedBadge?
    @State private var detailBadge: EarnedBadge?
    @State private var selectedCategory: BadgeCategory? = nil

    private var totalEarned: Int {
        Set(earnedBadges.map(\.badgeID)).count
    }

    private var filteredCategories: [BadgeCategory] {
        selectedCategory.map { [$0] } ?? BadgeCategory.allCases
    }

    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HabitraTheme.spacingLarge) {
                    summaryHeader
                    categoryFilter
                    badgeGrid
                }
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $detailBadge) { badge in
            BadgeDetailView(earnedBadge: badge, onShare: { sharingBadge = badge })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $sharingBadge) { badge in
            BadgeShareSheet(earnedBadge: badge)
        }
    }

    // MARK: - Summary Header

    private var summaryHeader: some View {
        HStack(spacing: HabitraTheme.spacingLarge) {
            VStack(spacing: 4) {
                Text("\(totalEarned)")
                    .font(HabitraFont.stat())
                    .foregroundStyle(Color.habitraAccent)
                Text("Earned")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack(spacing: 4) {
                Text("\(BadgeCatalog.all.count)")
                    .font(HabitraFont.stat())
                    .foregroundStyle(Color.habitraTextSecondary)
                Text("Total")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack(spacing: 4) {
                Text("\(Int(Double(totalEarned) / Double(max(BadgeCatalog.all.count, 1)) * 100))%")
                    .font(HabitraFont.stat())
                    .foregroundStyle(Color.habitraHabitGreen)
                Text("Complete")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .habitraCard()
        .statCardAccessibility(label: "Badges", value: "\(totalEarned) of \(BadgeCatalog.all.count) earned")
        .padding(.horizontal, HabitraTheme.screenPadding)
        .padding(.top, HabitraTheme.spacing)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(nil, label: "All")
                ForEach(BadgeCategory.allCases) { cat in
                    categoryChip(cat, label: cat.rawValue)
                }
            }
            .padding(.horizontal, HabitraTheme.screenPadding)
        }
    }

    private func categoryChip(_ category: BadgeCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withHabitraAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(label)
                .font(HabitraFont.caption())
                .tracking(0)
                .textCase(.none)
                .foregroundStyle(isSelected ? .white : Color.habitraTextTertiary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.habitraAccent : Color.habitraSurface)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : Color.habitraAccent.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSelected ? "\(label), selected" : label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Badge Grid

    private var badgeGrid: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacingLarge) {
            ForEach(filteredCategories) { category in
                categorySection(category)
            }
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private func categorySection(_ category: BadgeCategory) -> some View {
        let defs = BadgeCatalog.all.filter { $0.category == category }
        guard !defs.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                HStack(spacing: 6) {
                    Image(systemName: category.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.habitraTextTertiary)
                    Text(category.rawValue.uppercased())
                        .habitraCaption()
                        .sectionHeaderAccessibility()
                }

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                    spacing: 12
                ) {
                    ForEach(defs) { def in
                        badgeCell(def)
                    }
                }
            }
        )
    }

    private func badgeCell(_ def: BadgeDefinition) -> some View {
        let instances = earnedBadges.filter { $0.badgeID == def.id }
        let isEarned = !instances.isEmpty
        let isSecret = def.isSecret && !isEarned

        return Button {
            if isEarned, let first = instances.first {
                detailBadge = first
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    // Tier ring (behind badge circle)
                    if def.tier != .none {
                        Circle()
                            .stroke(
                                Color(hex: def.tier.colorHex).opacity(isEarned ? 0.6 : 0.15),
                                lineWidth: def.tier == .gold || def.tier == .diamond ? 3 : 2
                            )
                            .frame(width: 70, height: 70)
                    }

                    Circle()
                        .fill(
                            isEarned
                                ? Color(hex: def.colorHex).opacity(0.18)
                                : Color.habitraSurfaceLight
                        )
                        .frame(width: 64, height: 64)

                    if isSecret {
                        Image(systemName: "questionmark")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color.habitraTextTertiary.opacity(0.6))
                    } else {
                        Image(systemName: def.icon)
                            .font(.system(size: 26))
                            .foregroundStyle(
                                isEarned
                                    ? Color(hex: def.colorHex)
                                    : Color.habitraTextTertiary.opacity(0.3)
                            )
                    }

                    // Earned overlay checkmark
                    if isEarned {
                        Circle()
                            .fill(Color(hex: def.colorHex))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .offset(x: 22, y: -22)
                    }

                    // Count badge for per-habit badges earned multiple times
                    if instances.count > 1 {
                        Text("\(instances.count)")
                            .font(.system(.caption2))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.habitraAccent)
                            .clipShape(Circle())
                            .offset(x: -22, y: -22)
                    }
                }

                Text(isSecret ? "???" : def.name)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(
                        isEarned ? Color.habitraTextPrimary : Color.habitraTextTertiary.opacity(0.5)
                    )
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if isEarned, let first = instances.first {
                    Text(shortDate(first.earnedAt))
                        .font(.system(.caption2))
                        .foregroundStyle(Color(hex: def.colorHex).opacity(0.7))
                } else if !isSecret {
                    Text("~\(Int(def.simulatedRarity * 100))%")
                        .font(.system(.caption2))
                        .foregroundStyle(Color.habitraTextTertiary.opacity(0.6))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                isEarned
                    ? Color(hex: def.colorHex).opacity(0.06)
                    : Color.habitraSurface
            )
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                    .stroke(
                        isEarned
                            ? Color(hex: def.colorHex).opacity(0.3)
                            : Color.habitraAccent.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEarned)
        .badgeItemAccessibility(name: isSecret ? "Secret badge" : def.name, isEarned: isEarned, detail: isEarned ? "Tap to view details" : "")
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack {
        BadgeShelfView()
            .modelContainer(for: [Habit.self, HabitCompletion.self, EarnedBadge.self], inMemory: true)
    }
}
