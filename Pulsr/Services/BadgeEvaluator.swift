//
//  BadgeEvaluator.swift
//  Habitra
//
//  Evaluates all habits + completions against the badge catalog and inserts
//  any newly earned EarnedBadge records. Returns the list of newly earned
//  badges so the UI can show a celebration.
//
//  Call after every habit toggle and on app launch.
//  Idempotent: never awards the same (badgeID, habitID) pair twice.
//

import Foundation
import SwiftData

@MainActor
enum BadgeEvaluator {

    // MARK: - Public Entry Point

    /// Check all habits and return any newly earned badges.
    @discardableResult
    static func evaluate(habits: [Habit], context: ModelContext) -> [EarnedBadge] {
        let existing = fetchExisting(context: context)
        var newBadges: [EarnedBadge] = []

        let activeHabits = habits.filter { !$0.isArchived }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // --- Per-habit streak badges ---
        let streakThresholds: [(Int, String)] = [
            (1,   "streak_first"),
            (7,   "streak_7"),
            (14,  "streak_14"),
            (30,  "streak_30"),
            (45,  "streak_45"),
            (60,  "streak_60"),
            (75,  "streak_75"),
            (100, "streak_100"),
            (150, "streak_150"),
            (200, "streak_200"),
            (250, "streak_250"),
            (365, "streak_365"),
        ]
        for habit in activeHabits {
            let best = habit.longestStreak
            for (threshold, badgeID) in streakThresholds where best >= threshold {
                if !alreadyEarned(badgeID: badgeID, habitID: habit.id, existing: existing) {
                    let badge = EarnedBadge(
                        badgeID: badgeID,
                        habitID: habit.id,
                        habitName: habit.name,
                        habitIcon: habit.icon,
                        habitColorHex: habit.colorHex
                    )
                    context.insert(badge)
                    newBadges.append(badge)
                }
            }
        }

        // --- Full House: all scheduled habits done today ---
        let scheduledToday = activeHabits.filter { $0.frequency.isScheduled(for: today) }
        if !scheduledToday.isEmpty && scheduledToday.allSatisfy({ $0.isCompleted(on: today) }) {
            if !alreadyEarnedGlobal(badgeID: "perfect_day", on: today, existing: existing) {
                let badge = EarnedBadge(badgeID: "perfect_day")
                context.insert(badge)
                newBadges.append(badge)
            }
        }

        // --- Perfect Week: all scheduled habits done every day for 7 days ---
        if checkPerfectWeek(habits: activeHabits) {
            if !alreadyEarnedToday(badgeID: "perfect_week", existing: existing) {
                let badge = EarnedBadge(badgeID: "perfect_week")
                context.insert(badge)
                newBadges.append(badge)
            }
        }

        // --- Tiered Perfect Week: count total perfect_week badges earned ---
        let perfectWeekCount = (existing + newBadges).filter { $0.badgeID == "perfect_week" }.count
        let tieredPerfectWeek: [(Int, String)] = [(4, "perfect_week_bronze"), (12, "perfect_week_silver"), (52, "perfect_week_gold")]
        for (threshold, badgeID) in tieredPerfectWeek where perfectWeekCount >= threshold {
            if !alreadyEarnedGlobal(badgeID: badgeID, existing: existing) {
                let badge = EarnedBadge(badgeID: badgeID)
                context.insert(badge)
                newBadges.append(badge)
            }
        }

        // --- Unstoppable: 3+ habits each with current 30-day streak ---
        let thirtyDayHabits = activeHabits.filter { $0.currentStreak >= 30 }
        if thirtyDayHabits.count >= 3 {
            if !alreadyEarnedToday(badgeID: "unstoppable", existing: existing) {
                let badge = EarnedBadge(badgeID: "unstoppable")
                context.insert(badge)
                newBadges.append(badge)
            }
        }

        // --- Tiered Streak Master ---
        let sevenDayHabits = activeHabits.filter { $0.currentStreak >= 7 }
        let sixtyDayHabits = activeHabits.filter { $0.currentStreak >= 60 }

        if sevenDayHabits.count >= 3 && !alreadyEarnedGlobal(badgeID: "streak_master_bronze", existing: existing) {
            let badge = EarnedBadge(badgeID: "streak_master_bronze")
            context.insert(badge)
            newBadges.append(badge)
        }
        if thirtyDayHabits.count >= 3 && !alreadyEarnedGlobal(badgeID: "streak_master_silver", existing: existing) {
            let badge = EarnedBadge(badgeID: "streak_master_silver")
            context.insert(badge)
            newBadges.append(badge)
        }
        if sixtyDayHabits.count >= 5 && !alreadyEarnedGlobal(badgeID: "streak_master_gold", existing: existing) {
            let badge = EarnedBadge(badgeID: "streak_master_gold")
            context.insert(badge)
            newBadges.append(badge)
        }

        // --- Early Bird: 5 days where a completion was before 8am ---
        let earlyCount = countEarlyCompletions(habits: activeHabits)
        if earlyCount >= 5 && !alreadyEarnedGlobal(badgeID: "early_bird", existing: existing) {
            let badge = EarnedBadge(badgeID: "early_bird")
            context.insert(badge)
            newBadges.append(badge)
        }

        // --- Habit Builder: 5+ active habits ---
        if activeHabits.count >= 5 && !alreadyEarnedGlobal(badgeID: "habit_builder", existing: existing) {
            let badge = EarnedBadge(badgeID: "habit_builder")
            context.insert(badge)
            newBadges.append(badge)
        }

        // --- Health Synced: any auto-completed completion ---
        let hasHealthCompletion = activeHabits.flatMap(\.completions).contains { $0.isAutoCompleted }
        if hasHealthCompletion && !alreadyEarnedGlobal(badgeID: "health_synced", existing: existing) {
            let badge = EarnedBadge(badgeID: "health_synced")
            context.insert(badge)
            newBadges.append(badge)
        }

        // --- Journal Entry: 10+ completions with notes ---
        let notedCount = activeHabits.flatMap(\.completions).filter { ($0.note?.isEmpty == false) }.count
        if notedCount >= 10 && !alreadyEarnedGlobal(badgeID: "note_taker", existing: existing) {
            let badge = EarnedBadge(badgeID: "note_taker")
            context.insert(badge)
            newBadges.append(badge)
        }

        // --- Comeback Kid: complete a habit after a 3+ day gap ---
        for habit in activeHabits {
            if hasComeback(habit: habit, gapDays: 3) && !alreadyEarnedGlobal(badgeID: "comeback_kid", existing: existing) {
                let badge = EarnedBadge(badgeID: "comeback_kid")
                context.insert(badge)
                newBadges.append(badge)
                break
            }
        }

        // --- Phoenix: rebuild a 7-day streak after previously breaking one ---
        for habit in activeHabits {
            if isPhoenix(habit: habit) && !alreadyEarnedGlobal(badgeID: "phoenix", existing: existing) {
                let badge = EarnedBadge(badgeID: "phoenix")
                context.insert(badge)
                newBadges.append(badge)
                break
            }
        }

        // --- Night Owl: completion after 11pm ---
        let nightCompletion = activeHabits.flatMap(\.completions).contains { c in
            calendar.component(.hour, from: c.completedAt) >= 23
        }
        if nightCompletion && !alreadyEarnedGlobal(badgeID: "night_owl", existing: existing) {
            let badge = EarnedBadge(badgeID: "night_owl")
            context.insert(badge)
            newBadges.append(badge)
        }

        // --- Overachiever: multi-completion habit at 2x target in one day ---
        for habit in activeHabits where habit.isMultiCompletion {
            let count = habit.completionCount(on: today)
            if count >= habit.targetCompletionsPerDay * 2 &&
               !alreadyEarnedGlobal(badgeID: "overachiever", existing: existing) {
                let badge = EarnedBadge(badgeID: "overachiever")
                context.insert(badge)
                newBadges.append(badge)
                break
            }
        }

        // --- Streak Saver: all habits done after 9pm ---
        let hour = calendar.component(.hour, from: Date())
        if hour >= 21 && !scheduledToday.isEmpty && scheduledToday.allSatisfy({ $0.isCompleted(on: today) }) {
            if !alreadyEarnedToday(badgeID: "streak_saver", existing: existing) {
                let badge = EarnedBadge(badgeID: "streak_saver")
                context.insert(badge)
                newBadges.append(badge)
            }
        }

        // MARK: - Combo Badges

        // Streak Trio: 3 different streak badges earned this calendar week
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let allCurrent = existing + newBadges
        let streakBadgeIDs = Set(streakThresholds.map(\.1))
        let weekStreakBadges = allCurrent.filter {
            streakBadgeIDs.contains($0.badgeID) && $0.earnedAt >= weekStart
        }
        let uniqueWeekStreaks = Set(weekStreakBadges.map(\.badgeID))
        if uniqueWeekStreaks.count >= 3 && !alreadyEarnedGlobal(badgeID: "combo_streak_trio", existing: existing) {
            let badge = EarnedBadge(badgeID: "combo_streak_trio")
            context.insert(badge)
            newBadges.append(badge)
        }

        // Five-Star General: 5 habits at 30+ day streaks
        if thirtyDayHabits.count >= 5 && !alreadyEarnedGlobal(badgeID: "combo_5x30", existing: existing) {
            let badge = EarnedBadge(badgeID: "combo_5x30")
            context.insert(badge)
            newBadges.append(badge)
        }

        // Perfect Month: 4 Perfect Weeks in same calendar month
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let monthPerfectWeeks = allCurrent.filter { $0.badgeID == "perfect_week" && $0.earnedAt >= monthStart }
        if monthPerfectWeeks.count >= 4 && !alreadyEarnedGlobal(badgeID: "combo_perfect_month", on: monthStart, existing: existing) {
            let badge = EarnedBadge(badgeID: "combo_perfect_month")
            context.insert(badge)
            newBadges.append(badge)
        }

        // Category Sweep: all habits in every category completed today
        let categorizedHabits = scheduledToday.filter { $0.category != nil }
        if !categorizedHabits.isEmpty {
            let categories = Set(categorizedHabits.compactMap(\.category?.id))
            let allCategoriesComplete = categories.allSatisfy { catID in
                let habitsInCat = categorizedHabits.filter { $0.category?.id == catID }
                return habitsInCat.allSatisfy { $0.isCompleted(on: today) }
            }
            if allCategoriesComplete && categories.count >= 2 &&
               !alreadyEarnedGlobal(badgeID: "combo_category_sweep", on: today, existing: existing) {
                let badge = EarnedBadge(badgeID: "combo_category_sweep")
                context.insert(badge)
                newBadges.append(badge)
            }
        }

        // MARK: - Calendar Secret Badges

        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        let weekday = calendar.component(.weekday, from: today)

        // Holiday Hero: all habits on a major holiday
        let holidays: Set<String> = ["1-1", "7-4", "12-25", "12-31", "11-28", "10-31", "2-14"]
        let dateKey = "\(month)-\(day)"
        if holidays.contains(dateKey) && !scheduledToday.isEmpty &&
           scheduledToday.allSatisfy({ $0.isCompleted(on: today) }) &&
           !alreadyEarnedGlobal(badgeID: "holiday_hero", on: today, existing: existing) {
            let badge = EarnedBadge(badgeID: "holiday_hero")
            context.insert(badge)
            newBadges.append(badge)
        }

        // Palindrome Date
        if isPalindromeDate(today) && activeHabits.contains(where: { $0.isCompleted(on: today) }) &&
           !alreadyEarnedGlobal(badgeID: "palindrome_date", existing: existing) {
            let badge = EarnedBadge(badgeID: "palindrome_date")
            context.insert(badge)
            newBadges.append(badge)
        }

        // Friday the 13th
        if weekday == 6 && day == 13 && !scheduledToday.isEmpty &&
           scheduledToday.allSatisfy({ $0.isCompleted(on: today) }) &&
           !alreadyEarnedGlobal(badgeID: "friday_13th", existing: existing) {
            let badge = EarnedBadge(badgeID: "friday_13th")
            context.insert(badge)
            newBadges.append(badge)
        }

        // New Year New Me
        if month == 1 && day == 1 && !scheduledToday.isEmpty &&
           scheduledToday.allSatisfy({ $0.isCompleted(on: today) }) &&
           !alreadyEarnedGlobal(badgeID: "new_year_new_me", existing: existing) {
            let badge = EarnedBadge(badgeID: "new_year_new_me")
            context.insert(badge)
            newBadges.append(badge)
        }

        // Lucky Seven: 7 habits at 7+ day streaks on the 7th
        if day == 7 && sevenDayHabits.count >= 7 && !alreadyEarnedGlobal(badgeID: "triple_seven", existing: existing) {
            let badge = EarnedBadge(badgeID: "triple_seven")
            context.insert(badge)
            newBadges.append(badge)
        }

        // Full Month: complete every habit every day of the current month (check on last day only)
        let lastDayOfMonth = calendar.range(of: .day, in: .month, for: today)?.upperBound ?? 0
        if day == lastDayOfMonth - 1 {
            if checkFullMonth(habits: activeHabits, date: today) && !alreadyEarnedGlobal(badgeID: "full_month", existing: existing) {
                let badge = EarnedBadge(badgeID: "full_month")
                context.insert(badge)
                newBadges.append(badge)
            }
        }

        // MARK: - Seasonal Badges (Pro only)

        if SubscriptionManager.isPro {
            evaluateSeasonalBadges(habits: activeHabits, context: context, existing: existing + newBadges, newBadges: &newBadges)
        }

        // MARK: - Collection Completion

        evaluateCollections(context: context, existing: existing + newBadges, newBadges: &newBadges)

        if !newBadges.isEmpty {
            try? context.save()
            HapticManager.medium()
        }

        return newBadges
    }

    // MARK: - Seasonal Badge Evaluation

    private static func evaluateSeasonalBadges(
        habits: [Habit],
        context: ModelContext,
        existing: [EarnedBadge],
        newBadges: inout [EarnedBadge]
    ) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let season = SeasonalBadgeEngine.Season.current()

        switch season {
        case .spring:
            // Spring Awakening: 7 consecutive perfect days during spring
            if checkPerfectWeek(habits: habits) && !alreadyEarnedGlobal(badgeID: "spring_awakening", existing: existing) {
                let badge = EarnedBadge(badgeID: "spring_awakening")
                context.insert(badge)
                newBadges.append(badge)
            }
            // Blossom: new habit with 14-day streak during spring
            let springStart = springStartDate(for: today)
            for habit in habits where habit.createdAt >= springStart && habit.currentStreak >= 14 {
                if !alreadyEarnedGlobal(badgeID: "blossom", existing: existing) {
                    let badge = EarnedBadge(badgeID: "blossom")
                    context.insert(badge)
                    newBadges.append(badge)
                    break
                }
            }

        case .summer:
            // Summer Streak: any 30-day streak
            if habits.contains(where: { $0.currentStreak >= 30 }) && !alreadyEarnedGlobal(badgeID: "summer_streak", existing: existing) {
                let badge = EarnedBadge(badgeID: "summer_streak")
                context.insert(badge)
                newBadges.append(badge)
            }
            // Heat Wave: complete all habits before noon for 5 days
            let noonCount = countCompletionsBeforeHour(habits: habits, hour: 12)
            if noonCount >= 5 && !alreadyEarnedGlobal(badgeID: "heat_wave", existing: existing) {
                let badge = EarnedBadge(badgeID: "heat_wave")
                context.insert(badge)
                newBadges.append(badge)
            }

        case .fall:
            // Harvest: earn 10 badges during fall
            let fallStart = fallStartDate(for: today)
            let fallBadges = existing.filter { $0.earnedAt >= fallStart }
            if fallBadges.count >= 10 && !alreadyEarnedGlobal(badgeID: "harvest", existing: existing) {
                let badge = EarnedBadge(badgeID: "harvest")
                context.insert(badge)
                newBadges.append(badge)
            }
            // Golden Hour: complete between 5-7 PM on 10 different days
            let goldenCount = countCompletionsBetweenHours(habits: habits, startHour: 17, endHour: 19)
            if goldenCount >= 10 && !alreadyEarnedGlobal(badgeID: "golden_hour", existing: existing) {
                let badge = EarnedBadge(badgeID: "golden_hour")
                context.insert(badge)
                newBadges.append(badge)
            }

        case .winter:
            // Winter Warrior: 21 consecutive perfect days
            if checkConsecutivePerfectDays(habits: habits, required: 21) && !alreadyEarnedGlobal(badgeID: "winter_warrior", existing: existing) {
                let badge = EarnedBadge(badgeID: "winter_warrior")
                context.insert(badge)
                newBadges.append(badge)
            }
            // Snowflake: 5 active habits
            if habits.count >= 5 && !alreadyEarnedGlobal(badgeID: "snowflake", existing: existing) {
                let badge = EarnedBadge(badgeID: "snowflake")
                context.insert(badge)
                newBadges.append(badge)
            }
        }
    }

    // MARK: - Collection Completion

    private static func evaluateCollections(
        context: ModelContext,
        existing: [EarnedBadge],
        newBadges: inout [EarnedBadge]
    ) {
        let earnedIDs = Set(existing.map(\.badgeID))

        let collections: [(requiredIDs: [String], rewardID: String)] = [
            // Night Shift: night_owl + streak_saver
            (["night_owl", "streak_saver"], "collection_night_shift"),
            // The Comeback: comeback_kid + phoenix
            (["comeback_kid", "phoenix"], "collection_comeback_complete"),
            // Secret Agent: all secret badges
            (["night_owl", "overachiever", "streak_saver", "holiday_hero", "full_month",
              "palindrome_date", "friday_13th", "new_year_new_me", "triple_seven"],
             "collection_secret_agent"),
            // Consistency Crown: perfect_day + perfect_week + perfect_week_bronze + perfect_week_silver + unstoppable
            (["perfect_day", "perfect_week", "perfect_week_bronze", "perfect_week_silver", "unstoppable"],
             "collection_consistency_crown"),
        ]

        for (requiredIDs, rewardID) in collections {
            if requiredIDs.allSatisfy({ earnedIDs.contains($0) }) && !earnedIDs.contains(rewardID) {
                let badge = EarnedBadge(badgeID: rewardID)
                context.insert(badge)
                newBadges.append(badge)
            }
        }

        // Monthly Champion collection: all 12 monthly badges
        let monthKeys = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
        let monthlyIDs = monthKeys.map { "monthly_champion_\($0)" }
        if monthlyIDs.allSatisfy({ earnedIDs.contains($0) }) && !earnedIDs.contains("collection_monthly_champion") {
            let badge = EarnedBadge(badgeID: "collection_monthly_champion")
            context.insert(badge)
            newBadges.append(badge)
        }
    }

    // MARK: - Helpers

    private static func fetchExisting(context: ModelContext) -> [EarnedBadge] {
        (try? context.fetch(FetchDescriptor<EarnedBadge>())) ?? []
    }

    private static func alreadyEarned(badgeID: String, habitID: UUID, existing: [EarnedBadge]) -> Bool {
        existing.contains { $0.badgeID == badgeID && $0.habitID == habitID }
    }

    /// Global badge (not per-habit): only award once ever.
    private static func alreadyEarnedGlobal(badgeID: String, existing: [EarnedBadge]) -> Bool {
        existing.contains { $0.badgeID == badgeID }
    }

    /// Global badge (not per-habit): only award once ever (overload with unused date param for convenience).
    private static func alreadyEarnedGlobal(badgeID: String, on date: Date?, existing: [EarnedBadge]) -> Bool {
        existing.contains { $0.badgeID == badgeID }
    }

    /// Global badge keyed to a specific calendar day — only award once per day.
    private static func alreadyEarnedGlobal(badgeID: String, on date: Date, existing: [EarnedBadge]) -> Bool {
        existing.contains {
            $0.badgeID == badgeID &&
            Calendar.current.isDate($0.earnedAt, inSameDayAs: date)
        }
    }

    /// Global badge that should only be awarded once per calendar day.
    private static func alreadyEarnedToday(badgeID: String, existing: [EarnedBadge]) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return existing.contains {
            $0.badgeID == badgeID &&
            Calendar.current.isDate($0.earnedAt, inSameDayAs: today)
        }
    }

    // MARK: - Complex Checks

    private static func checkPerfectWeek(habits: [Habit]) -> Bool {
        guard !habits.isEmpty else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return false }
            let scheduled = habits.filter { $0.frequency.isScheduled(for: date) }
            guard !scheduled.isEmpty else { continue }
            if !scheduled.allSatisfy({ $0.isCompleted(on: date) }) { return false }
        }
        return true
    }

    private static func checkConsecutivePerfectDays(habits: [Habit], required: Int) -> Bool {
        guard !habits.isEmpty else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for offset in 0..<required {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return false }
            let scheduled = habits.filter { $0.frequency.isScheduled(for: date) }
            guard !scheduled.isEmpty else { continue }
            if !scheduled.allSatisfy({ $0.isCompleted(on: date) }) { return false }
        }
        return true
    }

    private static func checkFullMonth(habits: [Habit], date: Date) -> Bool {
        guard !habits.isEmpty else { return false }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let monthStart = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else { return false }

        for dayOffset in 0..<range.count {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: monthStart) else { return false }
            let scheduled = habits.filter { $0.frequency.isScheduled(for: dayDate) }
            guard !scheduled.isEmpty else { continue }
            if !scheduled.allSatisfy({ $0.isCompleted(on: dayDate) }) { return false }
        }
        return true
    }

    private static func countEarlyCompletions(habits: [Habit]) -> Int {
        let completionsBeforeEight = habits
            .flatMap(\.completions)
            .filter { Calendar.current.component(.hour, from: $0.completedAt) < 8 }
        let days = Set(completionsBeforeEight.map { Calendar.current.startOfDay(for: $0.completedAt) })
        return days.count
    }

    private static func countCompletionsBeforeHour(habits: [Habit], hour: Int) -> Int {
        let matching = habits
            .flatMap(\.completions)
            .filter { Calendar.current.component(.hour, from: $0.completedAt) < hour }
        let days = Set(matching.map { Calendar.current.startOfDay(for: $0.completedAt) })
        return days.count
    }

    private static func countCompletionsBetweenHours(habits: [Habit], startHour: Int, endHour: Int) -> Int {
        let matching = habits
            .flatMap(\.completions)
            .filter {
                let h = Calendar.current.component(.hour, from: $0.completedAt)
                return h >= startHour && h < endHour
            }
        let days = Set(matching.map { Calendar.current.startOfDay(for: $0.completedAt) })
        return days.count
    }

    private static func isPalindromeDate(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let s = formatter.string(from: date)
        return s == String(s.reversed())
    }

    /// Returns true if the habit was completed today after a gap of `gapDays` or more.
    private static func hasComeback(habit: Habit, gapDays: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard habit.isCompleted(on: today) else { return false }

        let previousCompletions = habit.completions
            .map { calendar.startOfDay(for: $0.completedDate) }
            .filter { $0 < today }
            .sorted()

        guard let lastDate = previousCompletions.last else { return false }
        let daysBetween = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
        return daysBetween >= gapDays
    }

    /// Returns true if current streak >= 7 AND there was a previously broken streak of 7+.
    private static func isPhoenix(habit: Habit) -> Bool {
        guard habit.currentStreak >= 7 else { return false }

        let calendar = Calendar.current
        let sortedDates = habit.completions
            .map { calendar.startOfDay(for: $0.completedDate) }
            .sorted()

        guard sortedDates.count >= 14 else { return false }

        var run = 1
        var hadLongRun = false
        for i in 1..<sortedDates.count {
            let diff = calendar.dateComponents([.day], from: sortedDates[i - 1], to: sortedDates[i]).day ?? 0
            if diff == 1 {
                run += 1
                if run >= 7 { hadLongRun = true }
            } else if diff > 1 {
                if hadLongRun { return true }
                run = 1
            }
        }
        return false
    }

    // MARK: - Season Date Helpers

    private static func springStartDate(for date: Date) -> Date {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return calendar.date(from: DateComponents(year: year, month: 3, day: 1))!
    }

    private static func fallStartDate(for date: Date) -> Date {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return calendar.date(from: DateComponents(year: year, month: 9, day: 1))!
    }
}
