//
//  SentimentAnalyzer.swift
//  Habitra
//
//  Phase 3 Week 8: On-device NaturalLanguage sentiment analysis
//

import Foundation
import NaturalLanguage

/// On-device sentiment analysis using Apple's NaturalLanguage framework.
/// No network requests — fully private.
enum SentimentAnalyzer {

    /// Analyze sentiment of text, returns score from -1.0 (negative) to 1.0 (positive).
    /// Returns 0.0 for empty/neutral text.
    static func analyzeSentiment(_ text: String) -> Double {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return 0.0
        }

        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        let (sentiment, _) = tagger.tag(
            at: text.startIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        )

        guard let sentimentTag = sentiment else { return 0.0 }
        return Double(sentimentTag.rawValue) ?? 0.0
    }

    /// Classify sentiment into a human-readable label
    static func sentimentLabel(for score: Double) -> String {
        switch score {
        case 0.3...:       return "Positive"
        case 0.1..<0.3:    return "Slightly positive"
        case -0.1..<0.1:   return "Neutral"
        case -0.3..<(-0.1): return "Slightly negative"
        default:            return "Negative"
        }
    }

    /// Classify sentiment into a color hex
    static func sentimentColor(for score: Double) -> String {
        switch score {
        case 0.3...:       return "4ADE80" // green
        case 0.1..<0.3:    return "22D3EE" // cyan
        case -0.1..<0.1:   return "FBBF24" // yellow
        case -0.3..<(-0.1): return "FB923C" // orange
        default:            return "F87171" // red
        }
    }

    /// Analyze a batch of journal entries and return average sentiment
    static func averageSentiment(texts: [String]) -> Double {
        let scores = texts.map { analyzeSentiment($0) }
        guard !scores.isEmpty else { return 0.0 }
        return scores.reduce(0, +) / Double(scores.count)
    }
}
