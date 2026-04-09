//
//  ScreenshotDemoData.swift
//  Habitra
//
//  Populates the app with realistic demo data for App Store screenshot capture.
//  Activated via launch argument: -screenshot-demo-data
//
//  Usage in Xcode:
//    1. Edit Scheme > Run > Arguments > Add "-screenshot-demo-data"
//    2. Build & Run on target simulator (e.g., iPhone 16 Pro Max)
//    3. Capture screenshots with Cmd+S
//    4. Remove the launch argument when done
//

import Foundation
import SwiftData

enum ScreenshotDemoData {

    // MARK: - Entry Point

    /// Call from app launch. Returns true if demo data was populated.
    @MainActor
    static func populateIfNeeded(context: ModelContext) -> Bool {
        guard ProcessInfo.processInfo.arguments.contains("-screenshot-demo-data") else {
            return false
        }

        clearExistingData(context: context)
        populateDemoData(context: context)
        configureUserDefaults()

        try? context.save()
        print("📸 Screenshot demo data populated successfully")
        return true
    }

    /// Removes demo data flag so it can be re-populated on next launch.
    static func reset() {
        UserDefaults.standard.removeObject(forKey: "screenshot_demo_populated")
    }

    // MARK: - Clear

    @MainActor
    private static func clearExistingData(context: ModelContext) {
        try? context.delete(model: HabitCompletion.self)
        try? context.delete(model: Habit.self)
        try? context.delete(model: HabitCategory.self)
        try? context.delete(model: MoodEntry.self)
        try? context.delete(model: EarnedBadge.self)
        try? context.delete(model: Quest.self)
        try? context.delete(model: BadgeCollection.self)
        try? context.save()
    }

    // MARK: - Populate

    @MainActor
    private static func populateDemoData(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // --- Categories ---
        let wellness = HabitCategory(name: "Wellness", sortOrder: 0)
        let fitness = HabitCategory(name: "Fitness", sortOrder: 1)
        let growth = HabitCategory(name: "Growth", sortOrder: 2)
        [wellness, fitness, growth].forEach { context.insert($0) }

        // --- Habits ---
        let meditate = Habit(
            name: "Meditate",
            icon: "brain.head.profile",
            colorHex: "6C63FF",
            frequency: .daily,
            sortOrder: 0,
            category: wellness
        )
        // Backdate creation for realistic streaks
        meditate.createdAt = calendar.date(byAdding: .day, value: -45, to: today) ?? today

        let exercise = Habit(
            name: "Exercise",
            icon: "figure.run",
            colorHex: "3B82F6",
            frequency: .weekdays,
            sortOrder: 1,
            category: fitness,
            healthKitSources: [.running, .cycling, .yoga]
        )
        exercise.createdAt = calendar.date(byAdding: .day, value: -40, to: today) ?? today

        let read = Habit(
            name: "Read 30 min",
            icon: "book.fill",
            colorHex: "06B6D4",
            frequency: .daily,
            sortOrder: 2,
            category: growth
        )
        read.createdAt = calendar.date(byAdding: .day, value: -60, to: today) ?? today

        let journal = Habit(
            name: "Journal",
            icon: "pencil.and.outline",
            colorHex: "4ADE80",
            frequency: .daily,
            sortOrder: 3,
            category: growth
        )
        journal.createdAt = calendar.date(byAdding: .day, value: -35, to: today) ?? today

        let water = Habit(
            name: "Drink Water",
            icon: "drop.fill",
            colorHex: "38BDF8",
            frequency: .daily,
            sortOrder: 4,
            category: wellness,
            targetCompletionsPerDay: 8
        )
        water.createdAt = calendar.date(byAdding: .day, value: -30, to: today) ?? today

        let habits = [meditate, exercise, read, journal, water]
        habits.forEach { context.insert($0) }

        // --- Completions ---
        // Build realistic streaks with occasional misses

        // Meditate: 21-day current streak (missed a few early on)
        addCompletions(for: meditate, context: context, calendar: calendar, today: today,
                       daysBack: 45, skipDays: [43, 40, 38, 35, 33, 30, 29, 28, 25, 24, 23])

        // Exercise: 14-day current streak (weekdays only, so fewer total days)
        addWeekdayCompletions(for: exercise, context: context, calendar: calendar, today: today,
                              daysBack: 40, missedWeekdays: [38, 33, 28, 26])

        // Read: 30-day unbroken streak (the star habit)
        addCompletions(for: read, context: context, calendar: calendar, today: today,
                       daysBack: 60, skipDays: [58, 55, 52, 50, 48, 45, 43, 42, 40, 38, 36, 35])

        // Journal: 7-day streak (newer habit, some misses)
        addCompletions(for: journal, context: context, calendar: calendar, today: today,
                       daysBack: 35, skipDays: [34, 32, 30, 28, 25, 22, 20, 18, 16, 14, 12, 10, 9])

        // Water: 10-day streak, multi-completion (6-8 per day)
        addMultiCompletions(for: water, context: context, calendar: calendar, today: today,
                            daysBack: 30, skipDays: [29, 27, 25, 22, 20, 18, 15, 13, 11])

        // Today's state: 3 of 5 completed (for a nice ~60% progress ring)
        // Meditate, Exercise, and Read are done today (added by the loops above)
        // Journal and Water are NOT done today — remove today's completions for them
        removeTodayCompletions(for: journal, context: context, calendar: calendar, today: today)
        removeTodayCompletions(for: water, context: context, calendar: calendar, today: today)

        // Add some completions with notes (for badge eligibility)
        addNotedCompletion(for: journal, context: context, calendar: calendar, today: today,
                           daysAgo: 1, note: "Feeling grateful for the progress I've made this month.")
        addNotedCompletion(for: journal, context: context, calendar: calendar, today: today,
                           daysAgo: 2, note: "Reflected on my morning routine. Need to wake up earlier.")
        addNotedCompletion(for: meditate, context: context, calendar: calendar, today: today,
                           daysAgo: 3, note: "20 minutes of focused breathing. Felt centered.")

        // --- Mood Entries (30 days) ---
        let moodPattern: [(Int, String, Double)] = [
            // (daysAgo, journalText, sentimentScore)
            (0, "", 0),
            (1, "Had a productive day. Finished the book I was reading.", 0.85),
            (2, "Good workout this morning, feeling energized.", 0.72),
            (3, "Bit tired today but pushed through my habits.", 0.15),
            (4, "Great day! Hit all my goals.", 0.92),
            (5, "", 0),
            (6, "Meditation was particularly calming today.", 0.68),
            (7, "", 0),
            (8, "Stressful meeting but evening routine helped me decompress.", 0.30),
            (9, "Feeling motivated to keep the streak going.", 0.78),
            (10, "", 0),
            (11, "Rainy day. Stayed in and read for two hours.", 0.55),
            (12, "", 0),
            (13, "Noticed my focus is improving since I started meditating daily.", 0.81),
            (14, "Weekend rest day. Feeling recharged.", 0.65),
            (15, "", 0),
            (16, "", 0),
            (17, "Hit my water goal every day this week!", 0.88),
            (18, "Tired but consistent. That's what matters.", 0.35),
            (19, "", 0),
            (20, "Two-week streak on meditation. Proud of myself.", 0.90),
            (21, "", 0),
            (22, "Missed exercise today. Not beating myself up about it.", 0.25),
            (23, "Back on track. One day off doesn't break the chain.", 0.60),
            (24, "", 0),
            (25, "", 0),
            (26, "Started journaling and it's already helping me think clearer.", 0.75),
            (27, "Early morning run. Beautiful sunrise.", 0.82),
            (28, "", 0),
            (29, "First day with all habits done!", 0.95),
        ]

        // Mood levels cycling mostly good/great with occasional dips
        let moodLevels: [MoodLevel] = [
            .good, .great, .good, .okay, .great,
            .good, .great, .good, .okay, .great,
            .good, .good, .great, .great, .good,
            .okay, .good, .great, .okay, .good,
            .great, .good, .bad, .good, .good,
            .great, .good, .great, .good, .great,
        ]

        for (index, entry) in moodPattern.enumerated() {
            let (daysAgo, journal, sentiment) = entry
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let mood = index < moodLevels.count ? moodLevels[index] : .good
            let moodEntry = MoodEntry(
                mood: mood,
                journalText: journal,
                sentimentScore: journal.isEmpty ? 0 : sentiment,
                date: date
            )
            context.insert(moodEntry)
        }

        // --- Earned Badges ---
        let badgesData: [(String, Int, UUID?, String?, String?, String?)] = [
            // (badgeID, daysAgo, habitID, habitName, habitIcon, habitColorHex)
            // Streak badges
            ("streak_1", 44, meditate.id, "Meditate", "brain.head.profile", "6C63FF"),
            ("streak_7", 37, meditate.id, "Meditate", "brain.head.profile", "6C63FF"),
            ("streak_14", 24, meditate.id, "Meditate", "brain.head.profile", "6C63FF"),
            ("streak_1", 39, exercise.id, "Exercise", "figure.run", "3B82F6"),
            ("streak_7", 30, exercise.id, "Exercise", "figure.run", "3B82F6"),
            ("streak_14", 14, exercise.id, "Exercise", "figure.run", "3B82F6"),
            ("streak_1", 59, read.id, "Read 30 min", "book.fill", "06B6D4"),
            ("streak_7", 52, read.id, "Read 30 min", "book.fill", "06B6D4"),
            ("streak_14", 45, read.id, "Read 30 min", "book.fill", "06B6D4"),
            ("streak_30", 29, read.id, "Read 30 min", "book.fill", "06B6D4"),
            ("streak_1", 34, journal.id, "Journal", "pencil.and.outline", "4ADE80"),
            ("streak_7", 7, journal.id, "Journal", "pencil.and.outline", "4ADE80"),
            ("streak_1", 29, water.id, "Drink Water", "drop.fill", "38BDF8"),
            ("streak_7", 20, water.id, "Drink Water", "drop.fill", "38BDF8"),
            // Global badges
            ("perfect_day", 5, nil, nil, nil, nil),
            ("habit_builder", 30, nil, nil, nil, nil),
            ("note_taker", 10, nil, nil, nil, nil),
            ("health_synced", 25, nil, nil, nil, nil),
            ("comeback_kid", 22, nil, nil, nil, nil),
            // Seasonal
            ("spring_awakening", 15, nil, nil, nil, nil),
        ]

        for badge in badgesData {
            guard let earnedDate = calendar.date(byAdding: .day, value: -badge.1, to: today) else { continue }
            let earned = EarnedBadge(
                badgeID: badge.0,
                earnedAt: earnedDate,
                habitID: badge.2,
                habitName: badge.3,
                habitIcon: badge.4,
                habitColorHex: badge.5
            )
            context.insert(earned)
        }

        // --- Quests ---
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!

        let monthlyQuest = Quest(
            questID: "monthly_\(calendar.component(.year, from: today))_\(String(format: "%02d", calendar.component(.month, from: today)))",
            title: "April Champion",
            descriptionText: "Complete all habits for 20 days this month",
            icon: "trophy.fill",
            colorHex: "F59E0B",
            questType: "monthly",
            targetValue: 20,
            startDate: monthStart,
            endDate: monthEnd,
            xpReward: 500,
            rewardBadgeID: "apr_champion"
        )
        monthlyQuest.currentValue = 5
        context.insert(monthlyQuest)

        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!

        let weeklyQuest = Quest(
            questID: "weekly_streak_builder",
            title: "Streak Builder",
            descriptionText: "Maintain a 7+ day streak on any 3 habits",
            icon: "flame.fill",
            colorHex: "F97316",
            questType: "weekly",
            targetValue: 3,
            startDate: weekStart,
            endDate: weekEnd,
            xpReward: 150
        )
        weeklyQuest.currentValue = 2
        context.insert(weeklyQuest)
    }

    // MARK: - UserDefaults Configuration

    private static func configureUserDefaults() {
        let defaults = UserDefaults.standard

        // Skip onboarding
        defaults.set(true, forKey: "hasCompletedOnboarding")
        defaults.set(true, forKey: "hasCompletedQuickTour")
        defaults.set(true, forKey: "badgeSystemInitialized")

        // Dark mode (best for screenshots)
        defaults.set(true, forKey: "prefersDarkMode")

        // XP: Level 7, ~65% through to level 8
        // Level 7 = 2450 XP, Level 8 = 3500 XP, so ~3130 XP = 65% through level 7
        defaults.set(3130, forKey: "habitra_lifetime_xp")
        defaults.set(true, forKey: "habitra_xp_backfilled")

        // Today's XP
        let todayKey = "habitra_xp_\(Self.dateKey(for: Date()))"
        defaults.set(85, forKey: todayKey)

        // Recent days XP for weekly display
        let calendar = Calendar.current
        for daysAgo in 1...6 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                let key = "habitra_xp_\(Self.dateKey(for: date))"
                let xp = [95, 70, 110, 60, 85, 75][daysAgo - 1]
                defaults.set(xp, forKey: key)
            }
        }

        // Smart sort enabled
        defaults.set(true, forKey: "smartSortEnabled")
    }

    // MARK: - Helpers

    private static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    @MainActor
    private static func addCompletions(
        for habit: Habit,
        context: ModelContext,
        calendar: Calendar,
        today: Date,
        daysBack: Int,
        skipDays: Set<Int>
    ) {
        for daysAgo in 0...daysBack {
            guard !skipDays.contains(daysAgo) else { continue }
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let completion = HabitCompletion(completedDate: date, habit: habit)
            context.insert(completion)
        }
    }

    @MainActor
    private static func addWeekdayCompletions(
        for habit: Habit,
        context: ModelContext,
        calendar: Calendar,
        today: Date,
        daysBack: Int,
        missedWeekdays: Set<Int>
    ) {
        for daysAgo in 0...daysBack {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            // Skip weekends (1=Sun, 7=Sat)
            guard weekday >= 2 && weekday <= 6 else { continue }
            guard !missedWeekdays.contains(daysAgo) else { continue }
            let completion = HabitCompletion(completedDate: date, habit: habit)
            context.insert(completion)
        }
    }

    @MainActor
    private static func addMultiCompletions(
        for habit: Habit,
        context: ModelContext,
        calendar: Calendar,
        today: Date,
        daysBack: Int,
        skipDays: Set<Int>
    ) {
        for daysAgo in 0...daysBack {
            guard !skipDays.contains(daysAgo) else { continue }
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            // Vary completion count between 6-8 for realism
            let count = [8, 7, 8, 6, 8, 7, 8, 8, 7, 8][daysAgo % 10]
            for _ in 0..<count {
                let completion = HabitCompletion(completedDate: date, habit: habit)
                context.insert(completion)
            }
        }
    }

    @MainActor
    private static func removeTodayCompletions(
        for habit: Habit,
        context: ModelContext,
        calendar: Calendar,
        today: Date
    ) {
        let completionsToRemove = habit.completions.filter {
            calendar.isDate($0.completedDate, inSameDayAs: today)
        }
        for completion in completionsToRemove {
            context.delete(completion)
        }
    }

    @MainActor
    private static func addNotedCompletion(
        for habit: Habit,
        context: ModelContext,
        calendar: Calendar,
        today: Date,
        daysAgo: Int,
        note: String
    ) {
        guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return }
        // Find existing completion for this day and add note
        if let existing = habit.completions.first(where: {
            calendar.isDate($0.completedDate, inSameDayAs: date)
        }) {
            existing.note = note
        } else {
            let completion = HabitCompletion(completedDate: date, habit: habit, note: note)
            context.insert(completion)
        }
    }
}
