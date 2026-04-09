//
//  Habit.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation
import SwiftData

/// Frequency type — stored as a raw string for SwiftData compatibility.
enum HabitFrequencyType: String, Codable, Hashable, Sendable {
    case daily
    case weekdays
    case weekends
    case custom
}

/// Computed frequency used throughout the app. Not stored directly.
enum HabitFrequency: Hashable, Sendable {
    case daily
    case weekdays
    case weekends
    case custom(days: [Int]) // 1=Sun, 2=Mon, ... 7=Sat

    var scheduledDays: Set<Int> {
        switch self {
        case .daily:
            return Set(1...7)
        case .weekdays:
            return Set(2...6)
        case .weekends:
            return [1, 7]
        case .custom(let days):
            return Set(days)
        }
    }

    var displayName: String {
        switch self {
        case .daily: return "Every day"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .custom(let days):
            if days.count == 7 { return "Every day" }
            if days.isEmpty { return "No days" }
            let symbols = Calendar.current.veryShortWeekdaySymbols
            let sorted = days.sorted()
            return sorted.map { symbols[$0 - 1] }.joined(separator: ", ")
        }
    }

    func isScheduled(for date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return scheduledDays.contains(weekday)
    }
}

@Model
final class Habit {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "circle.fill"
    var colorHex: String = "6C63FF"

    // Frequency — stored as flat properties for SwiftData compatibility
    var frequencyType: String = "daily"  // "daily", "weekdays", "weekends", "custom"
    var customDays: [Int] = []           // Only used when frequencyType == "custom"

    var reminderTime: Date?
    var sortOrder: Int = 0
    var isArchived: Bool = false
    var createdAt: Date = Date()

    // Multi-completion: how many times per day this habit should be completed (1 = once)
    var targetCompletionsPerDay: Int = 1

    // Interval reminders for multi-completion habits.
    // 0 = single reminder at reminderTime. > 0 = fire every N minutes starting at reminderTime.
    var reminderIntervalMinutes: Int = 0

    // HealthKit auto-complete
    var healthKitSourceRaw: String = ""         // HabitHealthSource raw value; "" = disabled (legacy single-source)
    var healthKitSourcesRaw: String = ""        // Comma-separated HabitHealthSource raw values for multi-select
    var minHealthKitDurationMinutes: Int = 15   // min workout/mindfulness duration in minutes; for sleep stores hours×60
    var healthKitStepGoal: Int = 7000           // daily step target (only used when source == .steps)

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var _completions: [HabitCompletion]? = []

    var category: HabitCategory?

    /// Non-optional accessor so call-sites stay unchanged
    @Transient
    var completions: [HabitCompletion] {
        get { _completions ?? [] }
        set { _completions = newValue }
    }

    /// Computed set of HealthKit sources — the primary accessor for multi-select.
    /// Handles migration from legacy single-source `healthKitSourceRaw`.
    @Transient
    var healthKitSources: Set<HabitHealthSource> {
        get {
            // If multi-select field has data, use it
            if !healthKitSourcesRaw.isEmpty {
                let sources = healthKitSourcesRaw
                    .split(separator: ",")
                    .compactMap { HabitHealthSource(rawValue: String($0)) }
                return Set(sources)
            }
            // Fall back to legacy single-source field
            if let single = HabitHealthSource(rawValue: healthKitSourceRaw), single != .none {
                return [single]
            }
            return []
        }
        set {
            let filtered = newValue.filter { $0 != .none }
            healthKitSourcesRaw = filtered.map(\.rawValue).sorted().joined(separator: ",")
            // Keep legacy field in sync for predicates (non-empty = has sources)
            healthKitSourceRaw = filtered.isEmpty ? "" : filtered.first!.rawValue
        }
    }

    /// Whether this habit has any HealthKit source linked.
    @Transient
    var hasHealthKitSource: Bool {
        !healthKitSources.isEmpty
    }

    /// Legacy single-source accessor — returns first source or .none.
    /// Prefer `healthKitSources` for new code.
    @Transient
    var healthKitSource: HabitHealthSource {
        get { healthKitSources.first ?? .none }
        set {
            if newValue == .none {
                healthKitSources = []
            } else {
                healthKitSources = [newValue]
            }
        }
    }

    /// Computed frequency enum for app logic
    @Transient
    var frequency: HabitFrequency {
        get {
            switch frequencyType {
            case "weekdays": return .weekdays
            case "weekends": return .weekends
            case "custom":   return .custom(days: customDays)
            default:         return .daily
            }
        }
        set {
            switch newValue {
            case .daily:
                frequencyType = "daily"
                customDays = []
            case .weekdays:
                frequencyType = "weekdays"
                customDays = []
            case .weekends:
                frequencyType = "weekends"
                customDays = []
            case .custom(let days):
                frequencyType = "custom"
                customDays = days.sorted()
            }
        }
    }

    init(
        name: String,
        icon: String = "circle.fill",
        colorHex: String = "6C63FF",
        frequency: HabitFrequency = .daily,
        reminderTime: Date? = nil,
        sortOrder: Int = 0,
        category: HabitCategory? = nil,
        targetCompletionsPerDay: Int = 1,
        healthKitSources: Set<HabitHealthSource> = [],
        minHealthKitDurationMinutes: Int = 15,
        healthKitStepGoal: Int = 7000
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.reminderTime = reminderTime
        self.sortOrder = sortOrder
        self.isArchived = false
        self.createdAt = Date()
        self._completions = []
        self.category = category
        self.targetCompletionsPerDay = max(1, targetCompletionsPerDay)
        self.minHealthKitDurationMinutes = max(1, minHealthKitDurationMinutes)
        self.healthKitStepGoal = max(1, healthKitStepGoal)

        // Store HealthKit sources
        let filtered = healthKitSources.filter { $0 != .none }
        self.healthKitSourcesRaw = filtered.map(\.rawValue).sorted().joined(separator: ",")
        self.healthKitSourceRaw = filtered.isEmpty ? "" : filtered.first!.rawValue

        // Set flat storage from frequency enum
        switch frequency {
        case .daily:
            self.frequencyType = "daily"
            self.customDays = []
        case .weekdays:
            self.frequencyType = "weekdays"
            self.customDays = []
        case .weekends:
            self.frequencyType = "weekends"
            self.customDays = []
        case .custom(let days):
            self.frequencyType = "custom"
            self.customDays = days.sorted()
        }
    }

    // MARK: - Multi-Completion Helpers

    /// Whether this habit requires multiple completions per day
    var isMultiCompletion: Bool {
        targetCompletionsPerDay > 1
    }

    /// Number of completions recorded for a specific date
    func completionCount(on date: Date) -> Int {
        let calendar = Calendar.current
        return completions.filter { calendar.isDate($0.completedDate, inSameDayAs: date) }.count
    }

    /// Progress toward daily target (0.0 to 1.0)
    func completionProgress(on date: Date) -> Double {
        let count = completionCount(on: date)
        let target = max(1, targetCompletionsPerDay)
        return min(1.0, Double(count) / Double(target))
    }

    /// Whether the daily target has been fully met
    func isCompleted(on date: Date) -> Bool {
        completionCount(on: date) >= targetCompletionsPerDay
    }

    /// Whether at least one completion exists but target isn't met yet
    func isPartiallyCompleted(on date: Date) -> Bool {
        let count = completionCount(on: date)
        return count > 0 && count < targetCompletionsPerDay
    }

    var isScheduledToday: Bool {
        frequency.isScheduled(for: Date())
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        if !isCompleted(on: checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            checkDate = yesterday
        }

        while true {
            if frequency.isScheduled(for: checkDate) {
                if isCompleted(on: checkDate) {
                    streak += 1
                } else {
                    break
                }
            }
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }
        return streak
    }

    var longestStreak: Int {
        guard !completions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sortedDates = completions
            .map { calendar.startOfDay(for: $0.completedDate) }
            .sorted()

        guard let firstDate = sortedDates.first, let lastDate = sortedDates.last else { return 0 }

        var longest = 0
        var current = 0
        var checkDate = firstDate

        while checkDate <= lastDate {
            if frequency.isScheduled(for: checkDate) {
                if sortedDates.contains(where: { calendar.isDate($0, inSameDayAs: checkDate) }) {
                    current += 1
                    longest = max(longest, current)
                } else {
                    current = 0
                }
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: checkDate) else { break }
            checkDate = nextDay
        }

        return longest
    }
}
