//
//  FeatureAvailability.swift
//  Habitra
//
//  Created by Jeanese Raymond on 2026-04-11.
//
//  v1.0 ships FREE-ONLY. All Pro features below are hidden from the UI via
//  these flags (NOT via SubscriptionManager, which is preserved for when
//  paid tiers return).
//
//  To re-enable a feature: flip the flag to `true` and un-hide its UI entry
//  points (grep for "FeatureAvailability" or the marker comment
//  "v1.0: hidden via FeatureAvailability").
//
//  See docs/RELEASE_STRATEGY.md for the full checklist.
//

import Foundation

/// Controls whether a feature is SHIPPED in the current build.
/// This is separate from `SubscriptionManager`, which controls ENTITLEMENT
/// (does the user own Pro). A feature must be both `available` AND `entitled`
/// for the user to access it. In v1.0, everything below is `false` so the
/// entitlement layer never gets consulted for these features.
enum FeatureAvailability {

    // MARK: - Hidden in v1.0 (planned for future releases)

    static let aiNudges: Bool          = false
    static let aiInsights: Bool        = false  // hides the "Coach" tab
    static let moodCheckin: Bool       = false
    static let healthKit: Bool         = false
    static let iCloudSync: Bool        = false
    static let allWidgets: Bool        = false
    static let exportCSV: Bool         = false
    static let customThemes: Bool      = false
    static let categories: Bool        = false
    static let quests: Bool            = false
    static let collections: Bool       = false
    static let seasonalBadges: Bool    = false

    // MARK: - Subscription availability

    /// Whether any paid subscription tier is offered for sale.
    /// v1.0: false — only the Tip Jar is available.
    static let subscriptionTiers: Bool = false
}
