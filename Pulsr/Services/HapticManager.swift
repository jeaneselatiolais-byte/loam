//
//  HapticManager.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import UIKit

/// Centralized haptic feedback for consistent feel across the app.
enum HapticManager {

    // MARK: - Standard Feedback

    /// Light tap — toggling switches, selecting options
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium tap — completing a habit, pressing a button
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy tap — important actions, archiving, deleting
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Soft tap — subtle interactions, scrolling detents
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success — habit completed, streak milestone
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning — approaching habit limit, streak at risk
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error — failed action, validation error
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection

    /// Selection tick — scrolling through pickers, reordering
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Habit-Specific Patterns

    /// Completion celebration — double-tap pattern for completing a habit
    static func habitCompleted() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let light = UIImpactFeedbackGenerator(style: .light)
            light.impactOccurred()
        }
    }

    /// Streak milestone — triple tap for streak achievements (7, 30, 100 days)
    static func streakMilestone() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }

    /// Undo completion — single soft tap
    static func habitUncompleted() {
        soft()
    }

    // MARK: - Gamification Patterns

    /// XP gained — lightweight feedback
    static func xpGained() {
        light()
    }

    /// Quest completed — reuse streak milestone triple-tap
    static func questCompleted() {
        streakMilestone()
    }

    /// Collection completed — double success notification
    static func collectionCompleted() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
        }
    }

    /// Level up — heavy impact + success
    static func levelUp() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
        }
    }
}
