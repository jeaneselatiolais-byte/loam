//
//  AppStoreMetadataView.swift
//  Habitra
//
//  Phase 2 Week 4: App Store submission checklist and metadata reference
//

import SwiftUI

/// Internal-only view showing App Store metadata for submission reference.
/// Access via Settings > Version label (5 taps).
struct AppStoreMetadataView: View {
    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HabitraTheme.spacingLarge) {
                    metadataSection("APP INFO") {
                        metadataRow("Name", "Habitra – Habit Tracker")
                        metadataRow("Subtitle", "AI Habit Coach — 100% Private")
                        metadataRow("Bundle ID", "com.jeanese.Habitra")
                        metadataRow("Category", "Health & Fitness")
                        metadataRow("Secondary", "Productivity")
                        metadataRow("Price", "Free (with IAP)")
                        metadataRow("Version", "1.0")
                    }

                    metadataSection("KEYWORDS") {
                        Text("habit tracker, streak, daily habits, routine, wellness, productivity, private, offline, no cloud, AI coach, HealthKit, mood journal, widget, habit building")
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextSecondary)
                            .padding(.vertical, 4)
                    }

                    metadataSection("DESCRIPTION") {
                        Text(appDescription)
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextSecondary)
                            .lineSpacing(4)
                    }

                    metadataSection("PROMOTIONAL TEXT") {
                        Text("Build habits that stick with on-device AI coaching — 100% private, zero cloud. Track streaks, predict success, correlate health data, and stay on course.")
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextSecondary)
                    }

                    metadataSection("WHAT'S NEW (v1.0)") {
                        Text("Habitra is here! Build streaks, track habits, and own your data — all on-device, no cloud required.")
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextSecondary)
                    }

                    metadataSection("SUBMISSION CHECKLIST") {
                        checklistItem("App icon (1024x1024)", done: true)
                        checklistItem("Screenshots (6.7\", 6.5\", 5.5\")", done: false)
                        checklistItem("Privacy policy URL", done: true)
                        checklistItem("App Review notes", done: false)
                        checklistItem("HealthKit usage descriptions", done: true)
                        checklistItem("CloudKit entitlement", done: true)
                        checklistItem("StoreKit configuration tested", done: true)
                        checklistItem("Entitlements (Push, App Groups)", done: true)
                        checklistItem("Launch screen configured", done: true)
                        checklistItem("Accessibility audit", done: true)
                        checklistItem("Dark/Light mode verified", done: true)
                    }

                    metadataSection("PRIVACY DECLARATIONS") {
                        metadataRow("Data Collected", "None")
                        metadataRow("Data Linked", "None")
                        metadataRow("Data Tracked", "None")
                        metadataRow("Privacy URL", "In-app (Settings)")
                    }

                    metadataSection("IN-APP PURCHASES") {
                        metadataRow("Pro Monthly", "$4.99/mo")
                        metadataRow("Pro Annual", "$39.99/yr (14-day trial)")
                        metadataRow("Pro Lifetime", "$79.99 one-time")
                        metadataRow("Tip Small", "$1.99")
                        metadataRow("Tip Medium", "$4.99")
                        metadataRow("Tip Large", "$9.99")
                    }
                }
                .padding(.horizontal, HabitraTheme.screenPadding)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("App Store Info")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func metadataSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
            Text(title)
                .habitraCaption()
                .sectionHeaderAccessibility()

            VStack(alignment: .leading, spacing: 6) {
                content()
            }
            .habitraCard()
        }
    }

    private func metadataRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
            Spacer()
            Text(value)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextPrimary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func checklistItem(_ text: String, done: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(done ? Color.habitraSuccess : Color.habitraTextTertiary.opacity(0.6))

            Text(text)
                .font(HabitraFont.body())
                .foregroundStyle(done ? Color.habitraTextPrimary : Color.habitraTextTertiary)
        }
    }

    private var appDescription: String {
        """
        Habitra is a beautifully simple habit tracker that respects your privacy. \
        All your data stays on your device — no accounts, no cloud, no tracking.

        BUILD STREAKS
        Complete habits daily and watch your streaks grow. \
        Milestone celebrations keep you motivated at 7, 14, 21, 30, 50, 100, and 365 days.

        TRACK PROGRESS
        See your completion rates, heatmaps, trends, and weekly patterns. \
        Dive into per-habit stats to find your strongest and weakest days.

        STAY REMINDED
        Set local notifications for each habit. \
        Everything works offline — no internet required.

        WIDGETS
        Add Habitra to your Lock Screen and Home Screen. \
        Streak widgets, habit grids, and progress bars keep your goals visible.

        SHARE YOUR WINS
        Generate beautiful streak cards to share your progress with friends.

        100% PRIVATE
        Zero network requests. Zero analytics. Zero data collection. \
        Your habits are yours alone.

        FREE FEATURES
        • Track up to 3 habits
        • Streaks and basic stats
        • Lock Screen streak widget
        • Local reminders
        • Light and dark mode

        HABITRA PRO
        • Unlimited habits and categories
        • All widget sizes
        • CSV data export
        • On-device AI nudges (coming soon)
        • HealthKit integration (coming soon)
        • iCloud sync (coming soon)
        """
    }
}

#Preview {
    NavigationStack {
        AppStoreMetadataView()
    }
}
