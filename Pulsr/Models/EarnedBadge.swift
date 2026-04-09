//
//  EarnedBadge.swift
//  Habitra
//
//  SwiftData model that records each badge a user has earned.
//  Per-habit badges (e.g. "Week Warrior on Running") store the habit info
//  so the shelf can display context. Global badges leave habitID nil.
//

import Foundation
import SwiftData

@Model
final class EarnedBadge {
    var id: UUID = UUID()
    var badgeID: String = ""        // matches BadgeDefinition.id
    var earnedAt: Date = Date()

    // Habit context — nil for global badges
    var habitID: UUID?
    var habitName: String?
    var habitIcon: String?
    var habitColorHex: String?

    init(
        badgeID: String,
        earnedAt: Date = Date(),
        habitID: UUID? = nil,
        habitName: String? = nil,
        habitIcon: String? = nil,
        habitColorHex: String? = nil
    ) {
        self.id = UUID()
        self.badgeID = badgeID
        self.earnedAt = earnedAt
        self.habitID = habitID
        self.habitName = habitName
        self.habitIcon = habitIcon
        self.habitColorHex = habitColorHex
    }

    /// The full definition from the catalog, if still defined.
    var definition: BadgeDefinition? {
        BadgeCatalog.definition(for: badgeID)
    }
}
