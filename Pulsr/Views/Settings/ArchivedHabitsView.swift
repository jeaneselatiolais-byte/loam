//
//  ArchivedHabitsView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import SwiftData

struct ArchivedHabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { $0.isArchived },
           sort: \Habit.name)
    private var archivedHabits: [Habit]

    @State private var habitToDelete: Habit?

    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            if archivedHabits.isEmpty {
                HabitraEmptyState(
                    icon: "archivebox",
                    title: "No archived habits",
                    message: "Habits you archive will appear here. You can restore them anytime."
                )
            } else {
                ScrollView {
                    VStack(spacing: HabitraTheme.spacing) {
                        ForEach(archivedHabits) { habit in
                            ArchivedHabitRow(
                                habit: habit,
                                onRestore: { restoreHabit(habit) },
                                onDelete: { habitToDelete = habit }
                            )
                        }
                    }
                    .padding(.horizontal, HabitraTheme.screenPadding)
                    .padding(.top, HabitraTheme.spacing)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Archived Habits")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Habit?", isPresented: .init(
            get: { habitToDelete != nil },
            set: { if !$0 { habitToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let habit = habitToDelete {
                    deleteHabit(habit)
                }
            }
            Button("Cancel", role: .cancel) {
                habitToDelete = nil
            }
        } message: {
            Text("This will permanently delete \"\(habitToDelete?.name ?? "")\" and all its history. This cannot be undone.")
        }
    }

    private func restoreHabit(_ habit: Habit) {
        withAnimation {
            let vm = HabitViewModel(modelContext: modelContext)
            vm.restoreHabit(habit)
        }
    }

    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            let vm = HabitViewModel(modelContext: modelContext)
            vm.deleteHabit(habit)
        }
    }
}

// MARK: - Archived Habit Row
private struct ArchivedHabitRow: View {
    let habit: Habit
    let onRestore: () -> Void
    let onDelete: () -> Void

    private var habitColor: Color {
        Color(hex: habit.colorHex)
    }

    var body: some View {
        HStack(spacing: HabitraTheme.spacing) {
            // Icon
            Image(systemName: habit.icon)
                .font(.system(size: 18))
                .foregroundStyle(habitColor.opacity(0.5))
                .frame(width: 40, height: 40)
                .background(habitColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextSecondary)

                HStack(spacing: 8) {
                    Text(habit.frequency.displayName)
                    Text("·")
                    Text("\(habit.completions.count) completions")
                }
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary)
            }

            Spacer()

            // Restore button
            Button(action: onRestore) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.habitraAccent)
            }
            .buttonStyle(.plain)

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.habitraDanger.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .habitraCard()
    }
}

#Preview {
    NavigationStack {
        ArchivedHabitsView()
    }
    .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self], inMemory: true)
}
