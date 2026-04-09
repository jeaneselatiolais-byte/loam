//
//  AdaptiveReminderOptimizer.swift
//  Habitra
//
//  Phase 3 Week 9: AI-powered adaptive reminder timing
//  Analyzes when users actually complete habits to suggest optimal reminder times.
//

import Foundation

/// Suggested optimal reminder time for a habit.
struct ReminderSuggestion {
    let habitID: UUID
    let suggestedHour: Int
    let suggestedMinute: Int
    let confidence: Double       // 0.0 to 1.0
    let reason: String
    let currentHour: Int?
    let currentMinute: Int?

    var suggestedTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var components = DateComponents()
        components.hour = suggestedHour
        components.minute = suggestedMinute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }

    var timeDelta: String? {
        guard let currentHour else { return nil }
        let currentMinutes = currentHour * 60 + (currentMinute ?? 0)
        let suggestedMinutes = suggestedHour * 60 + suggestedMinute
        let diff = suggestedMinutes - currentMinutes

        if abs(diff) < 15 { return nil } // Too small to matter
        let hours = abs(diff) / 60
        let mins = abs(diff) % 60

        let direction = diff > 0 ? "later" : "earlier"
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m \(direction)"
        } else if hours > 0 {
            return "\(hours)h \(direction)"
        } else {
            return "\(mins)m \(direction)"
        }
    }
}

/// Analyzes completion timestamps to find optimal reminder times.
@MainActor
enum AdaptiveReminderOptimizer {

    // MARK: - Analyze All Habits

    /// Generate reminder suggestions for all habits that have reminders set.
    static func suggestOptimalTimes(habits: [Habit]) -> [ReminderSuggestion] {
        habits.compactMap { habit in
            guard !habit.isArchived else { return nil }
            return analyzeHabit(habit)
        }
    }

    // MARK: - Per-Habit Analysis

    /// Analyze a single habit's completion patterns and suggest optimal time.
    static func analyzeHabit(_ habit: Habit) -> ReminderSuggestion? {
        let completions = habit.completions
        guard completions.count >= 5 else { return nil } // Need enough data

        let calendar = Calendar.current

        // Extract completion hours (using completedAt — exact timestamp)
        let completionHours = completions.map { completion -> (hour: Int, minute: Int) in
            let hour = calendar.component(.hour, from: completion.completedAt)
            let minute = calendar.component(.minute, from: completion.completedAt)
            return (hour, minute)
        }

        // Find the most common completion time window (2-hour buckets)
        var bucketCounts: [Int: Int] = [:]
        for (hour, _) in completionHours {
            let bucket = (hour / 2) * 2 // 0-1, 2-3, 4-5, etc.
            bucketCounts[bucket, default: 0] += 1
        }

        guard let peakBucket = bucketCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }

        // Get the average time within the peak bucket
        let peakCompletions = completionHours.filter { ($0.hour / 2) * 2 == peakBucket.key }
        let avgMinutesFromMidnight = peakCompletions.reduce(0.0) { total, c in
            total + Double(c.hour * 60 + c.minute)
        } / Double(peakCompletions.count)

        let suggestedHour = Int(avgMinutesFromMidnight) / 60
        let suggestedMinute = (Int(avgMinutesFromMidnight) % 60 / 15) * 15 // Round to 15 min

        let confidence = Double(peakBucket.value) / Double(completions.count)

        // Current reminder info
        var currentHour: Int? = nil
        var currentMinute: Int? = nil
        if let reminderTime = habit.reminderTime {
            currentHour = calendar.component(.hour, from: reminderTime)
            currentMinute = calendar.component(.minute, from: reminderTime)
        }

        // Determine reason
        let reason = buildReason(
            peakHour: suggestedHour,
            confidence: confidence,
            totalCompletions: completions.count,
            peakCount: peakBucket.value
        )

        // Only suggest if reasonably confident and timing would actually change
        guard confidence >= 0.3 else { return nil }

        // Check if suggestion is meaningfully different from current
        if let curH = currentHour, let curM = currentMinute {
            let diff = abs((suggestedHour * 60 + suggestedMinute) - (curH * 60 + curM))
            if diff < 30 { return nil } // Not enough difference to warrant a change
        }

        return ReminderSuggestion(
            habitID: habit.id,
            suggestedHour: suggestedHour,
            suggestedMinute: suggestedMinute,
            confidence: confidence,
            reason: reason,
            currentHour: currentHour,
            currentMinute: currentMinute
        )
    }

    // MARK: - Best Completion Window

    /// Returns the time window when a user most commonly completes their habits overall.
    static func bestCompletionWindow(habits: [Habit]) -> (startHour: Int, endHour: Int, label: String)? {
        let calendar = Calendar.current
        var allHours: [Int] = []

        for habit in habits where !habit.isArchived {
            for completion in habit.completions {
                allHours.append(calendar.component(.hour, from: completion.completedAt))
            }
        }

        guard !allHours.isEmpty else { return nil }

        // 3-hour window buckets
        var windowCounts: [Int: Int] = [:]
        for hour in allHours {
            let window = (hour / 3) * 3
            windowCounts[window, default: 0] += 1
        }

        guard let peakWindow = windowCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }

        let startHour = peakWindow.key
        let endHour = min(startHour + 3, 24)

        let label: String = {
            switch startHour {
            case 5..<9:   return "Early morning"
            case 9..<12:  return "Morning"
            case 12..<15: return "Afternoon"
            case 15..<18: return "Late afternoon"
            case 18..<21: return "Evening"
            case 21..<24: return "Night"
            default:       return "Late night"
            }
        }()

        return (startHour, endHour, label)
    }

    // MARK: - Helpers

    private static func buildReason(peakHour: Int, confidence: Double, totalCompletions: Int, peakCount: Int) -> String {
        let timeLabel: String = {
            switch peakHour {
            case 5..<9:   return "early morning"
            case 9..<12:  return "mid-morning"
            case 12..<15: return "early afternoon"
            case 15..<18: return "late afternoon"
            case 18..<21: return "evening"
            default:       return "nighttime"
            }
        }()

        let pct = Int(confidence * 100)
        return "You complete this habit \(pct)% of the time in the \(timeLabel). A reminder 30 minutes before your natural time can help."
    }
}
