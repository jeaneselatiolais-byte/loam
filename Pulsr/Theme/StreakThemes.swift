//
//  StreakThemes.swift
//  Habitra
//
//  Phase 3 Week 10: Custom streak card themes (Pro feature)
//

import SwiftUI

/// Predefined streak card themes for share cards.
struct StreakTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let gradientColors: [String]  // Hex colors for gradient
    let textColor: String         // Hex for text overlay
    let iconName: String          // SF Symbol for theme preview
    let isPro: Bool

    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors.map { Color(hex: $0) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var foregroundColor: Color {
        Color(hex: textColor)
    }
}

enum StreakThemeLibrary {

    static let allThemes: [StreakTheme] = [
        // Free themes
        StreakTheme(
            id: "midnight",
            name: "Midnight",
            gradientColors: ["0D0D14", "1A1A2E", "6C63FF"],
            textColor: "EEEDFE",
            iconName: "moon.stars.fill",
            isPro: false
        ),
        StreakTheme(
            id: "ocean",
            name: "Ocean",
            gradientColors: ["0C4A6E", "0369A1", "22D3EE"],
            textColor: "FFFFFF",
            iconName: "drop.fill",
            isPro: false
        ),

        // Pro themes
        StreakTheme(
            id: "sunset",
            name: "Sunset",
            gradientColors: ["831843", "BE185D", "FB923C"],
            textColor: "FFFFFF",
            iconName: "sun.horizon.fill",
            isPro: true
        ),
        StreakTheme(
            id: "forest",
            name: "Forest",
            gradientColors: ["052E16", "166534", "4ADE80"],
            textColor: "ECFDF5",
            iconName: "leaf.fill",
            isPro: true
        ),
        StreakTheme(
            id: "aurora",
            name: "Aurora",
            gradientColors: ["312E81", "6C63FF", "22D3EE"],
            textColor: "FFFFFF",
            iconName: "sparkles",
            isPro: true
        ),
        StreakTheme(
            id: "ember",
            name: "Ember",
            gradientColors: ["450A0A", "B91C1C", "FBBF24"],
            textColor: "FEF3C7",
            iconName: "flame.fill",
            isPro: true
        ),
        StreakTheme(
            id: "lavender",
            name: "Lavender",
            gradientColors: ["4C1D95", "7C3AED", "A89AFF"],
            textColor: "F5F3FF",
            iconName: "paintpalette.fill",
            isPro: true
        ),
        StreakTheme(
            id: "minimal",
            name: "Minimal",
            gradientColors: ["FAFAFA", "E5E5E5", "A3A3A3"],
            textColor: "171717",
            iconName: "square.fill",
            isPro: true
        ),
        StreakTheme(
            id: "neon",
            name: "Neon",
            gradientColors: ["0D0D14", "1A1A2E", "F472B6"],
            textColor: "EEEDFE",
            iconName: "bolt.fill",
            isPro: true
        ),
        StreakTheme(
            id: "cosmic",
            name: "Cosmic",
            gradientColors: ["1E1B4B", "312E81", "6366F1"],
            textColor: "E0E7FF",
            iconName: "star.fill",
            isPro: true
        ),
    ]

    static var freeThemes: [StreakTheme] {
        allThemes.filter { !$0.isPro }
    }

    static var proThemes: [StreakTheme] {
        allThemes.filter { $0.isPro }
    }

    static func theme(for id: String) -> StreakTheme {
        allThemes.first { $0.id == id } ?? allThemes[0]
    }

    static var defaultTheme: StreakTheme {
        allThemes[0] // Midnight
    }
}
