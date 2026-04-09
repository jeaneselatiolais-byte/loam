//
//  SettingsView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//  Phase 2 Week 2: Export Data, Privacy Policy, Rate & Feedback wired up
//

import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("prefersDarkMode") private var prefersDarkMode = true
    @State private var showingPaywall = false
    @State private var showingExportOptions = false
    @State private var exportURL: URL?
    @State private var showingShareSheet = false
    @State private var versionTapCount = 0
    @State private var showingMetadata = false
    @State private var loadingTipID: String? = nil
    @State private var showingHealthDisconnectAlert = false
    private var storeKit: StoreKitManager { .shared }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        // MARK: - App Info
                        VStack(spacing: 16) {
                            HabitraLogoMark(size: 72)

                            Text("HABITRA")
                                .font(HabitraFont.wordmark())
                                .foregroundStyle(Color.habitraTextPrimary)
                                .tracking(4)

                            Text("YOUR HABITS. YOUR PHONE. ZERO CLOUD.")
                                .habitraCaption(color: .habitraTextTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HabitraTheme.spacingLarge)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Habitra. Your habits, your phone, zero cloud.")

                        // MARK: - General Section
                        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                            Text("GENERAL")
                                .habitraCaption()
                                .sectionHeaderAccessibility()
                                .padding(.horizontal, HabitraTheme.screenPadding)

                            // Test notification button
                            Button {
                                NotificationManager.shared.scheduleTestNotification()
                            } label: {
                                settingsRowLabel(icon: "bell.fill", title: "Test Notification", color: .habitraHabitBlue)
                            }
                            .buttonStyle(.plain)

                            // Appearance toggle
                            HStack(spacing: HabitraTheme.spacing) {
                                Image(systemName: "paintbrush.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.habitraAccent)
                                    .frame(width: 32, height: 32)
                                    .background(Color.habitraAccent.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                Text("Dark Mode")
                                    .font(HabitraFont.body())
                                    .foregroundStyle(Color.habitraTextPrimary)

                                Spacer()

                                Toggle("", isOn: $prefersDarkMode)
                                    .labelsHidden()
                                    .tint(Color.habitraAccent)
                                    .accessibilityLabel("Dark Mode")
                                    .accessibilityHint("Double tap to toggle dark mode")
                            }
                            .habitraCard()

                            NavigationLink {
                                ArchivedHabitsView()
                            } label: {
                                HStack(spacing: HabitraTheme.spacing) {
                                    Image(systemName: "archivebox.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.habitraHabitOrange)
                                        .frame(width: 32, height: 32)
                                        .background(Color.habitraHabitOrange.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    Text("Archived Habits")
                                        .font(HabitraFont.body())
                                        .foregroundStyle(Color.habitraTextPrimary)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(Color.habitraTextTertiary)
                                }
                                .habitraCard()
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, HabitraTheme.screenPadding)

                        // MARK: - Pro Section
                        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                            Text("PRO")
                                .habitraCaption()
                                .sectionHeaderAccessibility()
                                .padding(.horizontal, HabitraTheme.screenPadding)

                            if storeKit.isProUnlocked {
                                proActiveCard
                                    .padding(.horizontal, HabitraTheme.screenPadding)
                            } else {
                                upgradeCard
                                    .padding(.horizontal, HabitraTheme.screenPadding)
                            }
                        }

                        // MARK: - Tip Jar (free users only)
                        if !storeKit.isProUnlocked {
                            VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                                Text("SUPPORT")
                                    .habitraCaption()
                                    .sectionHeaderAccessibility()
                                    .padding(.horizontal, HabitraTheme.screenPadding)

                                VStack(spacing: HabitraTheme.spacing) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "heart.fill")
                                            .foregroundStyle(Color.habitraHabitPink)
                                        Text("Love Habitra? Leave a tip!")
                                            .font(HabitraFont.body())
                                            .foregroundStyle(Color.habitraTextPrimary)
                                    }

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
                                }
                                .habitraCard()
                            }
                        }

                        // MARK: - Health Section (shown when HealthKit is connected)
                        if SubscriptionManager.canUseHealthKit && HealthKitManager.shared.isAuthorized {
                            VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                                Text("APPLE HEALTH")
                                    .habitraCaption()
                                    .sectionHeaderAccessibility()
                                    .padding(.horizontal, HabitraTheme.screenPadding)

                                VStack(spacing: 0) {
                                    // Status row
                                    HStack(spacing: HabitraTheme.spacing) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.habitraHabitPink)
                                            .frame(width: 32, height: 32)
                                            .background(Color.habitraHabitPink.opacity(0.12))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("HealthKit Connected")
                                                .font(HabitraFont.body())
                                                .foregroundStyle(Color.habitraTextPrimary)
                                            Text("Reading steps, sleep, workouts & HRV")
                                                .font(HabitraFont.footnote())
                                                .foregroundStyle(Color.habitraTextTertiary)
                                        }

                                        Spacer()

                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.habitraSuccess)
                                    }
                                    .padding(HabitraTheme.cardPadding)
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel("HealthKit Connected. Reading steps, sleep, workouts and HRV")

                                    Divider().padding(.horizontal, HabitraTheme.cardPadding)

                                    // Disconnect — clears app-side auth
                                    Button {
                                        showingHealthDisconnectAlert = true
                                    } label: {
                                        HStack(spacing: HabitraTheme.spacing) {
                                            Image(systemName: "heart.slash.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Color.habitraDanger)
                                                .frame(width: 32, height: 32)
                                                .background(Color.habitraDanger.opacity(0.10))
                                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                            Text("Disconnect from Habitra")
                                                .font(HabitraFont.body())
                                                .foregroundStyle(Color.habitraDanger)

                                            Spacer()
                                        }
                                        .padding(HabitraTheme.cardPadding)
                                    }
                                    .buttonStyle(.plain)

                                    Divider().padding(.horizontal, HabitraTheme.cardPadding)

                                    // Deep link to iOS Health privacy settings
                                    Button {
                                        if let url = URL(string: "x-apple-health://") {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        HStack(spacing: HabitraTheme.spacing) {
                                            Image(systemName: "gear")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Color.habitraTextSecondary)
                                                .frame(width: 32, height: 32)
                                                .background(Color.habitraSurfaceLight)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Manage in iOS Health Settings")
                                                    .font(HabitraFont.body())
                                                    .foregroundStyle(Color.habitraTextPrimary)
                                                Text("Settings → Privacy & Security → Health → Habitra")
                                                    .font(HabitraFont.footnote())
                                                    .foregroundStyle(Color.habitraTextTertiary)
                                            }

                                            Spacer()

                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundStyle(Color.habitraTextTertiary)
                                        }
                                        .padding(HabitraTheme.cardPadding)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .background(Color.habitraSurface)
                                .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                                        .stroke(Color.habitraAccent.opacity(0.12), lineWidth: 1)
                                )
                                .padding(.horizontal, HabitraTheme.screenPadding)
                            }
                        }

                        // MARK: - Data Section
                        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                            Text("DATA")
                                .habitraCaption()
                                .sectionHeaderAccessibility()
                                .padding(.horizontal, HabitraTheme.screenPadding)

                            NavigationLink {
                                CloudSyncSettingsView()
                            } label: {
                                settingsRowLabel(icon: "icloud.fill", title: "iCloud Sync", color: .habitraHabitBlue)
                            }
                            .buttonStyle(.plain)

                            Button {
                                showingExportOptions = true
                            } label: {
                                settingsRowLabel(icon: "square.and.arrow.up.fill", title: "Export Data", color: .habitraHabitGreen)
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                PrivacyPolicyView()
                            } label: {
                                settingsRowLabel(icon: "hand.raised.fill", title: "Privacy Policy", color: .habitraHabitPink)
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                TermsOfUseView()
                            } label: {
                                settingsRowLabel(icon: "doc.text.fill", title: "Terms of Use", color: .habitraHabitPurple)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, HabitraTheme.screenPadding)

                        // MARK: - About Section
                        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                            Text("ABOUT")
                                .habitraCaption()
                                .sectionHeaderAccessibility()
                                .padding(.horizontal, HabitraTheme.screenPadding)

                            NavigationLink {
                                HelpGuideView()
                            } label: {
                                settingsRowLabel(icon: "questionmark.circle.fill", title: "Help Guide", color: .habitraAccentBright)
                            }
                            .buttonStyle(.plain)

                            Button {
                                requestAppReview()
                            } label: {
                                settingsRowLabel(icon: "star.fill", title: "Rate Habitra", color: .habitraHabitYellow)
                            }
                            .buttonStyle(.plain)

                            Button {
                                sendFeedback()
                            } label: {
                                settingsRowLabel(icon: "envelope.fill", title: "Send Feedback", color: .habitraHabitCyan)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, HabitraTheme.screenPadding)

                        // MARK: - Version
                        Text("Version 1.0 · Built with zero cloud")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                            .padding(.top, HabitraTheme.spacingLarge)
                            .accessibilityLabel("Version 1.0, Built with zero cloud")
                            .accessibilityAddTraits(.isButton)
                            .onTapGesture {
                                versionTapCount += 1
                                if versionTapCount >= 5 {
                                    versionTapCount = 0
                                    showingMetadata = true
                                }
                            }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(isPresented: $showingMetadata) {
                AppStoreMetadataView()
            }
            .confirmationDialog("Export Data", isPresented: $showingExportOptions) {
                Button("Habits Summary (CSV)") { exportData(mode: .habitsSummary) }
                Button("Completions Detail (CSV)") { exportData(mode: .completionsDetail) }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose export format")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheetView(items: [url])
                }
            }
            .alert("Disconnect Apple Health?", isPresented: $showingHealthDisconnectAlert) {
                Button("Disconnect", role: .destructive) {
                    disconnectHealthKit()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Habitra will stop reading health data and remove all HealthKit links from your habits. To fully revoke access, go to Settings → Privacy & Security → Health → Habitra.")
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    // MARK: - Export

    private func exportData(mode: DataExportService.ExportMode) {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
        guard let habits = try? modelContext.fetch(descriptor) else { return }

        if let url = try? DataExportService.generateCSV(habits: habits, mode: mode) {
            exportURL = url
            showingShareSheet = true
        }
    }

    // MARK: - Rate & Feedback

    private func requestAppReview() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        AppStore.requestReview(in: scene)
    }

    private func sendFeedback() {
        let email = "Habitra@outlook.com"
        let subject = "Habitra Feedback - v1.0"
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Settings Row

    private func settingsRowLabel(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: HabitraTheme.spacing) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .habitraCard()
    }

    // MARK: - Pro Cards

    private var upgradeCard: some View {
        VStack(spacing: HabitraTheme.spacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Habitra Pro")
                            .font(HabitraFont.headline())
                            .foregroundStyle(Color.habitraTextPrimary)

                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.habitraAccentGlow)
                    }

                    Text("Unlimited habits, AI coaching, all widgets, HealthKit")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextSecondary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("$4.99")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraAccentGlow)
                    Text("/month")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.habitraAccent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 6) {
                proFeatureRow("Unlimited habits")
                proFeatureRow("On-device AI nudges")
                proFeatureRow("All widget sizes + Standby")
                proFeatureRow("HealthKit integration")
                proFeatureRow("iCloud sync across devices")
            }
            .padding(.vertical, 4)

            HabitraButton("Start 14-Day Free Trial", icon: "sparkles") {
                showingPaywall = true
            }
        }
        .habitraCard()
        .interactiveCardAccessibility(
            label: "Habitra Pro, $4.99 per month. Unlimited habits, AI coaching, all widgets, HealthKit",
            hint: "Double tap to view subscription options"
        )
    }

    private var proActiveCard: some View {
        HStack(spacing: HabitraTheme.spacing) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.habitraAccent)

            VStack(alignment: .leading, spacing: 4) {
                Text("Habitra Pro Active")
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text(storeKit.hasLifetime ? "Lifetime access" : "Subscription active")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraHabitGreen)
            }

            Spacer()

            Button("Manage") {
                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    UIApplication.shared.open(url)
                }
            }
            .font(HabitraFont.caption())
            .tracking(0)
            .textCase(.none)
            .foregroundStyle(Color.habitraAccent)
        }
        .habitraCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(storeKit.hasLifetime ? "Habitra Pro Active, Lifetime access" : "Habitra Pro Active, Subscription active")
    }

    // MARK: - Tip Jar Helpers

    private func tipButton(_ product: Product) -> some View {
        let isPurchasingThis = loadingTipID == product.id
        return Button {
            guard loadingTipID == nil else { return }
            Task {
                loadingTipID = product.id
                _ = await storeKit.purchase(product)
                loadingTipID = nil
            }
        } label: {
            VStack(spacing: 4) {
                if isPurchasingThis {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Text(tipEmoji(for: product))
                        .font(.system(size: 24))
                        .opacity(loadingTipID != nil ? 0.4 : 1)
                }
                Text(product.displayPrice)
                    .font(HabitraFont.caption())
                    .tracking(0)
                    .textCase(.none)
                    .foregroundStyle(Color.habitraTextPrimary)
                    .opacity(loadingTipID != nil && !isPurchasingThis ? 0.4 : 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
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
            VStack(spacing: 4) {
                if isThisLoading {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Text(emoji)
                        .font(.system(size: 24))
                        .opacity(loadingTipID != nil ? 0.4 : 1)
                }
                Text(price)
                    .font(HabitraFont.caption())
                    .tracking(0)
                    .textCase(.none)
                    .foregroundStyle(Color.habitraTextTertiary)
                    .opacity(loadingTipID != nil && !isThisLoading ? 0.4 : 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
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

    private func proFeatureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.habitraAccent)
            Text(text)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
        }
    }

    // MARK: - HealthKit Disconnect

    private func disconnectHealthKit() {
        // Clear all habit HealthKit source links
        let descriptor = FetchDescriptor<Habit>()
        if let habits = try? modelContext.fetch(descriptor) {
            for habit in habits where habit.hasHealthKitSource {
                habit.healthKitSources = []
            }
            try? modelContext.save()
        }
        // Clear app-side authorization flag and cached data
        HealthKitManager.shared.disconnect()
    }
}

// MARK: - Share Sheet (UIKit wrapper)
struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self], inMemory: true)
}
