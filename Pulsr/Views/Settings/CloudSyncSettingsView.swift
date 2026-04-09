//
//  CloudSyncSettingsView.swift
//  Habitra
//
//  Phase 4: iCloud sync status and settings
//

import SwiftUI

struct CloudSyncSettingsView: View {
    @State private var syncManager = CloudSyncManager.shared
    @State private var showingPaywall = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @State private var appliedSyncValue: Bool = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")

    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HabitraTheme.spacingLarge) {
                    statusCard
                    if SubscriptionManager.canUseiCloudSync {
                        toggleSection
                    }
                    infoSection
                    privacySection
                }
                .padding(.horizontal, HabitraTheme.screenPadding)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("iCloud Sync")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .onAppear {
            syncManager.checkAvailability()
        }
    }

    // MARK: - Status

    @MainActor
    private var statusCard: some View {
        VStack(spacing: HabitraTheme.spacing) {
            HStack(spacing: HabitraTheme.spacing) {
                ZStack {
                    Circle()
                        .fill(Color(hex: syncManager.syncStatus.colorHex).opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: syncManager.syncStatus.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: syncManager.syncStatus.colorHex))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("iCloud Sync")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text(iCloudSyncEnabled && SubscriptionManager.canUseiCloudSync
                         ? syncManager.syncStatus.rawValue
                         : "Disabled")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color(hex: iCloudSyncEnabled && SubscriptionManager.canUseiCloudSync
                                               ? syncManager.syncStatus.colorHex
                                               : "7A74B0"))

                    if !SubscriptionManager.canUseiCloudSync {
                        Text("Pro feature")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    } else if iCloudSyncEnabled, let lastSync = syncManager.lastSyncDate {
                        Text("Last synced \(lastSync.formatted(.relative(presentation: .named)))")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }

                Spacer()
            }

            if !SubscriptionManager.canUseiCloudSync {
                HabitraButton("Upgrade to Pro", icon: "sparkles") {
                    showingPaywall = true
                }
            } else if iCloudSyncEnabled && syncManager.iCloudAvailable {
                HStack(spacing: 8) {
                    Image(systemName: syncManager.syncStatus == .syncing
                          ? "arrow.triangle.2.circlepath"
                          : "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(syncManager.syncStatus == .syncing
                                         ? Color.habitraHabitBlue
                                         : Color.habitraSuccess)
                    Text(syncManager.syncStatus == .syncing
                         ? "Syncing your habits across devices..."
                         : "Habits sync automatically across your devices")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextSecondary)

                    Spacer()

                    Button {
                        syncManager.refreshSync()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }
            }
        }
        .habitraCard()
    }

    // MARK: - Toggle

    private var toggleSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("SETTINGS")
                .habitraCaption()
                .sectionHeaderAccessibility()

            VStack(spacing: HabitraTheme.spacing) {
                HStack(spacing: HabitraTheme.spacing) {
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.habitraHabitBlue)
                        .frame(width: 32, height: 32)
                        .background(Color.habitraHabitBlue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("Enable iCloud Sync")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Spacer()

                    Toggle("", isOn: $iCloudSyncEnabled)
                        .labelsHidden()
                        .tint(Color.habitraAccent)
                        .disabled(!syncManager.iCloudAvailable)
                }

                if iCloudSyncEnabled != appliedSyncValue {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.habitraHabitYellow)
                        Text("Restart the app to apply this change")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }

                if !syncManager.iCloudAvailable {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.habitraHabitYellow)
                        Text("Sign in to iCloud in Settings to enable sync")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }
            }
            .habitraCard()
        }
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("HOW IT WORKS")
                .habitraCaption()
                .sectionHeaderAccessibility()

            VStack(alignment: .leading, spacing: 10) {
                infoRow(icon: "icloud.fill", text: "Uses Apple's CloudKit — your data stays in your iCloud account")
                infoRow(icon: "arrow.triangle.2.circlepath", text: "Changes sync automatically when connected to the internet")
                infoRow(icon: "iphone.gen3", text: "Works across iPhone and iPad signed into the same Apple ID")
                infoRow(icon: "lock.shield.fill", text: "End-to-end encrypted by Apple — we never see your data")
            }
            .habitraCard()
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.habitraAccent)
                .frame(width: 24)

            Text(text)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
        }
    }

    // MARK: - Privacy

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("PRIVACY")
                .habitraCaption()
                .sectionHeaderAccessibility()

            VStack(alignment: .leading, spacing: 8) {
                Text("Habitra uses Apple's CloudKit private database. Your habit data is stored in your personal iCloud account and is encrypted by Apple. Habitra has no server and cannot access your iCloud data.")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
            }
            .habitraCard()
        }
    }
}

#Preview {
    NavigationStack {
        CloudSyncSettingsView()
    }
}
