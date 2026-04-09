//
//  QuickTourView.swift
//  Habitra
//
//  Coach-mark spotlight tour shown once after onboarding completes.
//  Dims the live UI and cuts a translucent hole over each feature being explained.
//

import SwiftUI

// MARK: - Tour Step Model

private struct TourStep {
    let title: String
    let description: String
    /// iPad-specific description (falls back to `description` if nil)
    let iPadDescription: String?
    let icon: String
    /// Normalized screen position of the spotlight (nil = no spotlight, center card only)
    let spotlightAnchor: UnitPoint?
    /// iPad-specific spotlight anchor (falls back to `spotlightAnchor` if nil)
    let iPadSpotlightAnchor: UnitPoint??
    /// Diameter of the spotlight hole in points
    let spotlightSize: CGFloat
    /// Whether the tooltip card should sit above the spotlight (true) or below (false)
    let cardAbove: Bool

    init(
        title: String,
        description: String,
        iPadDescription: String? = nil,
        icon: String,
        spotlightAnchor: UnitPoint?,
        iPadSpotlightAnchor: UnitPoint?? = nil,
        spotlightSize: CGFloat,
        cardAbove: Bool
    ) {
        self.title = title
        self.description = description
        self.iPadDescription = iPadDescription
        self.icon = icon
        self.spotlightAnchor = spotlightAnchor
        self.iPadSpotlightAnchor = iPadSpotlightAnchor
        self.spotlightSize = spotlightSize
        self.cardAbove = cardAbove
    }

    func resolvedDescription(isRegularWidth: Bool) -> String {
        if isRegularWidth, let iPadDesc = iPadDescription {
            return iPadDesc
        }
        return description
    }

    func resolvedSpotlightAnchor(isRegularWidth: Bool) -> UnitPoint? {
        if isRegularWidth, let iPadAnchor = iPadSpotlightAnchor {
            return iPadAnchor
        }
        return spotlightAnchor
    }
}

// MARK: - Quick Tour View

struct QuickTourView: View {
    @AppStorage("hasCompletedQuickTour") private var hasCompletedQuickTour = false
    @Binding var isPresented: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var currentStep = 0
    @State private var cardOffset: CGFloat = 80
    @State private var cardOpacity: Double = 0
    @State private var backdropOpacity: Double = 0

    /// Whether we're in regular-width (iPad) layout
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    private let steps: [TourStep] = [
        TourStep(
            title: "Welcome to Habitra",
            description: "Build habits that stick. Here's a 30-second tour of everything you need to get started.",
            icon: "waveform.path.ecg",
            spotlightAnchor: nil,
            spotlightSize: 0,
            cardAbove: false
        ),
        TourStep(
            title: "Today's Habits",
            description: "Everything scheduled for today lives here. Your list resets each morning — a fresh start every day.",
            icon: "list.bullet.rectangle.portrait",
            spotlightAnchor: UnitPoint(x: 0.5, y: 0.42),
            // iPad: content is shifted right by the sidebar, center within detail area
            iPadSpotlightAnchor: UnitPoint(x: 0.62, y: 0.42),
            spotlightSize: 200,
            cardAbove: false
        ),
        TourStep(
            title: "Add a Habit",
            description: "Tap + to create a new habit. Pick an icon, a color, and how often you want to repeat it.",
            icon: "plus.circle.fill",
            spotlightAnchor: UnitPoint(x: 0.88, y: 0.08),
            // iPad: + button is within the detail pane, further right
            iPadSpotlightAnchor: UnitPoint(x: 0.92, y: 0.08),
            spotlightSize: 56,
            cardAbove: false
        ),
        TourStep(
            title: "Mark It Complete",
            description: "Tap the circle on the right side of any habit to log it done. You'll feel it — guaranteed.",
            icon: "checkmark.circle.fill",
            spotlightAnchor: UnitPoint(x: 0.87, y: 0.42),
            // iPad: checkbox is on the right side of the detail pane
            iPadSpotlightAnchor: UnitPoint(x: 0.9, y: 0.42),
            spotlightSize: 56,
            cardAbove: false
        ),
        TourStep(
            title: "Build Your Streak",
            description: "Complete a habit daily and your streak grows. Hit 7 days and the flame badge turns gold 🔥",
            icon: "flame.fill",
            spotlightAnchor: UnitPoint(x: 0.68, y: 0.42),
            // iPad: streak badge is within the detail area
            iPadSpotlightAnchor: UnitPoint(x: 0.78, y: 0.42),
            spotlightSize: 64,
            cardAbove: false
        ),
        TourStep(
            title: "Apple Health Sync",
            description: "Link habits to Apple Fitness or Mindfulness. Workouts and meditation sessions can complete habits automatically.",
            icon: "heart.fill",
            spotlightAnchor: nil,
            spotlightSize: 0,
            cardAbove: false
        ),
        TourStep(
            title: "Stats & Progress",
            description: "The Stats tab shows your completion heatmap, streaks, AI insights, and badges you've earned.",
            iPadDescription: "Tap Stats in the sidebar to see your completion heatmap, streaks, AI insights, and badges you've earned.",
            icon: "chart.bar.fill",
            spotlightAnchor: UnitPoint(x: 0.5, y: 0.955),
            // iPad: Stats is in the sidebar, not a bottom tab
            iPadSpotlightAnchor: UnitPoint(x: 0.12, y: 0.22),
            spotlightSize: 70,
            cardAbove: true
        ),
        TourStep(
            title: "You're All Set",
            description: "One habit, repeated daily, changes everything. Start small — then build from there.",
            icon: "star.fill",
            spotlightAnchor: nil,
            spotlightSize: 0,
            cardAbove: false
        ),
    ]

    private var step: TourStep { steps[currentStep] }
    private var isLastStep: Bool { currentStep == steps.count - 1 }
    private var progress: Double { Double(currentStep) / Double(steps.count - 1) }

    /// Maximum width for the tooltip card on iPad to prevent it stretching too wide
    private let iPadCardMaxWidth: CGFloat = 420

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dimmed backdrop with spotlight cutout
                spotlightBackdrop(geo: geo)
                    .opacity(backdropOpacity)

                // Pulsing ring around spotlight
                if let anchor = step.resolvedSpotlightAnchor(isRegularWidth: isRegularWidth) {
                    PulsingRing(
                        diameter: step.spotlightSize,
                        color: .habitraAccent
                    )
                    .position(
                        x: geo.size.width * anchor.x,
                        y: geo.size.height * anchor.y
                    )
                    .id(currentStep) // resets animation on step change
                }

                // Tooltip card — above or below spotlight
                cardPosition(geo: geo)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withHabitraAnimation(.easeOut(duration: 0.35)) {
                backdropOpacity = 1
            }
            withHabitraAnimation(.spring(response: 0.5, dampingFraction: 0.78).delay(0.2)) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
    }

    // MARK: - Backdrop

    private func spotlightBackdrop(geo: GeometryProxy) -> some View {
        ZStack {
            Color.black.opacity(0.72)

            if let anchor = step.resolvedSpotlightAnchor(isRegularWidth: isRegularWidth) {
                Circle()
                    .frame(width: step.spotlightSize + 16, height: step.spotlightSize + 16)
                    .position(
                        x: geo.size.width * anchor.x,
                        y: geo.size.height * anchor.y
                    )
                    .blendMode(.destinationOut)
            }
        }
        .compositingGroup()
        .animation(.easeInOut(duration: 0.35), value: currentStep)
    }

    // MARK: - Card Positioning

    @ViewBuilder
    private func cardPosition(geo: GeometryProxy) -> some View {
        let cardContent = tooltipCard
            .frame(maxWidth: isRegularWidth ? iPadCardMaxWidth : .infinity)
            .padding(.horizontal, HabitraTheme.screenPadding)

        if step.cardAbove {
            VStack(spacing: 0) {
                cardContent
                    .padding(.top, geo.safeAreaInsets.top + 16)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .offset(y: cardOffset)
            .opacity(cardOpacity)
        } else {
            VStack(spacing: 0) {
                Spacer()
                cardContent
                    .padding(.bottom, geo.safeAreaInsets.bottom + 16)
            }
            .frame(maxWidth: .infinity)
            .offset(y: cardOffset)
            .opacity(cardOpacity)
        }
    }

    // MARK: - Tooltip Card

    private var tooltipCard: some View {
        VStack(spacing: HabitraTheme.spacingLarge) {

            // Progress bar
            progressBar

            // Icon + text
            VStack(spacing: HabitraTheme.spacing) {
                // Step 0 (Welcome) uses the brand logo mark
                Group {
                    if currentStep == 0 {
                        HabitraLogoMark(size: 64)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.habitraAccent.opacity(0.15))
                                .frame(width: 64, height: 64)
                            Image(systemName: step.icon)
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(Color.habitraAccent)
                        }
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)

                Text(step.title)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
                    .multilineTextAlignment(.center)

                Text(step.resolvedDescription(isRegularWidth: isRegularWidth))
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }

            // Buttons
            VStack(spacing: 10) {
                Button(action: advance) {
                    Text(isLastStep ? "Let's Go!" : "Next")
                        .font(HabitraFont.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.habitraAccent)
                        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
                }

                if !isLastStep {
                    Button(action: dismiss) {
                        Text("Skip Tour")
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextTertiary)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
        .padding(HabitraTheme.spacingLarge)
        .background(Color.habitraSurface)
        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusLarge)
                .stroke(Color.habitraAccent.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 28, y: 10)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.habitraAccent.opacity(0.15))
                    .frame(height: 4)

                Capsule()
                    .fill(Color.habitraAccent)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Actions

    private func advance() {
        if isLastStep {
            dismiss()
            return
        }

        // Animate card out upward, swap step, animate back in
        withHabitraAnimation(.easeIn(duration: 0.14)) {
            cardOffset = step.cardAbove ? 20 : -20
            cardOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            currentStep += 1
            // Reset card position to enter from opposite direction
            cardOffset = steps[currentStep].cardAbove ? -40 : 40
            withHabitraAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
    }

    private func dismiss() {
        withHabitraAnimation(.easeIn(duration: 0.25)) {
            backdropOpacity = 0
            cardOpacity = 0
            cardOffset = 60
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            hasCompletedQuickTour = true
            isPresented = false
        }
    }
}

// MARK: - Pulsing Ring

/// Animating concentric rings that draw attention to a spotlight element.
private struct PulsingRing: View {
    let diameter: CGFloat
    let color: Color

    @State private var scale1: CGFloat = 1.0
    @State private var opacity1: Double = 0.7
    @State private var scale2: CGFloat = 1.0
    @State private var opacity2: Double = 0.5

    var body: some View {
        ZStack {
            // Outer ring — slower pulse
            Circle()
                .stroke(color.opacity(opacity1), lineWidth: 1.5)
                .frame(width: diameter + 36, height: diameter + 36)
                .scaleEffect(scale1)

            // Inner ring — faster pulse
            Circle()
                .stroke(color.opacity(opacity2), lineWidth: 2)
                .frame(width: diameter + 16, height: diameter + 16)
                .scaleEffect(scale2)
        }
        .onAppear {
            withHabitraAnimation(
                .easeOut(duration: 1.6)
                .repeatForever(autoreverses: false)
            ) {
                scale1 = 1.25
                opacity1 = 0
            }
            withHabitraAnimation(
                .easeOut(duration: 1.1)
                .repeatForever(autoreverses: false)
                .delay(0.3)
            ) {
                scale2 = 1.2
                opacity2 = 0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        // Simulate the app UI behind the tour
        Color.habitraBackground.ignoresSafeArea()
        VStack { Spacer() }

        QuickTourView(isPresented: .constant(true))
    }
}
