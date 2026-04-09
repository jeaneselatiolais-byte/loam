//
//  PrivacyPolicyView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HabitraTheme.spacingLarge) {

                    // Intro
                    Text("Habitra is built with privacy at its core. Here's exactly how your data is handled — no legal jargon, just plain language.")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, HabitraTheme.screenPadding)

                    // MARK: - Your Data Stays on Your Device
                    privacyCard(
                        icon: "iphone",
                        title: "Your Data Stays on Your Device",
                        body: "All your habit data is stored locally on your device using SwiftData. There is zero cloud storage — your habits, streaks, and completions never leave your phone."
                    )

                    // MARK: - No Analytics or Tracking
                    privacyCard(
                        icon: "eye.slash.fill",
                        title: "No Analytics or Tracking",
                        body: "Habitra contains no third-party analytics SDKs, no tracking pixels, and no user behavior monitoring. We don't know how you use the app, and we like it that way."
                    )

                    // MARK: - No Account Required
                    privacyCard(
                        icon: "person.slash.fill",
                        title: "No Account Required",
                        body: "There's no sign-up, no email collection, and no personal information gathered. You open the app and start building habits — that's it."
                    )

                    // MARK: - Notifications
                    privacyCard(
                        icon: "bell.badge.fill",
                        title: "Notifications",
                        body: "Reminders are powered entirely by local notifications scheduled on your device. No push notification servers are involved, and no data is sent anywhere to deliver them."
                    )

                    // MARK: - In-App Purchases
                    privacyCard(
                        icon: "creditcard.fill",
                        title: "In-App Purchases",
                        body: "All purchases are processed securely by Apple through the App Store. Habitra never sees, stores, or has access to your payment information."
                    )

                    // MARK: - HealthKit
                    privacyCard(
                        icon: "heart.text.square.fill",
                        title: "Apple HealthKit",
                        body: "Habitra reads steps, sleep, heart rate, HRV, and workout data with your permission. All health data stays exclusively on your device — it is never uploaded, shared, or sent to any server. Habitra does not write any data to HealthKit. You can revoke access anytime in Settings → Privacy & Security → Health → Habitra."
                    )

                    // MARK: - iCloud Sync
                    privacyCard(
                        icon: "icloud.fill",
                        title: "iCloud Sync",
                        body: "When enabled, your habit data syncs across your devices using Apple's private CloudKit container. Your data is encrypted and tied to your Apple ID — only you can see it. We can't read it even if we wanted to. iCloud Sync is optional and disabled by default."
                    )

                    // MARK: - Data Export
                    privacyCard(
                        icon: "square.and.arrow.up.fill",
                        title: "Data Export",
                        body: "CSV export gives you full ownership of your data. Download everything whenever you want — your habits, completions, and streaks are yours."
                    )

                    // MARK: - Contact
                    privacyCard(
                        icon: "envelope.fill",
                        title: "Questions?",
                        body: "If you have any privacy questions or concerns, we'd love to hear from you.",
                        contactEmail: "habitra@outlook.com"
                    )

                    // MARK: - Footer
                    VStack(spacing: 4) {
                        Text("Last updated: April 2026")
                            .font(HabitraFont.caption())
                            .foregroundStyle(Color.habitraTextTertiary)

                        Text("Habitra v1.0")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, HabitraTheme.spacing)
                }
                .padding(.top, HabitraTheme.spacing)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Privacy Card Builder

    private func privacyCard(
        icon: String,
        title: String,
        body: String,
        contactEmail: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.habitraAccent)
                    .frame(width: 28, height: 28)

                Text(title)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
            }

            // Body
            Text(body)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 38)

            // Optional email link
            if let email = contactEmail {
                Link(destination: URL(string: "mailto:\(email)")!) {
                    HStack(spacing: 6) {
                        Text(email)
                            .font(HabitraFont.caption())
                            .foregroundStyle(Color.habitraAccent)

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.habitraAccent)
                    }
                }
                .padding(.leading, 38)
                .padding(.top, 2)
            }
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
