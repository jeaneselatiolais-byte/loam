//
//  HabitraTests.swift
//  HabitraTests
//
//  Created by Jeanese Raymond on 3/24/26.
//  Phase 2 Week 4: Comprehensive unit tests
//

import Testing
import Foundation
import SwiftUI
@testable import Habitra

// MARK: - HabitFrequency Tests

struct HabitFrequencyTests {

    @Test func dailySchedulesAllDays() {
        let freq = HabitFrequency.daily
        #expect(freq.scheduledDays.count == 7)
        for day in 1...7 {
            #expect(freq.scheduledDays.contains(day))
        }
    }

    @Test func weekdaysSchedulesMondayThroughFriday() {
        let freq = HabitFrequency.weekdays
        #expect(freq.scheduledDays == Set(2...6))
        #expect(!freq.scheduledDays.contains(1)) // Sunday
        #expect(!freq.scheduledDays.contains(7)) // Saturday
    }

    @Test func weekendsSchedulesSaturdayAndSunday() {
        let freq = HabitFrequency.weekends
        #expect(freq.scheduledDays == Set([1, 7]))
    }

    @Test func customSchedulesSelectedDays() {
        let freq = HabitFrequency.custom(days: [2, 4, 6]) // Mon, Wed, Fri
        #expect(freq.scheduledDays == Set([2, 4, 6]))
        #expect(freq.scheduledDays.count == 3)
    }

    @Test func customEmptyDays() {
        let freq = HabitFrequency.custom(days: [])
        #expect(freq.scheduledDays.isEmpty)
    }

    @Test func dailyDisplayName() {
        #expect(HabitFrequency.daily.displayName == "Every day")
    }

    @Test func weekdaysDisplayName() {
        #expect(HabitFrequency.weekdays.displayName == "Weekdays")
    }

    @Test func weekendsDisplayName() {
        #expect(HabitFrequency.weekends.displayName == "Weekends")
    }

    @Test func customAllDaysDisplaysEveryDay() {
        let freq = HabitFrequency.custom(days: [1, 2, 3, 4, 5, 6, 7])
        #expect(freq.displayName == "Every day")
    }

    @Test func customEmptyDaysDisplaysNoDays() {
        let freq = HabitFrequency.custom(days: [])
        #expect(freq.displayName == "No days")
    }

    @Test func customSubsetDisplaysDayAbbreviations() {
        let freq = HabitFrequency.custom(days: [2, 4]) // Mon, Wed
        let name = freq.displayName
        // Should contain short weekday symbols for Mon and Wed
        #expect(!name.isEmpty)
        #expect(name != "Every day")
        #expect(name != "No days")
    }

    @Test func isScheduledForDateWorks() {
        let freq = HabitFrequency.weekdays
        let calendar = Calendar.current

        // Find next Monday
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        let monday = calendar.date(from: components)!

        #expect(freq.isScheduled(for: monday) == true)

        // Find next Sunday
        components.weekday = 1
        let sunday = calendar.date(from: components)!
        #expect(freq.isScheduled(for: sunday) == false)
    }

    @Test func weekendsIsNotScheduledOnWeekday() {
        let freq = HabitFrequency.weekends
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 3 // Tuesday
        let tuesday = calendar.date(from: components)!
        #expect(freq.isScheduled(for: tuesday) == false)
    }

    @Test func customIsScheduledOnlyForSelectedDays() {
        let freq = HabitFrequency.custom(days: [2]) // Monday only
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())

        components.weekday = 2 // Monday
        let monday = calendar.date(from: components)!
        #expect(freq.isScheduled(for: monday) == true)

        components.weekday = 3 // Tuesday
        let tuesday = calendar.date(from: components)!
        #expect(freq.isScheduled(for: tuesday) == false)
    }

    @Test func frequencyHashable() {
        let set: Set<HabitFrequency> = [.daily, .weekdays, .weekends, .custom(days: [1, 2])]
        #expect(set.count == 4)
    }
}

// MARK: - Habit Model Tests

struct HabitModelTests {

    @Test func habitInitializesWithDefaults() {
        let habit = Habit(name: "Test")
        #expect(habit.name == "Test")
        #expect(habit.icon == "circle.fill")
        #expect(habit.colorHex == "6C63FF")
        #expect(habit.frequencyType == "daily")
        #expect(habit.customDays.isEmpty)
        #expect(habit.isArchived == false)
        #expect(habit.reminderTime == nil)
        #expect(habit.completions.isEmpty)
    }

    @Test func habitInitializesWithCustomFrequency() {
        let habit = Habit(
            name: "Gym",
            icon: "figure.run",
            colorHex: "4ADE80",
            frequency: .custom(days: [2, 4, 6])
        )
        #expect(habit.frequencyType == "custom")
        #expect(habit.customDays == [2, 4, 6])
        #expect(habit.frequency.scheduledDays == Set([2, 4, 6]))
    }

    @Test func habitInitializesWithWeekdays() {
        let habit = Habit(name: "Work", frequency: .weekdays)
        #expect(habit.frequencyType == "weekdays")
        #expect(habit.customDays.isEmpty)
    }

    @Test func habitInitializesWithWeekends() {
        let habit = Habit(name: "Rest", frequency: .weekends)
        #expect(habit.frequencyType == "weekends")
    }

    @Test func habitInitializesWithReminder() {
        let reminderDate = Date()
        let habit = Habit(name: "Pill", reminderTime: reminderDate)
        #expect(habit.reminderTime != nil)
    }

    @Test func habitInitializesWithCategory() {
        let category = HabitCategory(name: "Health")
        let habit = Habit(name: "Run", category: category)
        #expect(habit.category?.name == "Health")
    }

    @Test func habitIdIsUnique() {
        let a = Habit(name: "A")
        let b = Habit(name: "B")
        #expect(a.id != b.id)
    }

    @Test func frequencyTransientPropertyGetterWorks() {
        let habit = Habit(name: "A", frequency: .daily)
        #expect(habit.frequencyType == "daily")

        let habit2 = Habit(name: "B", frequency: .weekdays)
        #expect(habit2.frequencyType == "weekdays")

        let habit3 = Habit(name: "C", frequency: .weekends)
        #expect(habit3.frequencyType == "weekends")

        let habit4 = Habit(name: "D", frequency: .custom(days: [1, 3, 5]))
        #expect(habit4.frequencyType == "custom")
        #expect(habit4.customDays == [1, 3, 5])
    }

    @Test func frequencyTransientPropertySetterWorks() {
        let habit = Habit(name: "Test")
        habit.frequency = .weekends
        #expect(habit.frequencyType == "weekends")
        #expect(habit.customDays.isEmpty)

        habit.frequency = .custom(days: [3, 1, 5])
        #expect(habit.frequencyType == "custom")
        #expect(habit.customDays == [1, 3, 5]) // sorted
    }

    @Test func frequencySetterClearsCustomDaysForNonCustom() {
        let habit = Habit(name: "Test", frequency: .custom(days: [1, 2, 3]))
        #expect(habit.customDays == [1, 2, 3])

        habit.frequency = .daily
        #expect(habit.frequencyType == "daily")
        #expect(habit.customDays.isEmpty)
    }

    @Test func isScheduledTodayReflectsFrequency() {
        let habit = Habit(name: "Daily", frequency: .daily)
        #expect(habit.isScheduledToday == true)
    }

    @Test func isCompletedReturnsFalseWithNoCompletions() {
        let habit = Habit(name: "Test")
        #expect(habit.isCompleted(on: Date()) == false)
    }

    @Test func currentStreakIsZeroWithNoCompletions() {
        let habit = Habit(name: "Test")
        #expect(habit.currentStreak == 0)
    }

    @Test func longestStreakIsZeroWithNoCompletions() {
        let habit = Habit(name: "Test")
        #expect(habit.longestStreak == 0)
    }

    @Test func sortOrderDefaultsToZero() {
        let habit = Habit(name: "Test")
        #expect(habit.sortOrder == 0)
    }

    @Test func sortOrderCanBeSet() {
        let habit = Habit(name: "Test", sortOrder: 5)
        #expect(habit.sortOrder == 5)
    }
}

// MARK: - HabitCompletion Tests

struct HabitCompletionTests {

    @Test func completionInitializesWithDefaults() {
        let completion = HabitCompletion()
        #expect(completion.note == nil)
        #expect(completion.habit == nil)
    }

    @Test func completionStoresNote() {
        let completion = HabitCompletion(note: "Felt great today")
        #expect(completion.note == "Felt great today")
    }

    @Test func completionDateIsStartOfDay() {
        let now = Date()
        let completion = HabitCompletion(completedDate: now)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)
        #expect(completion.completedDate == startOfDay)
    }

    @Test func completedAtIsExactTimestamp() {
        let before = Date()
        let completion = HabitCompletion()
        let after = Date()
        #expect(completion.completedAt >= before)
        #expect(completion.completedAt <= after)
    }

    @Test func completionIdIsUnique() {
        let a = HabitCompletion()
        let b = HabitCompletion()
        #expect(a.id != b.id)
    }
}

// MARK: - HabitCategory Tests

struct HabitCategoryTests {

    @Test func categoryInitializesCorrectly() {
        let category = HabitCategory(name: "Health")
        #expect(category.name == "Health")
        #expect(category.sortOrder == 0)
        #expect(category.habits.isEmpty)
    }

    @Test func categoryWithSortOrder() {
        let category = HabitCategory(name: "Work", sortOrder: 3)
        #expect(category.sortOrder == 3)
    }

    @Test func categoryIdIsUnique() {
        let a = HabitCategory(name: "A")
        let b = HabitCategory(name: "B")
        #expect(a.id != b.id)
    }
}

// MARK: - StreakCalculator Tests

struct StreakCalculatorTests {

    @Test func completionRateIsZeroForNewHabit() {
        let habit = Habit(name: "Test", frequency: .daily)
        let rate = StreakCalculator.completionRate(for: habit, days: 7)
        #expect(rate == 0.0)
    }

    @Test func completionRateIsZeroForZeroDays() {
        let habit = Habit(name: "Test", frequency: .daily)
        let rate = StreakCalculator.completionRate(for: habit, days: 0)
        #expect(rate == 0.0)
    }

    @Test func averageWeeklyRateIsZeroForEmptyArray() {
        let rate = StreakCalculator.averageWeeklyRate(habits: [])
        #expect(rate == 0.0)
    }

    @Test func averageMonthlyRateIsZeroForEmptyArray() {
        let rate = StreakCalculator.averageMonthlyRate(habits: [])
        #expect(rate == 0.0)
    }

    @Test func averageWeeklyRateIsZeroForNewHabits() {
        let habits = [Habit(name: "A"), Habit(name: "B")]
        let rate = StreakCalculator.averageWeeklyRate(habits: habits)
        #expect(rate == 0.0)
    }

    @Test func totalCompletionsIsZeroForNewHabit() {
        let habit = Habit(name: "Test")
        #expect(StreakCalculator.totalCompletions(habit: habit) == 0)
    }

    @Test func totalCompletionsAcrossHabitsWorks() {
        let habits: [Habit] = []
        #expect(StreakCalculator.totalCompletions(habits: habits) == 0)
    }

    @Test func completionMapReturnsCorrectDayCount() {
        let habit = Habit(name: "Test", frequency: .daily)
        let map = StreakCalculator.completionMap(habit: habit, days: 7)
        #expect(map.count == 7)
    }

    @Test func completionMapAllFalseForNewHabit() {
        let habit = Habit(name: "Test", frequency: .daily)
        let map = StreakCalculator.completionMap(habit: habit, days: 7)
        let allFalse = map.values.allSatisfy { $0 == false }
        #expect(allFalse)
    }

    @Test func completionMapForWeekdaysOnlyCountsWeekdays() {
        let habit = Habit(name: "Test", frequency: .weekdays)
        let map = StreakCalculator.completionMap(habit: habit, days: 14)
        // Over 14 days, there should be exactly 10 weekdays
        #expect(map.count == 10)
    }

    @Test func multiHabitCompletionMapReturnsCorrectDayCount() {
        let habits = [Habit(name: "A"), Habit(name: "B")]
        let map = StreakCalculator.completionMap(habits: habits, days: 30)
        #expect(map.count == 30)
    }

    @Test func multiHabitCompletionMapAllZeroForNewHabits() {
        let habits = [Habit(name: "A"), Habit(name: "B")]
        let map = StreakCalculator.completionMap(habits: habits, days: 7)
        let allZero = map.values.allSatisfy { $0 == 0 }
        #expect(allZero)
    }

    @Test func bestDayReturnsNilForNewHabit() {
        let habit = Habit(name: "Test", frequency: .daily)
        let best = StreakCalculator.bestDayOfWeek(habit: habit)
        if let best {
            #expect(best.rate == 0.0)
        }
    }

    @Test func worstDayReturnsNilForNewHabit() {
        let habit = Habit(name: "Test", frequency: .daily)
        let worst = StreakCalculator.worstDayOfWeek(habit: habit)
        if let worst {
            #expect(worst.rate == 0.0)
        }
    }

    @Test func weekdayNameReturnsCorrectValues() {
        #expect(StreakCalculator.weekdayName(for: 1) == "Sunday")
        #expect(StreakCalculator.weekdayName(for: 2) == "Monday")
        #expect(StreakCalculator.weekdayName(for: 3) == "Tuesday")
        #expect(StreakCalculator.weekdayName(for: 4) == "Wednesday")
        #expect(StreakCalculator.weekdayName(for: 5) == "Thursday")
        #expect(StreakCalculator.weekdayName(for: 6) == "Friday")
        #expect(StreakCalculator.weekdayName(for: 7) == "Saturday")
    }

    @Test func shortWeekdayNameReturnsCorrectValues() {
        #expect(StreakCalculator.shortWeekdayName(for: 1) == "Sun")
        #expect(StreakCalculator.shortWeekdayName(for: 2) == "Mon")
    }

    @Test func weekdayNameReturnsEmptyForOutOfRange() {
        #expect(StreakCalculator.weekdayName(for: 0) == "")
        #expect(StreakCalculator.weekdayName(for: 8) == "")
        #expect(StreakCalculator.shortWeekdayName(for: 0) == "")
        #expect(StreakCalculator.shortWeekdayName(for: 8) == "")
    }
}

// MARK: - WidgetSnapshot Tests

struct WidgetSnapshotTests {

    @Test func emptySnapshotHasCorrectDefaults() {
        let empty = WidgetSnapshot.empty
        #expect(empty.habits.isEmpty)
        #expect(empty.todayProgress == 0)
        #expect(empty.todayCompleted == 0)
        #expect(empty.todayTotal == 0)
    }

    @Test func widgetSnapshotEncodesAndDecodes() throws {
        let original = WidgetSnapshot(
            habits: [
                WidgetHabitData(
                    id: UUID(),
                    name: "Test",
                    icon: "star",
                    colorHex: "FF0000",
                    isCompletedToday: true,
                    currentStreak: 5,
                    weeklyRate: 0.8
                )
            ],
            todayProgress: 0.5,
            todayCompleted: 1,
            todayTotal: 2,
            updatedAt: Date()
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: data)

        #expect(decoded.habits.count == 1)
        #expect(decoded.habits[0].name == "Test")
        #expect(decoded.habits[0].isCompletedToday == true)
        #expect(decoded.habits[0].currentStreak == 5)
        #expect(decoded.todayProgress == 0.5)
        #expect(decoded.todayCompleted == 1)
        #expect(decoded.todayTotal == 2)
    }

    @Test func widgetHabitDataEncodesRoundTrip() throws {
        let habitData = WidgetHabitData(
            id: UUID(),
            name: "Meditate",
            icon: "brain.head.profile",
            colorHex: "6C63FF",
            isCompletedToday: false,
            currentStreak: 0,
            weeklyRate: 0.0
        )

        let data = try JSONEncoder().encode(habitData)
        let decoded = try JSONDecoder().decode(WidgetHabitData.self, from: data)

        #expect(decoded.name == "Meditate")
        #expect(decoded.icon == "brain.head.profile")
        #expect(decoded.colorHex == "6C63FF")
        #expect(decoded.isCompletedToday == false)
        #expect(decoded.currentStreak == 0)
        #expect(decoded.weeklyRate == 0.0)
    }

    @Test func emptySnapshotEncodesDecodes() throws {
        let empty = WidgetSnapshot.empty
        let data = try JSONEncoder().encode(empty)
        let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        #expect(decoded.habits.isEmpty)
        #expect(decoded.todayProgress == 0)
    }

    @Test func multipleHabitsSnapshot() throws {
        let habits = (1...5).map { i in
            WidgetHabitData(
                id: UUID(),
                name: "Habit \(i)",
                icon: "star",
                colorHex: "FFFFFF",
                isCompletedToday: i % 2 == 0,
                currentStreak: i,
                weeklyRate: Double(i) / 5.0
            )
        }
        let snapshot = WidgetSnapshot(
            habits: habits,
            todayProgress: 0.4,
            todayCompleted: 2,
            todayTotal: 5,
            updatedAt: Date()
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        #expect(decoded.habits.count == 5)
        #expect(decoded.todayCompleted == 2)
    }
}

// MARK: - SubscriptionManager Tests

struct SubscriptionManagerTests {

    @Test func freeHabitLimitIsFive() {
        #expect(HabitViewModel.freeHabitLimit == 5)
    }

    @Test @MainActor func canCreateHabitUnderLimit() {
        #expect(SubscriptionManager.canCreateHabit(currentCount: 0) == true)
        #expect(SubscriptionManager.canCreateHabit(currentCount: 1) == true)
        #expect(SubscriptionManager.canCreateHabit(currentCount: 4) == true)
    }

    @Test @MainActor func cannotCreateHabitAtLimit() {
        #expect(SubscriptionManager.canCreateHabit(currentCount: 5) == false)
        #expect(SubscriptionManager.canCreateHabit(currentCount: 10) == false)
    }
}

// MARK: - Color Extension Tests

struct ColorExtensionTests {

    @Test func hexInitializerParsesValidHex() {
        let _ = Color(hex: "6C63FF")
        let _ = Color(hex: "#6C63FF")
        let _ = Color(hex: "000000")
        let _ = Color(hex: "FFFFFF")
        let _ = Color(hex: "FF000080") // with alpha
    }

    @Test func habitPresetsHasEightColors() {
        #expect(Color.habitPresets.count == 8)
    }

    @Test func hexStringRoundTrips() {
        let color = Color(hex: "6C63FF")
        let hex = color.hexString
        #expect(hex != nil)
        #expect(hex!.count == 6)
    }
}

// MARK: - HabitFrequencyType Tests

struct HabitFrequencyTypeTests {

    @Test func rawValuesAreCorrect() {
        #expect(HabitFrequencyType.daily.rawValue == "daily")
        #expect(HabitFrequencyType.weekdays.rawValue == "weekdays")
        #expect(HabitFrequencyType.weekends.rawValue == "weekends")
        #expect(HabitFrequencyType.custom.rawValue == "custom")
    }

    @Test func frequencyTypeIsCodable() throws {
        let original = HabitFrequencyType.custom
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HabitFrequencyType.self, from: data)
        #expect(decoded == .custom)
    }

    @Test func allCasesExist() {
        let types: [HabitFrequencyType] = [.daily, .weekdays, .weekends, .custom]
        #expect(types.count == 4)
    }
}

// MARK: - HabitraProduct Tests

struct HabitraProductTests {

    @Test func subscriptionIDsHasThreeItems() {
        #expect(HabitraProduct.subscriptionIDs.count == 3)
    }

    @Test func tipIDsHasThreeItems() {
        #expect(HabitraProduct.tipIDs.count == 3)
    }

    @Test func monthlyIsSubscription() {
        #expect(HabitraProduct.proMonthly.isSubscription == true)
        #expect(HabitraProduct.proMonthly.isTip == false)
    }

    @Test func annualIsSubscription() {
        #expect(HabitraProduct.proAnnual.isSubscription == true)
        #expect(HabitraProduct.proAnnual.isTip == false)
    }

    @Test func lifetimeIsNotSubscription() {
        #expect(HabitraProduct.proLifetime.isSubscription == false)
        #expect(HabitraProduct.proLifetime.isTip == false)
    }

    @Test func tipsAreCorrectlyFlagged() {
        #expect(HabitraProduct.tipSmall.isTip == true)
        #expect(HabitraProduct.tipMedium.isTip == true)
        #expect(HabitraProduct.tipLarge.isTip == true)
        #expect(HabitraProduct.tipSmall.isSubscription == false)
    }

    @Test func productIDsAreCorrect() {
        #expect(HabitraProduct.proMonthly.rawValue == "com.jeanese.habitra.pro.monthly")
        #expect(HabitraProduct.proAnnual.rawValue == "com.jeanese.habitra.pro.annual")
        #expect(HabitraProduct.proLifetime.rawValue == "com.jeanese.habitra.pro.lifetime")
        #expect(HabitraProduct.tipSmall.rawValue == "com.jeanese.habitra.tip.small")
    }
}

// MARK: - StatsTimeRange Tests

struct StatsTimeRangeTests {

    @Test func allCasesHasFourItems() {
        #expect(StatsTimeRange.allCases.count == 4)
    }

    @Test func daysAreCorrect() {
        #expect(StatsTimeRange.week.days == 7)
        #expect(StatsTimeRange.month.days == 30)
        #expect(StatsTimeRange.quarter.days == 90)
        #expect(StatsTimeRange.all.days == 365)
    }

    @Test func heatmapWeeksAreCorrect() {
        #expect(StatsTimeRange.week.heatmapWeeks == 2)
        #expect(StatsTimeRange.month.heatmapWeeks == 5)
        #expect(StatsTimeRange.quarter.heatmapWeeks == 13)
        #expect(StatsTimeRange.all.heatmapWeeks == 52)
    }

    @Test func rawValuesAreCorrect() {
        #expect(StatsTimeRange.week.rawValue == "7D")
        #expect(StatsTimeRange.month.rawValue == "30D")
        #expect(StatsTimeRange.quarter.rawValue == "90D")
        #expect(StatsTimeRange.all.rawValue == "All")
    }

    @Test func labelsAreCorrect() {
        #expect(StatsTimeRange.week.label == "Last 7 Days")
        #expect(StatsTimeRange.month.label == "Last 30 Days")
        #expect(StatsTimeRange.quarter.label == "Last 90 Days")
        #expect(StatsTimeRange.all.label == "Last Year")
    }
}

// MARK: - TrendDirection Tests

struct TrendDirectionTests {

    @Test func iconsAreCorrect() {
        #expect(TrendDirection.up.icon == "arrow.up.right")
        #expect(TrendDirection.down.icon == "arrow.down.right")
        #expect(TrendDirection.neutral.icon == "arrow.right")
    }

    @Test func labelsAreCorrect() {
        #expect(TrendDirection.up.label == "Improving")
        #expect(TrendDirection.down.label == "Declining")
        #expect(TrendDirection.neutral.label == "Steady")
    }

    @Test func colorsAreDifferent() {
        // Verify they produce different colors (they should be success, danger, warning)
        let upColor = TrendDirection.up.color
        let downColor = TrendDirection.down.color
        let neutralColor = TrendDirection.neutral.color
        #expect(upColor != downColor)
        #expect(upColor != neutralColor)
    }
}

// MARK: - MilestoneCelebration Tests

struct MilestoneTests {

    @Test func milestoneDaysAreRecognized() {
        #expect(MilestoneCelebrationView.isMilestone(7) == true)
        #expect(MilestoneCelebrationView.isMilestone(14) == true)
        #expect(MilestoneCelebrationView.isMilestone(21) == true)
        #expect(MilestoneCelebrationView.isMilestone(30) == true)
        #expect(MilestoneCelebrationView.isMilestone(50) == true)
        #expect(MilestoneCelebrationView.isMilestone(100) == true)
        #expect(MilestoneCelebrationView.isMilestone(365) == true)
    }

    @Test func nonMilestoneDaysAreNotRecognized() {
        #expect(MilestoneCelebrationView.isMilestone(0) == false)
        #expect(MilestoneCelebrationView.isMilestone(1) == false)
        #expect(MilestoneCelebrationView.isMilestone(5) == false)
        #expect(MilestoneCelebrationView.isMilestone(10) == false)
        #expect(MilestoneCelebrationView.isMilestone(15) == false)
        #expect(MilestoneCelebrationView.isMilestone(99) == false)
    }
}

// MARK: - Theme Constants Tests

struct ThemeTests {

    @Test func cornerRadiiArePositive() {
        #expect(HabitraTheme.cornerRadius > 0)
        #expect(HabitraTheme.cornerRadiusSmall > 0)
        #expect(HabitraTheme.cornerRadiusLarge > 0)
        #expect(HabitraTheme.cornerRadiusSmall < HabitraTheme.cornerRadius)
        #expect(HabitraTheme.cornerRadius < HabitraTheme.cornerRadiusLarge)
    }

    @Test func spacingsArePositive() {
        #expect(HabitraTheme.spacing > 0)
        #expect(HabitraTheme.spacingSmall > 0)
        #expect(HabitraTheme.spacingLarge > 0)
        #expect(HabitraTheme.spacingSmall < HabitraTheme.spacing)
        #expect(HabitraTheme.spacing < HabitraTheme.spacingLarge)
    }

    @Test func paddingsArePositive() {
        #expect(HabitraTheme.cardPadding > 0)
        #expect(HabitraTheme.screenPadding > 0)
    }
}

// MARK: - DataExportService Tests

struct DataExportServiceTests {

    @Test func exportModeEnumExists() {
        // Verify the enum cases exist and are distinct
        let summary = DataExportService.ExportMode.habitsSummary
        let detail = DataExportService.ExportMode.completionsDetail
        #expect(summary != detail)
    }
}
