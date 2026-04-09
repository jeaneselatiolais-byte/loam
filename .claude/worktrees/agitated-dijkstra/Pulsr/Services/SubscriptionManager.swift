//
//  SubscriptionManager.swift
//  Pulsr
//
//  Created by Jeanese Raymond on 3/31/26.
//

import Foundation

// MARK: - Feature Gating
@MainActor
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    private init() {}

    // MARK: - Pro Feature Gates

    /// Check if user can track unlimited habits (Pro feature)
    func canTrackUnlimitedHabits() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    /// Check if user can access mood tracking (Pro feature)
    func canAccessMoodTracking() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    /// Check if user can access HealthKit integration (Pro feature)
    func canAccessHealthKitIntegration() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    /// Check if user can access AI predictions (Pro feature)
    func canAccessAIPredictions() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    /// Check if user can export to CSV (Pro feature)
    func canExportToCSV() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    /// Check if user can use Cloud Sync (Pro feature)
    func canUseCloudSync() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    /// Check if user can use custom themes (Pro feature)
    func canUseCustomThemes() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    /// Check if user can create custom categories (Pro feature)
    func canUseCustomCategories() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    // MARK: - Habit Limits

    /// Maximum number of habits user can create
    func habitLimit() -> Int {
        if StoreKitManager.shared.entitlements.isAnyProActive {
            return Int.max // Unlimited for Pro users
        }
        return 5 // Free tier limit
    }

    /// Check if user has reached their habit limit
    func hasReachedHabitLimit(currentCount: Int) -> Bool {
        return currentCount >= habitLimit()
    }

    // MARK: - Subscription Status

    /// Check if user is currently subscribed to any Pro plan
    func isProSubscriber() -> Bool {
        return StoreKitManager.shared.entitlements.isAnyProActive
    }

    /// Check if user has a lifetime subscription
    func hasLifetimeSubscription() -> Bool {
        return StoreKitManager.shared.entitlements.hasLifetime
    }

    /// Get current subscription tier name
    func currentSubscriptionTier() -> String {
        let entitlements = StoreKitManager.shared.entitlements

        if entitlements.hasLifetime {
            return "Lifetime"
        } else if let subscription = entitlements.currentSubscription {
            return subscription.capitalized
        }

        return "Free"
    }

    /// Get subscription expiration date if applicable
    func subscriptionExpirationDate() -> Date? {
        return StoreKitManager.shared.entitlements.expirationDate
    }

    /// Check if annual subscription is in trial period
    func isInTrialPeriod() -> Bool {
        return StoreKitManager.shared.entitlements.isInTrial
    }

    // MARK: - Paywall Triggering

    /// Show paywall for attempting to access a Pro feature
    func showPaywallForProFeature(_ featureName: String) {
        // This would be called before showing a feature
        // The actual paywall presentation is handled in the view that uses this
        print("User attempted to access Pro feature: \(featureName)")
    }

    /// Get appropriate message for Pro feature restriction
    func getProFeatureMessage(_ featureName: String) -> String {
        return "Upgrade to Pro to unlock \(featureName)"
    }
}
