//
//  HabitCorrelationAnalyzer.swift
//  Habitra
//
//  Phase 3 Week 9: Deep cross-habit correlation analysis
//

import Foundation

/// Correlation between two habits.
struct HabitCorrelation: Identifiable {
    let id = UUID()
    let habitAName: String
    let habitAIcon: String
    let habitAColorHex: String
    let habitBName: String
    let habitBIcon: String
    let habitBColorHex: String
    let coefficient: Double        // -1.0 to 1.0 (Pearson-like)
    let strength: CorrelationStrength
    let insight: String
}

enum CorrelationStrength: String {
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"
    case none = "None"

    var colorHex: String {
        switch self {
        case .strong:   return "6C63FF"
        case .moderate: return "22D3EE"
        case .weak:     return "FBBF24"
        case .none:     return "7A74B0"
        }
    }
}

/// Daily performance summary for correlation analysis.
struct DailyPerformance {
    let date: Date
    let completionRate: Double    // 0.0 to 1.0
    let moodLevel: Int?           // 1-5 or nil
}

/// Analyzes correlations between habits and between habits and mood.
@MainActor
enum HabitCorrelationAnalyzer {

    // MARK: - Pairwise Habit Correlations

    /// Calculate correlations between all pairs of active habits.
    static func analyzeCorrelations(habits: [Habit], days: Int = 30) -> [HabitCorrelation] {
        let activeHabits = habits.filter { !$0.isArchived }
        guard activeHabits.count >= 2 else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var correlations: [HabitCorrelation] = []

        for i in 0..<activeHabits.count {
            for j in (i+1)..<activeHabits.count {
                let habitA = activeHabits[i]
                let habitB = activeHabits[j]

                // Build completion arrays for days both are scheduled
                var aValues: [Double] = []
                var bValues: [Double] = []

                for offset in 0..<days {
                    guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                    let aScheduled = habitA.frequency.isScheduled(for: date)
                    let bScheduled = habitB.frequency.isScheduled(for: date)
                    guard aScheduled && bScheduled else { continue }

                    aValues.append(habitA.isCompleted(on: date) ? 1.0 : 0.0)
                    bValues.append(habitB.isCompleted(on: date) ? 1.0 : 0.0)
                }

                guard aValues.count >= 7 else { continue } // Need enough overlapping days

                let coefficient = pearsonCorrelation(x: aValues, y: bValues)
                let strength = classifyStrength(coefficient)

                guard strength != .none else { continue }

                let insight = buildCorrelationInsight(
                    habitA: habitA, habitB: habitB,
                    coefficient: coefficient, strength: strength
                )

                correlations.append(HabitCorrelation(
                    habitAName: habitA.name,
                    habitAIcon: habitA.icon,
                    habitAColorHex: habitA.colorHex,
                    habitBName: habitB.name,
                    habitBIcon: habitB.icon,
                    habitBColorHex: habitB.colorHex,
                    coefficient: coefficient,
                    strength: strength,
                    insight: insight
                ))
            }
        }

        return correlations.sorted { abs($0.coefficient) > abs($1.coefficient) }
    }

    // MARK: - Mood-Habit Correlations

    /// Analyze how mood affects habit completion across all habits.
    static func moodHabitCorrelations(habits: [Habit], moodEntries: [MoodEntry], days: Int = 30) -> [HabitCorrelation] {
        let activeHabits = habits.filter { !$0.isArchived }
        guard !moodEntries.isEmpty else { return [] }

        let calendar = Calendar.current
        var correlations: [HabitCorrelation] = []

        for habit in activeHabits {
            var moodValues: [Double] = []
            var completionValues: [Double] = []

            for mood in moodEntries {
                let date = calendar.startOfDay(for: mood.date)
                guard habit.frequency.isScheduled(for: date) else { continue }

                moodValues.append(Double(mood.moodLevel))
                completionValues.append(habit.isCompleted(on: date) ? 1.0 : 0.0)
            }

            guard moodValues.count >= 5 else { continue }

            let coefficient = pearsonCorrelation(x: moodValues, y: completionValues)
            let strength = classifyStrength(coefficient)
            guard strength != .none else { continue }

            let insight = buildMoodInsight(habit: habit, coefficient: coefficient)

            correlations.append(HabitCorrelation(
                habitAName: "Mood",
                habitAIcon: "face.smiling",
                habitAColorHex: "FBBF24",
                habitBName: habit.name,
                habitBIcon: habit.icon,
                habitBColorHex: habit.colorHex,
                coefficient: coefficient,
                strength: strength,
                insight: insight
            ))
        }

        return correlations.sorted { abs($0.coefficient) > abs($1.coefficient) }
    }

    // MARK: - Completion Velocity

    /// How quickly habits are completed after scheduled time (average time of day).
    static func completionVelocity(habits: [Habit]) -> [(habit: Habit, avgHour: Double, label: String)] {
        let calendar = Calendar.current

        return habits.filter { !$0.isArchived }.compactMap { habit in
            let hours = habit.completions.map {
                Double(calendar.component(.hour, from: $0.completedAt)) +
                Double(calendar.component(.minute, from: $0.completedAt)) / 60.0
            }
            guard !hours.isEmpty else { return nil }
            let avg = hours.reduce(0, +) / Double(hours.count)

            let label: String = {
                switch avg {
                case ..<7:    return "Early bird"
                case 7..<10:  return "Morning"
                case 10..<13: return "Midday"
                case 13..<17: return "Afternoon"
                case 17..<20: return "Evening"
                default:       return "Night owl"
                }
            }()

            return (habit, avg, label)
        }.sorted { $0.avgHour < $1.avgHour }
    }

    // MARK: - Pearson Correlation

    private static func pearsonCorrelation(x: [Double], y: [Double]) -> Double {
        guard x.count == y.count, x.count >= 3 else { return 0.0 }
        let n = Double(x.count)

        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).reduce(0.0) { $0 + $1.0 * $1.1 }
        let sumX2 = x.reduce(0.0) { $0 + $1 * $1 }
        let sumY2 = y.reduce(0.0) { $0 + $1 * $1 }

        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

        guard denominator > 0 else { return 0.0 }
        return numerator / denominator
    }

    // MARK: - Helpers

    private static func classifyStrength(_ coefficient: Double) -> CorrelationStrength {
        let abs = abs(coefficient)
        switch abs {
        case 0.5...: return .strong
        case 0.3..<0.5: return .moderate
        case 0.15..<0.3: return .weak
        default: return .none
        }
    }

    private static func buildCorrelationInsight(habitA: Habit, habitB: Habit, coefficient: Double, strength: CorrelationStrength) -> String {
        if coefficient > 0 {
            return "\(habitA.name) and \(habitB.name) tend to succeed or fail together (\(strength.rawValue.lowercased()) link). Completing one may help with the other."
        } else {
            return "When you complete \(habitA.name), you're less likely to complete \(habitB.name). They may compete for the same time or energy."
        }
    }

    private static func buildMoodInsight(habit: Habit, coefficient: Double) -> String {
        if coefficient > 0.3 {
            return "Your mood strongly predicts \(habit.name) completion. On tough days, try a 2-minute version to maintain the streak."
        } else if coefficient > 0 {
            return "Better mood slightly boosts \(habit.name) completion. Doing the habit might also improve your mood."
        } else {
            return "Interestingly, \(habit.name) completion doesn't depend much on mood — it's becoming automatic."
        }
    }
}
