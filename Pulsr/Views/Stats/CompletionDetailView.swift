//
//  CompletionDetailView.swift
//  Habitra
//
//  Phase 2 Week 3: View completions for a specific date
//

import SwiftUI
import SwiftData

/// Shows all completions for a specific date with optional notes.
struct CompletionDetailView: View {
    let date: Date
    let habits: [Habit]

    @Environment(\.dismiss) private var dismiss

    private var dateString: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    private var completedHabits: [(habit: Habit, completion: HabitCompletion?)] {
        let calendar = Calendar.current
        return habits
            .filter { $0.frequency.isScheduled(for: date) }
            .map { habit in
                let completion = habit.completions.first {
                    calendar.isDate($0.completedDate, inSameDayAs: date)
                }
                return (habit, completion)
            }
            .sorted { lhs, rhs in
                // Completed first, then by name
                if (lhs.completion != nil) != (rhs.completion != nil) {
                    return lhs.completion != nil
                }
                return lhs.habit.name < rhs.habit.name
            }
    }

    private var completionRate: Double {
        let scheduled = completedHabits.count
        guard scheduled > 0 else { return 0 }
        let completed = completedHabits.filter { $0.completion != nil }.count
        return Double(completed) / Double(scheduled)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        // Date header
                        dateHeader

                        if completedHabits.isEmpty {
                            HabitraEmptyState(
                                icon: "calendar.badge.minus",
                                title: "No habits scheduled",
                                message: "No habits were scheduled for this date."
                            )
                            .padding(.top, 40)
                        } else {
                            // Habit list
                            VStack(spacing: HabitraTheme.spacing) {
                                ForEach(completedHabits, id: \.habit.id) { item in
                                    completionRow(habit: item.habit, completion: item.completion)
                                }
                            }
                            .padding(.horizontal, HabitraTheme.screenPadding)
                        }
                    }
                    .padding(.top, HabitraTheme.spacing)
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("Day Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.habitraAccent)
                }
            }
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack(spacing: HabitraTheme.spacingLarge) {
            ProgressRing(
                progress: completionRate,
                lineWidth: 6,
                size: 56
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(dateString)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)

                let completed = completedHabits.filter { $0.completion != nil }.count
                let scheduled = completedHabits.count
                Text("\(completed) of \(scheduled) completed")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
            }

            Spacer()
        }
        .habitraCard()
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    // MARK: - Completion Row

    private func completionRow(habit: Habit, completion: HabitCompletion?) -> some View {
        let habitColor = Color(hex: habit.colorHex)
        let isComplete = completion != nil

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: HabitraTheme.spacing) {
                // Icon
                Image(systemName: habit.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(habitColor.opacity(isComplete ? 1.0 : 0.4))
                    .frame(width: 36, height: 36)
                    .background(habitColor.opacity(isComplete ? 0.12 : 0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(HabitraFont.headline())
                        .foregroundStyle(isComplete ? Color.habitraTextPrimary : Color.habitraTextTertiary)
                        .strikethrough(isComplete, color: .habitraTextTertiary)

                    if let completion, let time = completionTime(completion) {
                        Text("Completed at \(time)")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }

                Spacer()

                // Status
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(habitColor)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.habitraTextTertiary.opacity(0.6))
                }
            }

            // Note (if present)
            if let note = completion?.note, !note.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.habitraTextTertiary)

                    Text(note)
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextSecondary)
                        .lineLimit(3)
                }
                .padding(.leading, 48) // align with text after icon
            }
        }
        .habitraCard()
    }

    private func completionTime(_ completion: HabitCompletion) -> String? {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: completion.completedAt)
    }
}

#Preview {
    CompletionDetailView(date: Date(), habits: [])
}
