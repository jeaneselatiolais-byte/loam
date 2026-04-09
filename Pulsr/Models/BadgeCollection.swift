//
//  BadgeCollection.swift
//  Habitra
//
//  SwiftData model for badge collections/sets.
//  Complete a themed set of badges to earn a special reward badge.
//

import Foundation
import SwiftData

@Model
final class BadgeCollection {
    var id: UUID = UUID()
    var collectionID: String = ""
    var name: String = ""
    var descriptionText: String = ""
    var icon: String = "square.grid.2x2.fill"
    var colorHex: String = "6C63FF"
    var requiredBadgeIDs: [String] = []
    var rewardBadgeID: String = ""
    var isCompleted: Bool = false
    var completedAt: Date?
    var createdAt: Date = Date()

    init(
        collectionID: String,
        name: String,
        descriptionText: String,
        icon: String = "square.grid.2x2.fill",
        colorHex: String = "6C63FF",
        requiredBadgeIDs: [String],
        rewardBadgeID: String
    ) {
        self.id = UUID()
        self.collectionID = collectionID
        self.name = name
        self.descriptionText = descriptionText
        self.icon = icon
        self.colorHex = colorHex
        self.requiredBadgeIDs = requiredBadgeIDs
        self.rewardBadgeID = rewardBadgeID
    }

    /// How many required badges the user has earned
    func earnedCount(earnedBadgeIDs: Set<String>) -> Int {
        requiredBadgeIDs.filter { earnedBadgeIDs.contains($0) }.count
    }

    var progressFraction: Double {
        guard !requiredBadgeIDs.isEmpty else { return 0 }
        // This is a placeholder — the actual count must be computed with earnedBadgeIDs
        return isCompleted ? 1.0 : 0.0
    }
}
