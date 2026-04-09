//
//  WidgetDataProvider.swift
//  HabitraWidget
//
//  Shared data structures and reader for the widget extension.
//  This is a copy of the shared types needed by the widget target.
//

import Foundation

/// App Group identifier shared between main app and widget extension.
let appGroupID = "group.com.jeanese.Habitra"

/// Lightweight data structure for widget display.
struct WidgetHabitData: Codable, Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    let isCompletedToday: Bool
    let currentStreak: Int
    let weeklyRate: Double
}

struct WidgetSnapshot: Codable {
    let habits: [WidgetHabitData]
    let todayProgress: Double
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

/// Reads widget data from the App Group shared container.
enum WidgetDataReader {

    private static let fileName = "widget_data.json"

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(fileName)
    }

    static func load() -> WidgetSnapshot {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else {
            return .empty
        }

        // If the snapshot was written on a previous day, the completion data is stale.
        // Reset completions so widgets show today's fresh state (all incomplete).
        let calendar = Calendar.current
        if !calendar.isDateInToday(snapshot.updatedAt) {
            let resetHabits = snapshot.habits.map { habit in
                WidgetHabitData(
                    id: habit.id,
                    name: habit.name,
                    icon: habit.icon,
                    colorHex: habit.colorHex,
                    isCompletedToday: false,
                    currentStreak: habit.currentStreak,
                    weeklyRate: habit.weeklyRate
                )
            }
            return WidgetSnapshot(
                habits: resetHabits,
                todayProgress: 0,
                todayCompleted: 0,
                todayTotal: snapshot.todayTotal,
                updatedAt: snapshot.updatedAt
            )
        }

        return snapshot
    }

    /// Returns the start of the next calendar day, for scheduling a midnight timeline refresh.
    static func startOfNextDay() -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
        return tomorrow ?? Date(timeIntervalSinceNow: 3600)
    }
}
