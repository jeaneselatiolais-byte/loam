//
//  CollectionView.swift
//  Habitra
//
//  Displays badge collections/sets with progress tracking.
//  Pro-only feature with lock overlay for free users.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Query(sort: \BadgeCollection.createdAt)
    private var collections: [BadgeCollection]

    @Query(sort: \EarnedBadge.earnedAt, order: .reverse)
    private var earnedBadges: [EarnedBadge]

    @Environment(\.modelContext) private var modelContext

    private var earnedBadgeIDs: Set<String> {
        Set(earnedBadges.map(\.badgeID))
    }

    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HabitraTheme.spacingLarge) {
                    if collections.isEmpty {
                        HabitraEmptyState(
                            icon: "trophy.circle.fill",
                            title: "No collections yet",
                            message: "Collections will appear as you earn badges."
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(collections, id: \.id) { collection in
                                collectionCard(collection)
                            }
                        }
                        .padding(.horizontal, HabitraTheme.screenPadding)
                    }
                }
                .padding(.top, HabitraTheme.spacing)
                .padding(.bottom, 100)
            }

            if !SubscriptionManager.canUseCollections {
                proLockOverlay
            }
        }
        .navigationTitle("Collections")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            CollectionCatalog.ensureCollections(context: modelContext)
        }
    }

    // MARK: - Collection Card

    private func collectionCard(_ collection: BadgeCollection) -> some View {
        let earned = collection.earnedCount(earnedBadgeIDs: earnedBadgeIDs)
        let total = collection.requiredBadgeIDs.count
        let isComplete = collection.isCompleted || earned == total
        let progress = total > 0 ? Double(earned) / Double(total) : 0

        return VStack(spacing: HabitraTheme.spacingSmall) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: collection.colorHex).opacity(isComplete ? 0.2 : 0.08))
                    .frame(width: 56, height: 56)

                Image(systemName: collection.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(
                        isComplete ? Color(hex: collection.colorHex) : Color.habitraTextTertiary.opacity(0.4)
                    )

                if isComplete {
                    Circle()
                        .fill(Color.habitraHabitGreen)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .offset(x: 20, y: -20)
                }
            }

            // Name
            Text(collection.name)
                .font(HabitraFont.caption())
                .tracking(0)
                .textCase(.none)
                .foregroundStyle(Color.habitraTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Progress
            Text("\(earned)/\(total)")
                .font(HabitraFont.footnote())
                .foregroundStyle(isComplete ? Color.habitraHabitGreen : Color.habitraTextTertiary)

            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.habitraSurfaceLight)
                        .frame(height: 3)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: collection.colorHex))
                        .frame(width: max(0, geo.size.width * progress), height: 3)
                }
            }
            .frame(height: 3)

            // Mini badge icons
            HStack(spacing: 4) {
                ForEach(collection.requiredBadgeIDs.prefix(5), id: \.self) { badgeID in
                    if let def = BadgeCatalog.definition(for: badgeID) {
                        Image(systemName: def.icon)
                            .font(.system(size: 9))
                            .foregroundStyle(
                                earnedBadgeIDs.contains(badgeID)
                                    ? Color(hex: def.colorHex)
                                    : Color.habitraTextTertiary.opacity(0.2)
                            )
                    }
                }
                if collection.requiredBadgeIDs.count > 5 {
                    Text("+\(collection.requiredBadgeIDs.count - 5)")
                        .font(.system(.caption2))
                        .foregroundStyle(Color.habitraTextTertiary)
                }
            }
        }
        .padding(HabitraTheme.cardPadding)
        .background(Color.habitraSurface)
        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                .stroke(
                    isComplete
                        ? Color(hex: collection.colorHex).opacity(0.3)
                        : Color.habitraAccent.opacity(0.08),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Pro Lock

    private var proLockOverlay: some View {
        ZStack {
            Color.habitraBackground.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: HabitraTheme.spacing) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.habitraAccent)

                Text("Collections are Pro")
                    .font(HabitraFont.title())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text("Upgrade to unlock badge collections and earn special reward badges.")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CollectionView()
            .modelContainer(for: [BadgeCollection.self, EarnedBadge.self], inMemory: true)
    }
}
