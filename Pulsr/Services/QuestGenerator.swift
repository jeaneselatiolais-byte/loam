//
//  QuestGenerator.swift
//  Habitra
//
//  Deterministically generates weekly and monthly quests from the calendar.
//  No server needed — quests are derived from year/month/week.
//

import Foundation
import SwiftData

@MainActor
enum QuestGenerator {

    // MARK: - Public

    /// Ensures current quests exist. Call on app launch and when opening quest view.
    static func ensureCurrentQuests(context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Quest>())) ?? []
        let existingIDs = Set(existing.map(\.questID))

        let calendar = Calendar.current
        let today = Date()

        // Monthly quest
        let monthlyQuest = generateMonthlyQuest(for: today)
        if !existingIDs.contains(monthlyQuest.questID) {
            context.insert(monthlyQuest)
        }

        // Weekly quests (2 per week)
        let weeklyQuests = generateWeeklyQuests(for: today)
        for quest in weeklyQuests where !existingIDs.contains(quest.questID) {
            context.insert(quest)
        }

        // Clean up expired quests older than 2 months
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: today) ?? today
        for quest in existing where quest.endDate < twoMonthsAgo {
            context.delete(quest)
        }

        try? context.save()
    }

    // MARK: - Monthly Quest

    private static func generateMonthlyQuest(for date: Date) -> Quest {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let seed = year * 100 + month

        let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!

        let monthKeys = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
        let rewardBadgeID = "monthly_champion_\(monthKeys[month - 1])"

        let template = monthlyTemplates[seed % monthlyTemplates.count]

        return Quest(
            questID: "monthly_\(year)_\(String(format: "%02d", month))",
            title: template.title,
            descriptionText: template.description,
            icon: template.icon,
            colorHex: "F59E0B",
            questType: "monthly",
            targetValue: template.target,
            startDate: monthStart,
            endDate: monthEnd,
            xpReward: 500,
            rewardBadgeID: rewardBadgeID
        )
    }

    // MARK: - Weekly Quests

    private static func generateWeeklyQuests(for date: Date) -> [Quest] {
        let calendar = Calendar.current
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let week = calendar.component(.weekOfYear, from: date)
        let seed = year * 100 + week

        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!

        let t1 = weeklyTemplates[seed % weeklyTemplates.count]
        let t2 = weeklyTemplates[(seed + 3) % weeklyTemplates.count]

        return [
            Quest(
                questID: "weekly_\(year)_\(String(format: "%02d", week))_a",
                title: t1.title,
                descriptionText: t1.description,
                icon: t1.icon,
                colorHex: "6C63FF",
                questType: "weekly",
                targetValue: t1.target,
                startDate: weekStart,
                endDate: weekEnd,
                xpReward: 150
            ),
            Quest(
                questID: "weekly_\(year)_\(String(format: "%02d", week))_b",
                title: t2.title,
                descriptionText: t2.description,
                icon: t2.icon,
                colorHex: "3B82F6",
                questType: "weekly",
                targetValue: t2.target,
                startDate: weekStart,
                endDate: weekEnd,
                xpReward: 150
            ),
        ]
    }

    // MARK: - Templates

    struct QuestTemplate {
        let title: String
        let description: String
        let icon: String
        let target: Int
        let trackingType: String // used by QuestEvaluator
    }

    static let monthlyTemplates: [QuestTemplate] = [
        QuestTemplate(title: "Consistency King", description: "Reach 90% overall completion rate this month.", icon: "crown.fill", target: 90, trackingType: "completion_rate"),
        QuestTemplate(title: "Streak Builder", description: "Build a 14-day streak on any habit this month.", icon: "flame.fill", target: 14, trackingType: "best_streak"),
        QuestTemplate(title: "Perfect Weeks", description: "Earn 2 Perfect Weeks this month.", icon: "calendar.badge.checkmark", target: 2, trackingType: "perfect_weeks"),
        QuestTemplate(title: "Early Riser", description: "Complete a habit before 8 AM on 10 different days.", icon: "sunrise.fill", target: 10, trackingType: "early_completions"),
        QuestTemplate(title: "Reflections", description: "Add journal notes to 15 habit completions.", icon: "pencil.and.outline", target: 15, trackingType: "noted_completions"),
        QuestTemplate(title: "Zero Miss", description: "Complete all habits every day for 7 consecutive days.", icon: "checkmark.seal.fill", target: 7, trackingType: "consecutive_perfect"),
        QuestTemplate(title: "Variety Pack", description: "Complete 5 different habits in a single day, 5 times.", icon: "square.grid.2x2.fill", target: 5, trackingType: "variety_days"),
        QuestTemplate(title: "Comeback Trail", description: "Recover and rebuild 3 broken streaks.", icon: "arrow.counterclockwise.circle.fill", target: 3, trackingType: "comebacks"),
        QuestTemplate(title: "Night Runner", description: "Complete habits after 9 PM on 5 different days.", icon: "moon.stars.fill", target: 5, trackingType: "night_completions"),
        QuestTemplate(title: "Health Sync", description: "Auto-complete 10 habits via Apple Health.", icon: "heart.fill", target: 10, trackingType: "health_completions"),
        QuestTemplate(title: "Century Run", description: "Reach 100 total completions this month.", icon: "figure.run.circle.fill", target: 100, trackingType: "total_completions"),
        QuestTemplate(title: "The Grind", description: "No missed days for 21 consecutive days.", icon: "hammer.fill", target: 21, trackingType: "consecutive_perfect"),
    ]

    static let weeklyTemplates: [QuestTemplate] = [
        QuestTemplate(title: "5 for 7", description: "Complete all habits on 5 of 7 days.", icon: "hand.raised.fingers.spread.fill", target: 5, trackingType: "perfect_days"),
        QuestTemplate(title: "XP Hunter", description: "Earn 200 XP this week.", icon: "bolt.fill", target: 200, trackingType: "weekly_xp"),
        QuestTemplate(title: "Streak Starter", description: "Build a 5-day streak on any habit.", icon: "flame.fill", target: 5, trackingType: "best_streak"),
        QuestTemplate(title: "Daily Writer", description: "Add notes to 5 completions.", icon: "pencil.and.outline", target: 5, trackingType: "noted_completions"),
        QuestTemplate(title: "Morning Person", description: "Complete a habit before 9 AM on 3 days.", icon: "sunrise.fill", target: 3, trackingType: "early_completions"),
        QuestTemplate(title: "Full Sweep", description: "Complete all habits for 3 consecutive days.", icon: "checkmark.circle.fill", target: 3, trackingType: "consecutive_perfect"),
        QuestTemplate(title: "Quick Start", description: "Complete 30 total habits this week.", icon: "hare.fill", target: 30, trackingType: "total_completions"),
        QuestTemplate(title: "Badge Hunter", description: "Earn at least 1 new badge.", icon: "trophy.fill", target: 1, trackingType: "new_badges"),
    ]
}
