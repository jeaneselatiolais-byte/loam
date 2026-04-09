//
//  HabitDetailStatsView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//  Phase 2 Week 2: Time range support, share streak, trend analysis
//

import SwiftUI

struct HabitDetailStatsView: View {
    let habit: Habit
    var initialRange: StatsTimeRange = .month

    @State private var selectedRange: StatsTimeRange = .month
    @State private var showingStreakShare = false

    private var habitColor: Color {
        Color(hex: habit.colorHex)
    }

    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HabitraTheme.spacingLarge) {
                    habitHeader

                    timeRangePicker

                    streakCards

                    rateCards

                    trendSection

                    heatmapSection

                    insightsSection

                    weeklyBreakdown
                }
                .padding(.top, HabitraTheme.spacing)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingStreakShare = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.habitraAccent)
                }
            }
        }
        .sheet(isPresented: $showingStreakShare) {
            StreakShareSheet(habit: habit)
        }
        .onAppear {
            selectedRange = initialRange
        }
    }

    // MARK: - Time Range Picker

    private var timeRangePicker: some View {
        HStack(spacing: 0) {
            ForEach(StatsTimeRange.allCases) { range in
                Button {
                    withHabitraAnimation(.easeInOut(duration: 0.2)) {
                        selectedRange = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(HabitraFont.caption())
                        .tracking(0)
                        .textCase(.none)
                        .foregroundStyle(
                            selectedRange == range
                                ? Color.white
                                : Color.habitraTextTertiary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedRange == range
                                ? habitColor
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(3)
        .background(Color.habitraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(habitColor.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Header

    private var habitHeader: some View {
        HStack(spacing: HabitraTheme.spacing) {
            ZStack {
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                    .fill(habitColor.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: habit.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(habitColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(HabitraFont.title())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text(habit.frequency.displayName)
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Streak Cards

    private var streakCards: some View {
        HStack(spacing: HabitraTheme.spacing) {
            StatBadge(
                title: "Current",
                value: "\(habit.currentStreak)",
                subtitle: "day streak",
                icon: "flame.fill",
                color: habitColor
            )

            StatBadge(
                title: "Longest",
                value: "\(habit.longestStreak)",
                subtitle: "day streak",
                icon: "trophy.fill",
                color: .habitraHabitYellow
            )

            StatBadge(
                title: "Total",
                value: "\(completionsInRange)",
                subtitle: "completions",
                icon: "checkmark.circle.fill",
                color: .habitraHabitGreen
            )
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Rate Cards

    private var rateCards: some View {
        HStack(spacing: HabitraTheme.spacing) {
            RateCard(
                title: selectedRange.label,
                rate: StreakCalculator.completionRate(for: habit, days: selectedRange.days),
                color: habitColor
            )

            RateCard(
                title: "This Week",
                rate: StreakCalculator.completionRate(for: habit, days: 7),
                color: habitColor
            )
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Trend

    private var trendSection: some View {
        TrendAnalysisView(habits: [habit], days: selectedRange.days)
            .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Heatmap

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
            Text(selectedRange.label.uppercased())
                .habitraCaption()
                .sectionHeaderAccessibility()

            HabitHeatmapView(
                completionMap: StreakCalculator.completionMap(habit: habit, days: selectedRange.heatmapWeeks * 7),
                weeks: selectedRange.heatmapWeeks,
                color: habitColor
            )
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Insights

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("INSIGHTS")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            VStack(spacing: HabitraTheme.spacingSmall) {
                if let best = StreakCalculator.bestDayOfWeek(habit: habit, days: selectedRange.days) {
                    insightRow(
                        icon: "hand.thumbsup.fill",
                        text: "Best day: \(StreakCalculator.weekdayName(for: best.day)) (\(Int(best.rate * 100))%)",
                        color: .habitraHabitGreen
                    )
                }

                if let worst = StreakCalculator.worstDayOfWeek(habit: habit, days: selectedRange.days) {
                    insightRow(
                        icon: "exclamationmark.triangle.fill",
                        text: "Weakest day: \(StreakCalculator.weekdayName(for: worst.day)) (\(Int(worst.rate * 100))%)",
                        color: .habitraHabitOrange
                    )
                }

                insightRow(
                    icon: "calendar",
                    text: "Tracking since \(habit.createdAt.formatted(.dateTime.month(.abbreviated).day().year()))",
                    color: .habitraAccent
                )

                insightRow(
                    icon: "checkmark.circle",
                    text: "\(completionsInRange) completions in \(selectedRange.label.lowercased())",
                    color: habitColor
                )
            }
            .habitraCard()
            .padding(.horizontal, HabitraTheme.screenPadding)
        }
    }

    private func insightRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(text)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)

            Spacer()
        }
    }

    // MARK: - Weekly Breakdown

    private var weeklyBreakdown: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("WEEKLY PATTERN")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            WeeklyBarChart(habit: habit, color: habitColor, days: selectedRange.days)
                .habitraCard()
                .padding(.horizontal, HabitraTheme.screenPadding)
        }
    }

    // MARK: - Computed

    private var completionsInRange: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -selectedRange.days, to: today) else {
            return habit.completions.count
        }
        return habit.completions.filter { $0.completedDate >= startDate }.count
    }
}

// MARK: - Stat Badge
private struct StatBadge: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(value)
                .font(HabitraFont.title())
                .foregroundStyle(Color.habitraTextPrimary)

            Text(subtitle)
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .habitraCard()
        .statCardAccessibility(label: title, value: "\(value) \(subtitle)")
    }
}

// MARK: - Rate Card
private struct RateCard: View {
    let title: String
    let rate: Double
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(HabitraFont.caption())
                    .tracking(0)
                    .textCase(.none)
                    .foregroundStyle(Color.habitraTextTertiary)

                Text("\(Int(rate * 100))%")
                    .font(HabitraFont.stat())
                    .foregroundStyle(Color.habitraTextPrimary)
            }

            Spacer()

            ProgressRing(progress: rate, lineWidth: 5, size: 44, color: color)
        }
        .frame(maxWidth: .infinity)
        .habitraCard()
        .statCardAccessibility(label: title, value: "\(Int(rate * 100))%")
    }
}

// MARK: - Weekly Bar Chart
private struct WeeklyBarChart: View {
    let habit: Habit
    let color: Color
    var days: Int = 90

    private var dayRates: [(day: String, rate: Double)] {
        let symbols = Calendar.current.shortWeekdaySymbols
        return (1...7).map { weekday in
            let rate = dayCompletionRate(weekday: weekday)
            return (symbols[weekday - 1], rate)
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(dayRates.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 4) {
                    Text("\(Int(item.rate * 100))")
                        .font(.system(.caption2))
                        .foregroundStyle(Color.habitraTextTertiary)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(item.rate > 0 ? color.opacity(0.3 + item.rate * 0.7) : Color.habitraSurface)
                        .frame(height: max(4, CGFloat(item.rate) * 80))

                    Text(item.day)
                        .font(.system(.caption2))
                        .foregroundStyle(Color.habitraTextTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 120)
    }

    private func dayCompletionRate(weekday: Int) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var scheduled = 0
        var completed = 0

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let wd = calendar.component(.weekday, from: date)
            if wd == weekday && habit.frequency.isScheduled(for: date) {
                scheduled += 1
                if habit.isCompleted(on: date) {
                    completed += 1
                }
            }
        }

        guard scheduled > 0 else { return 0 }
        return Double(completed) / Double(scheduled)
    }
}

#Preview {
    NavigationStack {
        HabitDetailStatsView(
            habit: Habit(name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF")
        )
    }
}
