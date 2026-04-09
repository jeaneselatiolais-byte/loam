//
//  HealthAutoCompleteService.swift
//  Habitra
//
//  Checks today's Apple Health data (workouts, mindfulness, sleep, steps)
//  against each habit's linked HealthKit source and auto-completes matching
//  habits that haven't been logged yet.
//
//  Called on app launch and whenever the app returns to the foreground.
//  Requires HealthKit Pro entitlement (SubscriptionManager.canUseHealthKit).
//
//  Background delivery (auto-complete without opening the app) requires
//  the "Background Modes → Background fetch" capability and the
//  com.apple.developer.healthkit.background-delivery entitlement, which
//  can be added as a future enhancement.
//

import Foundation
import SwiftData
import HealthKit

@MainActor
final class HealthAutoCompleteService {
    static let shared = HealthAutoCompleteService()
    private init() {}

    // Tracks auto-completed habit names so TodayView can display a banner.
    private(set) var lastAutoCompletedNames: [String] = []

    // MARK: - Run

    /// Check HealthKit data for today and auto-complete matching habits.
    /// Safe to call multiple times — skips habits already completed today.
    func run(context: ModelContext) async {
        guard SubscriptionManager.canUseHealthKit else { return }
        guard HealthKitManager.shared.isAuthorized else { return }

        let hk = HealthKitManager.shared
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return }

        // Fetch habits that have a HealthKit source configured.
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived && $0.healthKitSourceRaw != "" }
        )
        guard let habits = try? context.fetch(descriptor), !habits.isEmpty else { return }

        // Batch-fetch all HealthKit data we might need (only fetch what's necessary).
        let neededSources = habits.reduce(into: Set<HabitHealthSource>()) { result, habit in
            result.formUnion(habit.healthKitSources)
        }
        let needsWorkouts = neededSources.contains(where: { $0.isWorkoutBased || $0 == .anyWorkout })

        async let workoutsTask   = needsWorkouts
            ? hk.fetchWorkouts(start: today, end: tomorrow)
            : [] as [HKWorkout]

        async let mindfulTask    = neededSources.contains(.mindfulness)
            ? hk.fetchMindfulMinutes(start: today, end: tomorrow)
            : 0.0

        async let sleepTask      = neededSources.contains(.sleep)
            ? hk.fetchSleepHoursPublic(start: today, end: tomorrow)
            : 0.0

        async let stepsTask      = neededSources.contains(.steps)
            ? hk.fetchStepCount(start: today, end: tomorrow)
            : 0

        let (workouts, mindfulMinutes, sleepHours, stepCount) =
            await (workoutsTask, mindfulTask, sleepTask, stepsTask)

        var autoCompleted: [String] = []
        var didInsert = false

        for habit in habits {
            guard habit.frequency.isScheduled(for: today) else { continue }
            guard !habit.isCompleted(on: today) else { continue }

            let sources = habit.healthKitSources
            guard !sources.isEmpty else { continue }
            let minMinutes = Double(habit.minHealthKitDurationMinutes)
            var matched = false

            // Check non-workout sources (single-select, so at most one of these)
            if sources.contains(.mindfulness) && mindfulMinutes >= minMinutes {
                insertCompletion(for: habit, on: today, workoutUUID: nil, context: context)
                matched = true
            } else if sources.contains(.sleep) {
                let requiredHours = minMinutes / 60.0
                if sleepHours >= requiredHours {
                    insertCompletion(for: habit, on: today, workoutUUID: nil, context: context)
                    matched = true
                }
            } else if sources.contains(.steps) {
                if stepCount >= habit.healthKitStepGoal {
                    insertCompletion(for: habit, on: today, workoutUUID: nil, context: context)
                    matched = true
                }
            } else if sources.contains(.anyWorkout) {
                // Any Workout — sum durations across ALL workouts for today
                let totalMinutes = workouts.reduce(0.0) { $0 + $1.duration / 60.0 }
                if totalMinutes >= minMinutes {
                    let longest = workouts.max(by: { $0.duration < $1.duration })
                    insertCompletion(for: habit, on: today,
                                     workoutUUID: longest?.uuid.uuidString, context: context)
                    matched = true
                }
            } else {
                // Specific workout types — sum durations across matching workouts
                let allTypes = sources
                    .filter { $0.isWorkoutBased }
                    .flatMap { $0.workoutActivityTypes }
                if !allTypes.isEmpty {
                    let typeSet = Set(allTypes)
                    let matching = workouts.filter { typeSet.contains($0.workoutActivityType) }
                    let totalMinutes = matching.reduce(0.0) { $0 + $1.duration / 60.0 }
                    if totalMinutes >= minMinutes {
                        let longest = matching.max(by: { $0.duration < $1.duration })
                        insertCompletion(for: habit, on: today,
                                         workoutUUID: longest?.uuid.uuidString, context: context)
                        matched = true
                    }
                }
            }

            if matched {
                autoCompleted.append(habit.name)
                didInsert = true
            }
        }

        if didInsert {
            try? context.save()
            WidgetDataProvider.updateWidgets(
                habits: (try? context.fetch(FetchDescriptor<Habit>(
                    predicate: #Predicate { !$0.isArchived }))) ?? []
            )
        }

        lastAutoCompletedNames = autoCompleted
    }

    // MARK: - Private

    private func insertCompletion(for habit: Habit, on date: Date,
                                   workoutUUID: String?, context: ModelContext) {
        let completion = HabitCompletion(
            completedDate: date,
            habit: habit,
            completionSource: "healthKit",
            healthKitWorkoutUUID: workoutUUID
        )
        context.insert(completion)
        StreakCache.shared.invalidate(habitID: habit.id)
        HapticManager.habitCompleted()
    }
}
