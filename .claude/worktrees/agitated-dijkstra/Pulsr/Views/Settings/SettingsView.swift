//
//  SettingsView.swift
//  Pulsr
//
//  Created by Jeanese Raymond on 3/31/26.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var isDarkMode = false
    @State private var isCloudSyncEnabled = false
    @State private var showPaywall = false
    @State private var showArchivedHabits = false
    @State private var showExportData = false
    @StateObject private var storeKitManager = StoreKitManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 12) {
                            HStack {
                                Text("Settings")
                                    .font(.system(size: 32, weight: .bold))
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        VStack(spacing: 16) {
                            // Test Notification Section
                            Section {
                                Button(action: sendTestNotification) {
                                    HStack {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.blue)
                                            .frame(width: 28)

                                        Text("Test Notification")
                                            .font(.system(size: 16, weight: .regular))

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                                .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20)

                            // Dark Mode Section
                            Section {
                                HStack {
                                    Image(systemName: "moon.stars.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.purple)
                                        .frame(width: 28)

                                    Text("Dark Mode")
                                        .font(.system(size: 16, weight: .regular))

                                    Spacer()

                                    Toggle("", isOn: $isDarkMode)
                                        .tint(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
                                }
                                .padding(16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)

                            // Archived Habits Section
                            Section {
                                NavigationLink(destination: Text("Archived Habits")) {
                                    HStack {
                                        Image(systemName: "archivebox.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.orange)
                                            .frame(width: 28)

                                        Text("Archived Habits")
                                            .font(.system(size: 16, weight: .regular))

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                                .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20)

                            // PRO Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("PRO")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 16) {
                                    // Header with Price
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text("Tethyr Pro")
                                                    .font(.system(size: 20, weight: .bold))
                                                Image(systemName: "sparkles")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.purple)
                                            }

                                            Text("Unlimited habits, AI coaching, all widgets, HealthKit")
                                                .font(.system(size: 13, weight: .regular))
                                                .foregroundColor(.gray)
                                                .lineLimit(2)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("$2.99")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("/month")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    // Features List
                                    VStack(alignment: .leading, spacing: 10) {
                                        FeatureRow(text: "Unlimited habits")
                                        FeatureRow(text: "On-device AI nudges")
                                        FeatureRow(text: "All widget sizes + Standby")
                                        FeatureRow(text: "HealthKit integration")
                                        FeatureRow(text: "iCloud sync across devices")
                                    }

                                    // Free Trial Button
                                    Button(action: { showPaywall = true }) {
                                        HStack {
                                            Image(systemName: "star.fill")
                                            Text("Start 14-Day Free Trial")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }

                            // SUPPORT Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("SUPPORT")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    Text("Love Tethyr? Leave a tip!")
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    HStack(spacing: 12) {
                                        TipJarButton(emoji: "😊", price: "$1.99", productId: "com.jeanese.tethyr.tip.small")
                                        TipJarButton(emoji: "🙏", price: "$4.99", productId: "com.jeanese.tethyr.tip.medium")
                                        TipJarButton(emoji: "❤️", price: "$9.99", productId: "com.jeanese.tethyr.tip.large")
                                    }
                                }
                                .padding(16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }

                            // DATA Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DATA")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)

                                // iCloud Sync Toggle
                                HStack {
                                    HStack(spacing: 12) {
                                        Image(systemName: "icloud.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.blue)
                                            .frame(width: 28)

                                        Text("iCloud Sync")
                                            .font(.system(size: 16, weight: .regular))
                                    }

                                    Spacer()

                                    Toggle("", isOn: $isCloudSyncEnabled)
                                        .tint(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
                                }
                                .padding(16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)

                                // Export Data
                                Button(action: { showExportData = true }) {
                                    HStack {
                                        Image(systemName: "arrow.up.doc.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.green)
                                            .frame(width: 28)

                                        Text("Export Data")
                                            .font(.system(size: 16, weight: .regular))

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal, 20)

                            // LEGAL Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("LEGAL")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 8) {
                                    Link(destination: URL(string: "https://example.com/privacy") ?? URL(fileURLWithPath: "")) {
                                        HStack {
                                            Image(systemName: "shield.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.blue)
                                                .frame(width: 28)

                                            Text("Privacy Policy")
                                                .font(.system(size: 16, weight: .regular))

                                            Spacer()

                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(16)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                    }

                                    Link(destination: URL(string: "https://example.com/terms") ?? URL(fileURLWithPath: "")) {
                                        HStack {
                                            Image(systemName: "doc.text.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.blue)
                                                .frame(width: 28)

                                            Text("Terms of Service")
                                                .font(.system(size: 16, weight: .regular))

                                            Spacer()

                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(16)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Tethyr Reminder"
        content.body = "Time to complete your daily habits! 🎯"
        content.sound = .default
        content.badge = NSNumber(value: 1)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Tip Jar Button
struct TipJarButton: View {
    let emoji: String
    let price: String
    let productId: String

    @StateObject private var storeKitManager = StoreKitManager.shared
    @State private var isPurchasing = false

    var body: some View {
        Button(action: purchaseTip) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 24))

                Text(price)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
            .cornerRadius(10)
        }
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
                HapticManager.shared.notification(type: .success)
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))

            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)

            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
