//
//  HabitraHabitGridWidget.swift
//  HabitraWidget
//
//  Home Screen small 2x2 — habit completion grid.
//  Pro tier.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct HabitGridTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitGridEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitGridEntry) -> Void) {
        completion(HabitGridEntry(from: WidgetDataReader.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitGridEntry>) -> Void) {
        let entry = HabitGridEntry(from: WidgetDataReader.load())
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let midnight = WidgetDataReader.startOfNextDay()
        let nextUpdate = min(nextHour, midnight)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Entry

struct HabitGridEntry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabitData]
    let todayProgress: Double

    init(from snapshot: WidgetSnapshot) {
        self.date = snapshot.updatedAt
        self.habits = Array(snapshot.habits.prefix(6)) // max 6 in grid
        self.todayProgress = snapshot.todayProgress
    }

    static let placeholder = HabitGridEntry(from: WidgetSnapshot(
        habits: [
            WidgetHabitData(id: UUID(), name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF",
                           isCompletedToday: true, currentStreak: 7, weeklyRate: 0.85),
            WidgetHabitData(id: UUID(), name: "Exercise", icon: "figure.run", colorHex: "4ADE80",
                           isCompletedToday: false, currentStreak: 3, weeklyRate: 0.6),
            WidgetHabitData(id: UUID(), name: "Read", icon: "book.fill", colorHex: "3B82F6",
                           isCompletedToday: true, currentStreak: 12, weeklyRate: 0.9),
            WidgetHabitData(id: UUID(), name: "Water", icon: "drop.fill", colorHex: "22D3EE",
                           isCompletedToday: false, currentStreak: 0, weeklyRate: 0.4),
        ],
        todayProgress: 0.5,
        todayCompleted: 2,
        todayTotal: 4,
        updatedAt: Date()
    ))
}

// MARK: - Widget View

struct HabitGridWidgetView: View {
    let entry: HabitGridEntry

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 12))
                    .foregroundStyle(WidgetColors.accent)
                Text("Today")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WidgetColors.textSecondary)
                Spacer()
                Text("\(Int(entry.todayProgress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.accent)
            }

            // Habit grid
            if entry.habits.isEmpty {
                Spacer()
                Text("No habits today")
                    .font(.system(size: 12))
                    .foregroundStyle(WidgetColors.textTertiary)
                Spacer()
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(entry.habits) { habit in
                        habitCell(habit)
                    }
                }
            }
        }
        .padding(12)
        .containerBackground(WidgetColors.background, for: .widget)
    }

    private func habitCell(_ habit: WidgetHabitData) -> some View {
        let color = Color(hex: habit.colorHex)

        return HStack(spacing: 6) {
            Image(systemName: habit.icon)
                .font(.system(size: 12))
                .foregroundStyle(habit.isCompletedToday ? color.opacity(0.5) : color)

            Text(habit.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(
                    habit.isCompletedToday
                        ? WidgetColors.textTertiary
                        : WidgetColors.textPrimary
                )
                .lineLimit(1)

            Spacer()

            if habit.isCompletedToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(color)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(habit.isCompletedToday ? color.opacity(0.08) : WidgetColors.surface)
        )
    }
}

// MARK: - Widget Definition

struct HabitraHabitGridWidget: Widget {
    let kind = "HabitraHabitGridWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitGridTimelineProvider()) { entry in
            HabitGridWidgetView(entry: entry)
        }
        .configurationDisplayName("Habit Grid")
        .description("See all your habits and their completion status at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    HabitraHabitGridWidget()
} timeline: {
    HabitGridEntry.placeholder
}
