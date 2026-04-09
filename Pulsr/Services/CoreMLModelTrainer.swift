//
//  CoreMLModelTrainer.swift
//  Habitra
//
//  Phase 3 Week 10: On-device adaptive prediction model
//  Uses a locally-trained weighted regression that improves as user data accumulates.
//  No CreateML dependency (iOS-compatible). Weights are learned from user's own data.
//

import Foundation

/// On-device model that learns personalized feature weights from the user's habit data.
/// Updates locally as data accumulates — no cloud needed.
@MainActor
final class CoreMLModelTrainer {
    static let shared = CoreMLModelTrainer()

    private(set) var isModelTrained: Bool = false
    private(set) var lastTrainedDate: Date?
    private var learnedWeights: [String: Double] = [:]
    private var learnedBias: Double = 0.5

    private let minimumSamples = 30
    private let retrainInterval: TimeInterval = 86400 // Daily
    private let weightsKey = "HabitraMLWeights"
    private let biasKey = "HabitraMLBias"
    private let trainedDateKey = "HabitraMLTrainedDate"

    private init() {
        loadModel()
    }

    // MARK: - Public API

    /// Train the model on user's habit data using gradient descent.
    func trainModel(habits: [Habit], moodEntries: [MoodEntry] = []) -> Bool {
        let samples = buildTrainingSamples(habits: habits, moodEntries: moodEntries)
        guard samples.count >= minimumSamples else {
            print("Habitra ML: Not enough data (\(samples.count)/\(minimumSamples))")
            return false
        }

        // Initialize weights
        let featureNames = [
            "dayOfWeek", "recentRate7d", "recentRate3d", "currentStreak",
            "completedYesterday", "daysSinceCompletion", "moodAvg",
            "habitAge", "isWeekend"
        ]

        var weights: [String: Double] = [:]
        for name in featureNames {
            weights[name] = learnedWeights[name] ?? 0.1
        }
        var bias = learnedBias

        // Mini-batch gradient descent
        let learningRate = 0.01
        let epochs = 50

        for _ in 0..<epochs {
            let shuffled = samples.shuffled()
            for sample in shuffled {
                let predicted = predict(features: sample.features, weights: weights, bias: bias)
                let error = sample.target - predicted

                // Update weights
                for (name, value) in sample.features {
                    weights[name, default: 0] += learningRate * error * value
                }
                bias += learningRate * error
            }
        }

        // Clamp weights
        for (name, w) in weights {
            weights[name] = max(-2.0, min(2.0, w))
        }
        bias = max(0.0, min(1.0, bias))

        // Save
        learnedWeights = weights
        learnedBias = bias
        isModelTrained = true
        lastTrainedDate = Date()
        saveModel()

        // Evaluate
        let accuracy = evaluateAccuracy(samples: samples, weights: weights, bias: bias)
        print("Habitra ML: Trained on \(samples.count) samples, accuracy: \(Int(accuracy * 100))%")

        return true
    }

    /// Predict completion probability using learned weights.
    func predictWithLearnedModel(habit: Habit, on date: Date, moodEntries: [MoodEntry] = []) -> Double? {
        guard isModelTrained else { return nil }

        let features = extractFeatures(habit: habit, date: date, moodEntries: moodEntries)
        let raw = predict(features: features, weights: learnedWeights, bias: learnedBias)
        return max(0.0, min(1.0, raw))
    }

    var needsRetraining: Bool {
        guard let lastTrained = lastTrainedDate else { return true }
        return Date().timeIntervalSince(lastTrained) >= retrainInterval
    }

    var trainingStatus: TrainingStatus {
        if isModelTrained {
            return needsRetraining ? .needsUpdate : .trained(lastTrained: lastTrainedDate ?? Date())
        }
        return .untrained
    }

    func availableSampleCount(habits: [Habit], moodEntries: [MoodEntry] = []) -> Int {
        buildTrainingSamples(habits: habits, moodEntries: moodEntries).count
    }

    // MARK: - Prediction Core

    private func predict(features: [String: Double], weights: [String: Double], bias: Double) -> Double {
        var sum = bias
        for (name, value) in features {
            sum += (weights[name] ?? 0) * value
        }
        // Sigmoid activation
        return 1.0 / (1.0 + exp(-sum))
    }

    // MARK: - Feature Extraction

    private func extractFeatures(habit: Habit, date: Date, moodEntries: [MoodEntry]) -> [String: Double] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        let r7d = StreakCalculator.completionRate(for: habit, days: 7)
        let r3d = StreakCalculator.completionRate(for: habit, days: 3)

        let yesterday = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        let completedYesterday = habit.isCompleted(on: yesterday) ? 1.0 : 0.0

        let sortedCompletions = habit.completions.map { calendar.startOfDay(for: $0.completedDate) }.sorted(by: >)
        let daysSince = sortedCompletions.first.flatMap {
            calendar.dateComponents([.day], from: $0, to: date).day
        } ?? 30
        let daysSinceNorm = min(Double(daysSince) / 30.0, 1.0)

        let recentMoods = moodEntries.sorted { $0.date > $1.date }.prefix(3)
        let moodAvg = recentMoods.isEmpty ? 0.5 :
            Double(recentMoods.reduce(0) { $0 + $1.moodLevel }) / (Double(recentMoods.count) * 5.0)

        let habitAge = calendar.dateComponents([.day], from: habit.createdAt, to: date).day ?? 0
        let habitAgeNorm = min(Double(habitAge) / 90.0, 1.0)

        let isWeekend = (weekday == 1 || weekday == 7) ? 1.0 : 0.0

        return [
            "dayOfWeek": Double(weekday) / 7.0,
            "recentRate7d": r7d,
            "recentRate3d": r3d,
            "currentStreak": min(Double(habit.currentStreak) / 30.0, 1.0),
            "completedYesterday": completedYesterday,
            "daysSinceCompletion": 1.0 - daysSinceNorm,
            "moodAvg": moodAvg,
            "habitAge": habitAgeNorm,
            "isWeekend": isWeekend,
        ]
    }

    // MARK: - Training Data

    private struct TrainingSample {
        let features: [String: Double]
        let target: Double // 0.0 or 1.0
    }

    private func buildTrainingSamples(habits: [Habit], moodEntries: [MoodEntry]) -> [TrainingSample] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var samples: [TrainingSample] = []

        for habit in habits where !habit.isArchived {
            for offset in 1...60 {
                guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                guard habit.frequency.isScheduled(for: date) else { continue }

                let features = extractFeatures(habit: habit, date: date, moodEntries: moodEntries)
                let completed = habit.isCompleted(on: date) ? 1.0 : 0.0

                samples.append(TrainingSample(features: features, target: completed))
            }
        }

        return samples
    }

    // MARK: - Evaluation

    private func evaluateAccuracy(samples: [TrainingSample], weights: [String: Double], bias: Double) -> Double {
        var correct = 0
        for sample in samples {
            let predicted = predict(features: sample.features, weights: weights, bias: bias)
            let predictedClass = predicted >= 0.5 ? 1.0 : 0.0
            if predictedClass == sample.target { correct += 1 }
        }
        return samples.isEmpty ? 0 : Double(correct) / Double(samples.count)
    }

    // MARK: - Persistence

    private func saveModel() {
        UserDefaults.standard.set(learnedWeights, forKey: weightsKey)
        UserDefaults.standard.set(learnedBias, forKey: biasKey)
        UserDefaults.standard.set(lastTrainedDate, forKey: trainedDateKey)
    }

    private func loadModel() {
        if let weights = UserDefaults.standard.dictionary(forKey: weightsKey) as? [String: Double] {
            learnedWeights = weights
            learnedBias = UserDefaults.standard.double(forKey: biasKey)
            lastTrainedDate = UserDefaults.standard.object(forKey: trainedDateKey) as? Date
            isModelTrained = !weights.isEmpty
        }
    }
}

// MARK: - Training Status

enum TrainingStatus: Equatable {
    case untrained
    case needsUpdate
    case trained(lastTrained: Date)

    var label: String {
        switch self {
        case .untrained: return "Not trained"
        case .needsUpdate: return "Update available"
        case .trained: return "Trained"
        }
    }

    var icon: String {
        switch self {
        case .untrained: return "brain"
        case .needsUpdate: return "arrow.clockwise"
        case .trained: return "brain.head.profile.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .untrained: return "7A74B0"
        case .needsUpdate: return "FBBF24"
        case .trained: return "4ADE80"
        }
    }
}
