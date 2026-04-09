//
//  Quest.swift
//  Habitra
//
//  SwiftData model for weekly and monthly quests/challenges.
//  Quests are deterministically generated from the calendar.
//

import Foundation
import SwiftData

@Model
final class Quest {
    var id: UUID = UUID()
    var questID: String = ""           // deterministic, e.g. "monthly_2026_04"
    var title: String = ""
    var descriptionText: String = ""
    var icon: String = "target"
    var colorHex: String = "6C63FF"
    var questType: String = "monthly"  // "weekly" | "monthly"
    var targetValue: Int = 0
    var currentValue: Int = 0
    var isCompleted: Bool = false
    var completedAt: Date?
    var startDate: Date = Date()
    var endDate: Date = Date()
    var xpReward: Int = 0
    var rewardBadgeID: String?
    var createdAt: Date = Date()

    init(
        questID: String,
        title: String,
        descriptionText: String,
        icon: String = "target",
        colorHex: String = "6C63FF",
        questType: String = "monthly",
        targetValue: Int,
        startDate: Date,
        endDate: Date,
        xpReward: Int,
        rewardBadgeID: String? = nil
    ) {
        self.id = UUID()
        self.questID = questID
        self.title = title
        self.descriptionText = descriptionText
        self.icon = icon
        self.colorHex = colorHex
        self.questType = questType
        self.targetValue = targetValue
        self.startDate = startDate
        self.endDate = endDate
        self.xpReward = xpReward
        self.rewardBadgeID = rewardBadgeID
    }

    var isExpired: Bool {
        Date() > endDate
    }

    var isActive: Bool {
        !isCompleted && !isExpired
    }

    var progressFraction: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }

    var daysRemaining: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }
}
