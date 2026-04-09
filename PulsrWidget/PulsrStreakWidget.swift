//
//  HabitraStreakWidget.swift
//  HabitraWidget
//
//  Lock Screen small widget — shows today's streak and progress.
//  Available on Free tier.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct StreakTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(from: WidgetDataReader.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let snapshot = WidgetDataReader.load()
        let entry = StreakEntry(from: snapshot)

        // Refresh at the earlier of next hour or midnight (so data resets for the new day)
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let midnight = WidgetDataReader.startOfNextDay()
        let nextUpdate = min(nextHour, midnight)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Entry

struct StreakEntry: TimelineEntry {
    let date: Date
    let todayProgress: Double
    let todayCompleted: Int
    let todayTotal: Int
    let topStreak: Int
    let topHabitName: String
    let topHabitIcon: String
    let topHabitColor: String

    init(from snapshot: WidgetSnapshot) {
        self.date = snapshot.updatedAt
        self.todayProgress = snapshot.todayProgress
        self.todayCompleted = snapshot.todayCompleted
        self.todayTotal = snapshot.todayTotal

        // Find the habit with the highest streak
        if let best = snapshot.habits.max(by: { $0.currentStreak < $1.currentStreak }) {
            self.topStreak = best.currentStreak
            self.topHabitName = best.name
            self.topHabitIcon = best.icon
            self.topHabitColor = best.colorHex
        } else {
            self.topStreak = 0
            self.topHabitName = "Habitra"
            self.topHabitIcon = "waveform.path.ecg"
            self.topHabitColor = "6C63FF"
        }
    }

    static let placeholder = StreakEntry(from: WidgetSnapshot(
        habits: [
            WidgetHabitData(id: UUID(), name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF",
                           isCompletedToday: true, currentStreak: 7, weeklyRate: 0.85)
        ],
        todayProgress: 0.6,
        todayCompleted: 3,
        todayTotal: 5,
        updatedAt: Date()
    ))
}

// MARK: - Widget Views

struct StreakWidgetView: View {
    let entry: StreakEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryInline:
            accessoryInlineView
        case .systemSmall:
            systemSmallView
        case .systemExtraLarge:
            standbyView
        default:
            systemSmallView
        }
    }

    // MARK: - Lock Screen Circular
    private var accessoryCircularView: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 1) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                Text("\(entry.topStreak)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
        }
        .containerBackground(for: .widget) { }
    }

    // MARK: - Lock Screen Rectangular
    private var accessoryRectangularView: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                    Text("\(entry.topStreak) day streak")
                        .font(.system(size: 12, weight: .semibold))
                }

                Text("\(entry.todayCompleted)/\(entry.todayTotal) today")
                    .font(.system(size: 11))
                    .opacity(0.7)
            }

            Spacer()

            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(lineWidth: 3)
                    .opacity(0.2)
                Circle()
                    .trim(from: 0, to: entry.todayProgress)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(Int(entry.todayProgress * 100))%")
                    .font(.system(size: 9, weight: .bold))
            }
            .frame(width: 32, height: 32)
        }
        .containerBackground(for: .widget) { }
    }

    // MARK: - Lock Screen Inline
    private var accessoryInlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
            Text("\(entry.topStreak)d streak · \(entry.todayCompleted)/\(entry.todayTotal) done")
        }
        .containerBackground(for: .widget) { }
    }

    // MARK: - Standby / Extra Large
    private var standbyView: some View {
        VStack(spacing: 24) {
            // Pulse icon
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 48))
                .foregroundStyle(WidgetColors.accent)

            // Giant streak number
            VStack(spacing: 8) {
                Text("\(entry.topStreak)")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.textPrimary)

                Text("day streak")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(WidgetColors.textTertiary)
            }

            // Progress
            VStack(spacing: 8) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(WidgetColors.surface)
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(WidgetColors.accent)
                            .frame(width: geo.size.width * entry.todayProgress, height: 12)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 40)

                Text("\(entry.todayCompleted) of \(entry.todayTotal) completed today")
                    .font(.system(size: 16))
                    .foregroundStyle(WidgetColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(WidgetColors.background, for: .widget)
    }

    // MARK: - Home Screen Small
    private var systemSmallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 14))
                    .foregroundStyle(WidgetColors.accent)
                Spacer()
                Text("\(entry.todayCompleted)/\(entry.todayTotal)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WidgetColors.textSecondary)
            }

            Spacer()

            // Streak number
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(entry.topStreak)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.textPrimary)

                Text("days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WidgetColors.textTertiary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(WidgetColors.surface)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(WidgetColors.accent)
                        .frame(width: geo.size.width * entry.todayProgress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .containerBackground(WidgetColors.background, for: .widget)
    }
}

// MARK: - Widget Definition

struct HabitraStreakWidget: Widget {
    let kind = "HabitraStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("See your current habit streak and daily progress.")
        .supportedFamilies([
            .systemSmall,
            .systemExtraLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

#Preview(as: .systemSmall) {
    HabitraStreakWidget()
} timeline: {
    StreakEntry.placeholder
}
