//
//  HealthHabitCorrelator.swift
//  Habitra
//
//  Phase 4: Correlate HealthKit data with habit completion patterns
//  "Your workout habit is 40% more likely when you sleep 7+ hrs"
//

import Foundation

/// A correlation between a health metric and habit completion.
struct HealthCorrelation: Identifiable {
    let id = UUID()
    let habitName: String
    let habitIcon: String
    let habitColorHex: String
    let metricName: String
    let metricIcon: String
    let insight: String
    let correlation: Double        // -1 to 1
    let highMetricRate: Double     // completion rate when metric is high
    let lowMetricRate: Double      // completion rate when metric is low
    let difference: Double         // highMetricRate - lowMetricRate
}

/// Analyzes how health metrics affect habit completion.
@MainActor
enum HealthHabitCorrelator {

    // MARK: - Analyze All

    /// Generate health-habit correlations for all active habits.
    static func analyze(habits: [Habit], healthData: [DailyHealthData]) -> [HealthCorrelation] {
        guard healthData.count >= 7 else { return [] }

        var correlations: [HealthCorrelation] = []

        for habit in habits where !habit.isArchived {
            correlations.append(contentsOf: analyzeHabit(habit, healthData: healthData))
        }

        return correlations
            .filter { abs($0.difference) >= 0.1 } // Only meaningful differences
            .sorted { abs($0.difference) > abs($1.difference) }
    }

    // MARK: - Per-Habit Analysis

    private static func analyzeHabit(_ habit: Habit, healthData: [DailyHealthData]) -> [HealthCorrelation] {
        let calendar = Calendar.current
        var correlations: [HealthCorrelation] = []

        // Build paired data (health + completion for each day)
        let pairs: [(health: DailyHealthData, completed: Bool)] = healthData.compactMap { data in
            let date = calendar.startOfDay(for: data.date)
            guard habit.frequency.isScheduled(for: date) else { return nil }
            return (data, habit.isCompleted(on: date))
        }

        guard pairs.count >= 7 else { return [] }

        // Steps correlation
        if let corr = analyzeMetric(
            habit: habit,
            pairs: pairs,
            metricName: "Steps",
            metricIcon: "figure.walk",
            getValue: { Double($0.steps) },
            threshold: 7000
        ) {
            correlations.append(corr)
        }

        // Sleep correlation
        if let corr = analyzeMetric(
            habit: habit,
            pairs: pairs,
            metricName: "Sleep",
            metricIcon: "bed.double.fill",
            getValue: { $0.sleepHours },
            threshold: 7.0
        ) {
            correlations.append(corr)
        }

        // Active energy correlation
        if let corr = analyzeMetric(
            habit: habit,
            pairs: pairs,
            metricName: "Activity",
            metricIcon: "flame.fill",
            getValue: { $0.activeEnergy },
            threshold: 300
        ) {
            correlations.append(corr)
        }

        // HRV correlation (higher = better recovery)
        let withHRV = pairs.filter { $0.health.hrv != nil }
        if withHRV.count >= 5 {
            if let corr = analyzeMetric(
                habit: habit,
                pairs: withHRV,
                metricName: "HRV",
                metricIcon: "heart.fill",
                getValue: { $0.hrv ?? 0 },
                threshold: 40
            ) {
                correlations.append(corr)
            }
        }

        return correlations
    }

    // MARK: - Metric Analysis

    private static func analyzeMetric(
        habit: Habit,
        pairs: [(health: DailyHealthData, completed: Bool)],
        metricName: String,
        metricIcon: String,
        getValue: (DailyHealthData) -> Double,
        threshold: Double
    ) -> HealthCorrelation? {
        let highDays = pairs.filter { getValue($0.health) >= threshold }
        let lowDays = pairs.filter { getValue($0.health) < threshold }

        guard highDays.count >= 3, lowDays.count >= 3 else { return nil }

        let highRate = Double(highDays.filter(\.completed).count) / Double(highDays.count)
        let lowRate = Double(lowDays.filter(\.completed).count) / Double(lowDays.count)
        let diff = highRate - lowRate

        guard abs(diff) >= 0.1 else { return nil }

        // Pearson correlation
        let values = pairs.map { getValue($0.health) }
        let completions = pairs.map { $0.completed ? 1.0 : 0.0 }
        let pearson = pearsonCorrelation(x: values, y: completions)

        let insight = buildInsight(
            habitName: habit.name,
            metricName: metricName,
            diff: diff,
            threshold: threshold,
            highRate: highRate,
            lowRate: lowRate
        )

        return HealthCorrelation(
            habitName: habit.name,
            habitIcon: habit.icon,
            habitColorHex: habit.colorHex,
            metricName: metricName,
            metricIcon: metricIcon,
            insight: insight,
            correlation: pearson,
            highMetricRate: highRate,
            lowMetricRate: lowRate,
            difference: diff
        )
    }

    // MARK: - Insight Builder

    private static func buildInsight(
        habitName: String,
        metricName: String,
        diff: Double,
        threshold: Double,
        highRate: Double,
        lowRate: Double
    ) -> String {
        let pct = Int(abs(diff) * 100)
        let thresholdStr: String

        switch metricName {
        case "Steps": thresholdStr = "\(Int(threshold))+ steps"
        case "Sleep": thresholdStr = "\(Int(threshold))+ hrs of sleep"
        case "Activity": thresholdStr = "\(Int(threshold))+ kcal active energy"
        case "HRV": thresholdStr = "\(Int(threshold))+ ms HRV"
        default: thresholdStr = "higher \(metricName)"
        }

        if diff > 0 {
            return "\(habitName) is \(pct)% more likely when you get \(thresholdStr). (\(Int(highRate * 100))% vs \(Int(lowRate * 100))%)"
        } else {
            return "\(habitName) is \(pct)% less likely on high \(metricName.lowercased()) days. (\(Int(highRate * 100))% vs \(Int(lowRate * 100))%)"
        }
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
        let num = n * sumXY - sumX * sumY
        let den = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))
        guard den > 0 else { return 0 }
        return num / den
    }
}
