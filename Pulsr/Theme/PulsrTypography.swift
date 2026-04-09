//
//  HabitraTypography.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//
//  Typography uses a two-tier approach:
//  - Display/heading sizes: DM Sans (Google Fonts, variable font)
//    Falls back gracefully to SF Pro Rounded if font files are not bundled.
//  - Body/label sizes: SF Pro (system default — best readability at small sizes)
//
//  To bundle DM Sans:
//  1. Download from fonts.google.com/specimen/DM+Sans
//  2. Add DMSans[opsz,wght].ttf to Xcode under Pulsr/Fonts/
//  3. Add "UIAppFonts" key to Pulsr-Info.plist with value "DMSans[opsz,wght].ttf"
//

import SwiftUI

// MARK: - Font Helpers

private extension Font {
    /// Returns DM Sans at the given size and weight, scaling with Dynamic Type.
    /// Falls back to SF Pro Rounded if DM Sans is not bundled.
    static func dmSans(size: CGFloat, weight: Font.Weight = .regular,
                       relativeTo textStyle: Font.TextStyle = .body) -> Font {
        if UIFont.familyNames.contains("DM Sans") {
            return Font.custom("DM Sans", size: size, relativeTo: textStyle).weight(weight)
        }
        // Fallback: SF Pro Rounded — softer terminals, similar geometric feel
        return Font.custom(".AppleSystemUIFontRounded", size: size, relativeTo: textStyle).weight(weight)
    }
}

// MARK: - Typography System

enum HabitraFont {
    /// Large screen titles — "Today", "Stats"
    static func largeTitle() -> Font {
        .dmSans(size: 34, weight: .bold, relativeTo: .largeTitle)
    }

    /// Section headers
    static func title() -> Font {
        .dmSans(size: 24, weight: .semibold, relativeTo: .title2)
    }

    /// Card titles, habit names
    static func headline() -> Font {
        .dmSans(size: 17, weight: .semibold, relativeTo: .headline)
    }

    /// Primary body text — SF Pro with Dynamic Type scaling
    static func body() -> Font {
        .system(.body, design: .default, weight: .regular)
    }

    /// Secondary labels, stats — scales with Dynamic Type
    static func caption() -> Font {
        .system(.caption, design: .default, weight: .medium)
    }

    /// Small metadata, timestamps — scales with Dynamic Type
    static func footnote() -> Font {
        .system(.footnote, design: .default, weight: .regular)
    }

    /// Large stat numbers (streak count, percentage) — rounded numerals feel energetic
    static func stat() -> Font {
        .dmSans(size: 48, weight: .bold, relativeTo: .largeTitle)
    }

    /// Wordmark style — spaced capitals for brand lockup
    static func wordmark() -> Font {
        .dmSans(size: 28, weight: .semibold, relativeTo: .title)
    }
}

// MARK: - Text Style Modifiers

struct HabitraTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(HabitraFont.largeTitle())
            .foregroundStyle(Color.habitraTextPrimary)
            .tracking(-0.3)
    }
}

struct HabitraHeadlineStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(HabitraFont.headline())
            .foregroundStyle(Color.habitraTextPrimary)
    }
}

struct HabitraBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(HabitraFont.body())
            .foregroundStyle(Color.habitraTextSecondary)
    }
}

struct HabitraCaptionStyle: ViewModifier {
    var color: Color = .habitraTextTertiary

    func body(content: Content) -> some View {
        content
            .font(HabitraFont.caption())
            .foregroundStyle(color)
            .tracking(1.5)
            .textCase(.uppercase)
    }
}

extension View {
    func habitraTitle() -> some View { modifier(HabitraTitleStyle()) }
    func habitraHeadline() -> some View { modifier(HabitraHeadlineStyle()) }
    func habitraBody() -> some View { modifier(HabitraBodyStyle()) }
    func habitraCaption(color: Color = .habitraTextTertiary) -> some View {
        modifier(HabitraCaptionStyle(color: color))
    }
}
