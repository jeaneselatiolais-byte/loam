//
//  HabitNoteSheet.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import SwiftData

struct HabitNoteSheet: View {
    let habit: Habit
    let completion: HabitCompletion
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var noteText: String = ""
    @FocusState private var isEditorFocused: Bool

    private let maxCharacters = 280

    private var habitColor: Color {
        Color(hex: habit.colorHex)
    }

    private var remainingCharacters: Int {
        maxCharacters - noteText.count
    }

    private var characterCountColor: Color {
        if remainingCharacters <= 0 {
            return .habitraDanger
        } else if remainingCharacters <= 30 {
            return .habitraWarning
        } else {
            return .habitraTextTertiary
        }
    }

    var body: some View {
        VStack(spacing: HabitraTheme.spacingLarge) {
            // MARK: - Drag Indicator
            Capsule()
                .fill(Color.habitraTextTertiary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, HabitraTheme.spacing)

            // MARK: - Habit Header
            VStack(spacing: HabitraTheme.spacingSmall) {
                ZStack {
                    Circle()
                        .fill(habitColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: habit.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(habitColor)
                }

                Text(habit.name)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text("Completed!")
                    .font(HabitraFont.caption())
                    .foregroundStyle(habitColor)
            }

            // MARK: - Prompt
            Text("How did it go?")
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)

            // MARK: - Note Editor
            VStack(alignment: .trailing, spacing: HabitraTheme.spacingSmall) {
                TextEditor(text: $noteText)
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160, maxHeight: 220)
                    .padding(HabitraTheme.spacing)
                    .background(Color.habitraSurfaceLight)
                    .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                            .stroke(
                                isEditorFocused ? habitColor.opacity(0.5) : Color.habitraTextTertiary.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .focused($isEditorFocused)
                    .onChange(of: noteText) { _, newValue in
                        if newValue.count > maxCharacters {
                            noteText = String(newValue.prefix(maxCharacters))
                        }
                    }

                // Character count
                Text("\(noteText.count)/\(maxCharacters)")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(characterCountColor)
                    .padding(.trailing, 4)
            }

            Spacer()

            // MARK: - Actions
            VStack(spacing: HabitraTheme.spacing) {
                HabitraButton("Save Note", icon: "square.and.pencil") {
                    saveNote()
                }

                HabitraSecondaryButton("Skip") {
                    onDismiss()
                }
            }
            .padding(.bottom, HabitraTheme.spacing)
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
        .background(Color.habitraBackground.ignoresSafeArea())
        .onAppear {
            noteText = completion.note ?? ""
            isEditorFocused = true
        }
        .interactiveDismissDisabled(false)
    }

    // MARK: - Actions

    private func saveNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        completion.note = trimmed.isEmpty ? nil : trimmed
        try? modelContext.save()
        onDismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitCompletion.self, configurations: config)
    let habit = Habit(name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF")
    let completion = HabitCompletion(completedDate: Date(), habit: habit)
    container.mainContext.insert(habit)
    container.mainContext.insert(completion)

    return HabitNoteSheet(
        habit: habit,
        completion: completion,
        onDismiss: {}
    )
    .modelContainer(container)
}
