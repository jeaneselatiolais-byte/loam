//
//  CalendarHeatmapView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI

/// GitHub-style contribution heatmap showing habit completions over time.
struct CalendarHeatmapView: View {
    let completionMap: [Date: Int]
    let maxPerDay: Int
    var weeks: Int = 12
    var color: Color = .habitraAccent

    private let calendar = Calendar.current
    private let cellSize: CGFloat = 14
    private let cellSpacing: CGFloat = 3

    private var gridData: [[DayCell]] {
        let today = calendar.startOfDay(for: Date())
        let totalDays = weeks * 7

        // Find the start date (aligned to start of week)
        guard let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: today) else {
            return []
        }

        // Align to Sunday
        let startWeekday = calendar.component(.weekday, from: startDate)
        let alignedStart: Date
        if startWeekday == 1 {
            alignedStart = startDate
        } else {
            alignedStart = calendar.date(byAdding: .day, value: -(startWeekday - 1), to: startDate) ?? startDate
        }

        var weekColumns: [[DayCell]] = []
        var currentDate = alignedStart

        while currentDate <= today {
            var week: [DayCell] = []
            for _ in 0..<7 {
                let dayStart = calendar.startOfDay(for: currentDate)
                let count = completionMap[dayStart] ?? 0
                let isFuture = dayStart > today
                week.append(DayCell(date: dayStart, count: count, isFuture: isFuture))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            weekColumns.append(week)
        }

        return weekColumns
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
            // Month labels
            monthLabels

            // Grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cellSpacing) {
                    ForEach(Array(gridData.enumerated()), id: \.offset) { _, week in
                        VStack(spacing: cellSpacing) {
                            ForEach(week, id: \.date) { day in
                                dayCellView(day)
                            }
                        }
                    }
                }
                .padding(.leading, 24) // space for day labels
            }

            // Legend
            legendView
        }
    }

    // MARK: - Month Labels

    private var monthLabels: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 24)

            let months = extractMonthLabels()
            ForEach(months, id: \.offset) { item in
                Text(item.label)
                    .font(.system(.caption2))
                    .foregroundStyle(Color.habitraTextTertiary)
                if item.offset < months.count - 1 {
                    Spacer()
                }
            }
        }
    }

    private struct MonthLabel: Identifiable {
        let offset: Int
        let label: String
        var id: Int { offset }
    }

    private func extractMonthLabels() -> [MonthLabel] {
        var labels: [MonthLabel] = []
        var lastMonth = -1

        for (weekIndex, week) in gridData.enumerated() {
            guard let firstDay = week.first else { continue }
            let month = calendar.component(.month, from: firstDay.date)
            if month != lastMonth {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                labels.append(MonthLabel(offset: weekIndex, label: formatter.string(from: firstDay.date)))
                lastMonth = month
            }
        }

        return labels
    }

    // MARK: - Day Cell

    private func dayCellView(_ day: DayCell) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(cellColor(for: day))
            .frame(width: cellSize, height: cellSize)
    }

    private func cellColor(for day: DayCell) -> Color {
        if day.isFuture {
            return Color.habitraSurface.opacity(0.3)
        }
        guard maxPerDay > 0, day.count > 0 else {
            return Color.habitraSurface
        }
        let intensity = Double(day.count) / Double(maxPerDay)
        return color.opacity(0.2 + (intensity * 0.8))
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: 4) {
            Spacer()
            Text("Less")
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary)

            ForEach(0..<5) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(level == 0 ? Color.habitraSurface : color.opacity(0.2 + (Double(level) / 4.0 * 0.8)))
                    .frame(width: 10, height: 10)
            }

            Text("More")
                .font(.system(.caption2))
                .foregroundStyle(Color.habitraTextTertiary)
        }
    }
}

// MARK: - Day Cell Model
private struct DayCell {
    let date: Date
    let count: Int
    let isFuture: Bool
}

// MARK: - Single Habit Heatmap (bool variant)
struct HabitHeatmapView: View {
    let completionMap: [Date: Bool]
    var weeks: Int = 12
    var color: Color = .habitraAccent

    private var intMap: [Date: Int] {
        completionMap.mapValues { $0 ? 1 : 0 }
    }

    var body: some View {
        CalendarHeatmapView(
            completionMap: intMap,
            maxPerDay: 1,
            weeks: weeks,
            color: color
        )
    }
}

#Preview {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()

        CalendarHeatmapView(
            completionMap: [:],
            maxPerDay: 3,
            weeks: 12
        )
        .habitraCard()
        .padding()
    }
}
