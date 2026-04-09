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
                                title: "Free Habit Limit",
                                body: "Free accounts can track up to 5 habits. Upgrade to Habitra Pro for unlimited habits and categories."
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
                                icon: "brain.head.profile",
                                title: "AI Coaching Banner",
                                body: "A contextual coaching message appears at the top of the Today tab. It adapts to your current progress — motivating you in the morning, warning about at-risk streaks in the evening, and celebrating when you're all done. Tap the X to dismiss."
                            ),
                            HelpItem(
                                icon: "arrow.up.arrow.down",
                                title: "Smart Sort (AI)",
                                body: "Tap the + menu and toggle \"Smart Sort (AI)\" to have your habits automatically ordered by priority. Incomplete habits needing the most attention appear first, based on their AI health score. Toggle back to return to manual order."
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
                                body: "The Stats tab shows active habit count, your best streak, and completion rate. Use the time range picker (7D, 30D, 90D, All) to adjust the view. An AI Health Score section shows each habit's grade (A+ through F)."
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
                                body: "Long-press a habit in Stats and choose \"Share Streak\" to generate a branded streak card. Choose from 10 gradient themes (2 free, 8 Pro) and share the image to social media or messages."
                            ),
                        ]
                    )

                    // MARK: - AI Coach
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

                    // MARK: - Mood Tracking
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

                    // MARK: - Health
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

                    // MARK: - Widgets
                    collapsibleSection(
                        title: "WIDGETS",
                        items: [
                            HelpItem(
                                icon: "lock.fill",
                                title: "Lock Screen Widget",
                                body: "Add the Streak widget to your Lock Screen. It shows your top streak count and daily progress in circular, rectangular, or inline format."
                            ),
                            HelpItem(
                                icon: "square.grid.2x2.fill",
                                title: "Habit Grid Widget",
                                body: "A small or medium Home Screen widget showing each habit with its icon, name, and a checkmark when completed today. Pro feature."
                            ),
                            HelpItem(
                                icon: "chart.bar.xaxis",
                                title: "Progress Bar Widget",
                                body: "A medium or large Home Screen widget showing weekly progress bars for each habit, streak badges, and an overall progress ring. Pro feature."
                            ),
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
                                body: "When sharing a streak card, choose from 10 gradient themes: Midnight and Ocean (free), plus Sunset, Forest, Aurora, Ember, Lavender, Minimal, Neon, and Cosmic (Pro). Themes change the background gradient and text color of your share card."
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

                    // MARK: - Free vs Pro
                    collapsibleSection(
                        title: "FREE VS PRO",
                        items: [
                            HelpItem(
                                icon: "gift.fill",
                                title: "Free Tier",
                                body: "Track up to 3 habits with streaks, basic stats, the Lock Screen streak widget, reminders, AI coaching messages, and light/dark mode. Free forever."
                            ),
                            HelpItem(
                                icon: "sparkles",
                                title: "Habitra Pro",
                                body: "Unlimited habits and categories, all widget sizes (Habit Grid, Progress Bars, Standby), on-device AI predictions and nudges, mood check-in and trends, HealthKit integration, iCloud sync across devices, CSV data export, custom streak themes, and AI report sharing.\n\n$4.99/mo · $39.99/yr · $79.99 lifetime\n14-day free trial on the annual plan."
                            ),
                            HelpItem(
                                icon: "heart.fill",
                                title: "Tip Jar",
                                body: "Love Habitra? The Tip Jar on the upgrade screen lets you leave a one-time tip ($1.99, $4.99, or $9.99) to support indie development."
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
                                body: "A well-timed reminder dramatically increases your chance of sticking with a habit. Check the Coach tab's adaptive reminder suggestions to find your optimal time."
                            ),
                            HelpItem(
                                icon: "face.smiling",
                                title: "Track Your Mood",
                                body: "Log your mood daily in the Coach tab. Over time, Habitra will discover how your mood affects specific habits and offer personalized insights."
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
                                icon: "doc.text.fill",
                                title: "Read Your Weekly Recap",
                                body: "Every Sunday at 7 PM, you'll get a notification to check your AI-generated weekly recap. It highlights your wins, areas to improve, and predictions for next week."
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
                            HelpItem(
                                icon: "brain",
                                title: "AI Model Not Training",
                                body: "The AI model needs at least 30 data points (habit completions across multiple days). Keep tracking for 1-2 weeks and the model will train automatically. You can also manually trigger training from Coach > AI Model."
                            ),
                            HelpItem(
                                icon: "heart.slash",
                                title: "HealthKit Not Connecting",
                                body: "Make sure you've granted Habitra access in iOS Settings > Privacy & Security > Health > Habitra. HealthKit requires a Pro subscription. If data isn't showing, wait a few hours for Apple Health to sync new data."
                            ),
                            HelpItem(
                                icon: "icloud.slash",
                                title: "iCloud Sync Issues",
                                body: "Verify you're signed into iCloud in iOS Settings. iCloud sync requires a Pro subscription and an active internet connection. Changes may take a few minutes to appear on other devices. Check Settings > iCloud Sync for current status."
                            ),
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
