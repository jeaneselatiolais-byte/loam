//
//  HelpGuideView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//  Updated: Collapsible sections, multi-completion habits documentation
//

import SwiftUI

struct HelpGuideView: View {
    // Track which sections are expanded
    @State private var expandedSections: Set<String> = []

    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HabitraTheme.spacingLarge) {

                    // MARK: - Getting Started
                    collapsibleSection(
                        title: "GETTING STARTED",
                        items: [
                            HelpItem(
                                icon: "plus.circle.fill",
                                title: "Create a Habit",
                                body: "Tap the + button in the top-right of the Today tab. Choose \"New Habit\" to build from scratch, or \"Quick Add Template\" to pick from 16 pre-built habits across Health, Productivity, Mindfulness, and Lifestyle categories."
                            ),
                            HelpItem(
                                icon: "checkmark.circle.fill",
                                title: "Complete a Habit",
                                body: "Tap the circle on the right side of any habit to mark it done for today. A pulse animation and haptic feedback confirm the completion. You can also add a journal note after completing."
                            ),
                            HelpItem(
                                icon: "flame.fill",
                                title: "Build Streaks",
                                body: "Complete habits consistently to build streaks. Your current streak appears as a badge on each habit. Miss a scheduled day and your streak resets to zero. Milestones are celebrated at 7, 14, 21, 30, 50, 100, and 365 days with confetti animations."
                            ),
                            HelpItem(
                                icon: "5.circle.fill",
                                title: "Habit Limit",
                                body: "You can track up to 5 habits in this release. Focused is better — pick the ones that matter most. More capacity is on the roadmap."
                            ),
                        ]
                    )

                    // MARK: - Managing Habits
                    collapsibleSection(
                        title: "MANAGING HABITS",
                        items: [
                            HelpItem(
                                icon: "pencil",
                                title: "Edit a Habit",
                                body: "Tap a habit's name or icon to open the edit form, or long-press and choose Edit. You can change the name, icon, color, frequency, and reminder."
                            ),
                            HelpItem(
                                icon: "note.text",
                                title: "Habit Notes",
                                body: "After completing a habit, a note sheet appears where you can journal about the session (up to 280 characters). Notes are stored with each completion and visible in day detail views."
                            ),
                            HelpItem(
                                icon: "archivebox.fill",
                                title: "Archive a Habit",
                                body: "Long-press a habit and choose Archive. Archived habits keep their history but won't appear in your daily list. Restore them from Settings > Archived Habits."
                            ),
                            HelpItem(
                                icon: "trash.fill",
                                title: "Delete a Habit",
                                body: "Long-press a habit and choose Delete to permanently remove it and all its completion history. This cannot be undone."
                            ),
                            HelpItem(
                                icon: "arrow.uturn.backward.circle.fill",
                                title: "Restore Archived Habits",
                                body: "Go to Settings > Archived Habits. Tap the restore arrow to bring a habit back to your active list, or tap the trash icon to permanently delete it."
                            ),
                            HelpItem(
                                icon: "square.grid.2x2",
                                title: "Quick Add Templates",
                                body: "Tap the + button and choose \"Quick Add Template\" to pick from pre-built habits like Exercise, Meditate, Read, Drink Water, and more. Templates come with pre-set icons and colors."
                            ),
                        ]
                    )

                    // MARK: - Scheduling
                    collapsibleSection(
                        title: "SCHEDULING & FREQUENCY",
                        items: [
                            HelpItem(
                                icon: "calendar",
                                title: "Frequency Options",
                                body: "Every day — appears daily.\nWeekdays — Monday through Friday.\nWeekends — Saturday and Sunday.\nCustom — pick specific days of the week."
                            ),
                            HelpItem(
                                icon: "repeat",
                                title: "Multi-Completion Habits",
                                body: "Some habits need to be done more than once a day. When creating or editing a habit, set the \"Times per Day\" to track multiple completions.\n\nExamples:\n• Drink Water — 8 times/day\n• Skincare — 2 times/day (morning & evening)\n• Take Medication — 3 times/day\n\nEach tap adds one completion. The progress ring fills as you go, and the counter shows your progress (e.g., \"3 of 8\"). Your streak counts the day as complete only when you hit your daily target."
                            ),
                            HelpItem(
                                icon: "bell.fill",
                                title: "Reminders",
                                body: "Toggle on a reminder when creating or editing a habit. Set a time and Habitra will send a local notification on each scheduled day. For multi-completion habits, you'll get interval reminders spaced throughout the day. All notifications are local — no internet required."
                            ),
                            HelpItem(
                                icon: "bell.badge.fill",
                                title: "Test Notifications",
                                body: "Go to Settings and tap Test Notification to verify reminders are working. A test notification will appear in 5 seconds."
                            ),
                            HelpItem(
                                icon: "timer",
                                title: "Live Activity Timer",
                                body: "Long-press a habit and choose \"Start Timer\" to begin a 10-minute session. A Live Activity appears on your Lock Screen and Dynamic Island showing the countdown."
                            ),
                        ]
                    )

                    // MARK: - Today View
                    collapsibleSection(
                        title: "TODAY VIEW",
                        items: [
                            HelpItem(
                                icon: "checkmark.circle.fill",
                                title: "Daily Overview",
                                body: "The Today tab shows all habits scheduled for today with a progress ring at the top. Tap the circle on any habit to mark it done. A pulse animation and haptic feedback confirm each completion."
                            ),
                            HelpItem(
                                icon: "moon.stars.fill",
                                title: "Other Habits Section",
                                body: "Habits not scheduled for today appear in the \"Other Habits\" section at the bottom. Tap one to edit its schedule."
                            ),
                        ]
                    )

                    // MARK: - Stats
                    collapsibleSection(
                        title: "STATS & PROGRESS",
                        items: [
                            HelpItem(
                                icon: "chart.bar.fill",
                                title: "Stats Overview",
                                body: "The Stats tab shows active habit count, your best streak, and completion rate. Use the time range picker (7D, 30D, 90D, All) to adjust the view."
                            ),
                            HelpItem(
                                icon: "chart.xyaxis.line",
                                title: "Habit Detail Stats",
                                body: "Tap any habit in the Stats tab for a deep dive: current and longest streak, completion rates, a heatmap, trend analysis, best and weakest days, and a weekly bar chart. You can also share your streak from here."
                            ),
                            HelpItem(
                                icon: "arrow.up.right",
                                title: "Trend Analysis",
                                body: "The trend chart shows your daily completion rate over time with a smooth curve. A badge indicates if you're Improving, Steady, or Declining compared to the previous period."
                            ),
                            HelpItem(
                                icon: "circle.dotted",
                                title: "Progress Ring",
                                body: "The ring on the Today tab shows what percentage of today's scheduled habits are complete. For multi-completion habits, each completion counts toward the ring."
                            ),
                            HelpItem(
                                icon: "square.and.arrow.up",
                                title: "Share Streaks",
                                body: "Long-press a habit in Stats and choose \"Share Streak\" to generate a branded streak card. Choose from gradient themes and share the image to social media or messages."
                            ),
                        ]
                    )

                    // MARK: - AI Coach
                    // v1.0: hidden via FeatureAvailability — see docs/RELEASE_STRATEGY.md
                    if FeatureAvailability.aiInsights {
                    collapsibleSection(
                        title: "AI COACH",
                        items: [
                            HelpItem(
                                icon: "brain.head.profile",
                                title: "Coach Tab",
                                body: "The Coach tab is your AI-powered dashboard. It shows pattern-based insights, tomorrow's predictions, mood check-ins, weekly recaps, and health correlations — all processed on-device with zero cloud."
                            ),
                            HelpItem(
                                icon: "chart.dots.scatter",
                                title: "Predictions & Correlations",
                                body: "Tap \"Predictions & Correlations\" to see tomorrow's habit success forecast with percentage likelihood, risk factors, and suggested actions. Also shows how your habits correlate with each other and with your mood, plus adaptive reminder suggestions."
                            ),
                            HelpItem(
                                icon: "lightbulb.fill",
                                title: "AI Insights",
                                body: "The Coach tab detects patterns like: skip patterns (\"You usually skip Fridays\"), streak danger warnings, improvement/decline trends, habit correlations (\"Meditate and Exercise succeed together\"), and tracking milestones. Insights are prioritized from Urgent to Info."
                            ),
                            HelpItem(
                                icon: "doc.text.fill",
                                title: "Weekly Recap",
                                body: "Tap \"Weekly Recap\" for an AI-generated summary: overall completion rate, best and worst habits, strongest and weakest days, mood summary, key takeaways, tomorrow's outlook, and a motivational message. Recaps are generated every Sunday (notification at 7 PM)."
                            ),
                            HelpItem(
                                icon: "waveform.path.ecg",
                                title: "AI Model",
                                body: "Tap the AI Model card to see your personalized prediction model status. The model trains on your own data using gradient descent. You can manually retrain it. It needs 30+ data points and retrains daily. All training happens on-device."
                            ),
                            HelpItem(
                                icon: "square.and.arrow.up",
                                title: "Share AI Report",
                                body: "Tap \"Share Report\" to generate a text summary of your health scores, predictions, and insights that you can share or save."
                            ),
                        ]
                    )

                    } // end AI Coach FeatureAvailability gate

                    // MARK: - Mood Tracking
                    // v1.0: hidden via FeatureAvailability — see docs/RELEASE_STRATEGY.md
                    if FeatureAvailability.moodCheckin {
                    collapsibleSection(
                        title: "MOOD TRACKING",
                        items: [
                            HelpItem(
                                icon: "face.smiling",
                                title: "Daily Mood Check-In",
                                body: "Tap \"How are you feeling?\" in the Coach tab to log your mood. Choose from 5 levels (Terrible to Great) and optionally write a journal entry. Your journal is analyzed for sentiment using Apple's on-device NaturalLanguage framework."
                            ),
                            HelpItem(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Mood Trends",
                                body: "Tap \"Mood Trends\" to see your mood over time: average mood, sentiment score, mood distribution chart, sparkline trend, and recent journal entries with sentiment badges. Filter by 7, 30, or 90 days."
                            ),
                            HelpItem(
                                icon: "text.bubble",
                                title: "Journal Sentiment",
                                body: "When you write a journal entry, Habitra uses Apple's NaturalLanguage framework to analyze sentiment in real time. The score ranges from Negative to Positive and is displayed alongside your entry. All processing is on-device — your journal never leaves your phone."
                            ),
                        ]
                    )

                    } // end Mood Tracking FeatureAvailability gate

                    // MARK: - Health
                    // v1.0: hidden via FeatureAvailability — see docs/RELEASE_STRATEGY.md
                    if FeatureAvailability.healthKit {
                    collapsibleSection(
                        title: "HEALTH INSIGHTS",
                        items: [
                            HelpItem(
                                icon: "heart.text.clipboard",
                                title: "HealthKit Integration",
                                body: "Tap \"Health Insights\" in the Coach tab to connect Apple Health. Habitra reads your steps, sleep, active energy, and HRV to discover how health metrics affect your habit completion. Read-only — Habitra never writes to HealthKit. Pro feature."
                            ),
                            HelpItem(
                                icon: "link",
                                title: "Health x Habit Correlations",
                                body: "After connecting HealthKit, Habitra analyzes correlations like: \"Your workout habit is 40% more likely when you get 7+ hrs of sleep.\" Correlations are shown with comparison bars and percentage differences."
                            ),
                        ]
                    )

                    } // end Health FeatureAvailability gate

                    // MARK: - Widgets
                    collapsibleSection(
                        title: "WIDGETS",
                        items: [
                            HelpItem(
                                icon: "lock.fill",
                                title: "Lock Screen Widget",
                                body: "Add the Streak widget to your Lock Screen. It shows your top streak count and daily progress in circular, rectangular, or inline format."
                            ),
                            // v1.0: Habit Grid and Progress Bar widgets hidden — Pro feature
                            // These items will be restored when FeatureAvailability.allWidgets is true
                            HelpItem(
                                icon: "timer",
                                title: "Live Activity",
                                body: "Start a habit timer from the context menu to show a countdown on your Lock Screen and Dynamic Island. The Live Activity displays habit name, icon, and remaining time."
                            ),
                            HelpItem(
                                icon: "arrow.clockwise",
                                title: "Widget Updates",
                                body: "Widgets update automatically every time you complete or modify a habit. They also refresh hourly in the background."
                            ),
                        ]
                    )

                    // MARK: - Data & Sync
                    // v1.0: hidden via FeatureAvailability — see docs/RELEASE_STRATEGY.md
                    // iCloud Sync and CSV Export are hidden in v1.0; section only shown when at least one is available
                    if FeatureAvailability.iCloudSync || FeatureAvailability.exportCSV {
                    collapsibleSection(
                        title: "DATA & SYNC",
                        items: [
                            HelpItem(
                                icon: "icloud.fill",
                                title: "iCloud Sync",
                                body: "Go to Settings > iCloud Sync to see your sync status. When enabled (Pro feature), habits sync automatically across all devices signed into the same Apple ID using Apple's CloudKit. Your data is end-to-end encrypted by Apple — Habitra has no server and cannot access it."
                            ),
                            HelpItem(
                                icon: "square.and.arrow.up.fill",
                                title: "Export Data",
                                body: "Go to Settings > Export Data to download your habit data as a CSV file. Choose between a habits summary or a detailed completions export. Share the file via AirDrop, email, or save to Files."
                            ),
                        ]
                    )
                    }

                    // MARK: - Appearance
                    collapsibleSection(
                        title: "APPEARANCE",
                        items: [
                            HelpItem(
                                icon: "moon.fill",
                                title: "Dark Mode",
                                body: "Toggle Dark Mode on or off in Settings. Habitra defaults to dark mode with the signature purple-on-black brand look. Light mode uses a soft lavender palette."
                            ),
                            HelpItem(
                                icon: "paintpalette.fill",
                                title: "Habit Colors",
                                body: "Each habit can have its own color from 8 presets: purple, blue, cyan, green, yellow, orange, pink, and red. The color is used throughout the app — streaks, rings, stats, and widgets."
                            ),
                            HelpItem(
                                icon: "sparkles",
                                title: "Streak Themes",
                                body: "When sharing a streak card, choose from gradient themes including Midnight and Ocean. Themes change the background gradient and text color of your share card. More themes are on the roadmap."
                            ),
                        ]
                    )

                    // MARK: - Privacy
                    collapsibleSection(
                        title: "PRIVACY",
                        items: [
                            HelpItem(
                                icon: "lock.shield.fill",
                                title: "Privacy First",
                                body: "All your data is stored on your device using SwiftData. AI processing, mood analysis, and health correlations all happen on-device. There are no accounts, no analytics, no trackers, and no data collection of any kind."
                            ),
                            HelpItem(
                                icon: "antenna.radiowaves.left.and.right.slash",
                                title: "Offline First",
                                body: "Habitra works fully offline, including all notifications, stats, AI coaching, and widgets. The only optional network feature is iCloud sync (Pro), which uses Apple's encrypted CloudKit."
                            ),
                            HelpItem(
                                icon: "heart.fill",
                                title: "Health Data Privacy",
                                body: "HealthKit data is read-only and never leaves your device. Habitra never writes to HealthKit or sends health data anywhere. All correlations are computed locally."
                            ),
                        ]
                    )

                    // MARK: - Support & Roadmap
                    // v1.0: replaces "Free vs Pro" — see docs/RELEASE_STRATEGY.md
                    collapsibleSection(
                        title: "SUPPORT HABITRA",
                        items: [
                            HelpItem(
                                icon: "gift.fill",
                                title: "Free Forever",
                                body: "Habitra is 100% free. Track up to 5 habits with streaks, stats, Lock Screen widget, reminders, and light/dark mode. No ads, no tracking, no cloud."
                            ),
                            HelpItem(
                                icon: "heart.fill",
                                title: "Tip Jar",
                                body: "Love Habitra? Go to Settings > Support & Roadmap to leave an optional one-time tip ($1.99, $4.99, or $9.99). Tips don't unlock anything — they fuel development of the features on the roadmap."
                            ),
                            HelpItem(
                                icon: "sparkles",
                                title: "What's Coming",
                                body: "We're building: on-device AI Coach, Apple Health integration, iCloud sync, more widgets, and weekly quests. See Settings > Support & Roadmap for the full list. No dates — we ship when they're ready."
                            ),
                        ]
                    )

                    // MARK: - Tips
                    collapsibleSection(
                        title: "TIPS FOR SUCCESS",
                        items: [
                            HelpItem(
                                icon: "lightbulb.fill",
                                title: "Start Small",
                                body: "Begin with 1-2 habits you can realistically do every day. Add more once those become routine."
                            ),
                            HelpItem(
                                icon: "clock.fill",
                                title: "Set Reminders",
                                body: "A well-timed reminder dramatically increases your chance of sticking with a habit. Set one when creating or editing any habit."
                            ),
                            HelpItem(
                                icon: "rectangle.on.rectangle",
                                title: "Use Widgets",
                                body: "Add a Habitra widget to your Lock Screen or Home Screen to see your streaks at a glance without opening the app."
                            ),
                            HelpItem(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Check Your Stats",
                                body: "Review the Stats tab weekly. The heatmap, health scores, and AI insights help you spot patterns and adjust your routine."
                            ),
                            HelpItem(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Review Weekly",
                                body: "Check the Stats tab at least once a week. The heatmap and completion trends help you spot patterns and stay accountable."
                            ),
                        ]
                    )

                    // MARK: - Troubleshooting
                    collapsibleSection(
                        title: "TROUBLESHOOTING",
                        items: [
                            HelpItem(
                                icon: "bell.slash.fill",
                                title: "Notifications Not Working",
                                body: "Make sure notifications are enabled in iOS Settings > Habitra > Notifications. Use Settings > Test Notification inside the app to verify. If the test works but habit reminders don't, try editing the habit and toggling the reminder off and back on."
                            ),
                            HelpItem(
                                icon: "square.dashed",
                                title: "Widgets Not Updating",
                                body: "Widgets update when you complete or modify a habit. If a widget is stale, open the app, make any change, and check again. iOS may throttle widget updates in Low Power Mode."
                            ),
                            HelpItem(
                                icon: "exclamationmark.triangle.fill",
                                title: "Habits Not Showing",
                                body: "If a habit isn't showing on the Today tab, check its frequency — it may not be scheduled for today. Look under the \"Other Habits\" section at the bottom, or check if it was accidentally archived in Settings > Archived Habits."
                            ),
                            // v1.0: AI Model, HealthKit, iCloud troubleshooting hidden — Pro features
                            // Restore these when FeatureAvailability flags are flipped
                        ]
                    )
                }
                .padding(.top, HabitraTheme.spacing)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Help Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Collapsible Section Builder

    private func collapsibleSection(title: String, items: [HelpItem]) -> some View {
        let isExpanded = expandedSections.contains(title)

        return VStack(alignment: .leading, spacing: 0) {
            // Section header — tap to expand/collapse
            Button {
                withHabitraAnimation(.easeInOut(duration: 0.25)) {
                    if expandedSections.contains(title) {
                        expandedSections.remove(title)
                    } else {
                        expandedSections.insert(title)
                    }
                }
            } label: {
                HStack {
                    Text(title)
                        .habitraCaption()
                        .sectionHeaderAccessibility()

                    Spacer()

                    HStack(spacing: 6) {
                        Text("\(items.count)")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.habitraTextTertiary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HabitraTheme.screenPadding)
            .padding(.bottom, isExpanded ? HabitraTheme.spacing : 0)

            // Expandable content
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        helpRow(item)

                        if index < items.count - 1 {
                            Divider()
                                .background(Color.habitraAccent.opacity(0.1))
                                .padding(.leading, 52)
                        }
                    }
                }
                .habitraCard()
                .padding(.horizontal, HabitraTheme.screenPadding)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func helpRow(_ item: HelpItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.habitraAccent)
                .frame(width: 28, height: 28)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text(item.body)
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Help Item Model
private struct HelpItem {
    let icon: String
    let title: String
    let body: String
}

#Preview {
    NavigationStack {
        HelpGuideView()
    }
}
