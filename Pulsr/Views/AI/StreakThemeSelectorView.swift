//
//  StreakThemeSelectorView.swift
//  Habitra
//
//  Phase 3 Week 11: Theme picker for streak share cards
//

import SwiftUI

struct StreakThemeSelectorView: View {
    @Binding var selectedThemeID: String
    @State private var showingPaywall = false

    var body: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            Text("THEME")
                .habitraCaption()
                .sectionHeaderAccessibility()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(StreakThemeLibrary.allThemes) { theme in
                        themePreview(theme)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    @MainActor
    private func themePreview(_ theme: StreakTheme) -> some View {
        let isSelected = selectedThemeID == theme.id
        let isLocked = theme.isPro && !SubscriptionManager.isPro

        return Button {
            if isLocked {
                showingPaywall = true
            } else {
                withHabitraAnimation(.spring(response: 0.3)) {
                    selectedThemeID = theme.id
                }
                HapticManager.selection()
            }
        } label: {
            ZStack {
                // Gradient preview
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.gradient)
                    .frame(width: 64, height: 80)

                VStack(spacing: 4) {
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.6))
                    } else {
                        Image(systemName: theme.iconName)
                            .font(.system(size: 16))
                            .foregroundStyle(theme.foregroundColor.opacity(0.8))
                    }

                    Text(theme.name)
                        .font(.system(.caption2))
                        .foregroundStyle(theme.foregroundColor.opacity(0.7))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()
        StreakThemeSelectorView(selectedThemeID: .constant("midnight"))
            .padding()
    }
}
