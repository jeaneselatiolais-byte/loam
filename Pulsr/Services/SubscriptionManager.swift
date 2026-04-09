//
//  SubscriptionManager.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation

/// Lightweight gate for Pro features.
/// Reads from StoreKitManager to determine entitlement.
@MainActor
enum SubscriptionManager {

    /// Whether the user has Pro access (subscription, lifetime, or trial)
    static var isPro: Bool {
        StoreKitManager.shared.isProUnlocked
    }

    /// Maximum habits allowed for the current tier
    static var habitLimit: Int {
        isPro ? .max : HabitViewModel.freeHabitLimit
    }

    /// Whether the user can create another habit
    static func canCreateHabit(currentCount: Int) -> Bool {
        currentCount < habitLimit
    }

    // MARK: - Feature Gates

    static var canUseAINudges: Bool { isPro }
    static var canUseMoodCheckin: Bool { isPro }
    static var canUseHealthKit: Bool { isPro }
    static var canUseiCloudSync: Bool { isPro }
    static var canUseAllWidgets: Bool { isPro }
    static var canExportCSV: Bool { isPro }
    static var canUseCustomThemes: Bool { isPro }
    static var canUseCategories: Bool { isPro }
    static var canUseQuests: Bool { isPro }
    static var canUseCollections: Bool { isPro }
    static var canUseSeasonalBadges: Bool { isPro }
}
