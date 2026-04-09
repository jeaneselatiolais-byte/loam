//
//  StreakCalculator.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation

/// Centralized streak and stats computation.
/// Pulls logic out of the model for testability and reuse.
enum StreakCalculator {

    // MARK: - Completion Rate

    /// Completion rate for a habit over the last N days
    static func completionRate(for habit: Habit, days: Int = 7) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var scheduled = 0
        var completed = 0

        for offset in 0..<days {
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

    /// Average completion rate across all habits this week
    static func averageWeeklyRate(habits: [Habit]) -> Double {
        guard !habits.isEmpty else { return 0 }
        let rates = habits.map { completionRate(for: $0, days: 7) }
        return rates.reduce(0, +) / Double(rates.count)
    }

    /// Average completion rate across all habits for last 30 days
    static func averageMonthlyRate(habits: [Habit]) -> Double {
        guard !habits.isEmpty else { return 0 }
        let rates = habits.map { completionRate(for: $0, days: 30) }
        return rates.reduce(0, +) / Double(rates.count)
    }

    // MARK: - Completion Map (for heatmap)

    /// Returns a dictionary of [Date: Int] representing completion counts per day
    /// over the last N days across all provided habits.
    static func completionMap(habits: [Habit], days: Int = 90) -> [Date: Int] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var map: [Date: Int] = [:]

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let count = habits.filter { $0.isCompleted(on: dayStart) && $0.frequency.isScheduled(for: dayStart) }.count
            map[dayStart] = count
        }

        return map
    }

    /// Returns completion map for a single habit
    static func completionMap(habit: Habit, days: Int = 90) -> [Date: Bool] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var map: [Date: Bool] = [:]

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            if habit.frequency.isScheduled(for: dayStart) {
                map[dayStart] = habit.isCompleted(on: dayStart)
            }
        }

        return map
    }

    // MARK: - Total Completions

    static func totalCompletions(habit: Habit) -> Int {
        habit.completions.count
    }

    static func totalCompletions(habits: [Habit]) -> Int {
        habits.reduce(0) { $0 + $1.completions.count }
    }

    // MARK: - Best Day of Week

    /// Returns the weekday (1=Sun..7=Sat) with highest completion rate
    static func bestDayOfWeek(habit: Habit, days: Int = 90) -> (day: Int, rate: Double)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dayCounts: [Int: (scheduled: Int, completed: Int)] = [:]

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            if habit.frequency.isScheduled(for: date) {
                var entry = dayCounts[weekday, default: (0, 0)]
                entry.scheduled += 1
                if habit.isCompleted(on: date) {
                    entry.completed += 1
                }
                dayCounts[weekday] = entry
            }
        }

        let rates = dayCounts.compactMap { day, counts -> (Int, Double)? in
            guard counts.scheduled > 0 else { return nil }
            return (day, Double(counts.completed) / Double(counts.scheduled))
        }

        return rates.max(by: { $0.1 < $1.1 }).map { (day: $0.0, rate: $0.1) }
    }

    // MARK: - Worst Day of Week

    static func worstDayOfWeek(habit: Habit, days: Int = 90) -> (day: Int, rate: Double)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dayCounts: [Int: (scheduled: Int, completed: Int)] = [:]

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            if habit.frequency.isScheduled(for: date) {
                var entry = dayCounts[weekday, default: (0, 0)]
                entry.scheduled += 1
                if habit.isCompleted(on: date) {
                    entry.completed += 1
                }
                dayCounts[weekday] = entry
            }
        }

        let rates = dayCounts.compactMap { day, counts -> (Int, Double)? in
            guard counts.scheduled > 0 else { return nil }
            return (day, Double(counts.completed) / Double(counts.scheduled))
        }

        return rates.min(by: { $0.1 < $1.1 }).map { (day: $0.0, rate: $0.1) }
    }

    // MARK: - Day Name Helper

    static func weekdayName(for day: Int) -> String {
        let symbols = Calendar.current.weekdaySymbols
        guard day >= 1, day <= 7 else { return "" }
        return symbols[day - 1]
    }

    static func shortWeekdayName(for day: Int) -> String {
        let symbols = Calendar.current.shortWeekdaySymbols
        guard day >= 1, day <= 7 else { return "" }
        return symbols[day - 1]
    }
}
