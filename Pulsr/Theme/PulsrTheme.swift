//
//  HabitraTheme.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI

// MARK: - Color Palette (extracted from brand logo, adaptive for light/dark)
extension Color {
    // Backgrounds
    static let habitraBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "0D0D14")) : UIColor(Color(hex: "F5F4FF"))
    })
    static let habitraSurface = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "1A1A2E")) : UIColor.white
    })
    static let habitraSurfaceLight = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "242442")) : UIColor(Color(hex: "EEEDF8"))
    })

    // Accents (same in both modes)
    static let habitraAccent = Color(hex: "6C63FF")
    static let habitraAccentBright = Color(hex: "7C73FF")
    static let habitraAccentGlow = Color(hex: "A89AFF")
    static let habitraAccentMuted = Color(hex: "534AB7")

    // Text
    static let habitraTextPrimary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "EEEDFE")) : UIColor(Color(hex: "1A1A2E"))
    })
    static let habitraTextSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "AFA9EC")) : UIColor(Color(hex: "5C5680"))
    })
    static let habitraTextTertiary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "7A74B0")) : UIColor(Color(hex: "9B93C4"))
    })

    // Semantic
    static let habitraSuccess = Color(hex: "4ADE80")
    static let habitraWarning = Color(hex: "FBBF24")
    static let habitraDanger = Color(hex: "F87171")

    // Habit preset colors
    static let habitraHabitPurple = Color(hex: "6C63FF")
    static let habitraHabitBlue = Color(hex: "3B82F6")
    static let habitraHabitCyan = Color(hex: "22D3EE")
    static let habitraHabitGreen = Color(hex: "4ADE80")
    static let habitraHabitYellow = Color(hex: "FBBF24")
    static let habitraHabitOrange = Color(hex: "FB923C")
    static let habitraHabitPink = Color(hex: "F472B6")
    static let habitraHabitRed = Color(hex: "F87171")

    // Vital (warm amber) — the reward/completion color.
    // Used for completed states, achievement moments, and celebration.
    // Structurally paired with habitraAccent (cool indigo) to create a
    // precision-to-reward emotional arc throughout the app.
    static let habitraVital = Color(hex: "F59E0B")
    static let habitraVitalGlow = Color(hex: "FCD34D")

    // Aliases kept for backward compatibility
    static let habitraGold = habitraVital
    static let habitraGoldGlow = habitraVitalGlow

    static let habitPresets: [Color] = [
        .habitraHabitPurple, .habitraHabitBlue, .habitraHabitCyan, .habitraHabitGreen,
        .habitraHabitYellow, .habitraHabitOrange, .habitraHabitPink, .habitraHabitRed
    ]
}

// MARK: - Hex Color Initializer
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

    /// Returns the hex string for storing in SwiftData
    var hexString: String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}

// MARK: - Theme Constants
enum HabitraTheme {
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 10
    static let cornerRadiusLarge: CGFloat = 26 // matches logo icon container
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
    static let spacing: CGFloat = 12
    static let spacingSmall: CGFloat = 8
    static let spacingLarge: CGFloat = 24

    // Animation
    static let pulseAnimation = Animation.easeInOut(duration: 0.6)
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.7)
}

// MARK: - Adaptive Color Palette (light mode variants)
extension Color {
    /// Background that adapts to light/dark mode
    static func habitraAdaptiveBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .habitraBackground : Color(hex: "F5F4FF")
    }

    static func habitraAdaptiveSurface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .habitraSurface : .white
    }

    static func habitraAdaptiveTextPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .habitraTextPrimary : Color(hex: "1A1A2E")
    }

    static func habitraAdaptiveTextSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .habitraTextSecondary : Color(hex: "5C5680")
    }

    static func habitraAdaptiveTextTertiary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .habitraTextTertiary : Color(hex: "9B93C4")
    }

    static func habitraAdaptiveBorder(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .habitraAccent.opacity(0.15) : Color(hex: "E0DCFF").opacity(0.6)
    }
}

// MARK: - Card Style Modifier
struct HabitraCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var padding: CGFloat = HabitraTheme.cardPadding
    var tintColor: Color? = nil

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                ZStack {
                    Color.habitraSurface
                    if let tint = tintColor {
                        tint.opacity(0.05)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                    .stroke(
                        colorScheme == .dark
                            ? Color.habitraAccent.opacity(0.15)
                            : Color(hex: "E0DCFF").opacity(0.5),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .light ? Color.black.opacity(0.04) : .clear,
                radius: 4, y: 2
            )
    }
}

extension View {
    func habitraCard(padding: CGFloat = HabitraTheme.cardPadding, tintColor: Color? = nil) -> some View {
        modifier(HabitraCardStyle(padding: padding, tintColor: tintColor))
    }
}
