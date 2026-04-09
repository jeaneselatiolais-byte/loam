//
//  HabitHealthScorer.swift
//  Habitra
//
//  Phase 3 Week 10: Overall habit health scoring system
//  Combines multiple signals into a single 0-100 "health score" per habit.
//

import Foundation

/// Health score for a single habit.
struct HabitHealthScore: Identifiable {
    let id: UUID
    let habitName: String
    let habitIcon: String
    let habitColorHex: String
    let score: Int              // 0-100
    let grade: HealthGrade
    let components: [ScoreComponent]
    let trend: ScoreTrend
    let summary: String
}

enum HealthGrade: String {
    case excellent = "A+"
    case great = "A"
    case good = "B"
    case fair = "C"
    case poor = "D"
    case critical = "F"

    var colorHex: String {
        switch self {
        case .excellent, .great: return "4ADE80"
        case .good:              return "22D3EE"
        case .fair:              return "FBBF24"
        case .poor:              return "FB923C"
        case .critical:          return "F87171"
        }
    }
}

enum ScoreTrend {
    case improving
    case stable
    case declining

    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable:    return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    var colorHex: String {
        switch self {
        case .improving: return "4ADE80"
        case .stable:    return "FBBF24"
        case .declining: return "F87171"
        }
    }
}

struct ScoreComponent {
    let name: String
    let score: Double   // 0-1
    let weight: Double  // 0-1
    let detail: String
}

/// Calculates a holistic health score for each habit.
@MainActor
enum HabitHealthScorer {

    // MARK: - Score All Habits

    static func scoreAll(habits: [Habit], moodEntries: [MoodEntry] = []) -> [HabitHealthScore] {
        habits
            .filter { !$0.isArchived }
            .map { scoreHabit($0, moodEntries: moodEntries) }
            .sorted { $0.score > $1.score }
    }

    // MARK: - Score Single Habit

    static func scoreHabit(_ habit: Habit, moodEntries: [MoodEntry] = []) -> HabitHealthScore {
        var components: [ScoreComponent] = []

        // 1. Consistency (30% weight) — 7-day completion rate
        let consistency = StreakCalculator.completionRate(for: habit, days: 7)
        components.append(ScoreComponent(
            name: "Consistency",
            score: consistency,
            weight: 0.30,
            detail: "\(Int(consistency * 100))% last 7 days"
        ))

        // 2. Momentum (25% weight) — current streak relative to longest
        let streakScore: Double = {
            let current = Double(habit.currentStreak)
            let longest = Double(max(habit.longestStreak, 1))
            return min(current / longest, 1.0)
        }()
        components.append(ScoreComponent(
            name: "Momentum",
            score: streakScore,
            weight: 0.25,
            detail: "\(habit.currentStreak) day streak"
        ))

        // 3. Reliability (20% weight) — 30-day rate
        let reliability = StreakCalculator.completionRate(for: habit, days: 30)
        components.append(ScoreComponent(
            name: "Reliability",
            score: reliability,
            weight: 0.20,
            detail: "\(Int(reliability * 100))% last 30 days"
        ))

        // 4. Trend (15% weight) — improving vs declining
        let recentRate = StreakCalculator.completionRate(for: habit, days: 7)
        let olderRate = completionRateForRange(habit: habit, startDaysAgo: 14, endDaysAgo: 7)
        let trendScore: Double = {
            let diff = recentRate - olderRate
            return max(0, min(1, 0.5 + diff))
        }()
        components.append(ScoreComponent(
            name: "Trend",
            score: trendScore,
            weight: 0.15,
            detail: trendScore > 0.55 ? "Improving" : trendScore < 0.45 ? "Declining" : "Stable"
        ))

        // 5. Engagement (10% weight) — total completions relative to age
        let habitAge = max(Calendar.current.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 1, 1)
        let scheduledDays = habit.frequency.scheduledDays.count
        let expectedCompletions = Double(habitAge) * Double(scheduledDays) / 7.0
        let engagement = expectedCompletions > 0 ?
            min(Double(habit.completions.count) / expectedCompletions, 1.0) : 0
        components.append(ScoreComponent(
            name: "Engagement",
            score: engagement,
            weight: 0.10,
            detail: "\(habit.completions.count) total completions"
        ))

        // Calculate weighted score
        let weightedScore = components.reduce(0.0) { $0 + $1.score * $1.weight }
        let score = Int(weightedScore * 100)

        // Determine grade
        let grade = gradeFromScore(score)

        // Determine trend
        let trend: ScoreTrend = {
            let diff = recentRate - olderRate
            if diff > 0.05 { return .improving }
            if diff < -0.05 { return .declining }
            return .stable
        }()

        // Build summary
        let summary = buildSummary(habit: habit, score: score, grade: grade, trend: trend, components: components)

        return HabitHealthScore(
            id: habit.id,
            habitName: habit.name,
            habitIcon: habit.icon,
            habitColorHex: habit.colorHex,
            score: score,
            grade: grade,
            components: components,
            trend: trend,
            summary: summary
        )
    }

    // MARK: - Overall Score

    /// Average health score across all active habits.
    static func overallScore(habits: [Habit]) -> Int {
        let scores = scoreAll(habits: habits)
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0) { $0 + $1.score } / scores.count
    }

    // MARK: - Helpers

    private static func gradeFromScore(_ score: Int) -> HealthGrade {
        switch score {
        case 90...: return .excellent
        case 80..<90: return .great
        case 65..<80: return .good
        case 50..<65: return .fair
        case 30..<50: return .poor
        default: return .critical
        }
    }

    private static func buildSummary(habit: Habit, score: Int, grade: HealthGrade, trend: ScoreTrend, components: [ScoreComponent]) -> String {
        let weakest = components.min(by: { $0.score < $1.score })

        switch grade {
        case .excellent, .great:
            return "\(habit.name) is thriving! Keep doing what you're doing."
        case .good:
            if let weak = weakest, weak.score < 0.6 {
                return "Solid performance. \(weak.name) could use attention — \(weak.detail)."
            }
            return "Good progress. A few more consistent days will push this higher."
        case .fair:
            return "Room to grow. Focus on building a streak to gain momentum."
        case .poor, .critical:
            return "This habit needs attention. Try simplifying it or setting a reminder."
        }
    }

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
