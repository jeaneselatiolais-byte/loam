//
//  PatternDetectionEngine.swift
//  Habitra
//
//  Phase 3 Week 8: On-device pattern detection for habit insights
//  Identifies skip patterns, at-risk habits, best/worst days, and correlations
//

import Foundation

/// A detected pattern or insight about user habits.
struct HabitInsight: Identifiable, Equatable {
    let id = UUID()
    let type: InsightType
    let habitName: String
    let habitIcon: String
    let habitColorHex: String
    let title: String
    let message: String
    let priority: InsightPriority
    let createdAt: Date

    static func == (lhs: HabitInsight, rhs: HabitInsight) -> Bool {
        lhs.id == rhs.id
    }
}

enum InsightType: String, Codable {
    case atRisk          // "You usually skip Fridays"
    case streakDanger    // "Your streak is at risk"
    case bestDay         // "Saturday is your best day"
    case worstDay        // "Wednesday is your weakest day"
    case improvement     // "Your completion rate improved 15%"
    case decline         // "Your completion rate dropped 20%"
    case correlation     // "Sleep affects your workout"
    case milestone       // "You've been tracking for 30 days"
    case suggestion      // "Try pairing habits together"
    case weeklyRecap     // Weekly summary
}

enum InsightPriority: Int, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3

    static func < (lhs: InsightPriority, rhs: InsightPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// On-device pattern detection engine.
/// Analyzes habit history to generate actionable insights.
/// No network requests — fully private.
@MainActor
enum PatternDetectionEngine {

    // MARK: - Generate All Insights

    /// Analyze all habits and return prioritized insights.
    static func generateInsights(habits: [Habit], moodEntries: [MoodEntry] = []) -> [HabitInsight] {
        var insights: [HabitInsight] = []

        for habit in habits where !habit.isArchived {
            insights.append(contentsOf: analyzeHabit(habit))
        }

        // Cross-habit insights
        insights.append(contentsOf: crossHabitInsights(habits: habits))

        // Mood-habit correlations
        if !moodEntries.isEmpty {
            insights.append(contentsOf: moodCorrelations(habits: habits, moods: moodEntries))
        }

        // Sort by priority (highest first), then by date
        return insights.sorted { lhs, rhs in
            if lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }
            return lhs.createdAt > rhs.createdAt
        }
    }

    // MARK: - Per-Habit Analysis

    private static func analyzeHabit(_ habit: Habit) -> [HabitInsight] {
        var insights: [HabitInsight] = []

        // Skip pattern detection
        if let skipInsight = detectSkipPattern(habit) {
            insights.append(skipInsight)
        }

        // Streak danger detection
        if let dangerInsight = detectStreakDanger(habit) {
            insights.append(dangerInsight)
        }

        // Trend detection (improvement or decline)
        if let trendInsight = detectTrend(habit) {
            insights.append(trendInsight)
        }

        // Best/worst day insights
        if let bestDay = detectBestDay(habit) {
            insights.append(bestDay)
        }
        if let worstDay = detectWorstDay(habit) {
            insights.append(worstDay)
        }

        // Tracking milestone
        if let milestone = detectTrackingMilestone(habit) {
            insights.append(milestone)
        }

        return insights
    }

    // MARK: - Skip Pattern Detection

    /// Detects if a user consistently skips on certain days.
    private static func detectSkipPattern(_ habit: Habit) -> HabitInsight? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = 30

        // Count misses per weekday
        var missedByDay: [Int: Int] = [:]
        var scheduledByDay: [Int: Int] = [:]

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)

            if habit.frequency.isScheduled(for: date) {
                scheduledByDay[weekday, default: 0] += 1
                if !habit.isCompleted(on: date) {
                    missedByDay[weekday, default: 0] += 1
                }
            }
        }

        // Find days where miss rate > 60%
        for (weekday, missed) in missedByDay {
            let scheduled = scheduledByDay[weekday, default: 0]
            guard scheduled >= 3 else { continue } // Need enough data

            let missRate = Double(missed) / Double(scheduled)
            if missRate >= 0.6 {
                let dayName = StreakCalculator.weekdayName(for: weekday)
                return HabitInsight(
                    type: .atRisk,
                    habitName: habit.name,
                    habitIcon: habit.icon,
                    habitColorHex: habit.colorHex,
                    title: "Skip pattern detected",
                    message: "You usually skip \(habit.name) on \(dayName)s. Try setting a specific reminder or pairing it with another routine.",
                    priority: .high,
                    createdAt: Date()
                )
            }
        }

        return nil
    }

    // MARK: - Streak Danger Detection

    /// Warns if today is a scheduled day and the user hasn't completed it yet,
    /// and they have an active streak worth protecting.
    private static func detectStreakDanger(_ habit: Habit) -> HabitInsight? {
        let today = Date()
        guard habit.frequency.isScheduled(for: today) else { return nil }
        guard !habit.isCompleted(on: today) else { return nil }
        guard habit.currentStreak >= 3 else { return nil }

        let hour = Calendar.current.component(.hour, from: today)
        guard hour >= 18 else { return nil } // Only warn in evening

        return HabitInsight(
            type: .streakDanger,
            habitName: habit.name,
            habitIcon: habit.icon,
            habitColorHex: habit.colorHex,
            title: "\(habit.currentStreak)-day streak at risk!",
            message: "Don't forget \(habit.name) today — you're on a \(habit.currentStreak)-day streak. Complete it before midnight to keep it alive.",
            priority: .urgent,
            createdAt: Date()
        )
    }

    // MARK: - Trend Detection

    /// Detects if completion rate is improving or declining.
    private static func detectTrend(_ habit: Habit) -> HabitInsight? {
        let recentRate = StreakCalculator.completionRate(for: habit, days: 7)
        let olderRate = completionRateForRange(habit: habit, startDaysAgo: 14, endDaysAgo: 7)

        guard olderRate > 0 else { return nil } // Not enough data

        let change = recentRate - olderRate

        if change >= 0.15 {
            let pct = Int(change * 100)
            return HabitInsight(
                type: .improvement,
                habitName: habit.name,
                habitIcon: habit.icon,
                habitColorHex: habit.colorHex,
                title: "Great improvement!",
                message: "\(habit.name) completion rate improved \(pct)% this week compared to last week. Keep it up!",
                priority: .medium,
                createdAt: Date()
            )
        }

        if change <= -0.2 {
            let pct = Int(abs(change) * 100)
            return HabitInsight(
                type: .decline,
                habitName: habit.name,
                habitIcon: habit.icon,
                habitColorHex: habit.colorHex,
                title: "Completion rate dropping",
                message: "\(habit.name) completion rate dropped \(pct)% this week. Consider simplifying or adjusting the schedule.",
                priority: .high,
                createdAt: Date()
            )
        }

        return nil
    }

    // MARK: - Best/Worst Day

    private static func detectBestDay(_ habit: Habit) -> HabitInsight? {
        guard let best = StreakCalculator.bestDayOfWeek(habit: habit, days: 30) else { return nil }
        guard best.rate >= 0.8 else { return nil }

        let dayName = StreakCalculator.weekdayName(for: best.day)
        return HabitInsight(
            type: .bestDay,
            habitName: habit.name,
            habitIcon: habit.icon,
            habitColorHex: habit.colorHex,
            title: "\(dayName) is your power day",
            message: "You complete \(habit.name) \(Int(best.rate * 100))% of the time on \(dayName)s. Build on that momentum!",
            priority: .low,
            createdAt: Date()
        )
    }

    private static func detectWorstDay(_ habit: Habit) -> HabitInsight? {
        guard let worst = StreakCalculator.worstDayOfWeek(habit: habit, days: 30) else { return nil }
        guard worst.rate <= 0.3 else { return nil }

        let dayName = StreakCalculator.weekdayName(for: worst.day)
        return HabitInsight(
            type: .worstDay,
            habitName: habit.name,
            habitIcon: habit.icon,
            habitColorHex: habit.colorHex,
            title: "\(dayName) needs attention",
            message: "You only complete \(habit.name) \(Int(worst.rate * 100))% of the time on \(dayName)s. Try moving it earlier in the day or setting a reminder.",
            priority: .medium,
            createdAt: Date()
        )
    }

    // MARK: - Tracking Milestone

    private static func detectTrackingMilestone(_ habit: Habit) -> HabitInsight? {
        let calendar = Calendar.current
        let daysSinceCreation = calendar.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 0
        let milestones = [30, 60, 90, 180, 365]

        for milestone in milestones {
            // Within 1 day of milestone
            if abs(daysSinceCreation - milestone) <= 1 {
                return HabitInsight(
                    type: .milestone,
                    habitName: habit.name,
                    habitIcon: habit.icon,
                    habitColorHex: habit.colorHex,
                    title: "\(milestone)-day tracking milestone!",
                    message: "You've been tracking \(habit.name) for \(milestone) days. That's real commitment — keep going!",
                    priority: .low,
                    createdAt: Date()
                )
            }
        }

        return nil
    }

    // MARK: - Cross-Habit Insights

    private static func crossHabitInsights(habits: [Habit]) -> [HabitInsight] {
        var insights: [HabitInsight] = []

        let activeHabits = habits.filter { !$0.isArchived }
        guard activeHabits.count >= 2 else { return insights }

        // Find habit pairs that tend to be completed together
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = 30

        for i in 0..<activeHabits.count {
            for j in (i+1)..<activeHabits.count {
                let habitA = activeHabits[i]
                let habitB = activeHabits[j]

                var bothDone = 0
                var aDoneOnly = 0
                var bDoneOnly = 0
                var neitherDone = 0

                for offset in 0..<days {
                    guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                    let aScheduled = habitA.frequency.isScheduled(for: date)
                    let bScheduled = habitB.frequency.isScheduled(for: date)
                    guard aScheduled && bScheduled else { continue }

                    let aDone = habitA.isCompleted(on: date)
                    let bDone = habitB.isCompleted(on: date)

                    if aDone && bDone { bothDone += 1 }
                    else if aDone { aDoneOnly += 1 }
                    else if bDone { bDoneOnly += 1 }
                    else { neitherDone += 1 }
                }

                let total = bothDone + aDoneOnly + bDoneOnly + neitherDone
                guard total >= 7 else { continue }

                let coOccurrence = Double(bothDone) / Double(total)
                if coOccurrence >= 0.7 {
                    insights.append(HabitInsight(
                        type: .correlation,
                        habitName: habitA.name,
                        habitIcon: "link",
                        habitColorHex: habitA.colorHex,
                        title: "Habit pair: \(habitA.name) + \(habitB.name)",
                        message: "You complete \(habitA.name) and \(habitB.name) together \(Int(coOccurrence * 100))% of the time. They reinforce each other!",
                        priority: .low,
                        createdAt: Date()
                    ))
                }
            }
        }

        // Overall health check
        let avgRate = StreakCalculator.averageWeeklyRate(habits: activeHabits)
        if avgRate < 0.3 && activeHabits.count >= 3 {
            insights.append(HabitInsight(
                type: .suggestion,
                habitName: "All Habits",
                habitIcon: "lightbulb.fill",
                habitColorHex: "FBBF24",
                title: "Consider simplifying",
                message: "Your overall completion rate is \(Int(avgRate * 100))% this week. Try focusing on fewer habits to build momentum, then add more.",
                priority: .high,
                createdAt: Date()
            ))
        }

        return insights
    }

    // MARK: - Mood Correlations

    private static func moodCorrelations(habits: [Habit], moods: [MoodEntry]) -> [HabitInsight] {
        var insights: [HabitInsight] = []
        let calendar = Calendar.current

        for habit in habits where !habit.isArchived {
            var goodMoodCompletions = 0
            var goodMoodMisses = 0
            var badMoodCompletions = 0
            var badMoodMisses = 0

            for mood in moods {
                let date = calendar.startOfDay(for: mood.date)
                guard habit.frequency.isScheduled(for: date) else { continue }

                let completed = habit.isCompleted(on: date)
                let isGoodMood = mood.moodLevel >= 4

                if isGoodMood {
                    if completed { goodMoodCompletions += 1 }
                    else { goodMoodMisses += 1 }
                } else {
                    if completed { badMoodCompletions += 1 }
                    else { badMoodMisses += 1 }
                }
            }

            let goodTotal = goodMoodCompletions + goodMoodMisses
            let badTotal = badMoodCompletions + badMoodMisses
            guard goodTotal >= 5, badTotal >= 5 else { continue }

            let goodRate = Double(goodMoodCompletions) / Double(goodTotal)
            let badRate = Double(badMoodCompletions) / Double(badTotal)
            let diff = goodRate - badRate

            if diff >= 0.25 {
                insights.append(HabitInsight(
                    type: .correlation,
                    habitName: habit.name,
                    habitIcon: habit.icon,
                    habitColorHex: habit.colorHex,
                    title: "Mood affects \(habit.name)",
                    message: "You're \(Int(diff * 100))% more likely to complete \(habit.name) on good mood days. On tough days, try starting with just 2 minutes.",
                    priority: .medium,
                    createdAt: Date()
                ))
            }
        }

        return insights
    }

    // MARK: - Helpers

    private static func completionRateForRange(habit: Habit, startDaysAgo: Int, endDaysAgo: Int) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var scheduled = 0
        var completed = 0

        for offset in endDaysAgo..<startDaysAgo {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            if habit.frequency.isScheduled(for: date) {
                scheduled += 1
                if habit.isCompleted(on: date) {
                    completed += 1
                }
            }
        }

        guard scheduled > 0 else { return 0 }
        return Double(completed) / Double(scheduled)
    }
}
