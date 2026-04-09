//
//  LiveActivityManager.swift
//  Habitra
//
//  Manages Live Activities for habit timers.
//

import ActivityKit
import Foundation

@MainActor
@Observable
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private(set) var currentActivity: Activity<HabitTimerAttributes>?
    private(set) var isTimerRunning = false
    private(set) var activeHabitID: UUID?

    private var timer: Timer?

    private init() {}

    // MARK: - Start Timer

    /// Start a Live Activity timer for a habit session
    func startTimer(for habit: Habit, targetMinutes: Int = 10) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Habitra: Live Activities not enabled")
            return
        }

        // Stop any existing timer first
        if isTimerRunning {
            stopTimer()
        }

        let attributes = HabitTimerAttributes(
            habitName: habit.name,
            habitIcon: habit.icon,
            habitColorHex: habit.colorHex,
            targetMinutes: targetMinutes
        )

        let initialState = HabitTimerAttributes.ContentState(
            startedAt: Date(),
            elapsedSeconds: 0,
            isCompleted: false
        )

        let content = ActivityContent(state: initialState, staleDate: nil)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivity = activity
            isTimerRunning = true
            activeHabitID = habit.id
            startUpdateTimer(startedAt: Date())
            HapticManager.medium()
            print("Habitra: Live Activity started for \(habit.name)")
        } catch {
            print("Habitra: Failed to start Live Activity: \(error)")
        }
    }

    // MARK: - Stop Timer

    func stopTimer(completed: Bool = false) {
        guard let activity = currentActivity else { return }

        let finalState = HabitTimerAttributes.ContentState(
            startedAt: Date(),
            elapsedSeconds: 0,
            isCompleted: completed
        )

        let finalContent = ActivityContent(state: finalState, staleDate: nil)

        Task {
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }

        timer?.invalidate()
        timer = nil
        currentActivity = nil
        isTimerRunning = false
        activeHabitID = nil

        if completed {
            HapticManager.habitCompleted()
        } else {
            HapticManager.soft()
        }
    }

    // MARK: - Update Timer

    private func startUpdateTimer(startedAt: Date) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let activity = self.currentActivity else { return }

                let elapsed = Int(Date().timeIntervalSince(startedAt))
                let state = HabitTimerAttributes.ContentState(
                    startedAt: startedAt,
                    elapsedSeconds: elapsed,
                    isCompleted: false
                )

                let content = ActivityContent(state: state, staleDate: nil)
                await activity.update(content)
            }
        }
    }

    // MARK: - Helpers

    var isActivityAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
}
