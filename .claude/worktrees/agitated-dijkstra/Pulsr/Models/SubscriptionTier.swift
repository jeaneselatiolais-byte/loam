//
//  SubscriptionTier.swift
//  Pulsr
//
//  Created by Jeanese Raymond on 3/31/26.
//

import Foundation

enum SubscriptionTier: String, CaseIterable, Identifiable {
    case free
    case monthly
    case annual
    case lifetime

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .monthly:
            return "Monthly"
        case .annual:
            return "Annual"
        case .lifetime:
            return "Lifetime"
        }
    }

    var price: String {
        switch self {
        case .free:
            return "Free"
        case .monthly:
            return "$2.99"
        case .annual:
            return "$29.99"
        case .lifetime:
            return "$79.99"
        }
    }

    var billingPeriod: String {
        switch self {
        case .free:
            return "Forever free"
        case .monthly:
            return "per month"
        case .annual:
            return "per year"
        case .lifetime:
            return "one-time purchase"
        }
    }

    var productId: String? {
        switch self {
        case .free:
            return nil
        case .monthly:
            return "com.jeanese.tethyr.subscription.monthly"
        case .annual:
            return "com.jeanese.tethyr.subscription.annual"
        case .lifetime:
            return "com.jeanese.tethyr.subscription.lifetime"
        }
    }

    var features: [String] {
        switch self {
        case .free:
            return [
                "✓ Track up to 5 habits",
                "✓ Basic streak tracking",
                "✓ Daily check-ins",
                "✓ Simple statistics",
            ]
        case .monthly, .annual, .lifetime:
            return [
                "✓ Unlimited habits",
                "✓ AI predictions & coaching",
                "✓ Mood tracking & insights",
                "✓ HealthKit integration",
                "✓ iCloud sync",
                "✓ CSV export",
                "✓ Custom themes",
                "✓ Priority support",
            ]
        }
    }

    var badgeText: String? {
        switch self {
        case .annual:
            return "Best value"
        case .lifetime:
            return "All features forever"
        default:
            return nil
        }
    }

    var isBestValue: Bool {
        return self == .annual
    }

    var isFree: Bool {
        return self == .free
    }

    var isPro: Bool {
        return self != .free
    }
}
