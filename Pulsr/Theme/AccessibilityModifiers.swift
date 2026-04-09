//
//  AccessibilityModifiers.swift
//  Habitra
//
//  Phase 2 Week 4: Accessibility labels, VoiceOver, and Dynamic Type
//  Updated: Comprehensive accessibility modifiers for all view patterns
//

import SwiftUI

// MARK: - Habit Row Accessibility

/// Makes a habit row fully accessible with combined label
struct HabitRowAccessibility: ViewModifier {
    let habitName: String
    let isCompleted: Bool
    let streakCount: Int
    let frequency: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(isCompleted ? "Double tap to uncomplete" : "Double tap to mark as complete")
            .accessibilityAddTraits(isCompleted ? .isSelected : [])
    }

    private var accessibilityLabel: String {
        let status = isCompleted ? "Completed" : "Not completed"
        let streak = streakCount > 0 ? ", \(streakCount) day streak" : ""
        return "\(habitName), \(frequency), \(status)\(streak)"
    }
}

/// Makes a progress ring announce its value
struct ProgressRingAccessibility: ViewModifier {
    let progress: Double
    let label: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

/// Makes a streak badge accessible
struct StreakBadgeAccessibility: ViewModifier {
    let count: Int

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(count > 0 ? "\(count) day streak" : "No streak")
    }
}

// MARK: - Stat Card Accessibility

/// Makes stat cards (icon + number + label) accessible as a single element
struct StatCardAccessibility: ViewModifier {
    let label: String
    let value: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(label), \(value)")
    }
}

// MARK: - Celebration Accessibility

/// Makes celebration overlays (milestones, badges, level-ups) accessible
struct CelebrationAccessibility: ViewModifier {
    let message: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(message)
            .accessibilityAddTraits(.isModal)
            .accessibilityHint("Double tap to dismiss")
    }
}

// MARK: - Insight Card Accessibility

/// Makes AI insight cards accessible
struct InsightCardAccessibility: ViewModifier {
    let title: String
    let detail: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title). \(detail)")
    }
}

// MARK: - Badge Item Accessibility

/// Makes badge grid items accessible
struct BadgeItemAccessibility: ViewModifier {
    let name: String
    let isEarned: Bool
    let detail: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(name), \(isEarned ? "earned" : "locked"). \(detail)")
    }
}

// MARK: - Mood Selector Accessibility

/// Makes mood emoji buttons accessible
struct MoodSelectorAccessibility: ViewModifier {
    let moodLabel: String
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(moodLabel)
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            .accessibilityHint(isSelected ? "Currently selected" : "Double tap to select")
    }
}

// MARK: - Section Header Accessibility

/// Adds header trait to section titles for VoiceOver navigation
struct SectionHeaderAccessibility: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Interactive Card Accessibility

/// Makes tappable cards that use onTapGesture accessible as buttons
struct InteractiveCardAccessibility: ViewModifier {
    let label: String
    let hint: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - View Extensions

extension View {
    func habitRowAccessibility(
        name: String,
        isCompleted: Bool,
        streakCount: Int,
        frequency: String
    ) -> some View {
        modifier(HabitRowAccessibility(
            habitName: name,
            isCompleted: isCompleted,
            streakCount: streakCount,
            frequency: frequency
        ))
    }

    func progressRingAccessibility(progress: Double, label: String = "Progress") -> some View {
        modifier(ProgressRingAccessibility(progress: progress, label: label))
    }

    func streakBadgeAccessibility(count: Int) -> some View {
        modifier(StreakBadgeAccessibility(count: count))
    }

    func statCardAccessibility(label: String, value: String) -> some View {
        modifier(StatCardAccessibility(label: label, value: value))
    }

    func celebrationAccessibility(message: String) -> some View {
        modifier(CelebrationAccessibility(message: message))
    }

    func insightCardAccessibility(title: String, detail: String) -> some View {
        modifier(InsightCardAccessibility(title: title, detail: detail))
    }

    func badgeItemAccessibility(name: String, isEarned: Bool, detail: String = "") -> some View {
        modifier(BadgeItemAccessibility(name: name, isEarned: isEarned, detail: detail))
    }

    func moodSelectorAccessibility(moodLabel: String, isSelected: Bool) -> some View {
        modifier(MoodSelectorAccessibility(moodLabel: moodLabel, isSelected: isSelected))
    }

    func sectionHeaderAccessibility() -> some View {
        modifier(SectionHeaderAccessibility())
    }

    func interactiveCardAccessibility(label: String, hint: String = "Double tap to open") -> some View {
        modifier(InteractiveCardAccessibility(label: label, hint: hint))
    }
}

// MARK: - Accessibility Announcement Helper

enum HabitraAccessibility {
    /// Post an accessibility announcement
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    /// Announce a habit completion
    static func announceCompletion(habitName: String, streak: Int) {
        let streakText = streak > 1 ? " \(streak) day streak!" : ""
        announce("\(habitName) completed.\(streakText)")
    }

    /// Announce a milestone
    static func announceMilestone(habitName: String, streak: Int) {
        announce("Milestone! \(habitName) reached a \(streak) day streak!")
    }
}
