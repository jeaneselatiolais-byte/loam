//
//  MoodEntry.swift
//  Habitra
//
//  Phase 3 Week 8: Mood tracking with NaturalLanguage sentiment analysis
//

import Foundation
import SwiftData

/// Mood level chosen by the user (quick pick)
enum MoodLevel: Int, Codable, Hashable, Sendable, CaseIterable {
    case terrible = 1
    case bad = 2
    case okay = 3
    case good = 4
    case great = 5

    var emoji: String {
        switch self {
        case .terrible: return "😞"
        case .bad:      return "😔"
        case .okay:     return "😐"
        case .good:     return "🙂"
        case .great:    return "😄"
        }
    }

    var label: String {
        switch self {
        case .terrible: return "Terrible"
        case .bad:      return "Bad"
        case .okay:     return "Okay"
        case .good:     return "Good"
        case .great:    return "Great"
        }
    }

    var color: String {
        switch self {
        case .terrible: return "F87171"
        case .bad:      return "FB923C"
        case .okay:     return "FBBF24"
        case .good:     return "4ADE80"
        case .great:    return "6C63FF"
        }
    }
}

@Model
final class MoodEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var moodLevel: Int = 3          // 1-5, maps to MoodLevel
    var journalText: String = ""    // Optional journal text
    var sentimentScore: Double = 0  // -1.0 to 1.0 from NaturalLanguage analysis
    var createdAt: Date = Date()

    /// Computed MoodLevel from stored Int
    @Transient
    var mood: MoodLevel {
        get { MoodLevel(rawValue: moodLevel) ?? .okay }
        set { moodLevel = newValue.rawValue }
    }

    init(
        mood: MoodLevel = .okay,
        journalText: String = "",
        sentimentScore: Double = 0.0,
        date: Date = Date()
    ) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.moodLevel = mood.rawValue
        self.journalText = journalText
        self.sentimentScore = sentimentScore
        self.createdAt = Date()
    }
}
