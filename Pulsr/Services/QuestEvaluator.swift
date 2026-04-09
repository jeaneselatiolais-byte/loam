//
//  QuestEvaluator.swift
//  Habitra
//
//  Evaluates active quests and updates progress. Returns newly completed quests.
//  Called from TodayView alongside BadgeEvaluator.
//

import Foundation
import SwiftData

@MainActor
enum QuestEvaluator {

    /// Evaluate all active quests and return any that were just completed.
    @discardableResult
    static func evaluate(habits: [Habit], context: ModelContext) -> [Quest] {
        guard SubscriptionManager.isPro else { return [] }

        let descriptor = FetchDescriptor<Quest>()
        guard let quests = try? context.fetch(descriptor) else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let activeHabits = habits.filter { !$0.isArchived }
        var newlyCompleted: [Quest] = []

        let earnedBadges = (try? context.fetch(FetchDescriptor<EarnedBadge>())) ?? []

        for quest in quests where quest.isActive {
            let newValue = computeProgress(
                quest: quest,
                habits: activeHabits,
                earnedBadges: earnedBadges,
                today: today
            )
            quest.currentValue = newValue

            if newValue >= quest.targetValue && !quest.isCompleted {
                quest.isCompleted = true
                quest.completedAt = Date()
                XPEngine.awardCompletion(habit: activeHabits.first!, habits: activeHabits) // placeholder - actual XP awarded below
                newlyCompleted.append(quest)
            }
        }

        // Award XP and badge for completed quests
        for quest in newlyCompleted {
            // Add quest XP
            let _ = addQuestXP(quest.xpReward)

            // Award reward badge if applicable
            if let rewardBadgeID = quest.rewardBadgeID,
               !earnedBadges.contains(where: { $0.badgeID == rewardBadgeID }) {
                let badge = EarnedBadge(badgeID: rewardBadgeID)
                context.insert(badge)
            }
        }

        if !newlyCompleted.isEmpty {
            try? context.save()
            HapticManager.questCompleted()
        }

        return newlyCompleted
    }

    // MARK: - Progress Computation

    private static func computeProgress(
        quest: Quest,
        habits: [Habit],
        earnedBadges: [EarnedBadge],
        today: Date
    ) -> Int {
        let calendar = Calendar.current
        let start = quest.startDate
        let allCompletions = habits.flatMap(\.completions).filter { $0.completedDate >= start && $0.completedDate <= today }

        // Determine tracking type from template
        let template = findTemplate(for: quest)

        switch template {
        case "completion_rate":
            return computeCompletionRate(habits: habits, start: start, end: today)

        case "best_streak":
            return habits.map(\.currentStreak).max() ?? 0

        case "perfect_weeks":
            let perfectWeeks = earnedBadges.filter { $0.badgeID == "perfect_week" && $0.earnedAt >= start }
            return perfectWeeks.count

        case "early_completions":
            let early = allCompletions.filter { calendar.component(.hour, from: $0.completedAt) < 8 }
            let days = Set(early.map { calendar.startOfDay(for: $0.completedAt) })
            return days.count

        case "noted_completions":
            return allCompletions.filter { $0.note?.isEmpty == false }.count

        case "consecutive_perfect":
            return countConsecutivePerfectDays(habits: habits, from: today)

        case "variety_days":
            return countVarietyDays(habits: habits, start: start, end: today)

        case "comebacks":
            return earnedBadges.filter { $0.badgeID == "comeback_kid" && $0.earnedAt >= start }.count

        case "night_completions":
            let night = allCompletions.filter { calendar.component(.hour, from: $0.completedAt) >= 21 }
            let days = Set(night.map { calendar.startOfDay(for: $0.completedAt) })
            return days.count

        case "health_completions":
            return allCompletions.filter { $0.isAutoCompleted }.count

        case "total_completions":
            return allCompletions.count

        case "perfect_days":
            return countPerfectDays(habits: habits, start: start, end: today)

        case "weekly_xp":
            return XPEngine.weekXP

        case "new_badges":
            return earnedBadges.filter { $0.earnedAt >= start }.count

        default:
            return 0
        }
    }

    // MARK: - Helpers

    private static func findTemplate(for quest: Quest) -> String {
        let templates: [QuestGenerator.QuestTemplate] =
            quest.questType == "monthly" ? QuestGenerator.monthlyTemplates : QuestGenerator.weeklyTemplates
        return templates.first(where: { $0.title == quest.title })?.trackingType ?? "total_completions"
    }

    private static func computeCompletionRate(habits: [Habit], start: Date, end: Date) -> Int {
        guard !habits.isEmpty else { return 0 }
        let calendar = Calendar.current
        var scheduledCount = 0
        var completedCount = 0

        var current = start
        while current <= end {
            for habit in habits {
                if habit.frequency.isScheduled(for: current) {
                    scheduledCount += 1
                    if habit.isCompleted(on: current) {
                        completedCount += 1
                    }
                }
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        guard scheduledCount > 0 else { return 0 }
        return Int(Double(completedCount) / Double(scheduledCount) * 100)
    }

    private static func countConsecutivePerfectDays(habits: [Habit], from date: Date) -> Int {
        let calendar = Calendar.current
        var count = 0
        var current = date

        for _ in 0..<365 {
            let scheduled = habits.filter { $0.frequency.isScheduled(for: current) }
            guard !scheduled.isEmpty else {
                current = calendar.date(byAdding: .day, value: -1, to: current)!
                count += 1
                continue
            }
            if scheduled.allSatisfy({ $0.isCompleted(on: current) }) {
                count += 1
                current = calendar.date(byAdding: .day, value: -1, to: current)!
            } else {
                break
            }
        }
        return count
    }

    private static func countPerfectDays(habits: [Habit], start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        var count = 0
        var current = start

        while current <= end {
            let scheduled = habits.filter { $0.frequency.isScheduled(for: current) }
            if !scheduled.isEmpty && scheduled.allSatisfy({ $0.isCompleted(on: current) }) {
                count += 1
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return count
    }

    private static func countVarietyDays(habits: [Habit], start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        var count = 0
        var current = start

        while current <= end {
            let completed = habits.filter { $0.isCompleted(on: current) }
            if completed.count >= 5 {
                count += 1
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return count
    }

    private static func addQuestXP(_ amount: Int) -> Int {
        let current = UserDefaults.standard.integer(forKey: "habitra_lifetime_xp")
        let new = current + amount
        UserDefaults.standard.set(new, forKey: "habitra_lifetime_xp")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = "habitra_xp_\(formatter.string(from: Date()))"
        let todayCurrent = UserDefaults.standard.integer(forKey: todayKey)
        UserDefaults.standard.set(todayCurrent + amount, forKey: todayKey)

        return new
    }
}

