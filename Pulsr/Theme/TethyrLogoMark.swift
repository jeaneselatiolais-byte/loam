//
//  HabitraLogoMark.swift
//  Habitra
//
//  Programmatic brand logo mark — a progress ring with an EKG pulse line.
//  Replaces the radar/crosshair icon. Renders crisply at any size.
//  Use this anywhere an in-app brand mark is needed (share cards, onboarding, settings).
//
//  NOTE: The home screen app icon (Assets.xcassets/AppIcon) and launch icon
//  (Assets.xcassets/LaunchIcon) are PNG files and must be regenerated separately.
//  Export this view at 1024×1024 via Xcode canvas or a rendering helper to produce
//  the new App Store icon.
//

import SwiftUI

// MARK: - Logo Mark

/// The Habitra brand mark: a progress ring with a heartbeat pulse line.
/// Scales proportionally — pass any `size` value.
struct HabitraLogoMark: View {
    var size: CGFloat = 60
    /// Override the primary ring color (defaults to brand accent)
    var ringColor: Color = .habitraAccent
    /// Override the completion color at the arc end (defaults to habitraVital)
    var completionColor: Color = .habitraVital

    var body: some View {
        ZStack {
            // Track ring — subtle background circle
            Circle()
                .stroke(ringColor.opacity(0.14), lineWidth: ringStroke)

            // Progress arc — ~85% filled, gap sits at top-right
            // Gradient transitions from accent (start) to vital/warm (end)
            Circle()
                .trim(from: 0.0, to: 0.85)
                .stroke(
                    LinearGradient(
                        colors: [ringColor, completionColor],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    ),
                    style: StrokeStyle(lineWidth: ringStroke, lineCap: .round)
                )
                .rotationEffect(.degrees(162)) // gap positioned at ~top-right

            // EKG pulse line — flat baseline with a single sharp spike
            PulseLineShape()
                .stroke(
                    ringColor,
                    style: StrokeStyle(
                        lineWidth: pulseStroke,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: size * 0.52, height: size * 0.34)

            // End-cap dot — marks the open end of the arc (the "goal")
            Circle()
                .fill(completionColor)
                .frame(width: dotSize, height: dotSize)
                .offset(
                    x: cos(.init(162 + 360 * 0.85 - 90) * .pi / 180) * (size / 2 - ringStroke / 2),
                    y: sin(.init(162 + 360 * 0.85 - 90) * .pi / 180) * (size / 2 - ringStroke / 2)
                )
        }
        .frame(width: size, height: size)
    }

    private var ringStroke: CGFloat { size * 0.09 }
    private var pulseStroke: CGFloat { size * 0.055 }
    private var dotSize: CGFloat { size * 0.12 }
}

// MARK: - Pulse Line Shape

/// A single EKG heartbeat spike: flat → up → down → flat.
/// Draws within a normalized rect; caller controls frame size.
private struct PulseLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let mid = h * 0.5

        var path = Path()
        path.move(to: CGPoint(x: 0, y: mid))
        // Flat left segment
        path.addLine(to: CGPoint(x: w * 0.28, y: mid))
        // Rise to peak
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.06))
        // Drop past baseline
        path.addLine(to: CGPoint(x: w * 0.52, y: h * 0.94))
        // Return to baseline
        path.addLine(to: CGPoint(x: w * 0.62, y: mid))
        // Flat right segment
        path.addLine(to: CGPoint(x: w, y: mid))
        return path
    }
}

// MARK: - App Icon Canvas View
// Use this view in a Xcode preview, set canvas to 1024×1024,
// and export as PNG for the App Store icon and launch icon.

struct HabitraAppIconCanvas: View {
    var body: some View {
        ZStack {
            // Background matches LaunchBackground color
            Color(hex: "0D0D14")

            HabitraLogoMark(size: 512)
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - Wordmark Lockup
// Used on share cards and onboarding.

struct HabitraWordmark: View {
    var size: CGFloat = 20        // logo mark size
    var style: Style = .light

    enum Style { case light, dark }

    private var textColor: Color {
        style == .light ? .white.opacity(0.9) : Color.habitraTextPrimary
    }

    var body: some View {
        HStack(spacing: size * 0.28) {
            HabitraLogoMark(size: size)
            Text("HABITRA")
                .font(.system(size: size * 0.72, weight: .semibold, design: .rounded))
                .tracking(size * 0.18)
                .foregroundStyle(textColor)
        }
    }
}

// MARK: - Previews

#Preview("Mark — small") {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()
        HabitraLogoMark(size: 60)
    }
    .frame(width: 120, height: 120)
}

#Preview("Mark — large") {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()
        HabitraLogoMark(size: 200)
    }
    .frame(width: 280, height: 280)
}

#Preview("Wordmark") {
    ZStack {
        Color(hex: "0D0D14").ignoresSafeArea()
        HabitraWordmark(size: 28, style: .light)
    }
    .frame(width: 240, height: 80)
}

#Preview("App Icon Canvas — export at 1024×1024") {
    HabitraAppIconCanvas()
}
