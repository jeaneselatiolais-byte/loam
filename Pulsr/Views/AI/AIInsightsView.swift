//
//  AIInsightsView.swift
//  Habitra
//
//  Phase 3 Week 8: AI-powered insights dashboard
//

import SwiftUI
import SwiftData

struct AIInsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.sortOrder)
    private var habits: [Habit]

    @Query(sort: \MoodEntry.date, order: .reverse)
    private var moodEntries: [MoodEntry]

    @State private var insights: [HabitInsight] = []
    @State private var isLoading = true
    @State private var showingMoodCheckIn = false
    @State private var showingWeeklyRecap = false
    @State private var showingPredictions = false
    @State private var showingMoodTrend = false
    @State private var showingModelStatus = false
    @State private var showingShareSheet = false
    @State private var shareText = ""
    @State private var showingHealth = false
    @State private var tomorrowPredictions: [HabitPrediction] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        // Header
                        aiHeader

                        // Quick mood check-in button
                        moodCheckInButton

                        // Prediction & Recap buttons
                        predictionButton
                        weeklyRecapButton

                        // Tomorrow's at-risk habits (inline preview)
                        if !tomorrowPredictions.isEmpty {
                            tomorrowPreview
                        }

                        // Health insights button
                        healthButton

                        // Mood trend button (if data exists)
                        if !moodEntries.isEmpty {
                            moodTrendButton
                        }

                        // Recent mood entries
                        if !moodEntries.isEmpty {
                            recentMoodSection
                        }

                        // Model status + export row
                        aiToolsRow

                        // Insights
                        if isLoading {
                            loadingView
                        } else if insights.isEmpty {
                            emptyInsightsView
                        } else {
                            insightsListSection
                        }
                    }
                    .padding(.top, HabitraTheme.spacing)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("AI Coach")
            .onAppear { generateInsights() }
            .sheet(isPresented: $showingModelStatus) {
                AIModelStatusView()
                    .presentationSizing(.page)
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheetView(items: [shareText])
            }
        }
        .fullScreenCover(isPresented: $showingMoodCheckIn) {
            MoodCheckInView()
        }
        .fullScreenCover(isPresented: $showingWeeklyRecap) {
            WeeklyRecapView()
        }
        .fullScreenCover(isPresented: $showingPredictions) {
            PredictionDashboardView()
        }
        .fullScreenCover(isPresented: $showingMoodTrend) {
            MoodTrendView()
        }
        .fullScreenCover(isPresented: $showingHealth) {
            HealthDashboardView()
        }
    }

    // MARK: - Header

    private var aiHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.habitraAccent.opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.habitraAccent)
            }

            Text("On-Device AI Coach")
                .font(HabitraFont.headline())
                .foregroundStyle(Color.habitraTextPrimary)
                .sectionHeaderAccessibility()

            Text("Pattern detection and insights — processed entirely on your device. Zero cloud.")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, HabitraTheme.spacing)
    }

    // MARK: - Mood Check-In Button

    private var moodCheckInButton: some View {
        Button {
            showingMoodCheckIn = true
        } label: {
            HStack(spacing: HabitraTheme.spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.habitraHabitPink.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Text(todaysMoodEmoji ?? "🫧")
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(todaysMoodEmoji != nil ? "Update Today's Mood" : "How are you feeling?")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text("Daily mood check-in with journal")
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
        .interactiveCardAccessibility(label: todaysMoodEmoji != nil ? "Update Today's Mood" : "How are you feeling?", hint: "Opens mood check-in")
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private var todaysMoodEmoji: String? {
        let today = Calendar.current.startOfDay(for: Date())
        return moodEntries.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }).map { MoodLevel(rawValue: $0.moodLevel)?.emoji ?? "😐" }
    }

    // MARK: - AI Tools Row

    private var aiToolsRow: some View {
        HStack(spacing: HabitraTheme.spacing) {
            // Model status
            Button {
                showingModelStatus = true
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: CoreMLModelTrainer.shared.trainingStatus.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: CoreMLModelTrainer.shared.trainingStatus.colorHex))

                    Text("AI Model")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .habitraCard()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("AI Model Status")
            .accessibilityHint("Opens model training status")

            // Export report
            Button {
                exportInsights()
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.habitraHabitCyan)

                    Text("Share Report")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .habitraCard()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Share Report")
            .accessibilityHint("Exports and shares your insights report")

            // Overall score
            let overallScore = HabitHealthScorer.overallScore(habits: habits)
            VStack(spacing: 6) {
                Text("\(overallScore)")
                    .font(HabitraFont.title())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text("Health")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .habitraCard()
            .statCardAccessibility(label: "Health Score", value: "\(overallScore)")
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private func exportInsights() {
        let healthScores = HabitHealthScorer.scoreAll(habits: habits, moodEntries: moodEntries)
        shareText = AIInsightsExporter.generateReport(
            habits: habits,
            moodEntries: moodEntries,
            insights: insights,
            predictions: tomorrowPredictions,
            healthScores: healthScores
        )
        showingShareSheet = true
    }

    // MARK: - Health Button

    private var healthButton: some View {
        Button {
            showingHealth = true
        } label: {
            HStack(spacing: HabitraTheme.spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.habitraHabitPink.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "heart.text.clipboard")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.habitraHabitPink)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Health Insights")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text("Steps, sleep, HRV × habit correlations")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }

                Spacer()

                if !SubscriptionManager.canUseHealthKit {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.habitraTextTertiary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .habitraCard()
        }
        .buttonStyle(.plain)
        .interactiveCardAccessibility(label: "Health Insights", hint: "Opens health correlations dashboard")
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Mood Trend Button

    private var moodTrendButton: some View {
        Button {
            showingMoodTrend = true
        } label: {
            HStack(spacing: HabitraTheme.spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.habitraHabitOrange.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.habitraHabitOrange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Mood Trends")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text("Track mood patterns and journal sentiment")
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
        .interactiveCardAccessibility(label: "Mood Trends", hint: "Opens mood trend analysis")
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Prediction Button

    private var predictionButton: some View {
        Button {
            showingPredictions = true
        } label: {
            HStack(spacing: HabitraTheme.spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.habitraHabitGreen.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "chart.dots.scatter")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.habitraHabitGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Predictions & Correlations")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text("Tomorrow's forecast, habit links, smart reminders")
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
        .interactiveCardAccessibility(label: "Predictions and Correlations", hint: "Opens prediction dashboard")
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Tomorrow Preview

    private var tomorrowPreview: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("TOMORROW'S OUTLOOK")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            let atRisk = tomorrowPredictions.filter { $0.riskLevel == .high }
            let moderate = tomorrowPredictions.filter { $0.riskLevel == .moderate }

            if !atRisk.isEmpty {
                ForEach(atRisk.prefix(2)) { prediction in
                    tomorrowMiniCard(prediction)
                        .padding(.horizontal, HabitraTheme.screenPadding)
                }
            }

            if !moderate.isEmpty && atRisk.isEmpty {
                ForEach(moderate.prefix(2)) { prediction in
                    tomorrowMiniCard(prediction)
                        .padding(.horizontal, HabitraTheme.screenPadding)
                }
            }

            if atRisk.isEmpty && moderate.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.habitraSuccess)

                    Text("All habits on track for tomorrow")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextSecondary)
                }
                .habitraCard()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("All habits on track for tomorrow")
                .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private func tomorrowMiniCard(_ prediction: HabitPrediction) -> some View {
        HStack(spacing: HabitraTheme.spacing) {
            Image(systemName: prediction.riskLevel.icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: prediction.riskLevel.colorHex))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(prediction.habitName)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text("\(Int(prediction.successProbability * 100))% likely — \(prediction.suggestedAction ?? prediction.riskLevel.label)")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .habitraCard()
        .insightCardAccessibility(title: prediction.habitName, detail: "\(Int(prediction.successProbability * 100))% likely. \(prediction.suggestedAction ?? prediction.riskLevel.label)")
    }

    // MARK: - Weekly Recap Button

    private var weeklyRecapButton: some View {
        Button {
            showingWeeklyRecap = true
        } label: {
            HStack(spacing: HabitraTheme.spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.habitraHabitBlue.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.habitraHabitBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Recap")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text("AI-generated summary of your week")
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
        .interactiveCardAccessibility(label: "Weekly Recap", hint: "Opens AI weekly summary")
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Recent Mood

    private var recentMoodSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("RECENT MOOD")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(moodEntries.prefix(7)) { entry in
                        moodDayChip(entry)
                    }
                }
                .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private func moodDayChip(_ entry: MoodEntry) -> some View {
        let mood = MoodLevel(rawValue: entry.moodLevel) ?? .okay
        return VStack(spacing: 4) {
            Text(mood.emoji)
                .font(.system(size: 20))

            Text(entry.date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .frame(width: 52, height: 56)
        .background(Color(hex: mood.color).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.date.formatted(.dateTime.weekday(.wide))), mood: \(mood.emoji)")
    }

    // MARK: - Insights List

    private var insightsListSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            HStack {
                Text("INSIGHTS")
                    .habitraCaption()
                    .sectionHeaderAccessibility()

                Spacer()

                Text("\(insights.count) found")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .padding(.horizontal, HabitraTheme.screenPadding)

            ForEach(Array(insights.enumerated()), id: \.element.id) { index, insight in
                insightCard(insight)
                    .staggeredAppearance(index: index, total: insights.count)
                    .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private func insightCard(_ insight: HabitInsight) -> some View {
        HStack(alignment: .top, spacing: HabitraTheme.spacing) {
            // Type icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(insightColor(insight).opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: insightIcon(insight))
                    .font(.system(size: 18))
                    .foregroundStyle(insightColor(insight))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(insight.title)
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Spacer()

                    priorityBadge(insight.priority)
                }

                Text(insight.message)
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if insight.habitName != "All Habits" {
                    HStack(spacing: 4) {
                        Image(systemName: insight.habitIcon)
                            .font(.system(size: 10))
                        Text(insight.habitName)
                            .font(HabitraFont.footnote())
                    }
                    .foregroundStyle(Color(hex: insight.habitColorHex))
                    .padding(.top, 2)
                }
            }
        }
        .habitraCard()
        .insightCardAccessibility(title: insight.title, detail: insight.message)
    }

    private func priorityBadge(_ priority: InsightPriority) -> some View {
        let (label, color): (String, Color) = {
            switch priority {
            case .urgent: return ("Urgent", .habitraDanger)
            case .high:   return ("High", .habitraWarning)
            case .medium: return ("Medium", .habitraAccent)
            case .low:    return ("Info", .habitraTextTertiary)
            }
        }()

        return Text(label)
            .font(.system(.caption2))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func insightIcon(_ insight: HabitInsight) -> String {
        switch insight.type {
        case .atRisk:       return "exclamationmark.triangle.fill"
        case .streakDanger: return "flame.fill"
        case .improvement:  return "arrow.up.right"
        case .decline:      return "arrow.down.right"
        case .correlation:  return "link"
        case .suggestion:   return "lightbulb.fill"
        case .bestDay:      return "star.fill"
        case .worstDay:     return "target"
        case .milestone:    return "flag.fill"
        case .weeklyRecap:  return "doc.text.fill"
        }
    }

    private func insightColor(_ insight: HabitInsight) -> Color {
        switch insight.type {
        case .atRisk, .streakDanger, .decline: return .habitraDanger
        case .improvement, .bestDay: return .habitraSuccess
        case .correlation: return .habitraHabitCyan
        case .suggestion: return .habitraWarning
        case .worstDay: return .habitraHabitOrange
        case .milestone: return .habitraAccent
        case .weeklyRecap: return .habitraHabitBlue
        }
    }

    // MARK: - Loading / Empty

    private var loadingView: some View {
        VStack(spacing: HabitraTheme.spacing) {
            ProgressView()
                .tint(Color.habitraAccent)
            Text("Analyzing your patterns...")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var emptyInsightsView: some View {
        HabitraEmptyState(
            icon: "brain.head.profile",
            title: "Building your profile",
            message: "Keep tracking for a few more days. The AI coach needs at least a week of data to detect patterns."
        )
        .padding(.top, 20)
    }

    // MARK: - Generate

    private func generateInsights() {
        isLoading = true
        // Small delay for animation effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            insights = PatternDetectionEngine.generateInsights(
                habits: habits,
                moodEntries: moodEntries
            )
            tomorrowPredictions = HabitPredictionEngine.predictTomorrow(
                habits: habits,
                moodEntries: moodEntries
            )
            withHabitraAnimation { isLoading = false }
        }
    }
}

#Preview {
    AIInsightsView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self], inMemory: true)
}
