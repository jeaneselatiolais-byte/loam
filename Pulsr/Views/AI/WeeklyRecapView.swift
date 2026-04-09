//
//  WeeklyRecapView.swift
//  Habitra
//
//  Phase 3 Week 8: Weekly AI-generated recap view
//

import SwiftUI
import SwiftData

struct WeeklyRecapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.sortOrder)
    private var habits: [Habit]

    @Query(sort: \MoodEntry.date, order: .reverse)
    private var moodEntries: [MoodEntry]

    @State private var recap: WeeklyRecap?
    @State private var predictions: [HabitPrediction] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                if isLoading {
                    loadingView
                } else if let recap {
                    recapContent(recap)
                } else {
                    HabitraEmptyState(
                        icon: "doc.text",
                        title: "No data yet",
                        message: "Track habits for a week to get your first AI-generated recap."
                    )
                }
            }
            .navigationTitle("Weekly Recap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.habitraAccent)
                }
            }
            .onAppear { generateRecap() }
        }
    }

    // MARK: - Recap Content

    private func recapContent(_ recap: WeeklyRecap) -> some View {
        ScrollView {
            VStack(spacing: HabitraTheme.spacingLarge) {
                // Date range header
                dateHeader(recap)

                // Big score
                scoreSection(recap)

                // Stats grid
                statsGrid(recap)

                // Best & worst habits
                habitHighlights(recap)

                // Best & worst days
                dayHighlights(recap)

                // Mood summary
                if let mood = recap.moodSummary {
                    moodSection(mood)
                }

                // Next week outlook
                if !predictions.isEmpty {
                    nextWeekOutlook
                }

                // Insights
                insightsSection(recap)

                // Motivational
                motivationalSection(recap)
            }
            .padding(.horizontal, HabitraTheme.screenPadding)
            .padding(.bottom, 100)
        }
    }

    private func dateHeader(_ recap: WeeklyRecap) -> some View {
        VStack(spacing: 4) {
            Text("WEEK IN REVIEW")
                .habitraCaption()
                .sectionHeaderAccessibility()

            Text("\(recap.weekStartDate.formatted(.dateTime.month(.abbreviated).day())) – \(recap.weekEndDate.formatted(.dateTime.month(.abbreviated).day()))")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
        }
        .padding(.top, HabitraTheme.spacing)
    }

    private func scoreSection(_ recap: WeeklyRecap) -> some View {
        VStack(spacing: 8) {
            ZStack {
                ProgressRing(
                    progress: recap.overallRate,
                    lineWidth: 10,
                    size: 120,
                    color: scoreColor(recap.overallRate)
                )

                VStack(spacing: 2) {
                    Text("\(Int(recap.overallRate * 100))")
                        .font(HabitraFont.largeTitle())
                        .foregroundStyle(Color.habitraTextPrimary)
                    Text("%")
                        .font(HabitraFont.caption())
                        .tracking(0)
                        .textCase(.none)
                        .foregroundStyle(Color.habitraTextTertiary)
                }
            }

            Text("Overall Completion Rate")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .padding(.vertical, HabitraTheme.spacing)
    }

    private func statsGrid(_ recap: WeeklyRecap) -> some View {
        HStack(spacing: HabitraTheme.spacing) {
            statCard(
                value: "\(recap.totalCompletions)",
                label: "Completed",
                icon: "checkmark.circle.fill",
                color: .habitraSuccess
            )

            statCard(
                value: "\(recap.totalScheduled)",
                label: "Scheduled",
                icon: "calendar",
                color: .habitraAccent
            )

            if let (_, streak) = recap.streakHighlight {
                statCard(
                    value: "\(streak)",
                    label: "Best Streak",
                    icon: "flame.fill",
                    color: .habitraHabitOrange
                )
            } else {
                statCard(
                    value: "\(habits.count)",
                    label: "Active",
                    icon: "bolt.fill",
                    color: .habitraHabitBlue
                )
            }
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(value)
                .font(HabitraFont.title())
                .foregroundStyle(Color.habitraTextPrimary)

            Text(label)
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .habitraCard()
    }

    private func habitHighlights(_ recap: WeeklyRecap) -> some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("HABIT HIGHLIGHTS")
                .habitraCaption()
                .sectionHeaderAccessibility()

            if let best = recap.bestHabit {
                habitHighlightRow(
                    icon: best.icon,
                    label: "Top performer",
                    name: best.name,
                    rate: best.completionRate,
                    color: Color(hex: best.colorHex),
                    badge: "star.fill"
                )
            }

            if let worst = recap.worstHabit, worst.completionRate < 1.0 {
                habitHighlightRow(
                    icon: worst.icon,
                    label: "Needs attention",
                    name: worst.name,
                    rate: worst.completionRate,
                    color: Color(hex: worst.colorHex),
                    badge: "target"
                )
            }
        }
    }

    private func habitHighlightRow(icon: String, label: String, name: String, rate: Double, color: Color, badge: String) -> some View {
        HStack(spacing: HabitraTheme.spacing) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)

                Text(name)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: badge)
                    .font(.system(size: 12))
                Text("\(Int(rate * 100))%")
                    .font(HabitraFont.caption())
                    .tracking(0)
                    .textCase(.none)
            }
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
        }
        .habitraCard()
    }

    private func dayHighlights(_ recap: WeeklyRecap) -> some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            if let (dayName, rate) = recap.bestDay {
                HStack(spacing: HabitraTheme.spacing) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.habitraSuccess)
                        .frame(width: 32)

                    Text("Best day: **\(dayName)** at \(Int(rate * 100))%")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextSecondary)
                }
                .habitraCard()
            }

            if let (dayName, rate) = recap.worstDay {
                HStack(spacing: HabitraTheme.spacing) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.habitraHabitOrange)
                        .frame(width: 32)

                    Text("Weakest day: **\(dayName)** at \(Int(rate * 100))%")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextSecondary)
                }
                .habitraCard()
            }
        }
    }

    private func moodSection(_ mood: MoodSummary) -> some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("MOOD")
                .habitraCaption()
                .sectionHeaderAccessibility()

            HStack(spacing: HabitraTheme.spacingLarge) {
                VStack(spacing: 4) {
                    Text(mood.dominantMood.emoji)
                        .font(.system(size: 36))
                    Text(mood.dominantMood.label)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Average")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                        Spacer()
                        Text(String(format: "%.1f/5", mood.averageMood))
                            .font(HabitraFont.headline())
                            .foregroundStyle(Color.habitraTextPrimary)
                    }

                    if mood.journalCount > 0 {
                        HStack {
                            Text("Journal entries")
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary)
                            Spacer()
                            Text("\(mood.journalCount)")
                                .font(HabitraFont.headline())
                                .foregroundStyle(Color.habitraTextPrimary)
                        }

                        HStack {
                            Text("Sentiment")
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary)
                            Spacer()
                            Text(SentimentAnalyzer.sentimentLabel(for: mood.averageSentiment))
                                .font(HabitraFont.headline())
                                .foregroundStyle(Color(hex: SentimentAnalyzer.sentimentColor(for: mood.averageSentiment)))
                        }
                    }
                }
            }
            .habitraCard()
        }
    }

    private func insightsSection(_ recap: WeeklyRecap) -> some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("KEY TAKEAWAYS")
                .habitraCaption()
                .sectionHeaderAccessibility()

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(recap.insights.enumerated()), id: \.offset) { index, insight in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .font(HabitraFont.headline())
                            .foregroundStyle(Color.habitraAccent)
                            .frame(width: 20)

                        Text(insight)
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .habitraCard()
        }
    }

    private func motivationalSection(_ recap: WeeklyRecap) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 24))
                .foregroundStyle(Color.habitraAccent.opacity(0.5))

            Text(recap.motivationalMessage)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, 20)

            Text("— Your AI Coach")
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .padding(.vertical, HabitraTheme.spacingLarge)
    }

    // MARK: - Next Week Outlook

    private var nextWeekOutlook: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("TOMORROW'S OUTLOOK")
                .habitraCaption()
                .sectionHeaderAccessibility()

            ForEach(predictions.prefix(3)) { prediction in
                HStack(spacing: 10) {
                    Image(systemName: prediction.riskLevel.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: prediction.riskLevel.colorHex))
                        .frame(width: 24)

                    Text(prediction.habitName)
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Spacer()

                    Text("\(Int(prediction.successProbability * 100))%")
                        .font(HabitraFont.caption())
                        .foregroundStyle(Color(hex: prediction.riskLevel.colorHex))
                }
            }
        }
        .habitraCard()
    }

    // MARK: - Helpers

    private var loadingView: some View {
        VStack(spacing: HabitraTheme.spacing) {
            ProgressView()
                .tint(Color.habitraAccent)
            Text("Generating your recap...")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
        }
    }

    private func scoreColor(_ rate: Double) -> Color {
        switch rate {
        case 0.8...: return .habitraSuccess
        case 0.5..<0.8: return .habitraAccent
        case 0.3..<0.5: return .habitraWarning
        default: return .habitraDanger
        }
    }

    private func generateRecap() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            recap = WeeklyRecapGenerator.generateRecap(
                habits: habits,
                moodEntries: moodEntries
            )
            predictions = HabitPredictionEngine.predictTomorrow(
                habits: habits,
                moodEntries: moodEntries
            )
            withHabitraAnimation { isLoading = false }
        }
    }
}

#Preview {
    WeeklyRecapView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self], inMemory: true)
}
