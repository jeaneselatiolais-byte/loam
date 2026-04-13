//
//  PaywallView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//
//  v1.0: This file has been rewritten as a Support + Roadmap view.
//  The struct name `PaywallView` is preserved so existing presentation
//  call sites compile without changes. When paid tiers return, restore
//  the subscription-tier layout from git tag `v1.0-free-only`.
//
//  See docs/RELEASE_STRATEGY.md for details.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var loadingTipID: String? = nil
    @State private var showThankYou = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var storeKit: StoreKitManager { .shared }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        headerSection
                        freeCalloutSection
                        tipJarSection
                        comingSoonSection
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
            .alert("Thank You! 💛", isPresented: $showThankYou) {
                Button("You're Welcome") { dismiss() }
            } message: {
                Text("Your support means the world. It keeps Habitra free and helps us build what's next.")
            }
            .alert("Something Went Wrong", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .task {
                if storeKit.tipProducts.isEmpty {
                    await storeKit.loadProducts()
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.habitraAccent.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "heart.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.habitraAccent)
            }
            .padding(.top, 20)

            Text("Support Habitra")
                .font(HabitraFont.largeTitle())
                .foregroundStyle(Color.habitraTextPrimary)

            Text("Free forever. Tips optional. Always yours.")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Free Callout

    private var freeCalloutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.habitraHabitGreen)
                Text("Habitra is 100% free")
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
            }

            Text("No ads. No tracking. No cloud. Your habits stay on your phone, and every feature in this release is yours to use — no strings attached.")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .habitraCard()
    }

    // MARK: - Tip Jar

    private var tipJarSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            HStack(spacing: 8) {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(Color.habitraAccent)
                Text("Leave a tip")
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
            }

            Text("If Habitra helps you build the habits you want, you can say thanks with an optional tip. It funds the features coming next.")
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: HabitraTheme.spacing) {
                if storeKit.tipProducts.isEmpty {
                    tipPlaceholderButton("☕", "$1.99", productID: "small")
                    tipPlaceholderButton("🍱", "$4.99", productID: "medium")
                    tipPlaceholderButton("💰", "$9.99", productID: "large")
                } else {
                    ForEach(storeKit.tipProducts, id: \.id) { product in
                        tipButton(product)
                    }
                }
            }
            .padding(.top, 4)
        }
        .habitraCard()
    }

    private func tipButton(_ product: Product) -> some View {
        let isPurchasingThis = loadingTipID == product.id
        return Button {
            guard loadingTipID == nil else { return }
            Task {
                loadingTipID = product.id
                let success = await storeKit.purchase(product)
                loadingTipID = nil
                if success {
                    showThankYou = true
                } else if let err = storeKit.purchaseError {
                    errorMessage = err
                    showError = true
                }
            }
        } label: {
            VStack(spacing: 6) {
                if isPurchasingThis {
                    ProgressView()
                        .frame(width: 28, height: 28)
                } else {
                    Text(tipEmoji(for: product))
                        .font(.system(size: 28))
                        .opacity(loadingTipID != nil ? 0.4 : 1)
                }
                Text(product.displayPrice)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextPrimary)
                    .opacity(loadingTipID != nil && !isPurchasingThis ? 0.4 : 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.habitraSurfaceLight)
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
        }
        .buttonStyle(.plain)
        .disabled(loadingTipID != nil)
    }

    private func tipPlaceholderButton(_ emoji: String, _ price: String, productID: String) -> some View {
        let isThisLoading = loadingTipID == productID
        return Button {
            guard loadingTipID == nil else { return }
            Task {
                loadingTipID = productID
                await storeKit.loadProducts()
                loadingTipID = nil
            }
        } label: {
            VStack(spacing: 6) {
                if isThisLoading {
                    ProgressView()
                        .frame(width: 28, height: 28)
                } else {
                    Text(emoji)
                        .font(.system(size: 28))
                        .opacity(loadingTipID != nil ? 0.4 : 1)
                }
                Text(price)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
                    .opacity(loadingTipID != nil && !isThisLoading ? 0.4 : 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.habitraSurfaceLight)
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
        }
        .buttonStyle(.plain)
        .disabled(loadingTipID != nil)
    }

    private func tipEmoji(for product: Product) -> String {
        if product.id.contains("small") { return "☕" }
        if product.id.contains("medium") { return "🍱" }
        return "💰"
    }

    // MARK: - Coming Soon (Roadmap)

    private var comingSoonSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.habitraAccentGlow)
                Text("On the roadmap")
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
            }

            Text("A few things we're building next. No dates yet — we ship when they're ready.")
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                roadmapRow(
                    icon: "brain.head.profile",
                    title: "On-device AI Coach",
                    blurb: "Gentle nudges and pattern insights — all computed privately on your phone."
                )
                roadmapRow(
                    icon: "heart.fill",
                    title: "Apple Health integration",
                    blurb: "Auto-complete habits from steps, workouts, sleep, and mindful minutes."
                )
                roadmapRow(
                    icon: "icloud.fill",
                    title: "iCloud sync",
                    blurb: "Keep your habits in sync across iPhone, iPad, and Mac — end-to-end encrypted."
                )
                roadmapRow(
                    icon: "rectangle.stack.fill",
                    title: "More widgets & StandBy",
                    blurb: "Lock Screen, medium, large, and StandBy widgets for every glance."
                )
                roadmapRow(
                    icon: "flag.checkered",
                    title: "Weekly Quests",
                    blurb: "Opt-in mini-challenges that reward consistency with XP and badges."
                )
            }
            .padding(.top, 4)
        }
        .habitraCard()
    }

    private func roadmapRow(icon: String, title: String, blurb: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.habitraAccent)
                .frame(width: 28, height: 28)
                .background(Color.habitraAccent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextPrimary)
                Text(blurb)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 6) {
            Text("Tips are one-time purchases. They don't unlock anything — Habitra is free for everyone.")
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

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
}

#Preview {
    PaywallView()
}
