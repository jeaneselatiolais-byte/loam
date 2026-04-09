//
//  SeasonalBadgeEngine.swift
//  Habitra
//
//  Provides seasonal badge definitions based on the current calendar month.
//  Seasonal badges are only visible and earnable during their active season.
//  Pro-only feature gated via SubscriptionManager.
//

import Foundation

enum SeasonalBadgeEngine {

    // MARK: - Season Detection

    enum Season: String {
        case spring, summer, fall, winter

        static func current(for date: Date = Date()) -> Season {
            let month = Calendar.current.component(.month, from: date)
            switch month {
            case 3...5:  return .spring
            case 6...8:  return .summer
            case 9...11: return .fall
            default:     return .winter
            }
        }
    }

    // MARK: - Current Season Badges

    static func currentSeasonBadges(for date: Date = Date()) -> [BadgeDefinition] {
        let season = Season.current(for: date)
        return allSeasonalBadges.filter { badge in
            seasonForBadge(badge.id) == season
        }
    }

    // MARK: - All Seasonal Badges (for collection evaluation)

    static let allSeasonalBadges: [BadgeDefinition] = springBadges + summerBadges + fallBadges + winterBadges

    // MARK: - Spring (Mar–May)

    private static let springBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "spring_awakening",
            name: "Spring Awakening",
            description: "Complete all habits every day for 7 consecutive days during spring.",
            icon: "leaf.fill",
            colorHex: "4ADE80",
            category: .seasonal,
            simulatedRarity: 0.15
        ),
        BadgeDefinition(
            id: "blossom",
            name: "Blossom",
            description: "Create a new habit and build a 14-day streak on it during spring.",
            icon: "camera.macro.circle.fill",
            colorHex: "F472B6",
            category: .seasonal,
            simulatedRarity: 0.12
        ),
    ]

    // MARK: - Summer (Jun–Aug)

    private static let summerBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "summer_streak",
            name: "Summer Streak",
            description: "Maintain any 30-day streak during summer.",
            icon: "sun.max.fill",
            colorHex: "FB923C",
            category: .seasonal,
            simulatedRarity: 0.18
        ),
        BadgeDefinition(
            id: "heat_wave",
            name: "Heat Wave",
            description: "Complete all habits before noon for 5 days during summer.",
            icon: "thermometer.sun.fill",
            colorHex: "F87171",
            category: .seasonal,
            simulatedRarity: 0.10
        ),
    ]

    // MARK: - Fall (Sep–Nov)

    private static let fallBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "harvest",
            name: "Harvest",
            description: "Earn 10 badges during fall. Reap what you sow.",
            icon: "leaf.arrow.circlepath",
            colorHex: "CD7F32",
            category: .seasonal,
            simulatedRarity: 0.08
        ),
        BadgeDefinition(
            id: "golden_hour",
            name: "Golden Hour",
            description: "Complete a habit between 5-7 PM on 10 different days during fall.",
            icon: "sunset.fill",
            colorHex: "F59E0B",
            category: .seasonal,
            simulatedRarity: 0.12
        ),
    ]

    // MARK: - Winter (Dec–Feb)

    private static let winterBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "winter_warrior",
            name: "Winter Warrior",
            description: "Zero missed days for 21 consecutive days during winter.",
            icon: "snowflake.circle.fill",
            colorHex: "22D3EE",
            category: .seasonal,
            simulatedRarity: 0.10
        ),
        BadgeDefinition(
            id: "snowflake",
            name: "Snowflake",
            description: "Maintain 5 active habits simultaneously during winter.",
            icon: "snowflake",
            colorHex: "C0C0C0",
            category: .seasonal,
            simulatedRarity: 0.20
        ),
    ]

    // MARK: - Helpers

    private static func seasonForBadge(_ id: String) -> Season {
        switch id {
        case "spring_awakening", "blossom": return .spring
        case "summer_streak", "heat_wave":  return .summer
        case "harvest", "golden_hour":      return .fall
        case "winter_warrior", "snowflake": return .winter
        default: return .spring
        }
    }
}
