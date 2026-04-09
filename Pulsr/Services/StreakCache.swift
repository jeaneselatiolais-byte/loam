//
//  StreakCache.swift
//  Habitra
//
//  Phase 2 Week 4: Performance cache for streak and stats calculations
//

import Foundation

/// Caches expensive streak and completion-rate calculations.
/// Invalidated per-habit when completions change.
@MainActor
final class StreakCache {
    static let shared = StreakCache()

    private struct CacheEntry {
        let currentStreak: Int
        let longestStreak: Int
        let completionCount: Int
        let timestamp: Date
    }

    private var cache: [UUID: CacheEntry] = [:]
    private let maxAge: TimeInterval = 60 // 1 minute staleness window

    private init() {}

    // MARK: - Get or Compute

    func currentStreak(for habit: Habit) -> Int {
        if let entry = validEntry(for: habit) {
            return entry.currentStreak
        }
        let value = habit.currentStreak
        updateCache(for: habit)
        return value
    }

    func longestStreak(for habit: Habit) -> Int {
        if let entry = validEntry(for: habit) {
            return entry.longestStreak
        }
        let value = habit.longestStreak
        updateCache(for: habit)
        return value
    }

    // MARK: - Invalidation

    func invalidate(habitID: UUID) {
        cache.removeValue(forKey: habitID)
    }

    func invalidateAll() {
        cache.removeAll()
    }

    // MARK: - Internal

    private func validEntry(for habit: Habit) -> CacheEntry? {
        guard let entry = cache[habit.id] else { return nil }
        // Stale if too old or completion count changed
        if Date().timeIntervalSince(entry.timestamp) > maxAge {
            return nil
        }
        if entry.completionCount != habit.completions.count {
            return nil
        }
        return entry
    }

    private func updateCache(for habit: Habit) {
        cache[habit.id] = CacheEntry(
            currentStreak: habit.currentStreak,
            longestStreak: habit.longestStreak,
            completionCount: habit.completions.count,
            timestamp: Date()
        )
    }
}
