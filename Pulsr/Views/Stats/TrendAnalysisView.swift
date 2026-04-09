//
//  TrendAnalysisView.swift
//  Habitra
//
//  Phase 2 Week 2: Completion trend line with direction indicators
//

import SwiftUI

/// Shows a completion trend line chart over time with direction indicator.
struct TrendAnalysisView: View {
    let habits: [Habit]
    let days: Int

    private var dailyRates: [DailyRate] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<days).reversed().compactMap { offset -> DailyRate? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let scheduled = habits.filter { $0.frequency.isScheduled(for: date) }
            guard !scheduled.isEmpty else { return nil }
            let completed = scheduled.filter { $0.isCompleted(on: date) }.count
            let rate = Double(completed) / Double(scheduled.count)
            return DailyRate(date: date, rate: rate)
        }
    }

    private var trend: TrendDirection {
        guard dailyRates.count >= 7 else { return .neutral }
        let recentCount = min(7, dailyRates.count / 2)
        let recentAvg = dailyRates.suffix(recentCount).map(\.rate).reduce(0, +) / Double(recentCount)
        let olderAvg = dailyRates.prefix(recentCount).map(\.rate).reduce(0, +) / Double(recentCount)
        let diff = recentAvg - olderAvg
        if diff > 0.05 { return .up }
        if diff < -0.05 { return .down }
        return .neutral
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            // Header
            HStack {
                Text("TREND")
                    .habitraCaption()
                    .sectionHeaderAccessibility()

                Spacer()

                trendBadge
            }

            if dailyRates.count >= 2 {
                TrendLineChart(data: dailyRates)
                    .frame(height: 100)
            } else {
                Text("Not enough data yet")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextTertiary)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
            }
        }
        .habitraCard()
    }

    private var trendBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: trend.icon)
                .font(.system(size: 12, weight: .bold))
            Text(trend.label)
                .font(HabitraFont.caption())
                .tracking(0)
                .textCase(.none)
        }
        .foregroundStyle(trend.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(trend.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Trend Line Chart

private struct TrendLineChart: View {
    let data: [DailyRate]

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let maxRate = max(data.map(\.rate).max() ?? 1.0, 0.01)
            let points = data.enumerated().map { index, item -> CGPoint in
                let x = data.count > 1
                    ? CGFloat(index) / CGFloat(data.count - 1) * width
                    : width / 2
                let y = height - (CGFloat(item.rate / maxRate) * (height - 10)) - 5
                return CGPoint(x: x, y: y)
            }

            ZStack {
                // Grid lines
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { level in
                    Path { path in
                        let y = height - (CGFloat(level) * (height - 10)) - 5
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(Color.habitraTextTertiary.opacity(0.1), lineWidth: 0.5)
                }

                // Gradient fill under curve
                if points.count >= 2, let first = points.first, let last = points.last {
                    Path { path in
                        path.move(to: CGPoint(x: first.x, y: height))
                        path.addLine(to: first)
                        for i in 1..<points.count {
                            let prev = points[i - 1]
                            let curr = points[i]
                            let mid = CGPoint(
                                x: (prev.x + curr.x) / 2,
                                y: (prev.y + curr.y) / 2
                            )
                            path.addQuadCurve(to: mid, control: CGPoint(x: mid.x, y: prev.y))
                            path.addQuadCurve(to: curr, control: CGPoint(x: mid.x, y: curr.y))
                        }
                        path.addLine(to: CGPoint(x: last.x, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.habitraAccent.opacity(0.3), Color.habitraAccent.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // Line
                    Path { path in
                        path.move(to: first)
                        for i in 1..<points.count {
                            let prev = points[i - 1]
                            let curr = points[i]
                            let mid = CGPoint(
                                x: (prev.x + curr.x) / 2,
                                y: (prev.y + curr.y) / 2
                            )
                            path.addQuadCurve(to: mid, control: CGPoint(x: mid.x, y: prev.y))
                            path.addQuadCurve(to: curr, control: CGPoint(x: mid.x, y: curr.y))
                        }
                    }
                    .stroke(
                        Color.habitraAccent,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )

                    // End dot
                    Circle()
                        .fill(Color.habitraAccent)
                        .frame(width: 6, height: 6)
                        .position(last)
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct DailyRate: Identifiable {
    let date: Date
    let rate: Double
    var id: Date { date }
}

enum TrendDirection {
    case up, down, neutral

    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }

    var label: String {
        switch self {
        case .up: return "Improving"
        case .down: return "Declining"
        case .neutral: return "Steady"
        }
    }

    var color: Color {
        switch self {
        case .up: return .habitraSuccess
        case .down: return .habitraDanger
        case .neutral: return .habitraWarning
        }
    }
}

#Preview {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()
        TrendAnalysisView(habits: [], days: 30)
            .padding()
    }
}
