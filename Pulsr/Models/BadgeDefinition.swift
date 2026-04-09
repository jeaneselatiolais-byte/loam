//
//  BadgeDefinition.swift
//  Habitra
//
//  The full catalog of achievable badges.
//  Logic for *awarding* badges lives in BadgeEvaluator.
//

import Foundation

// MARK: - Category

enum BadgeCategory: String, CaseIterable, Identifiable {
    case streak      = "Streaks"
    case consistency = "Consistency"
    case milestone   = "Milestones"
    case comeback    = "Comebacks"
    case combo       = "Combos"
    case seasonal    = "Seasonal"
    case collection  = "Collections"
    case secret      = "Secret"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .streak:      return "flame.fill"
        case .consistency: return "checkmark.seal.fill"
        case .milestone:   return "star.fill"
        case .comeback:    return "arrow.counterclockwise.circle.fill"
        case .combo:       return "square.3.layers.3d.down.right"
        case .seasonal:    return "leaf.circle.fill"
        case .collection:  return "trophy.circle.fill"
        case .secret:      return "questionmark.circle.fill"
        }
    }
}

// MARK: - Tier

enum BadgeTier: String, CaseIterable, Comparable {
    case none, bronze, silver, gold, diamond

    static func < (lhs: BadgeTier, rhs: BadgeTier) -> Bool {
        let order: [BadgeTier] = [.none, .bronze, .silver, .gold, .diamond]
        return (order.firstIndex(of: lhs) ?? 0) < (order.firstIndex(of: rhs) ?? 0)
    }

    var colorHex: String {
        switch self {
        case .none:    return "6C63FF"
        case .bronze:  return "CD7F32"
        case .silver:  return "C0C0C0"
        case .gold:    return "F59E0B"
        case .diamond: return "22D3EE"
        }
    }

    var displayName: String {
        switch self {
        case .none:    return ""
        case .bronze:  return "Bronze"
        case .silver:  return "Silver"
        case .gold:    return "Gold"
        case .diamond: return "Diamond"
        }
    }
}

// MARK: - Definition

struct BadgeDefinition: Identifiable, Hashable {
    let id: String          // stable, used for dedup in EarnedBadge
    let name: String
    let description: String
    let icon: String        // SF Symbol
    let colorHex: String
    let category: BadgeCategory
    let isSecret: Bool      // hidden until earned
    let isPerHabit: Bool    // can be earned once per habit (vs. once globally)
    let tier: BadgeTier
    let tierGroup: String?  // groups related tiers (e.g., all Perfect Week tiers share "perfect_week")
    let simulatedRarity: Double // 0.0 to 1.0 — simulated % of users who earned this

    init(
        id: String,
        name: String,
        description: String,
        icon: String,
        colorHex: String,
        category: BadgeCategory,
        isSecret: Bool = false,
        isPerHabit: Bool = false,
        tier: BadgeTier = .none,
        tierGroup: String? = nil,
        simulatedRarity: Double = 0.5
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.colorHex = colorHex
        self.category = category
        self.isSecret = isSecret
        self.isPerHabit = isPerHabit
        self.tier = tier
        self.tierGroup = tierGroup
        self.simulatedRarity = simulatedRarity
    }

    static func == (lhs: BadgeDefinition, rhs: BadgeDefinition) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Catalog

enum BadgeCatalog {

    // MARK: All badges (static + seasonal)

    static let all: [BadgeDefinition] = {
        var badges = streakBadges + consistencyBadges + milestoneBadges
            + comebackBadges + comboBadges + collectionRewardBadges
            + monthlyChampionBadges + secretBadges
        badges += SeasonalBadgeEngine.currentSeasonBadges()
        return badges
    }()

    /// All badges including out-of-season ones (for collection evaluation)
    static let allEver: [BadgeDefinition] = {
        streakBadges + consistencyBadges + milestoneBadges
            + comebackBadges + comboBadges + collectionRewardBadges
            + monthlyChampionBadges + SeasonalBadgeEngine.allSeasonalBadges + secretBadges
    }()

    static func definition(for id: String) -> BadgeDefinition? {
        allEver.first { $0.id == id }
    }

    // MARK: - Streak (per-habit)

    static let streakBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "streak_first",
            name: "First Step",
            description: "Complete a habit for the very first time.",
            icon: "leaf.fill",
            colorHex: "4ADE80",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.95
        ),
        BadgeDefinition(
            id: "streak_7",
            name: "Week Warrior",
            description: "Keep a habit streak going for 7 days.",
            icon: "flame.fill",
            colorHex: "FB923C",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.65
        ),
        BadgeDefinition(
            id: "streak_14",
            name: "Two Weeks Strong",
            description: "Maintain a 14-day habit streak.",
            icon: "bolt.fill",
            colorHex: "FBBF24",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.45
        ),
        BadgeDefinition(
            id: "streak_30",
            name: "Monthly Champion",
            description: "Reach a 30-day streak on any habit.",
            icon: "trophy.fill",
            colorHex: "F59E0B",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.30
        ),
        BadgeDefinition(
            id: "streak_45",
            name: "Halfway There",
            description: "45 days strong. The habit is becoming you.",
            icon: "figure.walk.circle.fill",
            colorHex: "3B82F6",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.25
        ),
        BadgeDefinition(
            id: "streak_60",
            name: "Iron Will",
            description: "Sustain a 60-day streak. Unbreakable.",
            icon: "shield.fill",
            colorHex: "3B82F6",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.18
        ),
        BadgeDefinition(
            id: "streak_75",
            name: "Diamond Hands",
            description: "75 days. Nothing can shake you.",
            icon: "diamond.fill",
            colorHex: "22D3EE",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.15
        ),
        BadgeDefinition(
            id: "streak_100",
            name: "Century",
            description: "100 days in a row. Legendary.",
            icon: "crown.fill",
            colorHex: "22D3EE",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.08
        ),
        BadgeDefinition(
            id: "streak_150",
            name: "Marathon Runner",
            description: "150 consecutive days. Built different.",
            icon: "figure.run.circle.fill",
            colorHex: "A89AFF",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.05
        ),
        BadgeDefinition(
            id: "streak_200",
            name: "Legendary",
            description: "200 days without a miss. Truly elite.",
            icon: "medal.fill",
            colorHex: "F59E0B",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.03
        ),
        BadgeDefinition(
            id: "streak_250",
            name: "Titan",
            description: "250 days. You are an inspiration.",
            icon: "bolt.shield.fill",
            colorHex: "F472B6",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.02
        ),
        BadgeDefinition(
            id: "streak_365",
            name: "Year Strong",
            description: "365 consecutive days. You are the habit.",
            icon: "sparkles",
            colorHex: "A89AFF",
            category: .streak,
            isPerHabit: true,
            simulatedRarity: 0.01
        ),
    ]

    // MARK: - Consistency (global)

    static let consistencyBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "perfect_day",
            name: "Full House",
            description: "Complete every scheduled habit in a single day.",
            icon: "checkmark.circle.fill",
            colorHex: "4ADE80",
            category: .consistency,
            simulatedRarity: 0.70
        ),
        BadgeDefinition(
            id: "perfect_week",
            name: "Perfect Week",
            description: "Complete all scheduled habits every day for 7 days.",
            icon: "calendar.badge.checkmark",
            colorHex: "6C63FF",
            category: .consistency,
            simulatedRarity: 0.35
        ),
        // Tiered Perfect Week
        BadgeDefinition(
            id: "perfect_week_bronze",
            name: "Perfect Week II",
            description: "Earn 4 Perfect Weeks total.",
            icon: "calendar.badge.checkmark",
            colorHex: "CD7F32",
            category: .consistency,
            tier: .bronze,
            tierGroup: "perfect_week",
            simulatedRarity: 0.20
        ),
        BadgeDefinition(
            id: "perfect_week_silver",
            name: "Perfect Week III",
            description: "Earn 12 Perfect Weeks total.",
            icon: "calendar.badge.checkmark",
            colorHex: "C0C0C0",
            category: .consistency,
            tier: .silver,
            tierGroup: "perfect_week",
            simulatedRarity: 0.08
        ),
        BadgeDefinition(
            id: "perfect_week_gold",
            name: "Perfect Week IV",
            description: "Earn 52 Perfect Weeks total. A year of perfection.",
            icon: "calendar.badge.checkmark",
            colorHex: "F59E0B",
            category: .consistency,
            tier: .gold,
            tierGroup: "perfect_week",
            simulatedRarity: 0.02
        ),
        BadgeDefinition(
            id: "unstoppable",
            name: "Unstoppable",
            description: "Have 3 or more habits each on a 30-day+ streak simultaneously.",
            icon: "figure.run.circle.fill",
            colorHex: "F59E0B",
            category: .consistency,
            simulatedRarity: 0.12
        ),
        BadgeDefinition(
            id: "early_bird",
            name: "Early Bird",
            description: "Complete a habit before 8 AM on 5 different days.",
            icon: "sunrise.fill",
            colorHex: "FB923C",
            category: .consistency,
            simulatedRarity: 0.40
        ),
        // Tiered Streak Master
        BadgeDefinition(
            id: "streak_master_bronze",
            name: "Multi-Streak I",
            description: "Have 3 habits at 7+ day streaks simultaneously.",
            icon: "flame.circle.fill",
            colorHex: "CD7F32",
            category: .consistency,
            tier: .bronze,
            tierGroup: "streak_master",
            simulatedRarity: 0.35
        ),
        BadgeDefinition(
            id: "streak_master_silver",
            name: "Multi-Streak II",
            description: "Have 3 habits at 30+ day streaks simultaneously.",
            icon: "flame.circle.fill",
            colorHex: "C0C0C0",
            category: .consistency,
            tier: .silver,
            tierGroup: "streak_master",
            simulatedRarity: 0.10
        ),
        BadgeDefinition(
            id: "streak_master_gold",
            name: "Multi-Streak III",
            description: "Have 5 habits at 60+ day streaks simultaneously.",
            icon: "flame.circle.fill",
            colorHex: "F59E0B",
            category: .consistency,
            tier: .gold,
            tierGroup: "streak_master",
            simulatedRarity: 0.02
        ),
    ]

    // MARK: - Milestone (global, one-time)

    static let milestoneBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "habit_builder",
            name: "Habit Builder",
            description: "Create 5 or more habits.",
            icon: "square.stack.3d.up.fill",
            colorHex: "3B82F6",
            category: .milestone,
            simulatedRarity: 0.55
        ),
        BadgeDefinition(
            id: "health_synced",
            name: "Health Synced",
            description: "Auto-complete a habit via Apple Health for the first time.",
            icon: "heart.fill",
            colorHex: "F472B6",
            category: .milestone,
            simulatedRarity: 0.25
        ),
        BadgeDefinition(
            id: "note_taker",
            name: "Journal Entry",
            description: "Add notes to 10 habit completions.",
            icon: "pencil.and.outline",
            colorHex: "22D3EE",
            category: .milestone,
            simulatedRarity: 0.30
        ),
    ]

    // MARK: - Comeback (global)

    static let comebackBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "comeback_kid",
            name: "Comeback Kid",
            description: "Complete a habit after missing 3 or more days in a row.",
            icon: "arrow.counterclockwise.circle.fill",
            colorHex: "FBBF24",
            category: .comeback,
            simulatedRarity: 0.50
        ),
        BadgeDefinition(
            id: "phoenix",
            name: "Phoenix",
            description: "Rebuild a 7-day streak on a habit you previously broke.",
            icon: "flame.circle.fill",
            colorHex: "F87171",
            category: .comeback,
            simulatedRarity: 0.25
        ),
    ]

    // MARK: - Combo (global)

    static let comboBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "combo_streak_trio",
            name: "Streak Trio",
            description: "Earn 3 different streak badges in the same calendar week.",
            icon: "3.circle.fill",
            colorHex: "FB923C",
            category: .combo,
            simulatedRarity: 0.15
        ),
        BadgeDefinition(
            id: "combo_5x30",
            name: "Five-Star General",
            description: "Have 5 habits at 30+ day streaks simultaneously.",
            icon: "star.leadinghalf.filled",
            colorHex: "F59E0B",
            category: .combo,
            simulatedRarity: 0.04
        ),
        BadgeDefinition(
            id: "combo_perfect_month",
            name: "Perfect Month",
            description: "Earn 4 Perfect Weeks in the same calendar month.",
            icon: "calendar.circle.fill",
            colorHex: "4ADE80",
            category: .combo,
            simulatedRarity: 0.06
        ),
        BadgeDefinition(
            id: "combo_category_sweep",
            name: "Category Sweep",
            description: "Complete all habits in every category on the same day.",
            icon: "square.grid.2x2.fill",
            colorHex: "6C63FF",
            category: .combo,
            simulatedRarity: 0.10
        ),
    ]

    // MARK: - Collection Rewards (global, one-time)

    static let collectionRewardBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "collection_streak_master",
            name: "Streak Collector",
            description: "Earn every streak badge on a single habit.",
            icon: "flame.fill",
            colorHex: "F59E0B",
            category: .collection,
            tier: .diamond,
            simulatedRarity: 0.01
        ),
        BadgeDefinition(
            id: "collection_consistency_crown",
            name: "Consistency Crown",
            description: "Complete the Consistency badge collection.",
            icon: "crown.fill",
            colorHex: "6C63FF",
            category: .collection,
            tier: .diamond,
            simulatedRarity: 0.02
        ),
        BadgeDefinition(
            id: "collection_night_shift",
            name: "Night Shift Complete",
            description: "Earn all night-themed badges.",
            icon: "moon.stars.circle.fill",
            colorHex: "A89AFF",
            category: .collection,
            tier: .gold,
            simulatedRarity: 0.08
        ),
        BadgeDefinition(
            id: "collection_comeback_complete",
            name: "Resilience Master",
            description: "Earn all comeback badges.",
            icon: "arrow.triangle.2.circlepath.circle.fill",
            colorHex: "FBBF24",
            category: .collection,
            tier: .gold,
            simulatedRarity: 0.10
        ),
        BadgeDefinition(
            id: "collection_secret_agent",
            name: "Secret Agent",
            description: "Discover every secret badge.",
            icon: "eye.circle.fill",
            colorHex: "F472B6",
            category: .collection,
            tier: .diamond,
            simulatedRarity: 0.03
        ),
        BadgeDefinition(
            id: "collection_monthly_champion",
            name: "Year of Champions",
            description: "Complete monthly quests for all 12 months.",
            icon: "globe.americas.fill",
            colorHex: "22D3EE",
            category: .collection,
            tier: .diamond,
            simulatedRarity: 0.01
        ),
    ]

    // MARK: - Monthly Champion (quest rewards)

    static let monthlyChampionBadges: [BadgeDefinition] = {
        let months = [
            ("jan", "January",   "snowflake.circle.fill", "22D3EE"),
            ("feb", "February",  "heart.circle.fill",     "F472B6"),
            ("mar", "March",     "leaf.circle.fill",      "4ADE80"),
            ("apr", "April",     "cloud.rain.circle.fill", "3B82F6"),
            ("may", "May",       "sun.max.circle.fill",   "FBBF24"),
            ("jun", "June",      "flame.circle.fill",     "FB923C"),
            ("jul", "July",      "star.circle.fill",      "F87171"),
            ("aug", "August",    "bolt.circle.fill",       "F59E0B"),
            ("sep", "September", "leaf.arrow.circlepath",  "CD7F32"),
            ("oct", "October",   "moon.circle.fill",       "A89AFF"),
            ("nov", "November",  "wind.circle.fill",       "C0C0C0"),
            ("dec", "December",  "sparkle.magnifyingglass", "22D3EE"),
        ]
        return months.map { (key, name, icon, color) in
            BadgeDefinition(
                id: "monthly_champion_\(key)",
                name: "\(name) Champion",
                description: "Complete the \(name) monthly quest.",
                icon: icon,
                colorHex: color,
                category: .milestone,
                simulatedRarity: 0.08
            )
        }
    }()

    // MARK: - Secret

    static let secretBadges: [BadgeDefinition] = [
        BadgeDefinition(
            id: "night_owl",
            name: "Night Owl",
            description: "Complete a habit after 11 PM.",
            icon: "moon.stars.fill",
            colorHex: "6C63FF",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.35
        ),
        BadgeDefinition(
            id: "overachiever",
            name: "Overachiever",
            description: "Complete a multi-rep habit at double the required reps.",
            icon: "star.circle.fill",
            colorHex: "F59E0B",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.20
        ),
        BadgeDefinition(
            id: "streak_saver",
            name: "Streak Saver",
            description: "Complete all your habits after 9 PM on a day you almost missed.",
            icon: "clock.badge.checkmark.fill",
            colorHex: "A89AFF",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.25
        ),
        BadgeDefinition(
            id: "holiday_hero",
            name: "Holiday Hero",
            description: "Complete all your habits on a major holiday. No days off!",
            icon: "gift.circle.fill",
            colorHex: "F87171",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.15
        ),
        BadgeDefinition(
            id: "full_month",
            name: "Full Month",
            description: "Complete every habit every day for an entire calendar month.",
            icon: "calendar.circle.fill",
            colorHex: "4ADE80",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.05
        ),
        BadgeDefinition(
            id: "palindrome_date",
            name: "Palindrome",
            description: "Complete a habit on a palindrome date.",
            icon: "arrow.left.arrow.right.circle.fill",
            colorHex: "22D3EE",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.20
        ),
        BadgeDefinition(
            id: "friday_13th",
            name: "Fearless",
            description: "Complete all habits on Friday the 13th.",
            icon: "13.circle.fill",
            colorHex: "F87171",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.18
        ),
        BadgeDefinition(
            id: "new_year_new_me",
            name: "New Year, New Me",
            description: "Complete all habits on January 1st.",
            icon: "party.popper.fill",
            colorHex: "F59E0B",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.12
        ),
        BadgeDefinition(
            id: "triple_seven",
            name: "Lucky Seven",
            description: "Have 7 habits at 7+ day streaks on the 7th of any month.",
            icon: "7.circle.fill",
            colorHex: "FBBF24",
            category: .secret,
            isSecret: true,
            simulatedRarity: 0.02
        ),
    ]
}
