//
//  StatsView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//  Phase 2 Week 2: Time range picker, trend analysis, streak sharing
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Time Range

enum StatsTimeRange: String, CaseIterable, Identifiable {
    case week = "7D"
    case month = "30D"
    case quarter = "90D"
    case all = "All"

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .all: return 365
        }
    }

    var heatmapWeeks: Int {
        switch self {
        case .week: return 2
        case .month: return 5
        case .quarter: return 13
        case .all: return 52
        }
    }

    var label: String {
        switch self {
        case .week: return "Last 7 Days"
        case .month: return "Last 30 Days"
        case .quarter: return "Last 90 Days"
        case .all: return "Last Year"
        }
    }
}

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.sortOrder)
    private var habits: [Habit]

    @State private var selectedRange: StatsTimeRange = .month
    @State private var showingStreakShare: Habit?
    @State private var healthScores: [HabitHealthScore] = []
    @State private var showingBadgeShelf = false
    @State private var showingQuestTracker = false
    @State private var showingCollections = false

    @Query(sort: \EarnedBadge.earnedAt, order: .reverse)
    private var earnedBadges: [EarnedBadge]

    @Query(filter: #Predicate<Quest> { !$0.isCompleted },
           sort: \Quest.startDate, order: .reverse)
    private var activeQuests: [Quest]

    var body: some View {
        NavigationStack {
            statsContent
                .navigationTitle("Stats")
                .navigationDestination(isPresented: $showingBadgeShelf) {
                    BadgeShelfView()
                }
                .navigationDestination(isPresented: $showingQuestTracker) {
                    QuestTrackerView()
                }
                .navigationDestination(isPresented: $showingCollections) {
                    CollectionView()
                }
        }
        .sheet(item: $showingStreakShare) { habit in
            StreakShareSheet(habit: habit)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            healthScores = HabitHealthScorer.scoreAll(habits: habits)
        }
    }

    @ViewBuilder
    private var statsContent: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            if habits.isEmpty {
                HabitraEmptyState(
                    icon: "chart.bar.xaxis",
                    title: "No stats yet",
                    message: "Create habits and start tracking to see your progress here."
                )
            } else {
                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        // Time range picker
                        timeRangePicker

                        overviewSection

                        xpSection

                        badgesSection

                        questSection

                        collectionSection

                        // Health score bar
                        if !healthScores.isEmpty {
                            healthOverview
                        }

                        trendSection

                        heatmapSection

                        habitsSection
                    }
                    .padding(.top, HabitraTheme.spacing)
                    .padding(.bottom, 100)
                }
            }
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
                                ? Color.habitraAccent
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
                .stroke(Color.habitraAccent.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Overview Cards

    private var overviewSection: some View {
        HStack(spacing: HabitraTheme.spacing) {
            OverviewStatCard(
                title: "Active",
                value: "\(habits.count)",
                icon: "bolt.fill",
                color: .habitraAccent
            )

            OverviewStatCard(
                title: "Best Streak",
                value: "\(bestStreak)",
                icon: "flame.fill",
                color: .habitraHabitOrange
            )

            OverviewStatCard(
                title: selectedRange.rawValue,
                value: "\(Int(rangeRate * 100))%",
                icon: "chart.line.uptrend.xyaxis",
                color: .habitraHabitGreen
            )
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Trend

    private var trendSection: some View {
        TrendAnalysisView(habits: habits, days: selectedRange.days)
            .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Heatmap

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
            Text(selectedRange.label.uppercased())
                .habitraCaption()
                .sectionHeaderAccessibility()

            CalendarHeatmapView(
                completionMap: StreakCalculator.completionMap(habits: habits, days: selectedRange.heatmapWeeks * 7),
                maxPerDay: habits.count,
                weeks: selectedRange.heatmapWeeks
            )

            // Summary row
            HStack {
                statPill(label: "Total", value: "\(totalCompletionsInRange)")
                Spacer()
                statPill(label: "Rate", value: "\(Int(rangeRate * 100))%")
                Spacer()
                statPill(label: "Streak", value: "\(bestStreak)d")
            }
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(HabitraFont.headline())
                .foregroundStyle(Color.habitraTextPrimary)
            Text(label)
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary)
        }
    }

    // MARK: - Per-Habit Stats

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("HABITS")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            ForEach(habits) { habit in
                habitStatLink(habit)
            }
            .padding(.horizontal, HabitraTheme.screenPadding)
        }
    }

    private func habitStatLink(_ habit: Habit) -> some View {
        NavigationLink {
            HabitDetailStatsView(habit: habit, initialRange: selectedRange)
        } label: {
            HabitStatRow(habit: habit, days: selectedRange.days)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                showingStreakShare = habit
            } label: {
                Label("Share Streak", systemImage: "square.and.arrow.up")
            }
        }
    }

    // MARK: - Health Overview

    private var healthOverview: some View {
        let avgScore = healthScores.isEmpty ? 0 :
            healthScores.reduce(0) { $0 + $1.score } / healthScores.count

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("AI HEALTH SCORE")
                    .habitraCaption()
                    .sectionHeaderAccessibility()

                Spacer()

                Text("\(avgScore)/100")
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
            }

            // Mini health bar for each habit
            ForEach(healthScores.prefix(5)) { score in
                HStack(spacing: 8) {
                    Image(systemName: score.habitIcon)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: score.habitColorHex))
                        .frame(width: 18)

                    Text(score.habitName)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextSecondary)
                        .lineLimit(1)

                    Spacer()

                    // Score bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.habitraSurfaceLight)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: score.grade.colorHex))
                                .frame(width: geo.size.width * Double(score.score) / 100.0, height: 4)
                        }
                    }
                    .frame(width: 60, height: 4)

                    Text(score.grade.rawValue)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color(hex: score.grade.colorHex))
                        .frame(width: 22)
                }
            }
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Badges Banner

    private var badgesSection: some View {
        let earnedCount = Set(earnedBadges.map(\.badgeID)).count
        let totalCount = BadgeCatalog.all.count
        let recentThree = Array(earnedBadges.prefix(3))

        return Button {
            showingBadgeShelf = true
        } label: {
            HStack(spacing: HabitraTheme.spacing) {
                // Recent badge icons
                HStack(spacing: -10) {
                    ForEach(recentThree, id: \.id) { badge in
                        if let def = badge.definition {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: def.colorHex).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: def.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color(hex: def.colorHex))
                            }
                            .overlay(Circle().stroke(Color.habitraBackground, lineWidth: 2))
                        }
                    }
                    if recentThree.isEmpty {
                        ZStack {
                            Circle()
                                .fill(Color.habitraAccent.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.habitraAccent.opacity(0.6))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Badges")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text("\(earnedCount) of \(totalCount) earned")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }

                Spacer()

                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color.habitraAccent.opacity(0.15), lineWidth: 3)
                        .frame(width: 36, height: 36)
                    Circle()
                        .trim(from: 0, to: totalCount > 0 ? Double(earnedCount) / Double(totalCount) : 0)
                        .stroke(Color.habitraAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .habitraCard()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - XP Section

    private var xpSection: some View {
        HStack(spacing: HabitraTheme.spacing) {
            // Level ring
            ZStack {
                ProgressRing(
                    progress: XPEngine.xpProgressInLevel,
                    lineWidth: 4,
                    size: 48,
                    color: .habitraVital
                )
                Text("Lv.\(XPEngine.currentLevel)")
                    .font(.system(.caption2))
                    .foregroundStyle(Color.habitraVital)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(XPEngine.currentLevel)")
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)

                HStack(spacing: HabitraTheme.spacing) {
                    VStack(spacing: 1) {
                        Text("\(XPEngine.lifetimeXP)")
                            .font(HabitraFont.caption())
                            .foregroundStyle(Color.habitraVital)
                        Text("Lifetime")
                            .font(.system(.caption2))
                            .foregroundStyle(Color.habitraTextTertiary)
                    }

                    VStack(spacing: 1) {
                        Text("\(XPEngine.weekXP)")
                            .font(HabitraFont.caption())
                            .foregroundStyle(Color.habitraAccent)
                        Text("This Week")
                            .font(.system(.caption2))
                            .foregroundStyle(Color.habitraTextTertiary)
                    }

                    VStack(spacing: 1) {
                        Text("\(XPEngine.todayXP)")
                            .font(HabitraFont.caption())
                            .foregroundStyle(Color.habitraHabitGreen)
                        Text("Today")
                            .font(.system(.caption2))
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }
            }

            Spacer()
        }
        .habitraCard()
        .statCardAccessibility(label: "Level", value: "Level \(XPEngine.currentLevel), \(XPEngine.lifetimeXP) lifetime XP")
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Quest Section

    private var questSection: some View {
        Group {
            if let monthlyQuest = activeQuests.first(where: { $0.questType == "monthly" }) {
                Button {
                    showingQuestTracker = true
                } label: {
                    HStack(spacing: HabitraTheme.spacing) {
                        Image(systemName: monthlyQuest.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(Color.habitraVital)
                            .frame(width: 36, height: 36)
                            .background(Color.habitraVital.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Active Quest")
                                .font(HabitraFont.headline())
                                .foregroundStyle(Color.habitraTextPrimary)
                            Text(monthlyQuest.title)
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary)
                        }

                        Spacer()

                        // Progress ring
                        ZStack {
                            Circle()
                                .stroke(Color.habitraVital.opacity(0.15), lineWidth: 3)
                                .frame(width: 36, height: 36)
                            Circle()
                                .trim(from: 0, to: monthlyQuest.progressFraction)
                                .stroke(Color.habitraVital, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 36, height: 36)
                                .rotationEffect(.degrees(-90))
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                    .habitraCard()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, HabitraTheme.screenPadding)
                .overlay {
                    if !SubscriptionManager.canUseQuests {
                        RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                            .fill(Color.habitraBackground.opacity(0.6))
                            .overlay(
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color.habitraAccent)
                            )
                            .padding(.horizontal, HabitraTheme.screenPadding)
                    }
                }
            }
        }
    }

    // MARK: - Collection Section

    private var collectionSection: some View {
        Button {
            showingCollections = true
        } label: {
            HStack(spacing: HabitraTheme.spacing) {
                Image(systemName: "trophy.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.habitraAccent)
                    .frame(width: 36, height: 36)
                    .background(Color.habitraAccent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Collections")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)
                    Text("Complete badge sets for rewards")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .habitraCard()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HabitraTheme.screenPadding)
        .overlay {
            if !SubscriptionManager.canUseCollections {
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                    .fill(Color.habitraBackground.opacity(0.6))
                    .overlay(
                        Image(systemName: "lock.fill")
                            .foregroundStyle(Color.habitraAccent)
                    )
                    .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    // MARK: - Computed

    private var bestStreak: Int {
        habits.map(\.longestStreak).max() ?? 0
    }

    private var rangeRate: Double {
        guard !habits.isEmpty else { return 0 }
        let rates = habits.map { StreakCalculator.completionRate(for: $0, days: selectedRange.days) }
        return rates.reduce(0, +) / Double(rates.count)
    }

    private var totalCompletionsInRange: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -selectedRange.days, to: today) else {
            return StreakCalculator.totalCompletions(habits: habits)
        }
        return habits.reduce(0) { total, habit in
            total + habit.completions.filter { $0.completedDate >= startDate }.count
        }
    }
}

// MARK: - Overview Stat Card
struct OverviewStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            Text(value)
                .font(HabitraFont.title())
                .foregroundStyle(Color.habitraTextPrimary)

            Text(title)
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .habitraCard()
        .statCardAccessibility(label: title, value: value)
    }
}

// MARK: - Per-Habit Stat Row
struct HabitStatRow: View {
    let habit: Habit
    var days: Int = 7

    private var rate: Double {
        StreakCalculator.completionRate(for: habit, days: days)
    }

    private var habitColor: Color {
        Color(hex: habit.colorHex)
    }

    /// Last 7 days as (index, completed, scheduled) for the sparkline.
    private var sparklineData: [(index: Int, completed: Bool, scheduled: Bool)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: -(6 - i), to: today)!
            return (
                index: i,
                completed: habit.isCompleted(on: date),
                scheduled: habit.frequency.isScheduled(for: date)
            )
        }
    }

    var body: some View {
        HStack(spacing: HabitraTheme.spacing) {
            Image(systemName: habit.icon)
                .font(.system(size: 18))
                .foregroundStyle(habitColor)
                .frame(width: 36, height: 36)
                .background(habitColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
                Text("\(Int(rate * 100))% completion")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }

            Spacer()

            // 7-day sparkline
            Chart {
                ForEach(sparklineData, id: \.index) { day in
                    BarMark(
                        x: .value("Day", day.index),
                        y: .value("Done", day.completed ? 1.0 : (day.scheduled ? 0.18 : 0.0))
                    )
                    .foregroundStyle(
                        day.completed
                            ? habitColor
                            : (day.scheduled ? habitColor.opacity(0.18) : Color.clear)
                    )
                    .cornerRadius(2)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            .frame(width: 52, height: 20)

            StreakBadge(count: habit.currentStreak, color: habitColor)

            ProgressRing(
                progress: rate,
                lineWidth: 4,
                size: 36,
                color: habitColor
            )

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .habitraCard(tintColor: habitColor)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self], inMemory: true)
}
