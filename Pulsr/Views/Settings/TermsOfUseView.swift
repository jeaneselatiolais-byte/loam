//
//  TermsOfUseView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 4/8/26.
//

import SwiftUI

struct TermsOfUseView: View {
    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HabitraTheme.spacingLarge) {

                    // Intro
                    Text("By using Habitra, you agree to the following terms. We've kept them straightforward.")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, HabitraTheme.screenPadding)

                    // MARK: - Acceptance
                    termsCard(
                        icon: "checkmark.shield.fill",
                        title: "Acceptance of Terms",
                        body: "By downloading, installing, or using Habitra, you agree to these Terms of Use. If you do not agree, please do not use the app."
                    )

                    // MARK: - Eligibility
                    termsCard(
                        icon: "person.fill",
                        title: "Eligibility",
                        body: "You must be at least 13 years old to use Habitra. If you are under 18, a parent or legal guardian must agree to these terms on your behalf."
                    )

                    // MARK: - Subscriptions
                    termsCard(
                        icon: "creditcard.fill",
                        title: "Subscriptions & Purchases",
                        body: "Habitra Pro is available as a monthly subscription ($4.99/month), annual subscription ($39.99/year with a 14-day free trial), or lifetime purchase ($79.99). All payments are processed by Apple. Subscriptions auto-renew unless cancelled at least 24 hours before the current period ends. Manage or cancel anytime in your Apple ID settings."
                    )

                    // MARK: - Free Trial
                    termsCard(
                        icon: "gift.fill",
                        title: "Free Trials",
                        body: "Any unused portion of a free trial is forfeited when you purchase a subscription. Free trial eligibility is determined by Apple and may be limited to one per Apple ID."
                    )

                    // MARK: - Tip Jar
                    termsCard(
                        icon: "heart.fill",
                        title: "Tip Jar",
                        body: "Optional one-time tips ($1.99, $4.99, $9.99) support development and do not unlock additional features."
                    )

                    // MARK: - Refunds
                    termsCard(
                        icon: "arrow.uturn.left.circle.fill",
                        title: "Refunds",
                        body: "All purchases are subject to Apple's refund policies. To request a refund, visit reportaproblem.apple.com."
                    )

                    // MARK: - Data & Privacy
                    termsCard(
                        icon: "lock.fill",
                        title: "Data & Privacy",
                        body: "All your data is stored locally on your device or in your private iCloud account. We do not collect, store, or process your data on external servers. See our Privacy Policy for full details."
                    )

                    // MARK: - HealthKit
                    termsCard(
                        icon: "heart.text.square.fill",
                        title: "HealthKit Data",
                        body: "With your permission, Habitra reads health data for on-device analysis only. Health data is never shared with third parties, used for advertising, or transmitted externally."
                    )

                    // MARK: - AI Disclaimer
                    termsCard(
                        icon: "brain.head.profile",
                        title: "AI Features",
                        body: "On-device AI predictions and coaching are for informational purposes only and should not be considered medical, psychological, or professional advice."
                    )

                    // MARK: - Intellectual Property
                    termsCard(
                        icon: "doc.text.fill",
                        title: "Intellectual Property",
                        body: "Habitra and its content are protected by copyright. You are granted a limited, non-exclusive license for personal, non-commercial use."
                    )

                    // MARK: - Disclaimer
                    termsCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Disclaimer",
                        body: "Habitra is provided \"as is\" without warranties of any kind. We are not liable for any indirect, incidental, or consequential damages resulting from your use of the app."
                    )

                    // MARK: - Contact
                    termsCard(
                        icon: "envelope.fill",
                        title: "Questions?",
                        body: "If you have any questions about these terms, reach out anytime.",
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
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Terms Card Builder

    private func termsCard(
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
        TermsOfUseView()
    }
}
