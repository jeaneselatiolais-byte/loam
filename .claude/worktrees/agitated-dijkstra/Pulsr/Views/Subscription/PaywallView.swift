//
//  PaywallView.swift
//  Pulsr
//
//  Created by Jeanese Raymond on 3/31/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var storeKitManager = StoreKitManager.shared
    @State private var selectedTier: SubscriptionTier = .annual
    @State private var showRestorePurchases = false
    @State private var showTipJar = false
    @State private var showSuccessAlert = false

    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Upgrade to Pro")
                            .font(.system(size: 32, weight: .bold))
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }

                    Text("Unlock all features and take full control of your habits")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        // Subscription Cards
                        VStack(spacing: 12) {
                            ForEach([SubscriptionTier.monthly, .annual, .lifetime], id: \.self) { tier in
                                SubscriptionCardView(
                                    tier: tier,
                                    isSelected: selectedTier == tier,
                                    action: { selectedTier = tier }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // Purchase Button
                        Button(action: purchaseSelectedTier) {
                            if storeKitManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .frame(height: 18)
                            } else {
                                Text("Subscribe Now")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(storeKitManager.isLoading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // Tip Jar Section
                        VStack(spacing: 12) {
                            Divider()
                                .padding(.vertical, 8)

                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("Support indie development")
                                        .font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                }

                                HStack(spacing: 12) {
                                    TipButtonView(label: "$1.99", emoji: "😊", productId: "com.jeanese.tethyr.tip.small")
                                    TipButtonView(label: "$4.99", emoji: "🙏", productId: "com.jeanese.tethyr.tip.medium")
                                    TipButtonView(label: "$9.99", emoji: "❤️", productId: "com.jeanese.tethyr.tip.large")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // Restore & Continue Buttons
                        VStack(spacing: 12) {
                            Button(action: { showRestorePurchases.toggle() }) {
                                Text("Restore Purchases")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)), lineWidth: 1.5)
                            )

                            Button(action: { dismiss() }) {
                                Text("Continue without upgrading")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        // Footer Text
                        VStack(spacing: 8) {
                            Text("All subscriptions auto-renew. Cancel anytime in Settings.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                                .lineLimit(2)

                            HStack(spacing: 16) {
                                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy") ?? URL(fileURLWithPath: ""))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))

                                Link("Terms of Service", destination: URL(string: "https://example.com/terms") ?? URL(fileURLWithPath: ""))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .alert("Purchase Complete", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you! You now have access to all Pro features.")
        }
        .alert("Error", isPresented: .constant(storeKitManager.purchaseError != nil)) {
            Button("OK") {
                storeKitManager.purchaseError = nil
            }
        } message: {
            if let error = storeKitManager.purchaseError {
                Text(error.localizedDescription)
            }
        }
        .sheet(isPresented: $showRestorePurchases) {
            RestoreView()
        }
    }

    private func purchaseSelectedTier() {
        Task {
            guard let productId = selectedTier.productId,
                  let product = storeKitManager.getProduct(for: productId) else {
                return
            }

            let success = await storeKitManager.purchase(product)
            if success {
                showSuccessAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Subscription Card View
struct SubscriptionCardView: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(tier.displayName)
                            .font(.system(size: 17, weight: .semibold))

                        if let badge = tier.badgeText {
                            Text(badge)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
                                .cornerRadius(4)
                        }

                        Spacer()
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(tier.price)
                            .font(.system(size: 20, weight: .bold))
                        Text(tier.billingPeriod)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(tier.features, id: \.self) { feature in
                    Text(feature)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .border(
            isSelected ? Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)) : Color.clear,
            width: 2
        )
        .cornerRadius(12)
        .onTapGesture(perform: action)
    }
}

// MARK: - Tip Button View
struct TipButtonView: View {
    let label: String
    let emoji: String
    let productId: String

    @StateObject private var storeKitManager = StoreKitManager.shared
    @State private var isPurchasing = false

    var body: some View {
        Button(action: purchaseTip) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
        .cornerRadius(10)
        .disabled(isPurchasing || storeKitManager.isLoading)
        .opacity(isPurchasing || storeKitManager.isLoading ? 0.6 : 1.0)
    }

    private func purchaseTip() {
        Task {
            guard let product = storeKitManager.getProduct(for: productId) else { return }

            isPurchasing = true
            let success = await storeKitManager.purchase(product)
            isPurchasing = false

            if success {
                HapticManager.shared.impact(style: .medium)
            }
        }
    }
}

// MARK: - Restore View
struct RestoreView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var storeKitManager = StoreKitManager.shared
    @State private var isRestoring = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Restore Purchases")
                    .font(.system(size: 20, weight: .semibold))

                Text("If you previously purchased a subscription or lifetime access, tap below to restore it.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Button(action: restorePurchases) {
                    if isRestoring {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Restore Purchases")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(isRestoring)

                Spacer()
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your purchases have been restored successfully!")
        }
        .alert("Error", isPresented: .constant(storeKitManager.purchaseError != nil)) {
            Button("OK") {
                storeKitManager.purchaseError = nil
            }
        } message: {
            if let error = storeKitManager.purchaseError {
                Text(error.localizedDescription)
            }
        }
    }

    private func restorePurchases() {
        Task {
            isRestoring = true
            let success = await storeKitManager.restorePurchases()
            isRestoring = false

            if success {
                showSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    PaywallView()
}
