//
//  HabitraProgressBarWidget.swift
//  HabitraWidget
//
//  Home Screen medium 4x2 — progress bars for each habit.
//  Pro tier.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ProgressBarTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgressBarEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgressBarEntry) -> Void) {
        completion(ProgressBarEntry(from: WidgetDataReader.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressBarEntry>) -> Void) {
        let entry = ProgressBarEntry(from: WidgetDataReader.load())
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let midnight = WidgetDataReader.startOfNextDay()
        let nextUpdate = min(nextHour, midnight)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Entry

struct ProgressBarEntry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabitData]
    let todayProgress: Double
    let todayCompleted: Int
    let todayTotal: Int

    init(from snapshot: WidgetSnapshot) {
        self.date = snapshot.updatedAt
        self.habits = Array(snapshot.habits.prefix(5))
        self.todayProgress = snapshot.todayProgress
        self.todayCompleted = snapshot.todayCompleted
        self.todayTotal = snapshot.todayTotal
    }

    static let placeholder = ProgressBarEntry(from: WidgetSnapshot(
        habits: [
            WidgetHabitData(id: UUID(), name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF",
                           isCompletedToday: true, currentStreak: 7, weeklyRate: 0.85),
            WidgetHabitData(id: UUID(), name: "Exercise", icon: "figure.run", colorHex: "4ADE80",
                           isCompletedToday: false, currentStreak: 3, weeklyRate: 0.6),
            WidgetHabitData(id: UUID(), name: "Read", icon: "book.fill", colorHex: "3B82F6",
                           isCompletedToday: true, currentStreak: 12, weeklyRate: 0.9),
        ],
        todayProgress: 0.66,
        todayCompleted: 2,
        todayTotal: 3,
        updatedAt: Date()
    ))
}

// MARK: - Widget View

struct ProgressBarWidgetView: View {
    let entry: ProgressBarEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 14))
                    .foregroundStyle(WidgetColors.accent)

                Text("Today's Progress")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WidgetColors.textSecondary)

                Spacer()

                // Overall progress ring
                ZStack {
                    Circle()
                        .stroke(WidgetColors.surface, lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: entry.todayProgress)
                        .stroke(WidgetColors.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    Text("\(entry.todayCompleted)/\(entry.todayTotal)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetColors.textPrimary)
                }
                .frame(width: 36, height: 36)
            }

            // Habit progress bars
            if entry.habits.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No habits scheduled today")
                        .font(.system(size: 12))
                        .foregroundStyle(WidgetColors.textTertiary)
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(entry.habits) { habit in
                    habitProgressRow(habit)
                }
            }
        }
        .padding(14)
        .containerBackground(WidgetColors.background, for: .widget)
    }

    private func habitProgressRow(_ habit: WidgetHabitData) -> some View {
        let color = Color(hex: habit.colorHex)

        return HStack(spacing: 8) {
            Image(systemName: habit.icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 18)

            Text(habit.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(
                    habit.isCompletedToday ? WidgetColors.textTertiary : WidgetColors.textPrimary
                )
                .frame(width: 70, alignment: .leading)
                .lineLimit(1)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(WidgetColors.surface)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(habit.isCompletedToday ? 0.6 : 0.9))
                        .frame(width: geo.size.width * habit.weeklyRate)
                }
            }
            .frame(height: 8)

            // Streak
            HStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 9))
                Text("\(habit.currentStreak)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundStyle(habit.currentStreak > 0 ? color : WidgetColors.textTertiary)
            .frame(width: 30, alignment: .trailing)

            // Checkmark
            if habit.isCompletedToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            } else {
                Circle()
                    .stroke(WidgetColors.textTertiary.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 14, height: 14)
            }
        }
    }
}

// MARK: - Widget Definition

struct HabitraProgressBarWidget: Widget {
    let kind = "HabitraProgressBarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgressBarTimelineProvider()) { entry in
            ProgressBarWidgetView(entry: entry)
        }
        .configurationDisplayName("Progress")
        .description("Track each habit's weekly progress and streaks.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    HabitraProgressBarWidget()
} timeline: {
    ProgressBarEntry.placeholder
}
