//
//  MoodTrendView.swift
//  Habitra
//
//  Phase 3 Week 10: Mood trend analysis dashboard
//

import SwiftUI
import SwiftData

struct MoodTrendView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \MoodEntry.date, order: .reverse)
    private var allEntries: [MoodEntry]

    @State private var selectedRange = 30

    private var entries: [MoodEntry] {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -selectedRange, to: Date()) ?? Date()
        return allEntries.filter { $0.date >= cutoff }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                if allEntries.isEmpty {
                    HabitraEmptyState(
                        icon: "face.smiling",
                        title: "No mood data yet",
                        message: "Start logging your mood in the Coach tab to see trends here."
                    )
                } else {
                    ScrollView {
                        VStack(spacing: HabitraTheme.spacingLarge) {
                            rangePicker
                            summaryCards
                            moodChart
                            sentimentSection
                            distributionSection
                            journalHighlights
                        }
                        .padding(.top, HabitraTheme.spacing)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Mood Trends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.habitraAccent)
                }
            }
        }
    }

    // MARK: - Range Picker

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach([7, 30, 90], id: \.self) { range in
                Button {
                    withHabitraAnimation { selectedRange = range }
                } label: {
                    Text("\(range)D")
                        .font(HabitraFont.caption())
                        .tracking(0)
                        .textCase(.none)
                        .foregroundStyle(selectedRange == range ? .white : Color.habitraTextTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedRange == range ? Color.habitraAccent : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(3)
        .background(Color.habitraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.habitraAccent.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: HabitraTheme.spacing) {
            moodSummaryCard(
                title: "Average",
                value: String(format: "%.1f", averageMood),
                subtitle: "/5",
                icon: dominantMoodEmoji,
                color: Color(hex: dominantMoodLevel.color)
            )

            moodSummaryCard(
                title: "Entries",
                value: "\(entries.count)",
                subtitle: "logged",
                icon: "📝",
                color: .habitraAccent
            )

            moodSummaryCard(
                title: "Sentiment",
                value: SentimentAnalyzer.sentimentLabel(for: avgSentiment),
                subtitle: "",
                icon: sentimentEmoji,
                color: Color(hex: SentimentAnalyzer.sentimentColor(for: avgSentiment))
            )
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private func moodSummaryCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 24))

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }
            }

            Text(title)
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .habitraCard()
    }

    // MARK: - Mood Chart (sparkline)

    private var moodChart: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
            Text("MOOD OVER TIME")
                .habitraCaption()
                .sectionHeaderAccessibility()

            let sortedEntries = entries.sorted { $0.date < $1.date }

            if sortedEntries.count >= 2 {
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    let points = sortedEntries.enumerated().map { idx, entry -> CGPoint in
                        let x = sortedEntries.count > 1 ?
                            CGFloat(idx) / CGFloat(sortedEntries.count - 1) * width : width / 2
                        let y = height - (CGFloat(entry.moodLevel - 1) / 4.0 * (height - 20)) - 10
                        return CGPoint(x: x, y: y)
                    }

                    ZStack {
                        // Grid
                        ForEach(1...5, id: \.self) { level in
                            let y = height - (CGFloat(level - 1) / 4.0 * (height - 20)) - 10
                            Path { p in
                                p.move(to: CGPoint(x: 0, y: y))
                                p.addLine(to: CGPoint(x: width, y: y))
                            }
                            .stroke(Color.habitraTextTertiary.opacity(0.1), lineWidth: 0.5)
                        }

                        // Gradient fill
                        Path { path in
                            guard let first = points.first, let last = points.last else { return }
                            path.move(to: CGPoint(x: first.x, y: height))
                            path.addLine(to: first)
                            for i in 1..<points.count {
                                path.addLine(to: points[i])
                            }
                            path.addLine(to: CGPoint(x: last.x, y: height))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [Color.habitraAccent.opacity(0.2), Color.habitraAccent.opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )

                        // Line
                        Path { path in
                            guard let first = points.first else { return }
                            path.move(to: first)
                            for i in 1..<points.count {
                                path.addLine(to: points[i])
                            }
                        }
                        .stroke(Color.habitraAccent, style: StrokeStyle(lineWidth: 2, lineCap: .round))

                        // Dots with mood color
                        ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { idx, entry in
                            let mood = MoodLevel(rawValue: entry.moodLevel) ?? .okay
                            Circle()
                                .fill(Color(hex: mood.color))
                                .frame(width: 6, height: 6)
                                .position(points[idx])
                        }
                    }
                }
                .frame(height: 120)
            } else {
                Text("Not enough data yet")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextTertiary)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            }
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Sentiment Section

    private var sentimentSection: some View {
        let journalEntries = entries.filter { !$0.journalText.isEmpty }
        guard !journalEntries.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
                Text("JOURNAL SENTIMENT")
                    .habitraCaption()
                    .sectionHeaderAccessibility()

                HStack(spacing: HabitraTheme.spacingLarge) {
                    VStack(spacing: 4) {
                        Text(String(format: "%.2f", avgSentiment))
                            .font(HabitraFont.title())
                            .foregroundStyle(Color(hex: SentimentAnalyzer.sentimentColor(for: avgSentiment)))

                        Text(SentimentAnalyzer.sentimentLabel(for: avgSentiment))
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(journalEntries.count) journal entries")
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextSecondary)

                        Text("Analyzed on-device")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }
            }
            .habitraCard()
            .padding(.horizontal, HabitraTheme.screenPadding)
        )
    }

    // MARK: - Distribution

    private var distributionSection: some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
            Text("MOOD DISTRIBUTION")
                .habitraCaption()
                .sectionHeaderAccessibility()

            VStack(spacing: 6) {
                ForEach(MoodLevel.allCases.reversed(), id: \.rawValue) { mood in
                    let count = entries.filter { $0.moodLevel == mood.rawValue }.count
                    let pct = entries.isEmpty ? 0.0 : Double(count) / Double(entries.count)

                    HStack(spacing: 10) {
                        Text(mood.emoji)
                            .font(.system(size: 18))
                            .frame(width: 28)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.habitraSurfaceLight)
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: mood.color))
                                    .frame(width: max(2, geo.size.width * pct), height: 8)
                            }
                        }
                        .frame(height: 8)

                        Text("\(count)")
                            .font(HabitraFont.caption())
                            .tracking(0)
                            .textCase(.none)
                            .foregroundStyle(Color.habitraTextTertiary)
                            .frame(width: 24, alignment: .trailing)
                    }
                }
            }
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Journal Highlights

    private var journalHighlights: some View {
        let withJournals = entries.filter { !$0.journalText.isEmpty }.prefix(3)
        guard !withJournals.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                Text("RECENT JOURNALS")
                    .habitraCaption()
                    .sectionHeaderAccessibility()
                    .padding(.horizontal, HabitraTheme.screenPadding)

                ForEach(Array(withJournals)) { entry in
                    let mood = MoodLevel(rawValue: entry.moodLevel) ?? .okay
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(mood.emoji)
                                .font(.system(size: 16))
                            Text(entry.date.formatted(.dateTime.month(.abbreviated).day()))
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary)
                            Spacer()
                            Text(SentimentAnalyzer.sentimentLabel(for: entry.sentimentScore))
                                .font(.system(.caption2))
                                .foregroundStyle(Color(hex: SentimentAnalyzer.sentimentColor(for: entry.sentimentScore)))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: SentimentAnalyzer.sentimentColor(for: entry.sentimentScore)).opacity(0.12))
                                .clipShape(Capsule())
                        }

                        Text(entry.journalText)
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextSecondary)
                            .lineLimit(3)
                    }
                    .habitraCard()
                    .padding(.horizontal, HabitraTheme.screenPadding)
                }
            }
        )
    }

    // MARK: - Computed

    private var averageMood: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.reduce(0) { $0 + $1.moodLevel }) / Double(entries.count)
    }

    private var dominantMoodLevel: MoodLevel {
        MoodLevel(rawValue: Int(averageMood.rounded())) ?? .okay
    }

    private var dominantMoodEmoji: String {
        dominantMoodLevel.emoji
    }

    private var avgSentiment: Double {
        let withText = entries.filter { !$0.journalText.isEmpty }
        guard !withText.isEmpty else { return 0 }
        return withText.reduce(0.0) { $0 + $1.sentimentScore } / Double(withText.count)
    }

    private var sentimentEmoji: String {
        switch avgSentiment {
        case 0.3...:       return "😊"
        case 0.1..<0.3:    return "🙂"
        case -0.1..<0.1:   return "😐"
        case -0.3..<(-0.1): return "😕"
        default:            return "😞"
        }
    }
}

#Preview {
    MoodTrendView()
        .modelContainer(for: [MoodEntry.self], inMemory: true)
}
