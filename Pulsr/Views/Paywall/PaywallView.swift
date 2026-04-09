//
//  PaywallView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: HabitraProduct = .proAnnual
    @State private var purchaseSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showRestoreResult = false
    @State private var restoreMessage = ""
    @State private var isRestoring = false

    private var storeKit: StoreKitManager { .shared }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        headerSection
                        featuresSection
                        plansSection
                        purchaseButton
                        footerSection
                    }
                    .padding(.horizontal, HabitraTheme.screenPadding)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }
            }
            .alert("Welcome to Pro!", isPresented: $purchaseSuccess) {
                Button("Let's Go") { dismiss() }
            } message: {
                Text("You've unlocked unlimited habits, AI coaching, and all widgets. Enjoy!")
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Restore Purchases", isPresented: $showRestoreResult) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(restoreMessage)
            }
            .task {
                if storeKit.subscriptionProducts.isEmpty {
                    await storeKit.loadProducts()
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Pulse icon
            ZStack {
                Circle()
                    .fill(Color.habitraAccent.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.habitraAccent)
            }
            .padding(.top, 20)

            Text("Habitra Pro")
                .font(HabitraFont.largeTitle())
                .foregroundStyle(Color.habitraTextPrimary)

            Text("Unlock the full power of your habits")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            featureRow("infinity", "Unlimited habits & categories")
            featureRow("brain.head.profile", "On-device AI nudges & coaching")
            featureRow("chart.xyaxis.line", "Predictive failure alerts")
            featureRow("rectangle.stack.fill", "All widget sizes + Standby")
            featureRow("heart.fill", "HealthKit integration")
            featureRow("icloud.fill", "iCloud sync across devices")
            featureRow("square.and.arrow.up", "CSV export")
            featureRow("paintpalette.fill", "Custom streak themes")
        }
        .habitraCard()
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.habitraAccent)
                .frame(width: 24)

            Text(text)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextPrimary)

            Spacer()
        }
    }

    // MARK: - Plans

    private var plansSection: some View {
        VStack(spacing: HabitraTheme.spacing) {
            planCard(
                product: .proAnnual,
                title: "Annual",
                badge: "BEST VALUE — SAVE 33%"
            )
            planCard(
                product: .proMonthly,
                title: "Monthly",
                badge: nil
            )
            planCard(
                product: .proLifetime,
                title: "Lifetime",
                badge: "ONE TIME"
            )
        }
    }

    private func planCard(product: HabitraProduct, title: String, badge: String?) -> some View {
        let isSelected = selectedPlan == product
        let storeProduct = storeKit.product(for: product)

        return Button {
            selectedPlan = product
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(HabitraFont.headline())
                            .foregroundStyle(Color.habitraTextPrimary)

                        if let badge {
                            Text(badge)
                                .font(.system(.caption2))
                                .foregroundStyle(Color.habitraAccent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.habitraAccent.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    if product == .proAnnual {
                        Text("14-day free trial included")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraHabitGreen)
                    } else if product == .proLifetime {
                        Text("Pay once, keep forever")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(storeProduct?.displayPrice ?? priceLabel(for: product))
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text(periodLabel(for: product))
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.habitraAccent : Color.habitraTextTertiary.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(Color.habitraAccent)
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(.leading, 8)
            }
            .padding(HabitraTheme.cardPadding)
            .background(isSelected ? Color.habitraAccent.opacity(0.08) : Color.habitraSurface)
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                    .stroke(isSelected ? Color.habitraAccent.opacity(0.5) : Color.habitraAccent.opacity(0.1), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        VStack(spacing: 8) {
            Button {
                Task { await handlePurchase() }
            } label: {
                HStack(spacing: 8) {
                    if storeKit.isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(purchaseButtonTitle)
                        .font(HabitraFont.headline())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.habitraAccent)
                .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
            }
            .disabled(storeKit.isPurchasing)

            Button {
                Task { await handleRestore() }
            } label: {
                if isRestoring {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Restore Purchases")
                }
            }
            .font(HabitraFont.footnote())
            .foregroundStyle(Color.habitraTextTertiary)
            .disabled(isRestoring)
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 6) {
            Text("Payment will be charged to your Apple ID account. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary.opacity(0.6))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                NavigationLink("Terms of Use") {
                    TermsOfUseView()
                }
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary)

                NavigationLink("Privacy Policy") {
                    PrivacyPolicyView()
                }
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func handlePurchase() async {
        guard let product = storeKit.product(for: selectedPlan) else {
            // Products haven't loaded — retry once
            await storeKit.loadProducts()
            guard let product = storeKit.product(for: selectedPlan) else {
                if let loadErr = storeKit.loadError {
                    errorMessage = "Could not load products: \(loadErr)"
                } else {
                    errorMessage = "Unable to load subscription options. Please check your internet connection and try again."
                }
                showError = true
                return
            }
            let success = await storeKit.purchase(product)
            if success {
                purchaseSuccess = true
            } else if let error = storeKit.purchaseError {
                errorMessage = error
                showError = true
            }
            return
        }
        let success = await storeKit.purchase(product)
        if success {
            purchaseSuccess = true
        } else if let error = storeKit.purchaseError {
            errorMessage = error
            showError = true
        }
    }

    private func handleRestore() async {
        isRestoring = true
        await storeKit.restorePurchases()
        isRestoring = false

        if storeKit.isProUnlocked {
            purchaseSuccess = true
        } else {
            restoreMessage = "No active subscriptions found for this Apple ID. If you believe this is an error, contact Apple Support."
            showRestoreResult = true
        }
    }

    private var purchaseButtonTitle: String {
        switch selectedPlan {
        case .proAnnual:  return "Start Free Trial"
        case .proMonthly: return "Subscribe Now"
        case .proLifetime: return "Buy Lifetime"
        default: return "Subscribe"
        }
    }

    private func priceLabel(for product: HabitraProduct) -> String {
        switch product {
        case .proMonthly:  return "$4.99"
        case .proAnnual:   return "$39.99"
        case .proLifetime: return "$79.99"
        default: return ""
        }
    }

    private func periodLabel(for product: HabitraProduct) -> String {
        switch product {
        case .proMonthly:  return "/month"
        case .proAnnual:   return "/year"
        case .proLifetime: return "one time"
        default: return ""
        }
    }

}

#Preview {
    PaywallView()
}
