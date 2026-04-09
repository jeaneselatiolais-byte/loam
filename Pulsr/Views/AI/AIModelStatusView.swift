//
//  AIModelStatusView.swift
//  Habitra
//
//  Phase 3 Week 11: AI model training status and controls
//

import SwiftUI
import SwiftData

struct AIModelStatusView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.sortOrder)
    private var habits: [Habit]

    @Query(sort: \MoodEntry.date, order: .reverse)
    private var moodEntries: [MoodEntry]

    @State private var isTraining = false
    @State private var trainingResult: Bool?
    @State private var healthScores: [HabitHealthScore] = []

    private var trainer: CoreMLModelTrainer { .shared }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        modelStatusCard
                        trainingDataCard
                        if !healthScores.isEmpty {
                            healthScoresSection
                        }
                        privacyNote
                    }
                    .padding(.top, HabitraTheme.spacing)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("AI Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.habitraAccent)
                }
            }
            .onAppear {
                healthScores = HabitHealthScorer.scoreAll(habits: habits, moodEntries: moodEntries)
            }
        }
    }

    // MARK: - Model Status

    private var modelStatusCard: some View {
        VStack(spacing: HabitraTheme.spacing) {
            HStack(spacing: HabitraTheme.spacing) {
                ZStack {
                    Circle()
                        .fill(Color(hex: trainer.trainingStatus.colorHex).opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: trainer.trainingStatus.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: trainer.trainingStatus.colorHex))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Prediction Model")
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text(trainer.trainingStatus.label)
                        .font(HabitraFont.body())
                        .foregroundStyle(Color(hex: trainer.trainingStatus.colorHex))

                    if let date = trainer.lastTrainedDate {
                        Text("Last trained: \(date.formatted(.dateTime.month(.abbreviated).day().hour().minute()))")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }

                Spacer()
            }

            // Train / Retrain button
            Button {
                trainModel()
            } label: {
                HStack(spacing: 8) {
                    if isTraining {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: trainer.isModelTrained ? "arrow.clockwise" : "brain.head.profile")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Text(trainer.isModelTrained ? "Retrain Model" : "Train Model")
                        .font(HabitraFont.headline())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.habitraAccent)
                .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
            }
            .disabled(isTraining)

            if let result = trainingResult {
                HStack(spacing: 6) {
                    Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(result ? Color.habitraSuccess : Color.habitraDanger)

                    Text(result ? "Model trained successfully" : "Not enough data to train (need 30+ data points)")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextSecondary)
                }
                .transition(.opacity)
            }
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Training Data

    private var trainingDataCard: some View {
        let sampleCount = trainer.availableSampleCount(habits: habits, moodEntries: moodEntries)
        let readiness = min(Double(sampleCount) / 30.0, 1.0)

        return VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("TRAINING DATA")
                .habitraCaption()
                .sectionHeaderAccessibility()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(sampleCount)")
                        .font(HabitraFont.title())
                        .foregroundStyle(Color.habitraTextPrimary)
                    Text("data points available")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }

                Spacer()

                ProgressRing(
                    progress: readiness,
                    lineWidth: 5,
                    size: 48,
                    color: readiness >= 1.0 ? .habitraSuccess : .habitraWarning
                )
            }

            // Feature list
            VStack(alignment: .leading, spacing: 6) {
                featureRow("Day-of-week patterns", available: true)
                featureRow("Recent completion rates", available: true)
                featureRow("Streak momentum", available: true)
                featureRow("Completion recency", available: true)
                featureRow("Mood correlation", available: !moodEntries.isEmpty)
                featureRow("Habit maturity", available: true)
            }
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private func featureRow(_ name: String, available: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: available ? "checkmark.circle.fill" : "circle.dashed")
                .font(.system(size: 12))
                .foregroundStyle(available ? Color.habitraSuccess : Color.habitraTextTertiary.opacity(0.6))

            Text(name)
                .font(HabitraFont.body())
                .foregroundStyle(available ? Color.habitraTextSecondary : Color.habitraTextTertiary)
        }
    }

    // MARK: - Health Scores

    private var healthScoresSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("HABIT HEALTH")
                .habitraCaption()
                .sectionHeaderAccessibility()
                .padding(.horizontal, HabitraTheme.screenPadding)

            ForEach(healthScores) { score in
                healthScoreRow(score)
                    .padding(.horizontal, HabitraTheme.screenPadding)
            }
        }
    }

    private func healthScoreRow(_ score: HabitHealthScore) -> some View {
        HStack(spacing: HabitraTheme.spacing) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: score.habitColorHex).opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: score.habitIcon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: score.habitColorHex))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(score.habitName)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text(score.summary)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
                    .lineLimit(1)
            }

            Spacer()

            // Grade badge
            VStack(spacing: 2) {
                Text(score.grade.rawValue)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color(hex: score.grade.colorHex))

                Image(systemName: score.trend.icon)
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: score.trend.colorHex))
            }
            .frame(width: 36)

            // Score
            Text("\(score.score)")
                .font(HabitraFont.title())
                .foregroundStyle(Color.habitraTextPrimary)
                .frame(width: 36)
        }
        .habitraCard()
    }

    // MARK: - Privacy

    private var privacyNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.habitraAccent)

            Text("All AI processing happens on your device. Your data never leaves your phone.")
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Actions

    private func trainModel() {
        isTraining = true
        trainingResult = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = trainer.trainModel(habits: habits, moodEntries: moodEntries)
            withHabitraAnimation {
                trainingResult = result
                isTraining = false
                if result {
                    healthScores = HabitHealthScorer.scoreAll(habits: habits, moodEntries: moodEntries)
                }
            }
        }
    }
}

#Preview {
    AIModelStatusView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self], inMemory: true)
}
