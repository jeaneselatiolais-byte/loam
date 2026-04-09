//
//  QuickActionsManager.swift
//  Habitra
//
//  Phase 2 Week 3: Home screen 3D Touch / long-press quick actions
//

import UIKit

/// Manages dynamic home screen quick actions based on today's habits.
@MainActor
enum QuickActionsManager {

    enum ActionType: String {
        case addHabit = "com.jeanese.Habitra.addHabit"
        case viewStats = "com.jeanese.Habitra.viewStats"
        case quickAdd = "com.jeanese.Habitra.quickAdd"
    }

    /// Updates the dynamic shortcut items on the home screen icon.
    /// Call this when habits change or app enters background.
    static func updateShortcuts(todayProgress: String = "") {
        var shortcuts: [UIApplicationShortcutItem] = []

        shortcuts.append(UIApplicationShortcutItem(
            type: ActionType.addHabit.rawValue,
            localizedTitle: "New Habit",
            localizedSubtitle: "Create a new habit",
            icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill"),
            userInfo: nil
        ))

        shortcuts.append(UIApplicationShortcutItem(
            type: ActionType.viewStats.rawValue,
            localizedTitle: "View Stats",
            localizedSubtitle: todayProgress.isEmpty ? nil : todayProgress,
            icon: UIApplicationShortcutIcon(systemImageName: "chart.bar.fill"),
            userInfo: nil
        ))

        shortcuts.append(UIApplicationShortcutItem(
            type: ActionType.quickAdd.rawValue,
            localizedTitle: "Quick Add",
            localizedSubtitle: "Choose from templates",
            icon: UIApplicationShortcutIcon(systemImageName: "square.grid.2x2"),
            userInfo: nil
        ))

        UIApplication.shared.shortcutItems = shortcuts
    }
}
