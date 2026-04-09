//
//  WidgetColorHelpers.swift
//  HabitraWidget
//
//  Color helpers for widget views (can't import main app's theme).
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Widget-specific brand colors
enum WidgetColors {
    static let background = Color(hex: "0D0D14")
    static let surface = Color(hex: "1A1A2E")
    static let accent = Color(hex: "6C63FF")
    static let accentBright = Color(hex: "7C73FF")
    static let textPrimary = Color(hex: "EEEDFE")
    static let textSecondary = Color(hex: "AFA9EC")
    static let textTertiary = Color(hex: "7A74B0")
}
