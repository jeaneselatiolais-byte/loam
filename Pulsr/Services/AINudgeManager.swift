//
//  AINudgeManager.swift
//  Habitra
//
//  Phase 3 Week 8: Smart AI nudge notifications based on pattern detection
//

import Foundation
@preconcurrency import UserNotifications

/// Schedules intelligent nudge notifications based on detected patterns.
/// All processing is on-device — zero network requests.
@MainActor
final class AINudgeManager {
    static let shared = AINudgeManager()

    private let nudgeCategoryID = "HABITRA_AI_NUDGE"
    private let maxNudgesPerDay = 2

    private init() {}

    // MARK: - Schedule Nudges Based on Insights

    /// Analyze habits and schedule appropriate nudge notifications.
    func scheduleSmartNudges(habits: [Habit], moodEntries: [MoodEntry] = []) {
        guard SubscriptionManager.canUseAINudges else { return }

        let insights = PatternDetectionEngine.generateInsights(
            habits: habits,
            moodEntries: moodEntries
        )

        // Remove old AI nudges
        removeAllNudges()

        // Pick top nudges to schedule
        let topInsights = insights
            .filter { $0.priority >= .medium }
            .prefix(maxNudgesPerDay)

        for (index, insight) in topInsights.enumerated() {
            scheduleNudge(for: insight, delayMinutes: 30 + (index * 60))
        }

        // Schedule streak danger nudges for evening
        let dangerInsights = insights.filter { $0.type == .streakDanger }
        for insight in dangerInsights.prefix(2) {
            scheduleStreakDangerNudge(for: insight)
        }

        // Schedule predictive failure alerts for tomorrow's at-risk habits
        let predictions = HabitPredictionEngine.predictTomorrow(
            habits: habits,
            moodEntries: moodEntries
        )
        let highRisk = predictions.filter { $0.riskLevel == .high }
        for prediction in highRisk.prefix(2) {
            schedulePredictiveAlert(for: prediction)
        }
    }

    // MARK: - Schedule Individual Nudge

    private func scheduleNudge(for insight: HabitInsight, delayMinutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = nudgeTitle(for: insight)
        content.body = insight.message
        content.sound = .default
        content.categoryIdentifier = nudgeCategoryID
        content.userInfo = [
            "type": "ai_nudge",
            "insightType": insight.type.rawValue,
            "habitName": insight.habitName
        ]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(delayMinutes * 60),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "habitra_nudge_\(insight.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Habitra: Failed to schedule nudge: \(error)")
            }
        }
    }

    private func scheduleStreakDangerNudge(for insight: HabitInsight) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak at risk!"
        content.body = insight.message
        content.sound = .default
        content.categoryIdentifier = nudgeCategoryID
        content.interruptionLevel = .timeSensitive

        // Schedule for 8 PM today
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: "habitra_streak_danger_\(insight.habitName)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Habitra: Failed to schedule streak danger nudge: \(error)")
            }
        }
    }

    private func schedulePredictiveAlert(for prediction: HabitPrediction) {
        let content = UNMutableNotificationContent()
        content.title = "📊 Tomorrow's heads up"
        content.body = "\(prediction.habitName) is at \(Int(prediction.successProbability * 100))% success chance tomorrow. \(prediction.suggestedAction ?? "Plan ahead to stay on track.")"
        content.sound = .default
        content.categoryIdentifier = nudgeCategoryID

        // Schedule for 9 PM tonight
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = 21
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: "habitra_predict_\(prediction.habitID.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Habitra: Failed to schedule predictive alert: \(error)")
            }
        }
    }

    // MARK: - Weekly Recap Notification

    /// Schedule a weekly recap notification for Sunday evening.
    func scheduleWeeklyRecapReminder() {
        let content = UNMutableNotificationContent()
        content.title = "📋 Your weekly recap is ready"
        content.body = "See how your habits performed this week. Open the Coach tab for your AI-generated summary."
        content.sound = .default
        content.categoryIdentifier = nudgeCategoryID

        // Sunday at 7 PM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 19
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "habitra_weekly_recap",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Habitra: Failed to schedule weekly recap: \(error)")
            }
        }
    }

    // MARK: - Remove Nudges

    func removeAllNudges() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let nudgeIDs = requests
                .filter { $0.identifier.hasPrefix("habitra_nudge_") || $0.identifier.hasPrefix("habitra_streak_danger_") || $0.identifier.hasPrefix("habitra_predict_") }
                .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: nudgeIDs)
        }
    }

    // MARK: - Helpers

    private func nudgeTitle(for insight: HabitInsight) -> String {
        switch insight.type {
        case .atRisk:       return "📊 Pattern detected"
        case .streakDanger: return "🔥 Streak at risk!"
        case .improvement:  return "📈 You're improving!"
        case .decline:      return "💡 Heads up"
        case .correlation:  return "🔗 Habit connection"
        case .suggestion:   return "💡 Quick tip"
        case .bestDay:      return "⭐ Your power day"
        case .worstDay:     return "🎯 Room to grow"
        case .milestone:    return "🎉 Milestone!"
        case .weeklyRecap:  return "📋 Your weekly recap"
        }
    }
}
