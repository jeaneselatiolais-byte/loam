//
//  MoodCheckInView.swift
//  Habitra
//
//  Phase 3 Week 8: Daily mood check-in with optional journal + sentiment
//

import SwiftUI
import SwiftData

struct MoodCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMood: MoodLevel = .okay
    @State private var journalText: String = ""
    @State private var sentimentScore: Double = 0.0
    @State private var showingSentiment = false
    @State private var saved = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        headerSection
                        moodPicker
                        journalSection
                        if showingSentiment {
                            sentimentSection
                        }
                    }
                    .padding(.horizontal, HabitraTheme.screenPadding)
                    .padding(.bottom, 100)
                }

                // Save button
                VStack {
                    Spacer()
                    HabitraButton("Save Check-In", icon: "checkmark") {
                        saveEntry()
                    }
                    .padding(.horizontal, HabitraTheme.screenPadding)
                    .padding(.bottom, HabitraTheme.screenPadding)
                }
            }
            .navigationTitle("Mood Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.habitraTextSecondary)
                }
            }
            .alert("Check-in saved!", isPresented: $saved) {
                Button("OK") { dismiss() }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("How are you feeling?")
                .font(HabitraFont.title())
                .foregroundStyle(Color.habitraTextPrimary)

            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)
        }
        .padding(.top, HabitraTheme.spacingLarge)
    }

    // MARK: - Mood Picker

    private var moodPicker: some View {
        HStack(spacing: 12) {
            ForEach(MoodLevel.allCases, id: \.rawValue) { mood in
                Button {
                    withHabitraAnimation(.spring(response: 0.3)) {
                        selectedMood = mood
                    }
                    HapticManager.selection()
                } label: {
                    VStack(spacing: 6) {
                        Text(mood.emoji)
                            .font(.system(size: selectedMood == mood ? 40 : 32))

                        Text(mood.label)
                            .font(HabitraFont.footnote())
                            .foregroundStyle(
                                selectedMood == mood
                                    ? Color(hex: mood.color)
                                    : Color.habitraTextTertiary
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedMood == mood
                            ? Color(hex: mood.color).opacity(0.12)
                            : Color.habitraSurface
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
                    .overlay(
                        RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                            .stroke(
                                selectedMood == mood
                                    ? Color(hex: mood.color).opacity(0.4)
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                    .scaleEffect(selectedMood == mood ? 1.05 : 1.0)
                }
                .buttonStyle(.plain)
                .moodSelectorAccessibility(moodLabel: mood.label, isSelected: selectedMood == mood)
            }
        }
    }

    // MARK: - Journal

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("JOURNAL")
                    .habitraCaption()
                    .sectionHeaderAccessibility()

                Spacer()

                Text("Optional")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }

            TextEditor(text: $journalText)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .padding(12)
                .background(Color.habitraSurface)
                .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
                .overlay(
                    RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                        .stroke(Color.habitraAccent.opacity(0.2), lineWidth: 1)
                )
                .onChange(of: journalText) { _, newText in
                    if !newText.isEmpty {
                        // Debounced sentiment analysis
                        sentimentScore = SentimentAnalyzer.analyzeSentiment(newText)
                        withHabitraAnimation { showingSentiment = true }
                    } else {
                        withHabitraAnimation { showingSentiment = false }
                    }
                }

            if !journalText.isEmpty {
                Text("\(journalText.count) characters")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
            }
        }
    }

    // MARK: - Sentiment Analysis

    private var sentimentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI SENTIMENT ANALYSIS")
                .habitraCaption()
                .sectionHeaderAccessibility()

            HStack(spacing: HabitraTheme.spacing) {
                // Sentiment indicator
                ZStack {
                    Circle()
                        .fill(Color(hex: SentimentAnalyzer.sentimentColor(for: sentimentScore)).opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: sentimentIcon)
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: SentimentAnalyzer.sentimentColor(for: sentimentScore)))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(SentimentAnalyzer.sentimentLabel(for: sentimentScore))
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)

                    Text("Score: \(String(format: "%.2f", sentimentScore))")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }

                Spacer()

                // Sentiment bar
                sentimentBar
            }
            .habitraCard()

            Text("Analyzed on-device using Apple NaturalLanguage. Your journal never leaves your phone.")
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
                .padding(.horizontal, 4)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var sentimentIcon: String {
        switch sentimentScore {
        case 0.3...:       return "face.smiling.inverse"
        case 0.1..<0.3:    return "face.smiling"
        case -0.1..<0.1:   return "minus.circle"
        case -0.3..<(-0.1): return "cloud"
        default:            return "cloud.rain"
        }
    }

    private var sentimentBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.habitraSurfaceLight)
                    .frame(height: 6)

                // Fill
                let normalizedScore = (sentimentScore + 1) / 2 // 0 to 1
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: SentimentAnalyzer.sentimentColor(for: sentimentScore)))
                    .frame(width: geo.size.width * normalizedScore, height: 6)
            }
        }
        .frame(width: 80, height: 6)
    }

    // MARK: - Save

    private func saveEntry() {
        let entry = MoodEntry(
            mood: selectedMood,
            journalText: journalText.trimmingCharacters(in: .whitespacesAndNewlines),
            sentimentScore: sentimentScore
        )
        modelContext.insert(entry)

        do {
            try modelContext.save()
            HapticManager.success()
            saved = true
        } catch {
            print("Habitra: Failed to save mood entry: \(error)")
        }
    }
}

#Preview {
    MoodCheckInView()
        .modelContainer(for: [MoodEntry.self], inMemory: true)
}
