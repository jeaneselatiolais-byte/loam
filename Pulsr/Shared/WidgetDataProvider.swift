//
//  WidgetDataProvider.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation
import WidgetKit

/// App Group identifier shared between main app and widget extension.
let appGroupID = "group.com.jeanese.Habitra"

/// Lightweight data structure for widget display.
/// Encoded to JSON in the shared App Group container.
struct WidgetHabitData: Codable, Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    let isCompletedToday: Bool
    let currentStreak: Int
    let weeklyRate: Double // 0.0 - 1.0
}

struct WidgetSnapshot: Codable {
    let habits: [WidgetHabitData]
    let todayProgress: Double // 0.0 - 1.0
    let todayCompleted: Int
    let todayTotal: Int
    let updatedAt: Date

    static let empty = WidgetSnapshot(
        habits: [],
        todayProgress: 0,
        todayCompleted: 0,
        todayTotal: 0,
        updatedAt: Date()
    )
}

/// Reads/writes widget data through the App Group shared container.
enum WidgetDataProvider {

    private static let fileName = "widget_data.json"

    private static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    private static var fileURL: URL? {
        sharedContainerURL?.appendingPathComponent(fileName)
    }

    // MARK: - Write (called from main app)

    /// Save current habit state for widgets to read.
    static func save(_ snapshot: WidgetSnapshot) {
        guard let url = fileURL else {
            print("Habitra: App Group container not available")
            return
        }

        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Habitra: Failed to write widget data: \(error)")
        }
    }

    /// Build and save a snapshot from current habits.
    @MainActor
    static func updateWidgets(habits: [Habit]) {
        let today = Date()
        let todaysHabits = habits.filter {
            !$0.isArchived && $0.frequency.isScheduled(for: today)
        }

        let widgetHabits = todaysHabits.map { habit in
            WidgetHabitData(
                id: habit.id,
                name: habit.name,
                icon: habit.icon,
                colorHex: habit.colorHex,
                isCompletedToday: habit.isCompleted(on: today),
                currentStreak: habit.currentStreak,
                weeklyRate: StreakCalculator.completionRate(for: habit, days: 7)
            )
        }

        let completed = todaysHabits.filter { $0.isCompleted(on: today) }.count
        let total = todaysHabits.count

        let snapshot = WidgetSnapshot(
            habits: widgetHabits,
            todayProgress: total > 0 ? Double(completed) / Double(total) : 0,
            todayCompleted: completed,
            todayTotal: total,
            updatedAt: Date()
        )

        save(snapshot)

        // Tell WidgetKit to refresh
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Read (called from widget extension)

    static func load() -> WidgetSnapshot {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else {
            return .empty
        }
        return snapshot
    }
}
