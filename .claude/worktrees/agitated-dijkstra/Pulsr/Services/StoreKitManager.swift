//
//  StoreKitManager.swift
//  Pulsr
//
//  Created by Jeanese Raymond on 3/31/26.
//

import Foundation
import Combine
import StoreKit

// MARK: - Subscription Entitlements
struct SubscriptionEntitlements {
    var isProUnlocked: Bool = false          // Any active Pro subscription
    var hasLifetime: Bool = false            // Lifetime purchase
    var currentSubscription: String? = nil   // "monthly" or "annual"
    var expirationDate: Date? = nil          // Renewal/expiration date
    var isInTrial: Bool = false              // Annual plan trial status

    var isAnyProActive: Bool {
        return isProUnlocked || hasLifetime
    }
}

// MARK: - Purchase Error
enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed(String)
    case networkError
    case userCancelled
    case invalidTransaction
    case restoreFailed(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found in the App Store"
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        case .networkError:
            return "Network connection error. Please check your internet and try again."
        case .userCancelled:
            return "Purchase was cancelled"
        case .invalidTransaction:
            return "Transaction is invalid. Please try again."
        case .restoreFailed(let reason):
            return "Failed to restore purchases: \(reason)"
        case .unknown(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - StoreKitManager
@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var products: [Product] = []
    @Published var entitlements = SubscriptionEntitlements()
    @Published var isLoading = false
    @Published var purchaseError: PurchaseError? = nil

    private var updateListenerTask: Task<Void, Never>? = nil

    // Product IDs matching App Store Connect configuration
    private let subscriptionProductIds = [
        "com.jeanese.tethyr.subscription.monthly",
        "com.jeanese.tethyr.subscription.annual",
        "com.jeanese.tethyr.subscription.lifetime",
    ]

    private let consumableProductIds = [
        "com.jeanese.tethyr.tip.small",
        "com.jeanese.tethyr.tip.medium",
        "com.jeanese.tethyr.tip.large",
    ]

    private init() {
        // Don't start listening for updates here - wait for explicit initialization
    }

    // MARK: - Initialization

    func initializeStoreKit() async {
        await loadProducts()
        await checkEntitlements()
        await listenForTransactions()
    }

    // MARK: - Load Products

    private func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allProductIds = subscriptionProductIds + consumableProductIds
            let fetchedProducts = try await Product.products(for: allProductIds)

            // Sort products: subscriptions first, then consumables
            var sortedProducts: [Product] = []

            // Add subscriptions in order
            for id in subscriptionProductIds {
                if let product = fetchedProducts.first(where: { $0.id == id }) {
                    sortedProducts.append(product)
                }
            }

            // Add consumables
            for id in consumableProductIds {
                if let product = fetchedProducts.first(where: { $0.id == id }) {
                    sortedProducts.append(product)
                }
            }

            self.products = sortedProducts
        } catch {
            self.purchaseError = .unknown(error)
        }
    }

    // MARK: - Purchase Handling

    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify and process the purchase
                let transaction = try checkVerified(verification)

                // Update entitlements immediately
                await updateEntitlements()

                // Finish the transaction
                await transaction.finish()

                return true

            case .userCancelled:
                self.purchaseError = .userCancelled
                return false

            case .pending:
                // Purchase is pending user verification (rare)
                return false

            @unknown default:
                self.purchaseError = .purchaseFailed("Unknown result")
                return false
            }
        } catch StoreKitError.networkError {
            self.purchaseError = .networkError
            return false
        } catch {
            self.purchaseError = .purchaseFailed(error.localizedDescription)
            return false
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            // This syncs the user's transaction history with Apple
            try await AppStore.sync()

            // Then update entitlements based on current transactions
            await updateEntitlements()

            return true
        } catch {
            self.purchaseError = .restoreFailed(error.localizedDescription)
            return false
        }
    }

    // MARK: - Entitlements

    private func checkEntitlements() async {
        await updateEntitlements()
    }

    private func updateEntitlements() async {
        var newEntitlements = SubscriptionEntitlements()

        // Check for any active subscription transactions
        for await result in Transaction.all {
            guard case .verified(let transaction) = result else { continue }

            // Skip revoked transactions
            guard transaction.revocationDate == nil else { continue }

            // Skip expired transactions (for non-subscriptions)
            if transaction.expirationDate != nil {
                if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                    continue
                }
            }

            // Determine subscription type
            if transaction.productID == "com.jeanese.tethyr.subscription.monthly" {
                newEntitlements.isProUnlocked = true
                newEntitlements.currentSubscription = "monthly"
                newEntitlements.expirationDate = transaction.expirationDate
            } else if transaction.productID == "com.jeanese.tethyr.subscription.annual" {
                newEntitlements.isProUnlocked = true
                newEntitlements.currentSubscription = "annual"
                newEntitlements.expirationDate = transaction.expirationDate

                // Check if still in trial period
                let trialEndDate = Calendar.current.date(byAdding: .day, value: 14, to: transaction.purchaseDate) ?? transaction.purchaseDate
                newEntitlements.isInTrial = Date() < trialEndDate
            } else if transaction.productID == "com.jeanese.tethyr.subscription.lifetime" {
                newEntitlements.isProUnlocked = true
                newEntitlements.hasLifetime = true
                newEntitlements.currentSubscription = nil // Lifetime has no expiration
            }
        }

        self.entitlements = newEntitlements
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() async {
        updateListenerTask = Task(priority: .background) {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }

                // Update entitlements when transaction status changes
                await updateEntitlements()

                // Important: always finish transactions
                await transaction.finish()
            }
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Verification Helper

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.invalidTransaction
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helper Methods

    func getSubscriptionProducts() -> [Product] {
        return products.filter { subscriptionProductIds.contains($0.id) }
    }

    func getConsumableProducts() -> [Product] {
        return products.filter { consumableProductIds.contains($0.id) }
    }

    func getProduct(for id: String) -> Product? {
        return products.first { $0.id == id }
    }

    func isSubscriptionProduct(_ product: Product) -> Bool {
        return subscriptionProductIds.contains(product.id)
    }

    func getSubscriptionTierName(_ productId: String) -> String {
        switch productId {
        case "com.jeanese.tethyr.subscription.monthly":
            return "Monthly"
        case "com.jeanese.tethyr.subscription.annual":
            return "Annual"
        case "com.jeanese.tethyr.subscription.lifetime":
            return "Lifetime"
        default:
            return "Unknown"
        }
    }
}
