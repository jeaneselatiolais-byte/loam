//
//  WeeklyRecapGenerator.swift
//  Habitra
//
//  Phase 3 Week 8: On-device weekly recap generation
//

import Foundation

/// A generated weekly recap summarizing habit performance.
struct WeeklyRecap: Identifiable {
    let id = UUID()
    let weekStartDate: Date
    let weekEndDate: Date
    let overallRate: Double
    let totalCompletions: Int
    let totalScheduled: Int
    let bestHabit: HabitRecapItem?
    let worstHabit: HabitRecapItem?
    let bestDay: (name: String, rate: Double)?
    let worstDay: (name: String, rate: Double)?
    let streakHighlight: (habitName: String, streak: Int)?
    let moodSummary: MoodSummary?
    let insights: [String]
    let motivationalMessage: String
}

struct HabitRecapItem {
    let name: String
    let icon: String
    let colorHex: String
    let completionRate: Double
}

struct MoodSummary {
    let averageMood: Double // 1-5
    let dominantMood: MoodLevel
    let journalCount: Int
    let averageSentiment: Double
}

/// Generates weekly recaps entirely on-device.
@MainActor
enum WeeklyRecapGenerator {

    // MARK: - Generate Recap

    static func generateRecap(habits: [Habit], moodEntries: [MoodEntry] = []) -> WeeklyRecap {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(byAdding: .day, value: -7, to: today)!

        let activeHabits = habits.filter { !$0.isArchived }

        // Calculate per-habit stats for the week
        let habitStats: [(habit: Habit, rate: Double, completions: Int, scheduled: Int)] = activeHabits.map { habit in
            var scheduled = 0
            var completed = 0
            for offset in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                if habit.frequency.isScheduled(for: date) {
                    scheduled += 1
                    if habit.isCompleted(on: date) {
                        completed += 1
                    }
                }
            }
            let rate = scheduled > 0 ? Double(completed) / Double(scheduled) : 0
            return (habit, rate, completed, scheduled)
        }

        let totalCompletions = habitStats.reduce(0) { $0 + $1.completions }
        let totalScheduled = habitStats.reduce(0) { $0 + $1.scheduled }
        let overallRate = totalScheduled > 0 ? Double(totalCompletions) / Double(totalScheduled) : 0

        // Best and worst habit
        let sorted = habitStats.filter { $0.scheduled > 0 }.sorted { $0.rate > $1.rate }
        let bestHabit = sorted.first.map {
            HabitRecapItem(name: $0.habit.name, icon: $0.habit.icon, colorHex: $0.habit.colorHex, completionRate: $0.rate)
        }
        let worstHabit = sorted.count >= 2 ? sorted.last.map {
            HabitRecapItem(name: $0.habit.name, icon: $0.habit.icon, colorHex: $0.habit.colorHex, completionRate: $0.rate)
        } : nil

        // Best/worst day of the week
        let dayStats = computeDayStats(habits: activeHabits, days: 7)
        let bestDay = dayStats.max(by: { $0.value < $1.value }).map {
            (StreakCalculator.weekdayName(for: $0.key), $0.value)
        }
        let worstDay = dayStats.filter { $0.value > 0 }.min(by: { $0.value < $1.value }).map {
            (StreakCalculator.weekdayName(for: $0.key), $0.value)
        }

        // Streak highlight (longest active streak)
        let streakHighlight = activeHabits
            .max(by: { $0.currentStreak < $1.currentStreak })
            .flatMap { habit -> (String, Int)? in
                guard habit.currentStreak >= 3 else { return nil }
                return (habit.name, habit.currentStreak)
            }

        // Mood summary
        let moodSummary = computeMoodSummary(entries: moodEntries, since: weekStart)

        // Generate insights
        let insights = generateRecapInsights(
            overallRate: overallRate,
            habitStats: habitStats,
            streakHighlight: streakHighlight,
            moodSummary: moodSummary
        )

        // Motivational message
        let message = motivationalMessage(for: overallRate)

        return WeeklyRecap(
            weekStartDate: weekStart,
            weekEndDate: today,
            overallRate: overallRate,
            totalCompletions: totalCompletions,
            totalScheduled: totalScheduled,
            bestHabit: bestHabit,
            worstHabit: worstHabit,
            bestDay: bestDay,
            worstDay: worstDay,
            streakHighlight: streakHighlight,
            moodSummary: moodSummary,
            insights: insights,
            motivationalMessage: message
        )
    }

    // MARK: - Helpers

    private static func computeDayStats(habits: [Habit], days: Int) -> [Int: Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var scheduled: [Int: Int] = [:]
        var completed: [Int: Int] = [:]

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)

            for habit in habits {
                if habit.frequency.isScheduled(for: date) {
                    scheduled[weekday, default: 0] += 1
                    if habit.isCompleted(on: date) {
                        completed[weekday, default: 0] += 1
                    }
                }
            }
        }

        var rates: [Int: Double] = [:]
        for (day, sched) in scheduled {
            guard sched > 0 else { continue }
            rates[day] = Double(completed[day, default: 0]) / Double(sched)
        }
        return rates
    }

    private static func computeMoodSummary(entries: [MoodEntry], since: Date) -> MoodSummary? {
        let weekEntries = entries.filter { $0.date >= since }
        guard !weekEntries.isEmpty else { return nil }

        let avgMood = Double(weekEntries.reduce(0) { $0 + $1.moodLevel }) / Double(weekEntries.count)

        // Find dominant mood
        var moodCounts: [Int: Int] = [:]
        for entry in weekEntries {
            moodCounts[entry.moodLevel, default: 0] += 1
        }
        let dominantLevel = moodCounts.max(by: { $0.value < $1.value })?.key ?? 3
        let dominantMood = MoodLevel(rawValue: dominantLevel) ?? .okay

        // Journal entries with text
        let journalEntries = weekEntries.filter { !$0.journalText.isEmpty }
        let avgSentiment = journalEntries.isEmpty ? 0.0 :
            journalEntries.reduce(0.0) { $0 + $1.sentimentScore } / Double(journalEntries.count)

        return MoodSummary(
            averageMood: avgMood,
            dominantMood: dominantMood,
            journalCount: journalEntries.count,
            averageSentiment: avgSentiment
        )
    }

    private static func generateRecapInsights(
        overallRate: Double,
        habitStats: [(habit: Habit, rate: Double, completions: Int, scheduled: Int)],
        streakHighlight: (String, Int)?,
        moodSummary: MoodSummary?
    ) -> [String] {
        var insights: [String] = []

        if overallRate >= 0.9 {
            insights.append("Outstanding week! You completed \(Int(overallRate * 100))% of all scheduled habits.")
        } else if overallRate >= 0.7 {
            insights.append("Solid week at \(Int(overallRate * 100))% completion. Consistent effort pays off.")
        } else if overallRate >= 0.5 {
            insights.append("You completed \(Int(overallRate * 100))% this week. Every day is a chance to build momentum.")
        } else if overallRate > 0 {
            insights.append("Tough week at \(Int(overallRate * 100))% — consider simplifying to rebuild consistency.")
        }

        // Perfect habits
        let perfectHabits = habitStats.filter { $0.rate == 1.0 && $0.scheduled > 0 }
        if perfectHabits.count == 1 {
            insights.append("\(perfectHabits[0].habit.name) was perfect this week — 100% completion!")
        } else if perfectHabits.count > 1 {
            let names = perfectHabits.prefix(3).map { $0.habit.name }.joined(separator: ", ")
            insights.append("\(perfectHabits.count) habits hit 100% this week: \(names).")
        }

        if let (name, streak) = streakHighlight {
            insights.append("Your longest active streak: \(name) at \(streak) days.")
        }

        if let mood = moodSummary {
            let moodLabel = mood.dominantMood.label.lowercased()
            insights.append("Your dominant mood this week was \(moodLabel) (avg \(String(format: "%.1f", mood.averageMood))/5).")
        }

        return insights
    }

    private static func motivationalMessage(for rate: Double) -> String {
        switch rate {
        case 0.9...:  return "You're in the zone. This is what discipline looks like."
        case 0.7..<0.9: return "Strong week. Small improvements compound over time."
        case 0.5..<0.7: return "Progress, not perfection. You showed up this week."
        case 0.1..<0.5: return "Every master was once a beginner. Tomorrow is a fresh start."
        default:       return "The best time to start is now. Pick one habit and begin."
        }
    }
}
