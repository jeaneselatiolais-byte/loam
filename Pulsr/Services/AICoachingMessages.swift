//
//  AICoachingMessages.swift
//  Habitra
//
//  Phase 3 Week 10: Contextual AI coaching messages for the Today view
//

import Foundation

/// A contextual coaching message shown at the top of the Today view.
struct CoachingMessage: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let colorHex: String
    let type: CoachingMessageType
}

enum CoachingMessageType {
    case motivation
    case warning
    case celebration
    case tip
    case prediction
}

/// Generates contextual AI coaching messages based on current habit state.
@MainActor
enum AICoachingMessages {

    /// Generate the most relevant coaching message for right now.
    static func generateMessage(habits: [Habit], moodEntries: [MoodEntry] = []) -> CoachingMessage? {
        let activeHabits = habits.filter { !$0.isArchived }
        guard !activeHabits.isEmpty else { return nil }

        let todayHabits = activeHabits.filter { $0.frequency.isScheduled(for: Date()) }
        let completedCount = todayHabits.filter { $0.isCompleted(on: Date()) }.count
        let totalCount = todayHabits.count

        guard totalCount > 0 else { return nil }

        let progress = Double(completedCount) / Double(totalCount)
        let hour = Calendar.current.component(.hour, from: Date())

        // Priority-ordered message generation
        if let msg = allDoneMessage(progress: progress, totalCount: totalCount) { return msg }
        if let msg = streakDangerMessage(habits: todayHabits, hour: hour) { return msg }
        if let msg = almostDoneMessage(progress: progress, remaining: totalCount - completedCount) { return msg }
        if let msg = predictionMessage(habits: todayHabits, moodEntries: moodEntries) { return msg }
        if let msg = moodBasedMessage(moodEntries: moodEntries) { return msg }
        if let msg = timeBasedMessage(hour: hour, progress: progress, totalCount: totalCount) { return msg }
        if let msg = streakCelebration(habits: activeHabits) { return msg }

        return defaultMessage(progress: progress, completedCount: completedCount, totalCount: totalCount)
    }

    // MARK: - Message Generators

    private static func allDoneMessage(progress: Double, totalCount: Int) -> CoachingMessage? {
        guard progress >= 1.0 else { return nil }
        let messages = [
            "All \(totalCount) habits done! You're unstoppable today.",
            "Perfect day! Every habit checked off.",
            "100% completion — your future self thanks you.",
        ]
        return CoachingMessage(
            icon: "trophy.fill",
            text: messages.randomElement()!,
            colorHex: "4ADE80",
            type: .celebration
        )
    }

    private static func streakDangerMessage(habits: [Habit], hour: Int) -> CoachingMessage? {
        guard hour >= 17 else { return nil } // Evening only

        let atRisk = habits.filter { !$0.isCompleted(on: Date()) && $0.currentStreak >= 5 }
        guard let habit = atRisk.max(by: { $0.currentStreak < $1.currentStreak }) else { return nil }

        return CoachingMessage(
            icon: "flame.fill",
            text: "\(habit.name) has a \(habit.currentStreak)-day streak at risk. Don't let it break!",
            colorHex: "F87171",
            type: .warning
        )
    }

    private static func almostDoneMessage(progress: Double, remaining: Int) -> CoachingMessage? {
        guard progress >= 0.6 && progress < 1.0 && remaining <= 2 else { return nil }

        let word = remaining == 1 ? "habit" : "habits"
        return CoachingMessage(
            icon: "bolt.fill",
            text: "Just \(remaining) \(word) left — you're almost there!",
            colorHex: "6C63FF",
            type: .motivation
        )
    }

    private static func predictionMessage(habits: [Habit], moodEntries: [MoodEntry]) -> CoachingMessage? {
        let predictions = HabitPredictionEngine.predictTomorrow(habits: habits, moodEntries: moodEntries)
        guard let riskiest = predictions.first, riskiest.riskLevel == .high else { return nil }

        return CoachingMessage(
            icon: "chart.dots.scatter",
            text: "Tomorrow's forecast: \(riskiest.habitName) is at \(Int(riskiest.successProbability * 100))% chance. Plan ahead!",
            colorHex: "FBBF24",
            type: .prediction
        )
    }

    private static func moodBasedMessage(moodEntries: [MoodEntry]) -> CoachingMessage? {
        let today = Calendar.current.startOfDay(for: Date())
        guard let todayMood = moodEntries.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) else { return nil }

        let mood = MoodLevel(rawValue: todayMood.moodLevel) ?? .okay

        switch mood {
        case .terrible, .bad:
            return CoachingMessage(
                icon: "heart.fill",
                text: "Tough day? Even 2 minutes counts. Be kind to yourself.",
                colorHex: "F472B6",
                type: .tip
            )
        case .great:
            return CoachingMessage(
                icon: "sun.max.fill",
                text: "Great mood today! Channel that energy into your habits.",
                colorHex: "4ADE80",
                type: .motivation
            )
        default:
            return nil
        }
    }

    private static func timeBasedMessage(hour: Int, progress: Double, totalCount: Int) -> CoachingMessage? {
        switch hour {
        case 5..<9 where progress == 0:
            return CoachingMessage(
                icon: "sunrise.fill",
                text: "Fresh day, fresh start. \(totalCount) habits waiting for you.",
                colorHex: "FBBF24",
                type: .motivation
            )
        case 12..<14 where progress < 0.3:
            return CoachingMessage(
                icon: "clock.fill",
                text: "Afternoon check: most habits still open. A quick burst can turn this around.",
                colorHex: "FB923C",
                type: .tip
            )
        case 20..<24 where progress < 0.5:
            return CoachingMessage(
                icon: "moon.fill",
                text: "End of day — even completing one more habit builds the pattern.",
                colorHex: "7C73FF",
                type: .tip
            )
        default:
            return nil
        }
    }

    private static func streakCelebration(habits: [Habit]) -> CoachingMessage? {
        let bestStreak = habits.max(by: { $0.currentStreak < $1.currentStreak })
        guard let habit = bestStreak, habit.currentStreak >= 14 else { return nil }

        let milestones = [14, 21, 30, 50, 100, 200, 365]
        for m in milestones {
            if habit.currentStreak == m {
                return CoachingMessage(
                    icon: "star.fill",
                    text: "\(habit.name) just hit \(m) days! That's real discipline.",
                    colorHex: "6C63FF",
                    type: .celebration
                )
            }
        }
        return nil
    }

    private static func defaultMessage(progress: Double, completedCount: Int, totalCount: Int) -> CoachingMessage {
        if completedCount == 0 {
            return CoachingMessage(
                icon: "arrow.right.circle.fill",
                text: "Start with one. The first habit is always the hardest.",
                colorHex: "6C63FF",
                type: .motivation
            )
        }

        return CoachingMessage(
            icon: "checkmark.circle.fill",
            text: "\(completedCount) of \(totalCount) done. Keep the momentum going!",
            colorHex: "22D3EE",
            type: .motivation
        )
    }
}
