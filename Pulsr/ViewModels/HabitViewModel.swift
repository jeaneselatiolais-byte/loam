//
//  HabitViewModel.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class HabitViewModel {
    private let modelContext: ModelContext

    // Free tier limit
    static let freeHabitLimit = 5

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Queries

    /// All active (non-archived) habits, sorted by sortOrder
    func fetchActiveHabits() -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Habits scheduled for a specific date
    func habitsScheduled(for date: Date) -> [Habit] {
        fetchActiveHabits().filter { $0.frequency.isScheduled(for: date) }
    }

    /// Today's habits
    func todaysHabits() -> [Habit] {
        habitsScheduled(for: Date())
    }

    /// Today's completion progress (0.0 - 1.0)
    func todayProgress() -> Double {
        let habits = todaysHabits()
        guard !habits.isEmpty else { return 0 }
        let completed = habits.filter { $0.isCompleted(on: Date()) }.count
        return Double(completed) / Double(habits.count)
    }

    /// Count of active habits
    func activeHabitCount() -> Int {
        fetchActiveHabits().count
    }

    /// Whether the user can create more habits (free tier check)
    var canCreateHabit: Bool {
        SubscriptionManager.canCreateHabit(currentCount: activeHabitCount())
    }

    // MARK: - CRUD Operations

    func createHabit(
        name: String,
        icon: String,
        colorHex: String,
        frequency: HabitFrequency,
        reminderTime: Date?,
        reminderIntervalMinutes: Int = 0,
        category: HabitCategory?,
        targetCompletionsPerDay: Int = 1,
        healthKitSources: Set<HabitHealthSource> = [],
        minHealthKitDurationMinutes: Int = 15,
        healthKitStepGoal: Int = 7000
    ) {
        let sortOrder = activeHabitCount()
        let habit = Habit(
            name: name,
            icon: icon,
            colorHex: colorHex,
            frequency: frequency,
            reminderTime: reminderTime,
            sortOrder: sortOrder,
            category: category,
            targetCompletionsPerDay: targetCompletionsPerDay,
            healthKitSources: healthKitSources,
            minHealthKitDurationMinutes: minHealthKitDurationMinutes,
            healthKitStepGoal: healthKitStepGoal
        )
        habit.reminderIntervalMinutes = max(0, reminderIntervalMinutes)
        modelContext.insert(habit)
        save()
    }

    func updateHabit(
        _ habit: Habit,
        name: String,
        icon: String,
        colorHex: String,
        frequency: HabitFrequency,
        reminderTime: Date?,
        reminderIntervalMinutes: Int = 0,
        category: HabitCategory?,
        targetCompletionsPerDay: Int = 1,
        healthKitSources: Set<HabitHealthSource> = [],
        minHealthKitDurationMinutes: Int = 15,
        healthKitStepGoal: Int = 7000
    ) {
        habit.name = name
        habit.icon = icon
        habit.colorHex = colorHex
        habit.frequency = frequency
        habit.reminderTime = reminderTime
        habit.reminderIntervalMinutes = max(0, reminderIntervalMinutes)
        habit.category = category
        habit.targetCompletionsPerDay = max(1, targetCompletionsPerDay)
        habit.healthKitSources = healthKitSources
        habit.minHealthKitDurationMinutes = minHealthKitDurationMinutes
        habit.healthKitStepGoal = healthKitStepGoal
        save()
    }

    func archiveHabit(_ habit: Habit) {
        habit.isArchived = true
        save()
    }

    func restoreHabit(_ habit: Habit) {
        habit.isArchived = false
        habit.sortOrder = activeHabitCount()
        save()
    }

    func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        save()
    }

    /// All archived habits
    func fetchArchivedHabits() -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Completion Toggle

    func toggleCompletion(for habit: Habit, on date: Date = Date()) {
        if habit.isMultiCompletion {
            // Multi-completion: if fully completed, remove all for today; otherwise add one more
            if habit.isCompleted(on: date) {
                // Remove all completions for this date
                let calendar = Calendar.current
                let todayCompletions = habit.completions.filter {
                    calendar.isDate($0.completedDate, inSameDayAs: date)
                }
                for completion in todayCompletions {
                    modelContext.delete(completion)
                }
            } else {
                // Add one more completion toward the daily target
                let completion = HabitCompletion(completedDate: date, habit: habit)
                modelContext.insert(completion)
            }
        } else {
            // Single-completion: standard toggle
            if habit.isCompleted(on: date) {
                let calendar = Calendar.current
                if let completion = habit.completions.first(where: {
                    calendar.isDate($0.completedDate, inSameDayAs: date)
                }) {
                    modelContext.delete(completion)
                }
            } else {
                let completion = HabitCompletion(completedDate: date, habit: habit)
                modelContext.insert(completion)
            }
        }
        save()
    }

    // MARK: - Reorder

    func reorderHabits(_ habits: [Habit]) {
        for (index, habit) in habits.enumerated() {
            habit.sortOrder = index
        }
        save()
    }

    // MARK: - Stats

    /// Completion rate for a habit over the last N days
    func completionRate(for habit: Habit, days: Int = 7) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var scheduled = 0
        var completed = 0

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            if habit.frequency.isScheduled(for: date) {
                scheduled += 1
                if habit.isCompleted(on: date) {
                    completed += 1
                }
            }
        }

        guard scheduled > 0 else { return 0 }
        return Double(completed) / Double(scheduled)
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
            // Push updated data to widgets
            WidgetDataProvider.updateWidgets(habits: fetchActiveHabits())
        } catch {
            print("Habitra: Failed to save context: \(error)")
        }
    }
}
