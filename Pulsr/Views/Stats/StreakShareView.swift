//
//  StreakShareView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI

// MARK: - Shareable Streak Card

/// A branded card that renders a habit's streak stats for sharing to social media.
struct StreakShareCard: View {
    let habit: Habit

    private var habitColor: Color {
        Color(hex: habit.colorHex)
    }

    private var weeklyRate: Double {
        StreakCalculator.completionRate(for: habit, days: 7)
    }

    /// Recent 7-day completion data (today at trailing edge)
    private var recentDays: [(date: Date, completed: Bool, scheduled: Bool)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let scheduled = habit.frequency.isScheduled(for: date)
            let completed = habit.isCompleted(on: date)
            return (date, completed, scheduled)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: Branding
            brandingHeader

            // MARK: Habit Identity
            habitIdentity

            // MARK: Current Streak (hero)
            currentStreakHero

            // MARK: Stats Row
            statsRow

            // MARK: Mini Calendar
            miniCalendar

            // MARK: Tagline
            tagline
        }
        .padding(24)
        .frame(width: 340)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
    }

    // MARK: - Subviews

    private var brandingHeader: some View {
        HStack {
            HabitraWordmark(size: 20, style: .light)
            Spacer()
        }
    }

    private var habitIdentity: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                    .fill(.white.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: habit.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            Text(habit.name)
                .font(HabitraFont.title())
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()
        }
    }

    private var currentStreakHero: some View {
        VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.9))

                Text("\(habit.currentStreak)")
                    .font(HabitraFont.stat())
                    .foregroundStyle(.white)
            }

            Text("day streak")
                .font(HabitraFont.body())
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(
                label: "Longest",
                value: "\(habit.longestStreak)",
                unit: "days",
                icon: "trophy.fill"
            )

            Divider()
                .frame(height: 36)
                .background(.white.opacity(0.2))

            statItem(
                label: "This Week",
                value: "\(Int(weeklyRate * 100))%",
                unit: nil,
                icon: "chart.bar.fill"
            )
        }
        .padding(.vertical, 12)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
    }

    private func statItem(label: String, value: String, unit: String?, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.6))

                Text(label)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(.white.opacity(0.6))
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(HabitraFont.title())
                    .foregroundStyle(.white)

                if let unit {
                    Text(unit)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var miniCalendar: some View {
        VStack(spacing: 8) {
            Text("LAST 7 DAYS")
                .font(.system(.caption2))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.5))
                .sectionHeaderAccessibility()

            HStack(spacing: 8) {
                ForEach(Array(recentDays.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 4) {
                        Text(dayLabel(for: day.date))
                            .font(.system(.caption2))
                            .foregroundStyle(.white.opacity(0.5))

                        ZStack {
                            Circle()
                                .fill(dayCellColor(completed: day.completed, scheduled: day.scheduled))
                                .frame(width: 32, height: 32)

                            if day.completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                            } else if !day.scheduled {
                                Text("–")
                                    .font(HabitraFont.caption())
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var tagline: some View {
        Text("Track your habits with Habitra")
            .font(HabitraFont.footnote())
            .foregroundStyle(.white.opacity(0.6))
            .frame(maxWidth: .infinity)
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: [
                habitColor,
                habitColor.opacity(0.85),
                Color(hex: "0D0D14").opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Helpers

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1)).uppercased()
    }

    private func dayCellColor(completed: Bool, scheduled: Bool) -> Color {
        if completed {
            return .white.opacity(0.3)
        } else if scheduled {
            return .white.opacity(0.08)
        } else {
            return .white.opacity(0.04)
        }
    }
}

// MARK: - Share Sheet Wrapper

/// Presents a preview of the streak card with a share button that renders
/// the card to an image using `ImageRenderer` (iOS 16+).
struct StreakShareSheet: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss

    @State private var renderedImage: UIImage?
    @State private var showShareSheet = false

    private var shareCard: StreakShareCard {
        StreakShareCard(habit: habit)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                VStack(spacing: HabitraTheme.spacingLarge) {
                    Spacer()

                    // Card preview
                    shareCard
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)

                    Spacer()

                    // Share button
                    HabitraButton("Share", icon: "square.and.arrow.up") {
                        renderAndShare()
                    }
                    .padding(.horizontal, HabitraTheme.screenPadding)
                    .padding(.bottom, HabitraTheme.spacingLarge)
                }
            }
            .navigationTitle("Share Streak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Color.habitraAccent)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = renderedImage {
                    ShareActivityView(items: [image])
                }
            }
        }
    }

    @MainActor
    private func renderAndShare() {
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = 3.0 // Retina scale for high-quality export
        renderer.proposedSize = .unspecified

        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
            showShareSheet = true
        }
    }
}

// MARK: - UIActivityViewController Bridge

private struct ShareActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("Streak Share Card") {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()
        StreakShareCard(
            habit: Habit(name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF")
        )
    }
}

#Preview("Streak Share Sheet") {
    StreakShareSheet(
        habit: Habit(name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF")
    )
}
