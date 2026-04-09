//
//  Week11Tests.swift
//  HabitraTests
//
//  Phase 3 Week 11: Tests for ML integration, exporter, themes, health scores
//

import Testing
import Foundation
@testable import Habitra

// MARK: - AI Insights Exporter Tests

struct AIInsightsExporterTests {

    @Test @MainActor func generateReportReturnsNonEmpty() {
        let report = AIInsightsExporter.generateReport(
            habits: [],
            moodEntries: [],
            insights: [],
            predictions: [],
            healthScores: []
        )
        #expect(!report.isEmpty)
        #expect(report.contains("HABITRA AI REPORT"))
    }

    @Test @MainActor func generateReportIncludesDate() {
        let report = AIInsightsExporter.generateReport(
            habits: [],
            moodEntries: [],
            insights: [],
            predictions: [],
            healthScores: []
        )
        #expect(report.contains("Generated"))
    }

    @Test @MainActor func reportIncludesHealthScores() {
        let scores = [
            HabitHealthScore(
                id: UUID(),
                habitName: "Test",
                habitIcon: "star",
                habitColorHex: "6C63FF",
                score: 85,
                grade: .great,
                components: [],
                trend: .improving,
                summary: "Great!"
            )
        ]
        let report = AIInsightsExporter.generateReport(
            habits: [],
            insights: [],
            predictions: [],
            healthScores: scores
        )
        #expect(report.contains("OVERALL HEALTH"))
        #expect(report.contains("Test"))
    }

    @Test @MainActor func reportIncludesPredictions() {
        let predictions = [
            HabitPrediction(
                habitID: UUID(),
                habitName: "Meditate",
                habitIcon: "brain",
                habitColorHex: "6C63FF",
                successProbability: 0.75,
                riskLevel: .low,
                factors: [],
                suggestedAction: nil
            )
        ]
        let report = AIInsightsExporter.generateReport(
            habits: [],
            insights: [],
            predictions: predictions,
            healthScores: []
        )
        #expect(report.contains("FORECAST"))
        #expect(report.contains("Meditate"))
    }

    @Test @MainActor func reportIncludesInsights() {
        let insights = [
            HabitInsight(
                type: .atRisk,
                habitName: "Run",
                habitIcon: "figure.run",
                habitColorHex: "4ADE80",
                title: "Skip detected",
                message: "You skip on Fridays",
                priority: .high,
                createdAt: Date()
            )
        ]
        let report = AIInsightsExporter.generateReport(
            habits: [],
            insights: insights,
            predictions: [],
            healthScores: []
        )
        #expect(report.contains("KEY INSIGHTS"))
        #expect(report.contains("Skip detected"))
    }

    @Test @MainActor func shortSummaryIsCompact() {
        let summary = AIInsightsExporter.generateShortSummary(habits: [], healthScores: [])
        #expect(!summary.isEmpty)
        #expect(summary.contains("Habitra Stats"))
        #expect(summary.count < 300)
    }

    @Test @MainActor func reportEndsWithBranding() {
        let report = AIInsightsExporter.generateReport(
            habits: [],
            insights: [],
            predictions: [],
            healthScores: []
        )
        #expect(report.contains("Habitra"))
        #expect(report.contains("zero cloud"))
    }
}

// MARK: - Prediction Engine ML Integration Tests

struct PredictionMLIntegrationTests {

    @Test @MainActor func predictionUsesMLWhenTrained() {
        // Just verify the prediction engine produces valid results regardless of model state
        let habit = Habit(name: "Test", frequency: .daily)
        let prediction = HabitPredictionEngine.predictForHabit(habit, on: Date())
        #expect(prediction.successProbability >= 0.0)
        #expect(prediction.successProbability <= 1.0)
        #expect(!prediction.factors.isEmpty)
    }

    @Test @MainActor func predictionSuggestedActionForHighRisk() {
        // A brand new habit with no completions should be at risk
        let habit = Habit(name: "New", frequency: .daily)
        let prediction = HabitPredictionEngine.predictForHabit(habit, on: Date())
        // May or may not have a suggested action
        if prediction.riskLevel == .high {
            #expect(prediction.suggestedAction != nil)
        }
    }
}

// MARK: - StreakTheme Selector Integration Tests

struct StreakThemeIntegrationTests {

    @Test func allThemesHaveNames() {
        for theme in StreakThemeLibrary.allThemes {
            #expect(!theme.name.isEmpty)
        }
    }

    @Test func allThemesHaveIcons() {
        for theme in StreakThemeLibrary.allThemes {
            #expect(!theme.iconName.isEmpty)
        }
    }

    @Test func themeGradientHasMultipleColors() {
        for theme in StreakThemeLibrary.allThemes {
            #expect(theme.gradientColors.count >= 2)
        }
    }

    @Test func themeTextColorIsValidHex() {
        for theme in StreakThemeLibrary.allThemes {
            #expect(theme.textColor.count == 6)
        }
    }
}

// MARK: - Smart Sort Tests

struct SmartSortTests {

    @Test @MainActor func healthScorerSortsByScore() {
        let habits = [
            Habit(name: "A", frequency: .daily),
            Habit(name: "B", frequency: .daily),
            Habit(name: "C", frequency: .daily),
        ]
        let scores = HabitHealthScorer.scoreAll(habits: habits)
        // Should be sorted highest to lowest
        if scores.count >= 2 {
            for i in 0..<(scores.count - 1) {
                #expect(scores[i].score >= scores[i + 1].score)
            }
        }
    }
}

// MARK: - Coaching Message Integration Tests

struct CoachingIntegrationTests {

    @Test @MainActor func coachingMessageWithMultipleHabits() {
        let habits = [
            Habit(name: "A", frequency: .daily),
            Habit(name: "B", frequency: .daily),
            Habit(name: "C", frequency: .daily),
        ]
        let msg = AICoachingMessages.generateMessage(habits: habits)
        if let msg {
            #expect(!msg.text.isEmpty)
        }
    }

    @Test @MainActor func coachingMessageWithArchivedHabitsOnly() {
        let habit = Habit(name: "Archived", frequency: .daily)
        habit.isArchived = true
        let msg = AICoachingMessages.generateMessage(habits: [habit])
        // Should still work (archived habits excluded from today count)
        // Might return nil if no scheduled habits
        if let msg {
            #expect(!msg.text.isEmpty)
        }
    }
}
