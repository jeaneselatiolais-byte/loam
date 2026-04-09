//
//  StoreKitManager.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation
import StoreKit

/// Product identifiers — must match App Store Connect configuration
enum HabitraProduct: String, CaseIterable {
    // Subscriptions — IDs must match App Store Connect exactly (case-sensitive)
    case proMonthly  = "com.jeanese.habitra.pro.monthly"
    case proAnnual   = "com.jeanese.habitra.pro.annual"
    case proLifetime = "com.jeanese.habitra.pro.lifetime"

    // Tip Jar (consumables)
    case tipSmall  = "com.jeanese.habitra.tip.small"   // $1.99
    case tipMedium = "com.jeanese.habitra.tip.medium"   // $4.99
    case tipLarge  = "com.jeanese.habitra.tip.large"    // $9.99

    var isSubscription: Bool {
        switch self {
        case .proMonthly, .proAnnual: return true
        default: return false
        }
    }

    var isTip: Bool {
        switch self {
        case .tipSmall, .tipMedium, .tipLarge: return true
        default: return false
        }
    }

    static var subscriptionIDs: [String] {
        [proMonthly.rawValue, proAnnual.rawValue, proLifetime.rawValue]
    }

    static var tipIDs: [String] {
        [tipSmall.rawValue, tipMedium.rawValue, tipLarge.rawValue]
    }
}

@MainActor
@Observable
final class StoreKitManager {
    static let shared = StoreKitManager()

    // Products
    private(set) var subscriptionProducts: [Product] = []
    private(set) var tipProducts: [Product] = []

    // Entitlement state
    // Set to true to test Pro features during development
    #if DEBUG
    private(set) var isProUnlocked: Bool = true
    #else
    private(set) var isProUnlocked: Bool = false
    #endif
    private(set) var currentSubscription: Product? = nil
    private(set) var hasLifetime: Bool = false

    // Purchase state
    private(set) var isPurchasing: Bool = false
    private(set) var purchaseError: String? = nil
    private(set) var loadError: String? = nil

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await updateEntitlements() }
    }

    // Note: transactionListener is cancelled when the singleton is deallocated (app termination)

    // MARK: - Load Products

    func loadProducts() async {
        loadError = nil
        do {
            let allIDs = HabitraProduct.subscriptionIDs + HabitraProduct.tipIDs
            print("Habitra: Loading products for IDs: \(allIDs)")
            let products = try await Product.products(for: Set(allIDs))
            print("Habitra: Loaded \(products.count) products: \(products.map { "\($0.id) — \($0.displayPrice)" })")

            subscriptionProducts = products
                .filter { HabitraProduct.subscriptionIDs.contains($0.id) }
                .sorted { $0.price < $1.price }

            tipProducts = products
                .filter { HabitraProduct.tipIDs.contains($0.id) }
                .sorted { $0.price < $1.price }

            print("Habitra: Subscription products: \(subscriptionProducts.count), Tip products: \(tipProducts.count)")

            if subscriptionProducts.isEmpty {
                loadError = "No subscription products returned from the App Store. Requested IDs: \(HabitraProduct.subscriptionIDs)"
                print("Habitra: WARNING — \(loadError!)")
            }
        } catch {
            loadError = error.localizedDescription
            print("Habitra: Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateEntitlements()
                isPurchasing = false
                return true

            case .userCancelled:
                isPurchasing = false
                return false

            case .pending:
                isPurchasing = false
                return false

            @unknown default:
                isPurchasing = false
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            isPurchasing = false
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        print("Habitra: Restoring purchases...")
        try? await AppStore.sync()
        await updateEntitlements()
        print("Habitra: Restore complete — isProUnlocked: \(isProUnlocked), hasLifetime: \(hasLifetime)")
    }

    // MARK: - Entitlement Check

    func updateEntitlements() async {
        var foundPro = false
        var foundLifetime = false
        var activeSub: Product? = nil

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }

            if transaction.productID == HabitraProduct.proLifetime.rawValue {
                foundLifetime = true
                foundPro = true
            } else if HabitraProduct.subscriptionIDs.contains(transaction.productID) {
                foundPro = true
                // Find the matching product
                activeSub = subscriptionProducts.first { $0.id == transaction.productID }
            }
        }

        isProUnlocked = foundPro
        hasLifetime = foundLifetime
        currentSubscription = activeSub
    }

    // MARK: - Helpers

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.updateEntitlements()
                }
            }
        }
    }

    // MARK: - Display Helpers

    /// Formatted price for a product
    func displayPrice(for product: Product) -> String {
        product.displayPrice
    }

    /// Find a product by HabitraProduct enum
    func product(for habitraProduct: HabitraProduct) -> Product? {
        let allProducts = subscriptionProducts + tipProducts
        return allProducts.first { $0.id == habitraProduct.rawValue }
    }
}
