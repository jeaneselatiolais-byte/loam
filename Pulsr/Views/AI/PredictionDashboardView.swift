//
//  PredictionDashboardView.swift
//  Habitra
//
//  Phase 3 Week 9: AI prediction dashboard with tomorrow's forecast,
//  correlations, adaptive reminders, and completion velocity.
//

import SwiftUI
import SwiftData

struct PredictionDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.sortOrder)
    private var habits: [Habit]

    @Query(sort: \MoodEntry.date, order: .reverse)
    private var moodEntries: [MoodEntry]

    @State private var predictions: [HabitPrediction] = []
    @State private var correlations: [HabitCorrelation] = []
    @State private var moodCorrelations: [HabitCorrelation] = []
    @State private var reminderSuggestions: [ReminderSuggestion] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                if isLoading {
                    loadingView
                } else {
                    contentView
                }
            }
            .navigationTitle("AI Predictions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.habitraAccent)
                }
            }
            .onAppear { analyze() }
        }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(spacing: HabitraTheme.spacingLarge) {
                // Tomorrow's forecast
                if !predictions.isEmpty {
                    forecastSection
                }

                // Adaptive reminder suggestions
                if !reminderSuggestions.isEmpty {
                    reminderSection
                }

                // Habit correlations
                if !correlations.isEmpty {
                    correlationSection
                }

                // Mood-habit correlations
                if !moodCorrelations.isEmpty {
                    moodCorrelationSection
                }

                // Completion velocity
                velocitySection

                // Empty state if nothing
                if predictions.isEmpty && correlations.isEmpty {
                    HabitraEmptyState(
                        icon: "chart.dots.scatter",
                        title: "Gathering data",
                        message: "Keep tracking for a few more days. Predictions need at least a week of history."
                    )
                    .padding(.top, 20)
                }
            }
            .padding(.top, HabitraTheme.spacing)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Tomorrow's Forecast

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            HStack {
                Text("TOMORROW'S FORECAST")
                    .habitraCaption()
                    .sectionHeaderAccessibility()

                Spacer()

                Text(tomorrowLabel)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .padding(.horizontal, HabitraTheme.screenPadding)

            ForEach(predictions) { prediction in
                predictionCard(prediction)
                    .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private func predictionCard(_ prediction: HabitPrediction) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: HabitraTheme.spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: prediction.habitColorHex).opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: prediction.habitIcon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: prediction.habitColorHex))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(prediction.habitName)
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text(prediction.riskLevel.label)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color(hex: prediction.riskLevel.colorHex))
                }

                Spacer()

                // Probability circle
                ZStack {
                    Circle()
                        .stroke(Color(hex: prediction.riskLevel.colorHex).opacity(0.2), lineWidth: 3)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: prediction.successProbability)
                        .stroke(Color(hex: prediction.riskLevel.colorHex), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(prediction.successProbability * 100))")
                        .font(HabitraFont.caption())
                        .foregroundStyle(Color(hex: prediction.riskLevel.colorHex))
                }
            }

            // Factors
            if !prediction.factors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(prediction.factors.prefix(3)) { factor in
                        factorRow(factor)
                    }
                }
            }

            // Suggested action
            if let action = prediction.suggestedAction {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.habitraWarning)

                    Text(action)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextSecondary)
                }
                .padding(.top, 4)
            }
        }
        .habitraCard()
    }

    private func factorRow(_ factor: PredictionFactor) -> some View {
        HStack(spacing: 8) {
            Image(systemName: factorIcon(factor.impact))
                .font(.system(size: 10))
                .foregroundStyle(factorColor(factor.impact))
                .frame(width: 16)

            Text(factor.description)
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)

            Spacer()

            // Weight bar
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 2)
                    .fill(factorColor(factor.impact).opacity(0.3 + factor.weight * 0.7))
                    .frame(width: geo.size.width * factor.weight)
            }
            .frame(width: 40, height: 4)
        }
    }

    // MARK: - Reminder Suggestions

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("SMART REMINDERS")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            ForEach(Array(reminderSuggestions.enumerated()), id: \.offset) { _, suggestion in
                reminderSuggestionCard(suggestion)
                    .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private func reminderSuggestionCard(_ suggestion: ReminderSuggestion) -> some View {
        let habit = habits.first { $0.id == suggestion.habitID }

        return HStack(spacing: HabitraTheme.spacing) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.habitraHabitBlue.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.habitraHabitBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(habit?.name ?? "Habit")
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text("Try \(suggestion.suggestedTimeString)")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraHabitBlue)

                if let delta = suggestion.timeDelta {
                    Text(delta)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }
            }

            Spacer()

            // Confidence badge
            VStack(spacing: 2) {
                Text("\(Int(suggestion.confidence * 100))%")
                    .font(HabitraFont.caption())
                    .foregroundStyle(Color.habitraHabitBlue)
                Text("confident")
                    .font(.system(.caption2))
                    .foregroundStyle(Color.habitraTextTertiary)
            }
        }
        .habitraCard()
    }

    // MARK: - Correlations

    private var correlationSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("HABIT CONNECTIONS")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            ForEach(correlations.prefix(5)) { corr in
                correlationCard(corr)
                    .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private var moodCorrelationSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("MOOD CONNECTIONS")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            ForEach(moodCorrelations.prefix(3)) { corr in
                correlationCard(corr)
                    .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private func correlationCard(_ corr: HabitCorrelation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Habit A
                Image(systemName: corr.habitAIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: corr.habitAColorHex))

                Text(corr.habitAName)
                    .font(HabitraFont.caption())
                    .tracking(0)
                    .textCase(.none)
                    .foregroundStyle(Color.habitraTextPrimary)

                // Link icon
                Image(systemName: corr.coefficient > 0 ? "link" : "arrow.left.arrow.right")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: corr.strength.colorHex))

                // Habit B
                Image(systemName: corr.habitBIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: corr.habitBColorHex))

                Text(corr.habitBName)
                    .font(HabitraFont.caption())
                    .tracking(0)
                    .textCase(.none)
                    .foregroundStyle(Color.habitraTextPrimary)

                Spacer()

                // Strength badge
                Text(corr.strength.rawValue)
                    .font(.system(.caption2))
                    .foregroundStyle(Color(hex: corr.strength.colorHex))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: corr.strength.colorHex).opacity(0.12))
                    .clipShape(Capsule())
            }

            Text(corr.insight)
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .habitraCard()
    }

    // MARK: - Completion Velocity

    private var velocitySection: some View {
        let velocity = HabitCorrelationAnalyzer.completionVelocity(habits: habits)
        guard !velocity.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                Text("COMPLETION PATTERNS")
                    .habitraCaption()
                    .sectionHeaderAccessibility()
                    .padding(.horizontal, HabitraTheme.screenPadding)

                VStack(spacing: 6) {
                    ForEach(velocity, id: \.habit.id) { item in
                        HStack(spacing: HabitraTheme.spacing) {
                            Image(systemName: item.habit.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: item.habit.colorHex))
                                .frame(width: 20)

                            Text(item.habit.name)
                                .font(HabitraFont.body())
                                .foregroundStyle(Color.habitraTextPrimary)

                            Spacer()

                            Text(item.label)
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary)

                            Text(formatHour(item.avgHour))
                                .font(HabitraFont.caption())
                                .tracking(0)
                                .textCase(.none)
                                .foregroundStyle(Color.habitraTextSecondary)
                        }

                        if item.habit.id != velocity.last?.habit.id {
                            Divider()
                                .background(Color.habitraAccent.opacity(0.1))
                        }
                    }
                }
                .habitraCard()
                .padding(.horizontal, HabitraTheme.screenPadding)
            }
        )
    }

    // MARK: - Helpers

    private var loadingView: some View {
        VStack(spacing: HabitraTheme.spacing) {
            ProgressView()
                .tint(Color.habitraAccent)
            Text("Running predictions...")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
        }
    }

    private var tomorrowLabel: String {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else { return "" }
        return tomorrow.formatted(.dateTime.weekday(.wide))
    }

    private func factorIcon(_ impact: FactorImpact) -> String {
        switch impact {
        case .positive: return "arrow.up.circle.fill"
        case .negative: return "arrow.down.circle.fill"
        case .neutral:  return "minus.circle.fill"
        }
    }

    private func factorColor(_ impact: FactorImpact) -> Color {
        switch impact {
        case .positive: return .habitraSuccess
        case .negative: return .habitraDanger
        case .neutral:  return .habitraWarning
        }
    }

    private func formatHour(_ hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour - Double(h)) * 60)
        var components = DateComponents()
        components.hour = h
        components.minute = m
        let date = Calendar.current.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func analyze() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            predictions = HabitPredictionEngine.predictTomorrow(
                habits: habits,
                moodEntries: moodEntries
            )
            correlations = HabitCorrelationAnalyzer.analyzeCorrelations(habits: habits)
            moodCorrelations = HabitCorrelationAnalyzer.moodHabitCorrelations(
                habits: habits,
                moodEntries: moodEntries
            )
            reminderSuggestions = AdaptiveReminderOptimizer.suggestOptimalTimes(habits: habits)
            withHabitraAnimation { isLoading = false }
        }
    }
}

#Preview {
    PredictionDashboardView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self], inMemory: true)
}
