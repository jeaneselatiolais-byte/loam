//
//  NotificationManager.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Foreground Delivery

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Habitra: Notification permission error: \(error)")
            return false
        }
    }

    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: - Schedule (public entry point)

    /// Schedule notifications for a habit. Dispatches to single or interval scheduling.
    func scheduleReminder(for habit: Habit) {
        guard habit.reminderTime != nil else { return }

        Task {
            var authorized = await isAuthorized()
            if !authorized { authorized = await requestPermission() }
            guard authorized else { return }

            await removeReminderAsync(for: habit)

            if habit.reminderIntervalMinutes > 0 && habit.targetCompletionsPerDay > 1 {
                await scheduleIntervalReminders(for: habit)
            } else {
                await scheduleSingleReminder(for: habit)
            }
        }
    }

    // MARK: - Single Reminder (once/day)

    private func scheduleSingleReminder(for habit: Habit) async {
        guard let reminderTime = habit.reminderTime else { return }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderTime)
        let minute = calendar.component(.minute, from: reminderTime)
        let scheduledDays = habit.frequency.scheduledDays

        for weekday in scheduledDays {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            components.weekday = weekday

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let content = UNMutableNotificationContent()
            content.title = "Time for \(habit.name)"
            content.body = reminderBody(for: habit)
            content.sound = .default
            content.categoryIdentifier = "HABIT_REMINDER"
            content.threadIdentifier = habit.id.uuidString

            let request = UNNotificationRequest(
                identifier: singleNotificationID(for: habit, weekday: weekday),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    // MARK: - Interval Reminders (multi-completion)

    /// Schedules one notification per completion slot per scheduled weekday.
    /// Slots start at reminderTime and repeat every reminderIntervalMinutes.
    /// Maximum 20 slots to stay well within iOS's 64-notification cap.
    private func scheduleIntervalReminders(for habit: Habit) async {
        guard let startTime = habit.reminderTime,
              habit.reminderIntervalMinutes > 0 else { return }

        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let intervalMins = habit.reminderIntervalMinutes
        let slotCount = min(habit.targetCompletionsPerDay, 20)
        let scheduledDays = habit.frequency.scheduledDays

        // Build the time slots for one day
        var slots: [(hour: Int, minute: Int)] = []
        var totalMinutes = startHour * 60 + startMinute
        for _ in 0..<slotCount {
            let h = (totalMinutes / 60) % 24
            let m = totalMinutes % 60
            slots.append((h, m))
            totalMinutes += intervalMins
        }

        for weekday in scheduledDays {
            for (index, slot) in slots.enumerated() {
                var components = DateComponents()
                components.hour = slot.hour
                components.minute = slot.minute
                components.weekday = weekday

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                let content = UNMutableNotificationContent()
                content.title = habit.name
                content.body = intervalReminderBody(slot: index + 1, total: slotCount, habit: habit)
                content.sound = .default
                content.categoryIdentifier = "HABIT_REMINDER"
                content.threadIdentifier = habit.id.uuidString

                let request = UNNotificationRequest(
                    identifier: intervalNotificationID(for: habit, weekday: weekday, slot: index),
                    content: content,
                    trigger: trigger
                )
                try? await center.add(request)
            }
        }
    }

    // MARK: - Remove

    func removeReminder(for habit: Habit) {
        center.removePendingNotificationRequests(withIdentifiers: allNotificationIDs(for: habit))
    }

    private func removeReminderAsync(for habit: Habit) async {
        center.removePendingNotificationRequests(withIdentifiers: allNotificationIDs(for: habit))
        try? await Task.sleep(for: .milliseconds(100))
    }

    func removeAllReminders() {
        center.removeAllPendingNotificationRequests()
    }

    func rescheduleAll(habits: [Habit]) {
        removeAllReminders()
        for habit in habits where habit.reminderTime != nil && !habit.isArchived {
            scheduleReminder(for: habit)
        }
    }

    // MARK: - Test

    func scheduleTestNotification() {
        Task {
            var authorized = await isAuthorized()
            if !authorized { authorized = await requestPermission() }
            guard authorized else { return }

            let content = UNMutableNotificationContent()
            content.title = "Habitra"
            content.body = "Notifications are working! 🎉"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(
                identifier: "habitra.test.\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    // MARK: - Diagnostics

    func pendingNotificationCount() async -> Int {
        await center.pendingNotificationRequests().count
    }

    func printPendingNotifications() async {
        let requests = await center.pendingNotificationRequests()
        print("Habitra: \(requests.count) pending notifications:")
        for req in requests {
            if let trigger = req.trigger as? UNCalendarNotificationTrigger {
                print("  - \(req.identifier): \(req.content.title) at \(trigger.dateComponents)")
            }
        }
    }

    // MARK: - Private Helpers

    private func singleNotificationID(for habit: Habit, weekday: Int) -> String {
        "habitra.habit.\(habit.id.uuidString).day\(weekday)"
    }

    private func intervalNotificationID(for habit: Habit, weekday: Int, slot: Int) -> String {
        "habitra.habit.\(habit.id.uuidString).day\(weekday).slot\(slot)"
    }

    private func allNotificationIDs(for habit: Habit) -> [String] {
        let single = (1...7).map { singleNotificationID(for: habit, weekday: $0) }
        let interval = (1...7).flatMap { weekday in
            (0..<20).map { slot in intervalNotificationID(for: habit, weekday: weekday, slot: slot) }
        }
        return single + interval
    }

    private func reminderBody(for habit: Habit) -> String {
        let streak = habit.currentStreak
        return streak > 0 ? "Keep your \(streak)-day streak going! 🔥" : "Start building your streak today."
    }

    private func intervalReminderBody(slot: Int, total: Int, habit: Habit) -> String {
        if total == 1 { return reminderBody(for: habit) }
        return "Reminder \(slot) of \(total) — tap to log \(habit.name)"
    }
}
