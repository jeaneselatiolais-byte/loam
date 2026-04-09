//
//  PredictionTests.swift
//  HabitraTests
//
//  Phase 3 Week 9: Tests for prediction, correlation, and adaptive reminders
//

import Testing
import Foundation
@testable import Habitra

// MARK: - HabitPredictionEngine Tests

struct HabitPredictionEngineTests {

    @Test @MainActor func predictTomorrowReturnsEmptyForNoHabits() {
        let predictions = HabitPredictionEngine.predictTomorrow(habits: [])
        #expect(predictions.isEmpty)
    }

    @Test @MainActor func predictTomorrowReturnsEmptyForArchivedHabits() {
        let habit = Habit(name: "Archived", frequency: .daily)
        habit.isArchived = true
        let predictions = HabitPredictionEngine.predictTomorrow(habits: [habit])
        #expect(predictions.isEmpty)
    }

    @Test @MainActor func predictTomorrowReturnsPredictionForDailyHabit() {
        let habit = Habit(name: "Daily", frequency: .daily)
        let predictions = HabitPredictionEngine.predictTomorrow(habits: [habit])
        #expect(predictions.count == 1)
        #expect(predictions[0].habitName == "Daily")
        #expect(predictions[0].successProbability >= 0.0)
        #expect(predictions[0].successProbability <= 1.0)
    }

    @Test @MainActor func predictionHasValidRiskLevel() {
        let habit = Habit(name: "Test", frequency: .daily)
        let predictions = HabitPredictionEngine.predictTomorrow(habits: [habit])
        guard let p = predictions.first else { return }

        let validRisks: [PredictionRisk] = [.low, .moderate, .high]
        #expect(validRisks.contains(p.riskLevel))
    }

    @Test @MainActor func predictionHasFactors() {
        let habit = Habit(name: "Test", frequency: .daily)
        let prediction = HabitPredictionEngine.predictForHabit(habit, on: Date())
        #expect(!prediction.factors.isEmpty)
    }

    @Test @MainActor func predictionsAreSortedByRisk() {
        let habits = [
            Habit(name: "A", frequency: .daily),
            Habit(name: "B", frequency: .daily),
            Habit(name: "C", frequency: .daily),
        ]
        let predictions = HabitPredictionEngine.predictTomorrow(habits: habits)
        if predictions.count >= 2 {
            // Sorted riskiest first (lowest probability first)
            for i in 0..<(predictions.count - 1) {
                #expect(predictions[i].successProbability <= predictions[i + 1].successProbability)
            }
        }
    }
}

// MARK: - PredictionRisk Tests

struct PredictionRiskTests {

    @Test func riskLabelsExist() {
        #expect(!PredictionRisk.low.label.isEmpty)
        #expect(!PredictionRisk.moderate.label.isEmpty)
        #expect(!PredictionRisk.high.label.isEmpty)
    }

    @Test func riskColorsAreValidHex() {
        #expect(PredictionRisk.low.colorHex.count == 6)
        #expect(PredictionRisk.moderate.colorHex.count == 6)
        #expect(PredictionRisk.high.colorHex.count == 6)
    }

    @Test func riskIconsExist() {
        #expect(!PredictionRisk.low.icon.isEmpty)
        #expect(!PredictionRisk.moderate.icon.isEmpty)
        #expect(!PredictionRisk.high.icon.isEmpty)
    }
}

// MARK: - HabitCorrelationAnalyzer Tests

struct HabitCorrelationAnalyzerTests {

    @Test @MainActor func emptyHabitsReturnsNoCorrelations() {
        let correlations = HabitCorrelationAnalyzer.analyzeCorrelations(habits: [])
        #expect(correlations.isEmpty)
    }

    @Test @MainActor func singleHabitReturnsNoCorrelations() {
        let habits = [Habit(name: "A", frequency: .daily)]
        let correlations = HabitCorrelationAnalyzer.analyzeCorrelations(habits: habits)
        #expect(correlations.isEmpty)
    }

    @Test @MainActor func twoNewHabitsReturnsEmptyOrValid() {
        let habits = [
            Habit(name: "A", frequency: .daily),
            Habit(name: "B", frequency: .daily),
        ]
        let correlations = HabitCorrelationAnalyzer.analyzeCorrelations(habits: habits)
        // May be empty since no completion data
        for corr in correlations {
            #expect(corr.coefficient >= -1.0 && corr.coefficient <= 1.0)
        }
    }

    @Test @MainActor func moodCorrelationsEmptyWithNoMoods() {
        let habits = [Habit(name: "A", frequency: .daily)]
        let correlations = HabitCorrelationAnalyzer.moodHabitCorrelations(habits: habits, moodEntries: [])
        #expect(correlations.isEmpty)
    }

    @Test @MainActor func completionVelocityEmptyForNewHabits() {
        let habits = [Habit(name: "A", frequency: .daily)]
        let velocity = HabitCorrelationAnalyzer.completionVelocity(habits: habits)
        #expect(velocity.isEmpty) // No completions
    }

    @Test @MainActor func correlationsSortedByAbsCoefficient() {
        let habits = [
            Habit(name: "A", frequency: .daily),
            Habit(name: "B", frequency: .daily),
            Habit(name: "C", frequency: .daily),
        ]
        let correlations = HabitCorrelationAnalyzer.analyzeCorrelations(habits: habits)
        if correlations.count >= 2 {
            for i in 0..<(correlations.count - 1) {
                #expect(abs(correlations[i].coefficient) >= abs(correlations[i + 1].coefficient))
            }
        }
    }
}

// MARK: - CorrelationStrength Tests

struct CorrelationStrengthTests {

    @Test func strengthLabelsExist() {
        #expect(!CorrelationStrength.strong.rawValue.isEmpty)
        #expect(!CorrelationStrength.moderate.rawValue.isEmpty)
        #expect(!CorrelationStrength.weak.rawValue.isEmpty)
        #expect(!CorrelationStrength.none.rawValue.isEmpty)
    }

    @Test func strengthColorsAreValidHex() {
        let strengths: [CorrelationStrength] = [.strong, .moderate, .weak, .none]
        for s in strengths {
            #expect(s.colorHex.count == 6)
        }
    }
}

// MARK: - AdaptiveReminderOptimizer Tests

struct AdaptiveReminderOptimizerTests {

    @Test @MainActor func noSuggestionsForNewHabits() {
        let habit = Habit(name: "New", frequency: .daily)
        let suggestion = AdaptiveReminderOptimizer.analyzeHabit(habit)
        #expect(suggestion == nil) // Not enough completion data
    }

    @Test @MainActor func suggestOptimalTimesEmptyForNewHabits() {
        let habits = [Habit(name: "A", frequency: .daily)]
        let suggestions = AdaptiveReminderOptimizer.suggestOptimalTimes(habits: habits)
        #expect(suggestions.isEmpty)
    }

    @Test @MainActor func bestCompletionWindowNilForNoData() {
        let habits = [Habit(name: "A", frequency: .daily)]
        let window = AdaptiveReminderOptimizer.bestCompletionWindow(habits: habits)
        #expect(window == nil)
    }
}

// MARK: - ReminderSuggestion Tests

struct ReminderSuggestionTests {

    @Test func suggestedTimeStringFormats() {
        let suggestion = ReminderSuggestion(
            habitID: UUID(),
            suggestedHour: 9,
            suggestedMinute: 30,
            confidence: 0.7,
            reason: "Test reason",
            currentHour: 8,
            currentMinute: 0
        )
        #expect(!suggestion.suggestedTimeString.isEmpty)
        #expect(suggestion.suggestedTimeString.contains("9:30"))
    }

    @Test func timeDeltaCalculation() {
        let suggestion = ReminderSuggestion(
            habitID: UUID(),
            suggestedHour: 10,
            suggestedMinute: 0,
            confidence: 0.6,
            reason: "Test",
            currentHour: 8,
            currentMinute: 0
        )
        let delta = suggestion.timeDelta
        #expect(delta != nil)
        #expect(delta!.contains("later"))
    }

    @Test func timeDeltaNilForSmallDifference() {
        let suggestion = ReminderSuggestion(
            habitID: UUID(),
            suggestedHour: 9,
            suggestedMinute: 0,
            confidence: 0.5,
            reason: "Test",
            currentHour: 9,
            currentMinute: 10
        )
        #expect(suggestion.timeDelta == nil)
    }

    @Test func timeDeltaNilWhenNoCurrentTime() {
        let suggestion = ReminderSuggestion(
            habitID: UUID(),
            suggestedHour: 9,
            suggestedMinute: 0,
            confidence: 0.5,
            reason: "Test",
            currentHour: nil,
            currentMinute: nil
        )
        #expect(suggestion.timeDelta == nil)
    }
}
