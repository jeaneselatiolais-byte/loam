//
//  XPEngine.swift
//  Habitra
//
//  XP/Points system — awards experience points for habit completions and badges.
//  Stored in UserDefaults (not SwiftData) since it's a derived aggregate
//  that can be recalculated from completion history.
//

import Foundation
import SwiftData

struct XPGain {
    let base: Int
    let streakBonus: Int
    let perfectDayBonus: Int
    let total: Int
}

@MainActor
enum XPEngine {

    // MARK: - Constants

    static let baseCompletionXP = 10
    static let streakBonusPerDay = 2
    static let streakBonusCap = 50
    static let perfectDayBonusAmount = 25
    static let badgeBonusAmount = 100

    // MARK: - Level Curve

    /// Cumulative XP required to reach level N (1-indexed).
    /// Level 1 = 0 XP, Level 2 = 100, Level 3 = 275, Level 4 = 525, etc.
    static func xpForLevel(_ level: Int) -> Int {
        guard level > 1 else { return 0 }
        var total = 0
        for n in 2...level {
            total += n * 50 + (n - 1) * 25
        }
        return total
    }

    static var currentLevel: Int {
        let xp = lifetimeXP
        var level = 1
        while xpForLevel(level + 1) <= xp {
            level += 1
        }
        return level
    }

    /// Progress within the current level (0.0 to 1.0)
    static var xpProgressInLevel: Double {
        let xp = lifetimeXP
        let level = currentLevel
        let currentLevelXP = xpForLevel(level)
        let nextLevelXP = xpForLevel(level + 1)
        let range = nextLevelXP - currentLevelXP
        guard range > 0 else { return 1.0 }
        return Double(xp - currentLevelXP) / Double(range)
    }

    // MARK: - Award XP

    /// Award XP for completing a habit. Returns the XP breakdown.
    @discardableResult
    static func awardCompletion(habit: Habit, habits: [Habit]) -> XPGain {
        let base = baseCompletionXP
        let streakBonus = min(habit.currentStreak * streakBonusPerDay, streakBonusCap)

        // Perfect day bonus: check if all scheduled habits are now done
        let today = Calendar.current.startOfDay(for: Date())
        let scheduled = habits.filter { !$0.isArchived && $0.frequency.isScheduled(for: today) }
        let allDone = !scheduled.isEmpty && scheduled.allSatisfy { $0.isCompleted(on: today) }
        let perfectDay = allDone ? perfectDayBonusAmount : 0

        let total = base + streakBonus + perfectDay

        addXP(total)

        return XPGain(base: base, streakBonus: streakBonus, perfectDayBonus: perfectDay, total: total)
    }

    /// Award bonus XP for earning a badge.
    @discardableResult
    static func awardBadge() -> Int {
        addXP(badgeBonusAmount)
        return badgeBonusAmount
    }

    // MARK: - Backfill

    /// One-time backfill for existing users. Awards base XP for all completions
    /// and badge bonus for all earned badges.
    static func backfillIfNeeded(habits: [Habit], earnedBadges: [EarnedBadge]) {
        guard !UserDefaults.standard.bool(forKey: "habitra_xp_backfilled") else { return }

        let totalCompletions = habits.reduce(0) { $0 + $1.completions.count }
        let totalBadges = Set(earnedBadges.map(\.badgeID)).count

        let backfillXP = (totalCompletions * baseCompletionXP) + (totalBadges * badgeBonusAmount)
        if backfillXP > 0 {
            addXP(backfillXP)
        }

        UserDefaults.standard.set(true, forKey: "habitra_xp_backfilled")
    }

    // MARK: - Storage

    static var lifetimeXP: Int {
        get { UserDefaults.standard.integer(forKey: "habitra_lifetime_xp") }
    }

    static var todayXP: Int {
        UserDefaults.standard.integer(forKey: todayKey)
    }

    static var weekXP: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var total = 0
        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let key = dayKey(for: date)
            total += UserDefaults.standard.integer(forKey: key)
        }
        return total
    }

    @discardableResult
    private static func addXP(_ amount: Int) -> Int {
        let newLifetime = lifetimeXP + amount
        UserDefaults.standard.set(newLifetime, forKey: "habitra_lifetime_xp")

        let newToday = todayXP + amount
        UserDefaults.standard.set(newToday, forKey: todayKey)

        return newLifetime
    }

    private static var todayKey: String {
        dayKey(for: Date())
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "habitra_xp_\(formatter.string(from: date))"
    }
}
