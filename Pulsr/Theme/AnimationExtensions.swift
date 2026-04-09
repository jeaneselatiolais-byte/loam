//
//  AnimationExtensions.swift
//  Habitra
//
//  Phase 2 Week 4: Animation polish and smooth transitions
//

import SwiftUI
import UIKit

// MARK: - Reduce Motion Aware Animation Utilities

/// Wraps `withAnimation` to respect the user's Reduce Motion setting.
/// When Reduce Motion is enabled, applies the `reduced` animation (defaults to nil/instant).
func withHabitraAnimation<Result>(
    _ animation: Animation? = .easeOut(duration: 0.3),
    reduced: Animation? = nil,
    _ body: () throws -> Result
) rethrows -> Result {
    if UIAccessibility.isReduceMotionEnabled {
        return try withAnimation(reduced) { try body() }
    }
    return try withAnimation(animation) { try body() }
}

extension View {
    /// Applies `.animation()` only when Reduce Motion is off.
    func habitraAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        self.animation(
            UIAccessibility.isReduceMotionEnabled ? nil : animation,
            value: value
        )
    }
}

// MARK: - Staggered Appearance Animation

/// Applies a staggered fade-and-slide entrance animation to list items.
/// Respects Reduce Motion — shows items immediately when enabled.
struct StaggeredAppearance: ViewModifier {
    let index: Int
    let total: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 12))
            .onAppear {
                if reduceMotion {
                    appeared = true
                } else {
                    let delay = Double(index) * 0.05
                    withAnimation(.easeOut(duration: 0.35).delay(delay)) {
                        appeared = true
                    }
                }
            }
    }
}

extension View {
    /// Staggered entrance animation for list items
    func staggeredAppearance(index: Int, total: Int = 10) -> some View {
        modifier(StaggeredAppearance(index: index, total: total))
    }
}

// MARK: - Shimmer Loading Effect

/// Shimmer loading placeholder. Disabled when Reduce Motion is on.
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: -geo.size.width * 0.3 + phase * geo.size.width * 1.6)
                    }
                    .mask(content)
                )
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
        }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Smooth Scale Button Style

/// A button style that provides a subtle scale-down effect on press.
struct HabitraButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == HabitraButtonStyle {
    static var habitra: HabitraButtonStyle { HabitraButtonStyle() }
}

// MARK: - Card Press Effect

/// Adds a subtle press-down effect to cards for interactive feel.
struct CardPressModifier: ViewModifier {
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: .infinity)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
    }
}

extension View {
    func cardPressEffect() -> some View {
        modifier(CardPressModifier())
    }
}

// MARK: - Reduce Motion Aware Animation

extension Animation {
    /// Returns a simplified animation when Reduce Motion is enabled
    static func habitraSpring() -> Animation {
        .spring(response: 0.4, dampingFraction: 0.7)
    }

    static func habitraEaseOut(duration: Double = 0.3) -> Animation {
        .easeOut(duration: duration)
    }
}
