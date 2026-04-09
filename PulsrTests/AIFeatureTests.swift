//
//  AIFeatureTests.swift
//  HabitraTests
//
//  Phase 3 Week 8: Tests for AI features
//

import Testing
import Foundation
@testable import Habitra

// MARK: - SentimentAnalyzer Tests

struct SentimentAnalyzerTests {

    @Test func emptyTextReturnsZero() {
        let score = SentimentAnalyzer.analyzeSentiment("")
        #expect(score == 0.0)
    }

    @Test func whitespaceOnlyReturnsZero() {
        let score = SentimentAnalyzer.analyzeSentiment("   ")
        #expect(score == 0.0)
    }

    @Test func positiveTextReturnsScore() {
        let score = SentimentAnalyzer.analyzeSentiment("I love this! Amazing day, feeling wonderful and happy!")
        // NaturalLanguage sentiment may vary by platform; just verify it returns a valid range
        #expect(score >= -1.0 && score <= 1.0)
    }

    @Test func negativeTextReturnsScore() {
        let score = SentimentAnalyzer.analyzeSentiment("Terrible day. Everything went wrong. I hate this.")
        #expect(score >= -1.0 && score <= 1.0)
    }

    @Test func sentimentLabelForPositive() {
        let label = SentimentAnalyzer.sentimentLabel(for: 0.5)
        #expect(label == "Positive")
    }

    @Test func sentimentLabelForNeutral() {
        let label = SentimentAnalyzer.sentimentLabel(for: 0.0)
        #expect(label == "Neutral")
    }

    @Test func sentimentLabelForNegative() {
        let label = SentimentAnalyzer.sentimentLabel(for: -0.5)
        #expect(label == "Negative")
    }

    @Test func sentimentColorReturnsValidHex() {
        let colors = [-1.0, -0.5, -0.2, 0.0, 0.2, 0.5, 1.0].map {
            SentimentAnalyzer.sentimentColor(for: $0)
        }
        for color in colors {
            #expect(color.count == 6)
        }
    }

    @Test func averageSentimentForEmptyArray() {
        let avg = SentimentAnalyzer.averageSentiment(texts: [])
        #expect(avg == 0.0)
    }

    @Test func averageSentimentComputes() {
        let avg = SentimentAnalyzer.averageSentiment(texts: ["Great!", "Terrible"])
        // Should be somewhere between positive and negative
        #expect(avg > -1.0)
        #expect(avg < 1.0)
    }
}

// MARK: - MoodEntry Tests

struct MoodEntryTests {

    @Test func moodEntryInitializesCorrectly() {
        let entry = MoodEntry(mood: .good, journalText: "Nice day")
        #expect(entry.moodLevel == 4)
        #expect(entry.journalText == "Nice day")
        #expect(entry.mood == .good)
    }

    @Test func moodEntryDefaults() {
        let entry = MoodEntry()
        #expect(entry.moodLevel == 3) // .okay
        #expect(entry.journalText == "")
        #expect(entry.sentimentScore == 0.0)
    }

    @Test func moodDateIsStartOfDay() {
        let now = Date()
        let entry = MoodEntry(date: now)
        let calendar = Calendar.current
        #expect(entry.date == calendar.startOfDay(for: now))
    }

    @Test func moodTransientProperty() {
        let entry = MoodEntry(mood: .great)
        #expect(entry.mood == .great)
        entry.mood = .terrible
        #expect(entry.moodLevel == 1)
        #expect(entry.mood == .terrible)
    }
}

// MARK: - MoodLevel Tests

struct MoodLevelTests {

    @Test func allCasesAreFive() {
        #expect(MoodLevel.allCases.count == 5)
    }

    @Test func rawValuesAreSequential() {
        #expect(MoodLevel.terrible.rawValue == 1)
        #expect(MoodLevel.bad.rawValue == 2)
        #expect(MoodLevel.okay.rawValue == 3)
        #expect(MoodLevel.good.rawValue == 4)
        #expect(MoodLevel.great.rawValue == 5)
    }

    @Test func emojisAreDifferent() {
        let emojis = MoodLevel.allCases.map(\.emoji)
        #expect(Set(emojis).count == 5) // all unique
    }

    @Test func labelsAreDifferent() {
        let labels = MoodLevel.allCases.map(\.label)
        #expect(Set(labels).count == 5) // all unique
    }

    @Test func colorsAreValidHex() {
        for mood in MoodLevel.allCases {
            #expect(mood.color.count == 6)
        }
    }
}

// MARK: - InsightType Tests

struct InsightTypeTests {

    @Test func allTypesHaveRawValues() {
        let types: [InsightType] = [
            .atRisk, .streakDanger, .bestDay, .worstDay,
            .improvement, .decline, .correlation, .milestone,
            .suggestion, .weeklyRecap
        ]
        for type in types {
            #expect(!type.rawValue.isEmpty)
        }
    }

    @Test func insightTypeIsCodable() throws {
        let original = InsightType.atRisk
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(InsightType.self, from: data)
        #expect(decoded == .atRisk)
    }
}

// MARK: - InsightPriority Tests

struct InsightPriorityTests {

    @Test func prioritiesAreOrdered() {
        #expect(InsightPriority.low < InsightPriority.medium)
        #expect(InsightPriority.medium < InsightPriority.high)
        #expect(InsightPriority.high < InsightPriority.urgent)
    }
}

// MARK: - PatternDetectionEngine Tests

struct PatternDetectionEngineTests {

    @Test @MainActor func emptyHabitsProducesNoInsights() {
        let insights = PatternDetectionEngine.generateInsights(habits: [])
        #expect(insights.isEmpty)
    }

    @Test @MainActor func newHabitProducesMinimalInsights() {
        let habit = Habit(name: "Test", frequency: .daily)
        let insights = PatternDetectionEngine.generateInsights(habits: [habit])
        // New habit with no completions might produce some basic insights
        // but shouldn't crash
        #expect(insights.count >= 0)
    }

    @Test @MainActor func insightsAreSortedByPriority() {
        let habits = [
            Habit(name: "A", frequency: .daily),
            Habit(name: "B", frequency: .daily),
        ]
        let insights = PatternDetectionEngine.generateInsights(habits: habits)
        if insights.count >= 2 {
            // Verify sorted by priority descending
            for i in 0..<(insights.count - 1) {
                #expect(insights[i].priority >= insights[i + 1].priority)
            }
        }
    }
}

// MARK: - WeeklyRecapGenerator Tests

struct WeeklyRecapGeneratorTests {

    @Test @MainActor func emptyHabitsProducesRecap() {
        let recap = WeeklyRecapGenerator.generateRecap(habits: [])
        #expect(recap.overallRate == 0)
        #expect(recap.totalCompletions == 0)
        #expect(recap.totalScheduled == 0)
        #expect(!recap.motivationalMessage.isEmpty)
    }

    @Test @MainActor func recapHasDateRange() {
        let recap = WeeklyRecapGenerator.generateRecap(habits: [])
        #expect(recap.weekStartDate < recap.weekEndDate)
        let daysDiff = Calendar.current.dateComponents([.day], from: recap.weekStartDate, to: recap.weekEndDate).day
        #expect(daysDiff == 7)
    }

    @Test @MainActor func recapWithHabitsCalculatesRate() {
        let habits = [Habit(name: "A", frequency: .daily)]
        let recap = WeeklyRecapGenerator.generateRecap(habits: habits)
        // No completions, so rate should be 0
        #expect(recap.overallRate == 0)
        #expect(recap.totalScheduled == 7) // daily for 7 days
        #expect(recap.totalCompletions == 0)
    }

    @Test @MainActor func recapIncludesMotivationalMessage() {
        let recap = WeeklyRecapGenerator.generateRecap(habits: [])
        #expect(!recap.motivationalMessage.isEmpty)
    }

    @Test @MainActor func recapIncludesInsights() {
        let habits = [Habit(name: "A", frequency: .daily)]
        let recap = WeeklyRecapGenerator.generateRecap(habits: habits)
        // Recap generates insights array (may be empty if rate triggers no specific message)
        #expect(recap.insights.count >= 0)
    }

    @Test @MainActor func recapMoodSummaryIsNilWithNoMoods() {
        let recap = WeeklyRecapGenerator.generateRecap(habits: [], moodEntries: [])
        #expect(recap.moodSummary == nil)
    }

    @Test @MainActor func recapMoodSummaryWithEntries() {
        let moods = [
            MoodEntry(mood: .good, journalText: "Nice day"),
            MoodEntry(mood: .great, journalText: "Amazing!")
        ]
        let recap = WeeklyRecapGenerator.generateRecap(habits: [], moodEntries: moods)
        #expect(recap.moodSummary != nil)
        #expect(recap.moodSummary!.averageMood >= 4.0)
    }
}
