//
//  HabitPredictionEngine.swift
//  Habitra
//
//  Phase 3 Week 9: On-device habit success prediction using tabular regression
//  Uses feature engineering on local habit data — no Core ML model file needed
//  for initial launch. Upgrades to Core ML TabularRegressor when trained data exists.
//

import Foundation
import CoreML

/// Prediction result for a single habit on a given day.
struct HabitPrediction: Identifiable {
    let id = UUID()
    let habitID: UUID
    let habitName: String
    let habitIcon: String
    let habitColorHex: String
    let successProbability: Double   // 0.0 to 1.0
    let riskLevel: PredictionRisk
    let factors: [PredictionFactor]
    let suggestedAction: String?
}

enum PredictionRisk: String, Codable {
    case low        // > 70% likely to complete
    case moderate   // 40-70%
    case high       // < 40% likely to complete

    var label: String {
        switch self {
        case .low:      return "On Track"
        case .moderate: return "Needs Attention"
        case .high:     return "At Risk"
        }
    }

    var colorHex: String {
        switch self {
        case .low:      return "4ADE80"
        case .moderate: return "FBBF24"
        case .high:     return "F87171"
        }
    }

    var icon: String {
        switch self {
        case .low:      return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high:     return "xmark.shield.fill"
        }
    }
}

struct PredictionFactor: Identifiable {
    let id = UUID()
    let name: String
    let impact: FactorImpact   // positive or negative
    let weight: Double         // 0.0 to 1.0
    let description: String
}

enum FactorImpact {
    case positive
    case negative
    case neutral
}

/// On-device prediction engine using feature-based regression.
/// Phase 1: Rule-based statistical model (ships immediately).
/// Phase 2: Core ML TabularRegressor trained on accumulated user data.
@MainActor
enum HabitPredictionEngine {

    // MARK: - Predict Tomorrow

    /// Generate predictions for all active habits for tomorrow.
    static func predictTomorrow(habits: [Habit], moodEntries: [MoodEntry] = []) -> [HabitPrediction] {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
            return []
        }

        return habits
            .filter { !$0.isArchived && $0.frequency.isScheduled(for: tomorrow) }
            .map { predictForHabit($0, on: tomorrow, moodEntries: moodEntries) }
            .sorted { $0.successProbability < $1.successProbability } // Riskiest first
    }

    /// Generate prediction for a specific habit on a specific date.
    /// Uses the trained ML model when available, falls back to statistical model.
    static func predictForHabit(_ habit: Habit, on date: Date, moodEntries: [MoodEntry] = []) -> HabitPrediction {
        let features = extractFeatures(habit: habit, date: date, moodEntries: moodEntries)

        // Try trained model first, fall back to statistical
        let probability: Double
        if let mlProbability = CoreMLModelTrainer.shared.predictWithLearnedModel(
            habit: habit, on: date, moodEntries: moodEntries
        ) {
            probability = mlProbability
        } else {
            probability = calculateProbability(features: features)
        }
        let factors = buildFactors(features: features, habit: habit, date: date)
        let risk = riskLevel(from: probability)
        let action = suggestedAction(risk: risk, features: features, habit: habit)

        return HabitPrediction(
            habitID: habit.id,
            habitName: habit.name,
            habitIcon: habit.icon,
            habitColorHex: habit.colorHex,
            successProbability: probability,
            riskLevel: risk,
            factors: factors,
            suggestedAction: action
        )
    }

    // MARK: - Feature Extraction

    private struct HabitFeatures {
        let dayOfWeekRate: Double        // Historical completion rate for this weekday
        let currentStreak: Int           // Active streak count
        let recentRate7d: Double         // Last 7 days rate
        let recentRate3d: Double         // Last 3 days rate
        let recentTrend: Double          // Difference between recent and older rate
        let completedYesterday: Bool     // Did they complete yesterday
        let daysSinceLastCompletion: Int // Recency of last completion
        let moodAvgRecent: Double        // Average mood over last 3 entries (1-5, 0 if none)
        let habitAge: Int                // Days since habit was created
        let totalCompletions: Int        // Total historical completions
        let isWeekend: Bool              // Weekend day
    }

    private static func extractFeatures(habit: Habit, date: Date, moodEntries: [MoodEntry]) -> HabitFeatures {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetWeekday = calendar.component(.weekday, from: date)

        // Day of week completion rate (last 30 days)
        var dayScheduled = 0
        var dayCompleted = 0
        for offset in 0..<30 {
            guard let d = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let wd = calendar.component(.weekday, from: d)
            if wd == targetWeekday && habit.frequency.isScheduled(for: d) {
                dayScheduled += 1
                if habit.isCompleted(on: d) { dayCompleted += 1 }
            }
        }
        let dayOfWeekRate = dayScheduled > 0 ? Double(dayCompleted) / Double(dayScheduled) : 0.5

        // Recent rates
        let recentRate7d = StreakCalculator.completionRate(for: habit, days: 7)
        let recentRate3d = StreakCalculator.completionRate(for: habit, days: 3)

        // Older rate for trend
        let olderRate = completionRateForRange(habit: habit, startDaysAgo: 14, endDaysAgo: 7)
        let recentTrend = recentRate7d - olderRate

        // Yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let completedYesterday = habit.isCompleted(on: yesterday)

        // Days since last completion
        let daysSinceLastCompletion: Int = {
            let sortedCompletions = habit.completions
                .map { calendar.startOfDay(for: $0.completedDate) }
                .sorted(by: >)
            guard let lastDate = sortedCompletions.first else { return 999 }
            return calendar.dateComponents([.day], from: lastDate, to: today).day ?? 999
        }()

        // Mood average (recent 3 entries)
        let recentMoods = moodEntries
            .sorted { $0.date > $1.date }
            .prefix(3)
        let moodAvg = recentMoods.isEmpty ? 0.0 :
            Double(recentMoods.reduce(0) { $0 + $1.moodLevel }) / Double(recentMoods.count)

        // Habit age
        let habitAge = calendar.dateComponents([.day], from: habit.createdAt, to: today).day ?? 0

        // Weekend
        let isWeekend = targetWeekday == 1 || targetWeekday == 7

        return HabitFeatures(
            dayOfWeekRate: dayOfWeekRate,
            currentStreak: habit.currentStreak,
            recentRate7d: recentRate7d,
            recentRate3d: recentRate3d,
            recentTrend: recentTrend,
            completedYesterday: completedYesterday,
            daysSinceLastCompletion: daysSinceLastCompletion,
            moodAvgRecent: moodAvg,
            habitAge: habitAge,
            totalCompletions: habit.completions.count,
            isWeekend: isWeekend
        )
    }

    // MARK: - Probability Calculation (Statistical Model)

    private static func calculateProbability(features: HabitFeatures) -> Double {
        var score = 0.0
        var totalWeight = 0.0

        // Day-of-week historical rate (strongest predictor)
        let dowWeight = 3.0
        score += features.dayOfWeekRate * dowWeight
        totalWeight += dowWeight

        // Recent 3-day rate (strong short-term signal)
        let r3Weight = 2.5
        score += features.recentRate3d * r3Weight
        totalWeight += r3Weight

        // Recent 7-day rate
        let r7Weight = 2.0
        score += features.recentRate7d * r7Weight
        totalWeight += r7Weight

        // Streak momentum (active streak boosts prediction)
        let streakWeight = 1.5
        let streakFactor = min(Double(features.currentStreak) / 14.0, 1.0)
        score += streakFactor * streakWeight
        totalWeight += streakWeight

        // Yesterday's completion (habit chaining effect)
        let yesterdayWeight = 1.0
        score += (features.completedYesterday ? 1.0 : 0.0) * yesterdayWeight
        totalWeight += yesterdayWeight

        // Recency of last completion
        let recencyWeight = 1.0
        let recencyFactor: Double = {
            switch features.daysSinceLastCompletion {
            case 0...1: return 1.0
            case 2...3: return 0.7
            case 4...7: return 0.4
            default:    return 0.1
            }
        }()
        score += recencyFactor * recencyWeight
        totalWeight += recencyWeight

        // Trend boost/penalty
        let trendWeight = 1.0
        let trendFactor = max(0, min(1, 0.5 + features.recentTrend))
        score += trendFactor * trendWeight
        totalWeight += trendWeight

        // Mood factor (if available)
        if features.moodAvgRecent > 0 {
            let moodWeight = 0.8
            let moodFactor = (features.moodAvgRecent - 1.0) / 4.0 // normalize 1-5 to 0-1
            score += moodFactor * moodWeight
            totalWeight += moodWeight
        }

        // Habit maturity (older habits are more ingrained)
        let maturityWeight = 0.5
        let maturityFactor = min(Double(features.habitAge) / 60.0, 1.0)
        score += maturityFactor * maturityWeight
        totalWeight += maturityWeight

        let probability = totalWeight > 0 ? score / totalWeight : 0.5
        return max(0.0, min(1.0, probability))
    }

    // MARK: - Risk Level

    private static func riskLevel(from probability: Double) -> PredictionRisk {
        switch probability {
        case 0.7...: return .low
        case 0.4..<0.7: return .moderate
        default: return .high
        }
    }

    // MARK: - Factor Breakdown

    private static func buildFactors(features: HabitFeatures, habit: Habit, date: Date) -> [PredictionFactor] {
        var factors: [PredictionFactor] = []
        let calendar = Calendar.current
        let targetWeekday = calendar.component(.weekday, from: date)
        let dayName = StreakCalculator.weekdayName(for: targetWeekday)

        // Day of week
        let dowImpact: FactorImpact = features.dayOfWeekRate >= 0.7 ? .positive :
            features.dayOfWeekRate <= 0.3 ? .negative : .neutral
        factors.append(PredictionFactor(
            name: "\(dayName) history",
            impact: dowImpact,
            weight: features.dayOfWeekRate,
            description: "\(Int(features.dayOfWeekRate * 100))% completion on \(dayName)s"
        ))

        // Streak
        if features.currentStreak > 0 {
            factors.append(PredictionFactor(
                name: "Active streak",
                impact: .positive,
                weight: min(Double(features.currentStreak) / 14.0, 1.0),
                description: "\(features.currentStreak)-day streak provides momentum"
            ))
        }

        // Recent trend
        if features.recentTrend > 0.1 {
            factors.append(PredictionFactor(
                name: "Improving trend",
                impact: .positive,
                weight: min(features.recentTrend, 1.0),
                description: "Completion rate increasing recently"
            ))
        } else if features.recentTrend < -0.1 {
            factors.append(PredictionFactor(
                name: "Declining trend",
                impact: .negative,
                weight: min(abs(features.recentTrend), 1.0),
                description: "Completion rate decreasing recently"
            ))
        }

        // Yesterday
        factors.append(PredictionFactor(
            name: "Yesterday",
            impact: features.completedYesterday ? .positive : .negative,
            weight: features.completedYesterday ? 0.7 : 0.3,
            description: features.completedYesterday ?
                "Completed yesterday — momentum carries" :
                "Missed yesterday — harder to restart"
        ))

        // Mood
        if features.moodAvgRecent > 0 {
            let moodImpact: FactorImpact = features.moodAvgRecent >= 3.5 ? .positive :
                features.moodAvgRecent <= 2.5 ? .negative : .neutral
            factors.append(PredictionFactor(
                name: "Recent mood",
                impact: moodImpact,
                weight: (features.moodAvgRecent - 1) / 4.0,
                description: "Average mood: \(String(format: "%.1f", features.moodAvgRecent))/5"
            ))
        }

        // Sort by weight (most impactful first)
        return factors.sorted { $0.weight > $1.weight }
    }

    // MARK: - Suggested Actions

    private static func suggestedAction(risk: PredictionRisk, features: HabitFeatures, habit: Habit) -> String? {
        switch risk {
        case .high:
            if features.daysSinceLastCompletion > 3 {
                return "Start with just 2 minutes to rebuild the habit loop."
            }
            if features.recentTrend < -0.15 {
                return "Consider simplifying — do the minimum viable version."
            }
            return "Set a specific time and pair it with an existing routine."

        case .moderate:
            if features.currentStreak > 0 {
                return "Protect your \(features.currentStreak)-day streak — set an extra reminder."
            }
            if !features.completedYesterday {
                return "You missed yesterday — completing today will rebuild momentum."
            }
            return nil

        case .low:
            if features.currentStreak >= 7 {
                return "You're in a groove! Consider leveling up the difficulty."
            }
            return nil
        }
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
                if habit.isCompleted(on: date) { completed += 1 }
            }
        }

        guard scheduled > 0 else { return 0 }
        return Double(completed) / Double(scheduled)
    }
}
