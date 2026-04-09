//
//  OnboardingView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "100% Private",
            subtitle: "Your data never leaves your device.\nNo accounts. No cloud. No tracking.",
            accentColor: .habitraAccent
        ),
        OnboardingPage(
            icon: "waveform.path.ecg",
            title: "Track Your Pulse",
            subtitle: "Build habits with streaks, stats,\nand a rhythm that's uniquely yours.",
            accentColor: .habitraAccentBright
        ),
        OnboardingPage(
            icon: "bell.badge.fill",
            title: "Stay on Track",
            subtitle: "Smart reminders keep you going.\nEnable notifications to never miss a beat.",
            accentColor: .habitraHabitOrange
        ),
    ]

    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageView(page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom section
                bottomSection
            }
        }
        .onAppear {
            animateIn()
        }
        .onChange(of: currentPage) { _, _ in
            animateIn()
            HapticManager.selection()
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: HabitraTheme.spacingLarge) {
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.habitraAccent : Color.habitraTextTertiary.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }

            // Action button
            Button {
                HapticManager.medium()
                handleAction()
            } label: {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                    .font(HabitraFont.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.habitraAccent)
                    .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
            }

            // Skip
            if currentPage < pages.count - 1 {
                Button("Skip") {
                    HapticManager.light()
                    completeOnboarding()
                }
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
                .transition(.opacity)
            } else {
                Text(" ")
                    .font(HabitraFont.body())
            }
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
        .padding(.bottom, 40)
    }

    // MARK: - Page View

    private func pageView(_ page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 24) {
            Spacer()

            // Animated icon with layered glow
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(page.accentColor.opacity(0.04))
                    .frame(width: 200, height: 200)
                    .scaleEffect(index == currentPage ? iconScale * 1.1 : 0.8)
                    .opacity(index == currentPage ? iconOpacity * 0.5 : 0)

                // Middle glow
                Circle()
                    .fill(page.accentColor.opacity(0.08))
                    .frame(width: 160, height: 160)
                    .scaleEffect(index == currentPage ? iconScale : 0.8)
                    .opacity(index == currentPage ? iconOpacity * 0.7 : 0)

                // Inner glow
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 120, height: 120)
                    .scaleEffect(index == currentPage ? iconScale : 0.8)
                    .opacity(index == currentPage ? iconOpacity : 0)

                // Page 0 uses the brand logo mark; others use the SF Symbol icon
                if index == 0 {
                    HabitraLogoMark(size: 90)
                        .scaleEffect(index == currentPage ? iconScale : 0.8)
                        .opacity(index == currentPage ? iconOpacity : 0)
                } else {
                    Image(systemName: page.icon)
                        .font(.system(size: 52))
                        .foregroundStyle(page.accentColor)
                        .scaleEffect(index == currentPage ? iconScale : 0.8)
                        .opacity(index == currentPage ? iconOpacity : 0)
                }
            }

            // Text content
            VStack(spacing: 12) {
                Text(page.title)
                    .font(HabitraFont.title())
                    .foregroundStyle(Color.habitraTextPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(index == currentPage ? textOpacity : 0)
            .offset(y: index == currentPage ? 0 : 20)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Animations

    private func animateIn() {
        // Reset
        iconScale = 0.5
        iconOpacity = 0
        textOpacity = 0

        // Icon springs in
        withHabitraAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }

        // Text fades in after icon
        withHabitraAnimation(.easeOut(duration: 0.4).delay(0.3)) {
            textOpacity = 1.0
        }
    }

    // MARK: - Actions

    private func handleAction() {
        if currentPage == pages.count - 1 {
            Task {
                _ = await NotificationManager.shared.requestPermission()
                completeOnboarding()
            }
        } else {
            withHabitraAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }

    private func completeOnboarding() {
        HapticManager.success()
        withHabitraAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Page Model
private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
}

#Preview {
    OnboardingView()
}
