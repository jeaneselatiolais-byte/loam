//
//  CollectionCatalog.swift
//  Habitra
//
//  Static definitions of badge collections/sets.
//  Seed BadgeCollection records in SwiftData on first evaluation.
//

import Foundation
import SwiftData

@MainActor
enum CollectionCatalog {

    struct CollectionDef {
        let collectionID: String
        let name: String
        let description: String
        let icon: String
        let colorHex: String
        let requiredBadgeIDs: [String]
        let rewardBadgeID: String
    }

    static let all: [CollectionDef] = [
        CollectionDef(
            collectionID: "night_shift",
            name: "Night Shift",
            description: "Earn all night-themed badges.",
            icon: "moon.stars.circle.fill",
            colorHex: "A89AFF",
            requiredBadgeIDs: ["night_owl", "streak_saver"],
            rewardBadgeID: "collection_night_shift"
        ),
        CollectionDef(
            collectionID: "the_comeback",
            name: "The Comeback",
            description: "Earn all comeback badges.",
            icon: "arrow.triangle.2.circlepath.circle.fill",
            colorHex: "FBBF24",
            requiredBadgeIDs: ["comeback_kid", "phoenix"],
            rewardBadgeID: "collection_comeback_complete"
        ),
        CollectionDef(
            collectionID: "secret_agent",
            name: "Secret Agent",
            description: "Discover every secret badge.",
            icon: "eye.circle.fill",
            colorHex: "F472B6",
            requiredBadgeIDs: [
                "night_owl", "overachiever", "streak_saver",
                "holiday_hero", "full_month", "palindrome_date",
                "friday_13th", "new_year_new_me", "triple_seven"
            ],
            rewardBadgeID: "collection_secret_agent"
        ),
        CollectionDef(
            collectionID: "consistency_crown",
            name: "Consistency Crown",
            description: "Master the art of consistency.",
            icon: "crown.fill",
            colorHex: "6C63FF",
            requiredBadgeIDs: [
                "perfect_day", "perfect_week", "perfect_week_bronze",
                "perfect_week_silver", "unstoppable"
            ],
            rewardBadgeID: "collection_consistency_crown"
        ),
        CollectionDef(
            collectionID: "monthly_champion",
            name: "Year of Champions",
            description: "Complete the monthly quest for all 12 months.",
            icon: "globe.americas.fill",
            colorHex: "22D3EE",
            requiredBadgeIDs: [
                "monthly_champion_jan", "monthly_champion_feb", "monthly_champion_mar",
                "monthly_champion_apr", "monthly_champion_may", "monthly_champion_jun",
                "monthly_champion_jul", "monthly_champion_aug", "monthly_champion_sep",
                "monthly_champion_oct", "monthly_champion_nov", "monthly_champion_dec"
            ],
            rewardBadgeID: "collection_monthly_champion"
        ),
    ]

    /// Seed BadgeCollection records in SwiftData if they don't already exist.
    static func ensureCollections(context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<BadgeCollection>())) ?? []
        let existingIDs = Set(existing.map(\.collectionID))

        for def in all where !existingIDs.contains(def.collectionID) {
            let collection = BadgeCollection(
                collectionID: def.collectionID,
                name: def.name,
                descriptionText: def.description,
                icon: def.icon,
                colorHex: def.colorHex,
                requiredBadgeIDs: def.requiredBadgeIDs,
                rewardBadgeID: def.rewardBadgeID
            )
            context.insert(collection)
        }

        try? context.save()
    }
}
