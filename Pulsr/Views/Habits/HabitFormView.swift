//
//  HabitFormView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import SwiftData

// MARK: - Reminder Interval Unit

private enum ReminderUnit: String, CaseIterable, Identifiable {
    case hours = "Hours"
    case minutes = "Minutes"
    var id: String { rawValue }
    var multiplier: Int { self == .hours ? 60 : 1 }
    var shortLabel: String { self == .hours ? "hr" : "min" }
}

// MARK: - HabitFormView

struct HabitFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editingHabit: Habit?

    // Basics
    @State private var name: String = ""
    @State private var selectedIcon: String = "circle.fill"
    @State private var selectedColorHex: String = "6C63FF"

    // Schedule — days of week (1=Sun … 7=Sat), default all 7
    @State private var selectedDays: Set<Int> = Set(1...7)

    // Times per day
    @State private var targetCompletionsPerDay: Int = 1

    // Reminder
    @State private var hasReminder: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(
        from: DateComponents(hour: 9, minute: 0)
    ) ?? Date()
    // Interval reminder (multi-completion only)
    @State private var reminderIntervalValue: Int = 2
    @State private var reminderIntervalUnit: ReminderUnit = .hours

    // HealthKit — supports multiple workout selections
    @State private var healthKitSources: Set<HabitHealthSource> = []
    @State private var minHealthKitDuration: Int = 15
    @State private var healthKitStepGoal: Int = 7000
    @State private var showHealthSection: Bool = false

    private var isEditing: Bool { editingHabit != nil }

    private let iconOptions = [
        "figure.run", "dumbbell.fill", "brain.head.profile", "book.fill",
        "drop.fill", "bed.double.fill", "leaf.fill", "heart.fill",
        "pencil.and.outline", "music.note", "cup.and.saucer.fill", "fork.knife",
        "pills.fill", "sun.max.fill", "moon.fill", "phone.down.fill",
        "laptopcomputer", "paintpalette.fill", "dog.fill", "figure.yoga"
    ]

    // Derived frequency from selectedDays
    private var derivedFrequency: HabitFrequency {
        if selectedDays.count == 7 { return .daily }
        if selectedDays == Set([2, 3, 4, 5, 6]) { return .weekdays }
        if selectedDays == Set([1, 7]) { return .weekends }
        if selectedDays.isEmpty { return .daily }
        return .custom(days: selectedDays.sorted())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        nameSection
                        iconSection
                        colorSection
                        scheduleSection
                        timesPerDaySection
                        reminderSection
                        healthKitSection
                    }
                    .padding(HabitraTheme.screenPadding)
                    .padding(.bottom, 100)
                }

                // Floating save button
                VStack {
                    Spacer()
                    HabitraButton(isEditing ? "Save Changes" : "Create Habit", icon: "checkmark") {
                        saveHabit()
                    }
                    .padding(.horizontal, HabitraTheme.screenPadding)
                    .padding(.bottom, HabitraTheme.screenPadding)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                }
            }
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.habitraTextSecondary)
                }
            }
            .onAppear { populateFromEditing() }
        }
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HABIT NAME").habitraCaption().sectionHeaderAccessibility()
            TextField("e.g. Meditate", text: $name)
                .font(HabitraFont.headline())
                .foregroundStyle(Color.habitraTextPrimary)
                .padding(14)
                .background(Color.habitraSurface)
                .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
                .overlay(
                    RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                        .stroke(Color.habitraAccent.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // MARK: - Icon

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ICON").habitraCaption().sectionHeaderAccessibility()
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5),
                spacing: 10
            ) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundStyle(
                                selectedIcon == icon
                                    ? Color(hex: selectedColorHex)
                                    : Color.habitraTextTertiary
                            )
                            .frame(width: 48, height: 48)
                            .background(
                                selectedIcon == icon
                                    ? Color(hex: selectedColorHex).opacity(0.15)
                                    : Color.habitraSurface
                            )
                            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
                            .overlay(
                                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                                    .stroke(
                                        selectedIcon == icon
                                            ? Color(hex: selectedColorHex).opacity(0.5)
                                            : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(iconAccessibilityLabel(for: icon))
                    .accessibilityAddTraits(selectedIcon == icon ? [.isButton, .isSelected] : .isButton)
                }
            }
        }
    }

    // MARK: - Color

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COLOR").habitraCaption().sectionHeaderAccessibility()
            HStack(spacing: 12) {
                ForEach(Color.habitPresets, id: \.self) { color in
                    let hex = color.hexString ?? "6C63FF"
                    Button {
                        selectedColorHex = hex
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.9), lineWidth: selectedColorHex == hex ? 2.5 : 0)
                                    .padding(2)
                            )
                            .scaleEffect(selectedColorHex == hex ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedColorHex)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(colorAccessibilityLabel(for: hex))
                    .accessibilityAddTraits(selectedColorHex == hex ? [.isButton, .isSelected] : .isButton)
                }
            }
        }
    }

    // MARK: - Schedule (day-of-week chips)

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SCHEDULE").habitraCaption().sectionHeaderAccessibility()
                Spacer()
                Text(derivedFrequency.displayName)
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraAccent)
            }

            HStack(spacing: 0) {
                ForEach(1...7, id: \.self) { day in
                    let isOn = selectedDays.contains(day)
                    Button {
                        // Prevent deselecting the last day
                        if isOn && selectedDays.count == 1 { return }
                        if isOn { selectedDays.remove(day) } else { selectedDays.insert(day) }
                    } label: {
                        Text(dayLabel(for: day))
                            .font(HabitraFont.caption())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundStyle(isOn ? .white : Color.habitraTextTertiary)
                            .background(isOn ? Color(hex: selectedColorHex) : Color.habitraSurface)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(fullDayName(for: day))
                    .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
                    .animation(.easeInOut(duration: 0.15), value: isOn)

                    if day < 7 {
                        Divider()
                            .frame(height: 32)
                            .background(Color.habitraAccent.opacity(0.1))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                    .stroke(Color.habitraAccent.opacity(0.15), lineWidth: 1)
            )
        }
    }

    // MARK: - Times Per Day

    private var timesPerDaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TIMES PER DAY").habitraCaption().sectionHeaderAccessibility()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(targetCompletionsPerDay == 1 ? "Once per day" : "\(targetCompletionsPerDay)× per day")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextPrimary)
                    if targetCompletionsPerDay > 1 {
                        Text("Tap habit \(targetCompletionsPerDay) times to complete")
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)
                    }
                }

                Spacer()

                HStack(spacing: 20) {
                    Button {
                        if targetCompletionsPerDay > 1 { targetCompletionsPerDay -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(targetCompletionsPerDay > 1 ? Color.habitraAccent : Color.habitraAccent.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Decrease times per day")

                    Text("\(targetCompletionsPerDay)")
                        .font(HabitraFont.title())
                        .foregroundStyle(Color.habitraTextPrimary)
                        .frame(minWidth: 28)
                        .accessibilityLabel("Times per day")
                        .accessibilityValue("\(targetCompletionsPerDay)")

                    Button {
                        if targetCompletionsPerDay < 20 { targetCompletionsPerDay += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.habitraAccent)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Increase times per day")
                }
            }
            .habitraCard()
        }
    }

    // MARK: - Reminder

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("REMINDER").habitraCaption().sectionHeaderAccessibility()

            VStack(spacing: 0) {
                // Toggle row
                Toggle(isOn: $hasReminder) {
                    Text(targetCompletionsPerDay > 1 ? "Enable reminders" : "Daily reminder")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextPrimary)
                }
                .tint(Color.habitraAccent)
                .padding(HabitraTheme.cardPadding)
                .onChange(of: hasReminder) { _, isOn in
                    if isOn { requestNotificationPermission() }
                }

                if hasReminder {
                    Divider().padding(.horizontal, HabitraTheme.cardPadding)

                    if targetCompletionsPerDay == 1 {
                        // Single reminder — just a time picker
                        DatePicker(
                            "Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextPrimary)
                        .tint(Color.habitraAccent)
                        .padding(HabitraTheme.cardPadding)
                    } else {
                        // Interval reminder — every N hours/minutes + start time
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Text("Every")
                                    .font(HabitraFont.body())
                                    .foregroundStyle(Color.habitraTextPrimary)

                                Spacer()

                                HStack(spacing: 12) {
                                    Button {
                                        if reminderIntervalValue > 1 { reminderIntervalValue -= 1 }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(reminderIntervalValue > 1 ? Color.habitraAccent : Color.habitraAccent.opacity(0.6))
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Decrease reminder interval")

                                    Text("\(reminderIntervalValue)")
                                        .font(HabitraFont.headline())
                                        .foregroundStyle(Color.habitraTextPrimary)
                                        .frame(minWidth: 24)
                                        .accessibilityLabel("Reminder interval")
                                        .accessibilityValue("\(reminderIntervalValue) \(reminderIntervalUnit.rawValue.lowercased())")

                                    Button {
                                        let max = reminderIntervalUnit == .hours ? 12 : 59
                                        if reminderIntervalValue < max { reminderIntervalValue += 1 }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(Color.habitraAccent)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Increase reminder interval")
                                }

                                Picker("", selection: $reminderIntervalUnit) {
                                    ForEach(ReminderUnit.allCases) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 150)
                                .onChange(of: reminderIntervalUnit) { _, _ in
                                    // Clamp value to sensible range on unit change
                                    reminderIntervalValue = reminderIntervalUnit == .hours
                                        ? min(reminderIntervalValue, 12)
                                        : min(reminderIntervalValue * 60, 59)
                                }
                            }
                            .padding(HabitraTheme.cardPadding)

                            Divider().padding(.horizontal, HabitraTheme.cardPadding)

                            DatePicker(
                                "Starting at",
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                            .font(HabitraFont.body())
                            .foregroundStyle(Color.habitraTextPrimary)
                            .tint(Color.habitraAccent)
                            .padding(HabitraTheme.cardPadding)

                            // Preview of scheduled times
                            let preview = intervalPreview()
                            if !preview.isEmpty {
                                Divider().padding(.horizontal, HabitraTheme.cardPadding)
                                HStack(spacing: 6) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.habitraAccent)
                                    Text(preview)
                                        .font(HabitraFont.footnote())
                                        .foregroundStyle(Color.habitraTextTertiary)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, HabitraTheme.cardPadding)
                                .padding(.bottom, HabitraTheme.cardPadding)
                            }
                        }
                    }
                }
            }
            .background(Color.habitraSurface)
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                    .stroke(Color.habitraAccent.opacity(0.12), lineWidth: 1)
            )
        }
    }

    // MARK: - Apple Health

    /// Summary text for the linked sources.
    private var linkedSourcesSummary: String {
        let sources = healthKitSources.sorted { $0.displayName < $1.displayName }
        if sources.count == 1 {
            return sources.first?.displayName ?? ""
        } else if sources.count <= 3 {
            return sources.map(\.displayName).joined(separator: ", ")
        } else {
            let first2 = sources.prefix(2).map(\.displayName).joined(separator: ", ")
            return "\(first2) +\(sources.count - 2) more"
        }
    }

    /// Primary icon for linked sources header.
    private var linkedSourcesIcon: String {
        if healthKitSources.count == 1 {
            return healthKitSources.first?.icon ?? "figure.mixed.cardio"
        }
        return "figure.mixed.cardio"
    }

    /// Whether selected sources contain any workout-based type.
    private var hasWorkoutSourceSelected: Bool {
        healthKitSources.contains(where: { $0.isWorkoutBased })
    }

    /// The single non-workout source if exactly one is selected, nil otherwise.
    private var singleNonWorkoutSource: HabitHealthSource? {
        let nonWorkout = healthKitSources.filter { !$0.isWorkoutBased }
        return nonWorkout.count == 1 && healthKitSources.count == 1 ? nonWorkout.first : nil
    }

    @ViewBuilder
    private var healthKitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("APPLE HEALTH").habitraCaption().sectionHeaderAccessibility()

            if !SubscriptionManager.canUseHealthKit {
                HStack(spacing: HabitraTheme.spacing) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.habitraHabitPink.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(Color.habitraHabitPink.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("Auto-complete from Health app — Pro feature")
                        .font(HabitraFont.body())
                        .foregroundStyle(Color.habitraTextTertiary)
                }
                .habitraCard()
            } else if !healthKitSources.isEmpty {
                // LINKED STATE — show current sources + Remove button, then threshold
                VStack(spacing: 0) {
                    HStack(spacing: HabitraTheme.spacing) {
                        Image(systemName: linkedSourcesIcon)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.habitraHabitPink)
                            .frame(width: 32, height: 32)
                            .background(Color.habitraHabitPink.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Linked to \(linkedSourcesSummary)")
                                .font(HabitraFont.body())
                                .foregroundStyle(Color.habitraTextPrimary)
                                .lineLimit(2)
                            Text("Auto-completes when Health records a match")
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary)
                        }

                        Spacer()

                        Button {
                            withHabitraAnimation(.easeInOut(duration: 0.2)) {
                                healthKitSources = []
                            }
                        } label: {
                            Text("Remove")
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraDanger)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.habitraDanger.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(HabitraTheme.cardPadding)

                    Divider().padding(.horizontal, HabitraTheme.cardPadding)

                    // Threshold control beneath the linked header
                    thresholdControl
                        .padding(HabitraTheme.cardPadding)

                    Divider().padding(.horizontal, HabitraTheme.cardPadding)

                    // Change link button
                    Button {
                        withHabitraAnimation(.easeInOut(duration: 0.2)) {
                            showHealthSection = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 13))
                            Text("Change Activity Types")
                                .font(HabitraFont.body())
                        }
                        .foregroundStyle(Color.habitraAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, HabitraTheme.cardPadding)

                    // Inline picker — shown when "Change" is tapped
                    if showHealthSection {
                        Divider().padding(.horizontal, HabitraTheme.cardPadding)
                        healthSourceGrid
                            .padding(HabitraTheme.cardPadding)
                    }
                }
                .background(Color.habitraSurface)
                .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                        .stroke(Color.habitraHabitPink.opacity(0.3), lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: showHealthSection)

            } else {
                // NOT LINKED STATE — show grid directly, no collapse
                VStack(spacing: 0) {
                    HStack(spacing: HabitraTheme.spacing) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.habitraHabitPink.opacity(0.5))
                            .frame(width: 32, height: 32)
                            .background(Color.habitraHabitPink.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Not linked — select activities below")
                                .font(HabitraFont.body())
                                .foregroundStyle(Color.habitraTextTertiary)
                            Text("Tap one or more workouts to auto-complete")
                                .font(HabitraFont.footnote())
                                .foregroundStyle(Color.habitraTextTertiary.opacity(0.7))
                        }
                    }
                    .padding(HabitraTheme.cardPadding)

                    Divider().padding(.horizontal, HabitraTheme.cardPadding)

                    healthSourceGridWithoutNone
                        .padding(HabitraTheme.cardPadding)
                }
                .background(Color.habitraSurface)
                .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                        .stroke(Color.habitraAccent.opacity(0.12), lineWidth: 1)
                )
            }
        }
    }

    /// Grid shown inside the "change" expander when already linked — includes all sources.
    @ViewBuilder
    private var healthSourceGrid: some View {
        healthSourceButtons(sources: HabitHealthSource.allCases.filter { $0 != .none })
    }

    /// Grid shown in the "not linked" state — no None option needed.
    @ViewBuilder
    private var healthSourceGridWithoutNone: some View {
        healthSourceButtons(sources: HabitHealthSource.allCases.filter { $0 != .none })
    }

    /// Handles selection logic: workout types are multi-select, non-workout types are single-select
    /// and mutually exclusive with workout selections. "Any Workout" clears specific workouts and vice versa.
    private func toggleHealthSource(_ source: HabitHealthSource) {
        withHabitraAnimation(.easeInOut(duration: 0.15)) {
            if source.isWorkoutBased && source != .anyWorkout {
                // Specific workout: toggle it, clear non-workout sources & anyWorkout
                healthKitSources.subtract([.mindfulness, .sleep, .steps, .anyWorkout])
                if healthKitSources.contains(source) {
                    healthKitSources.remove(source)
                } else {
                    healthKitSources.insert(source)
                }
            } else if source == .anyWorkout {
                // Any Workout: exclusive — clears everything else
                if healthKitSources.contains(.anyWorkout) {
                    healthKitSources.remove(.anyWorkout)
                } else {
                    healthKitSources = [.anyWorkout]
                }
                showHealthSection = false
            } else {
                // Non-workout (mindfulness, sleep, steps): exclusive single-select
                if healthKitSources.contains(source) {
                    healthKitSources.remove(source)
                } else {
                    healthKitSources = [source]
                }
                showHealthSection = false
            }
        }

        // Adjust duration defaults
        if healthKitSources.contains(.sleep) && minHealthKitDuration < 60 {
            minHealthKitDuration = 420
        } else if !healthKitSources.contains(.sleep) && minHealthKitDuration > 120 {
            minHealthKitDuration = 15
        }
    }

    private func healthSourceButtons(sources: [HabitHealthSource]) -> some View {
        VStack(spacing: 12) {
            // Workout types section header
            HStack {
                Text("Workouts")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
                Text("— select one or more")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary.opacity(0.6))
                Spacer()
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                spacing: 8
            ) {
                // Workout-based sources (excluding anyWorkout, shown separately)
                ForEach(sources.filter { $0.isWorkoutBased && $0 != .anyWorkout }) { source in
                    healthSourceButton(source)
                }
                // Any Workout at end of workout section
                ForEach(sources.filter { $0 == .anyWorkout }) { source in
                    healthSourceButton(source)
                }
            }

            Divider().padding(.vertical, 4)

            // Non-workout types section header
            HStack {
                Text("Other")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary)
                Text("— single select")
                    .font(HabitraFont.footnote())
                    .foregroundStyle(Color.habitraTextTertiary.opacity(0.6))
                Spacer()
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                spacing: 8
            ) {
                ForEach(sources.filter { !$0.isWorkoutBased }) { source in
                    healthSourceButton(source)
                }
            }
        }
    }

    private func healthSourceButton(_ source: HabitHealthSource) -> some View {
        let isSelected = healthKitSources.contains(source)
        return Button {
            toggleHealthSource(source)
        } label: {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: source.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected ? Color.habitraHabitPink : Color.habitraTextTertiary)
                        .frame(maxWidth: .infinity)
                    // Multi-select checkmark for workout types
                    if isSelected && source.isWorkoutBased && source != .anyWorkout {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.habitraHabitPink)
                            .offset(x: 2, y: -2)
                    }
                }
                Text(source.displayName
                        .replacingOccurrences(of: " / ", with: "/")
                        .replacingOccurrences(of: " Training", with: "")
                )
                .font(HabitraFont.footnote())
                .foregroundStyle(isSelected ? Color.habitraTextPrimary : Color.habitraTextTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.habitraHabitPink.opacity(0.12) : Color.habitraSurfaceLight)
            .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                    .stroke(
                        isSelected ? Color.habitraHabitPink.opacity(0.5) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var thresholdControl: some View {
        if healthKitSources.contains(.steps) {
            HStack {
                Text("Step goal")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                Spacer()
                HStack(spacing: 16) {
                    Button { healthKitStepGoal = max(1000, healthKitStepGoal - 1000) } label: {
                        Image(systemName: "minus.circle.fill").font(.system(size: 24)).foregroundStyle(Color.habitraAccent)
                    }.buttonStyle(.plain)
                    .accessibilityLabel("Decrease step goal")
                    Text("\(healthKitStepGoal / 1000)k")
                        .font(HabitraFont.headline()).foregroundStyle(Color.habitraTextPrimary).frame(minWidth: 36)
                        .accessibilityLabel("Step goal")
                        .accessibilityValue("\(healthKitStepGoal) steps")
                    Button { healthKitStepGoal = min(50000, healthKitStepGoal + 1000) } label: {
                        Image(systemName: "plus.circle.fill").font(.system(size: 24)).foregroundStyle(Color.habitraAccent)
                    }.buttonStyle(.plain)
                    .accessibilityLabel("Increase step goal")
                }
            }
        } else if healthKitSources.contains(.sleep) {
            HStack {
                Text("Minimum sleep")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                Spacer()
                HStack(spacing: 16) {
                    Button { minHealthKitDuration = max(240, minHealthKitDuration - 30) } label: {
                        Image(systemName: "minus.circle.fill").font(.system(size: 24)).foregroundStyle(Color.habitraAccent)
                    }.buttonStyle(.plain)
                    .accessibilityLabel("Decrease minimum sleep")
                    Text("\(minHealthKitDuration / 60) hr")
                        .font(HabitraFont.headline()).foregroundStyle(Color.habitraTextPrimary).frame(minWidth: 44)
                        .accessibilityLabel("Minimum sleep")
                        .accessibilityValue("\(minHealthKitDuration / 60) hours")
                    Button { minHealthKitDuration = min(600, minHealthKitDuration + 30) } label: {
                        Image(systemName: "plus.circle.fill").font(.system(size: 24)).foregroundStyle(Color.habitraAccent)
                    }.buttonStyle(.plain)
                    .accessibilityLabel("Increase minimum sleep")
                }
            }
        } else {
            HStack {
                Text("Minimum duration")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                Spacer()
                HStack(spacing: 16) {
                    Button { minHealthKitDuration = max(5, minHealthKitDuration - 5) } label: {
                        Image(systemName: "minus.circle.fill").font(.system(size: 24)).foregroundStyle(Color.habitraAccent)
                    }.buttonStyle(.plain)
                    .accessibilityLabel("Decrease minimum duration")
                    Text("\(minHealthKitDuration) min")
                        .font(HabitraFont.headline()).foregroundStyle(Color.habitraTextPrimary).frame(minWidth: 56)
                        .accessibilityLabel("Minimum duration")
                        .accessibilityValue("\(minHealthKitDuration) minutes")
                    Button { minHealthKitDuration = min(180, minHealthKitDuration + 5) } label: {
                        Image(systemName: "plus.circle.fill").font(.system(size: 24)).foregroundStyle(Color.habitraAccent)
                    }.buttonStyle(.plain)
                    .accessibilityLabel("Increase minimum duration")
                }
            }
        }
    }

    // MARK: - Helpers

    private func dayLabel(for weekday: Int) -> String {
        // 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
        ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"][weekday - 1]
    }

    private func fullDayName(for weekday: Int) -> String {
        ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][weekday - 1]
    }

    private func iconAccessibilityLabel(for icon: String) -> String {
        let mapping: [String: String] = [
            "figure.run": "Running",
            "dumbbell.fill": "Weightlifting",
            "brain.head.profile": "Brain",
            "book.fill": "Reading",
            "drop.fill": "Water",
            "bed.double.fill": "Sleep",
            "leaf.fill": "Nature",
            "heart.fill": "Heart",
            "pencil.and.outline": "Writing",
            "music.note": "Music",
            "cup.and.saucer.fill": "Tea",
            "fork.knife": "Eating",
            "pills.fill": "Medication",
            "sun.max.fill": "Sun",
            "moon.fill": "Moon",
            "phone.down.fill": "Phone down",
            "laptopcomputer": "Computer",
            "paintpalette.fill": "Art",
            "dog.fill": "Dog",
            "figure.yoga": "Yoga"
        ]
        return mapping[icon] ?? icon
    }

    private func colorAccessibilityLabel(for hex: String) -> String {
        let mapping: [String: String] = [
            "6C63FF": "Purple",
            "3B82F6": "Blue",
            "22D3EE": "Cyan",
            "4ADE80": "Green",
            "FBBF24": "Yellow",
            "FB923C": "Orange",
            "F472B6": "Pink",
            "F87171": "Red"
        ]
        return mapping[hex.uppercased()] ?? "Color"
    }

    /// Generates a human-readable preview of reminder times for interval mode.
    private func intervalPreview() -> String {
        guard targetCompletionsPerDay > 1 else { return "" }
        let intervalMins = reminderIntervalValue * reminderIntervalUnit.multiplier
        guard intervalMins > 0 else { return "" }

        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: reminderTime)
        let startMinute = calendar.component(.minute, from: reminderTime)

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        var times: [String] = []
        var total = startHour * 60 + startMinute
        let count = min(targetCompletionsPerDay, 4) // show first 4

        for _ in 0..<count {
            let h = (total / 60) % 24
            let m = total % 60
            var components = DateComponents()
            components.hour = h
            components.minute = m
            if let date = calendar.date(from: components) {
                times.append(formatter.string(from: date))
            }
            total += intervalMins
        }

        let suffix = targetCompletionsPerDay > 4 ? "…" : ""
        return times.joined(separator: ", ") + suffix
    }

    private func populateFromEditing() {
        guard let habit = editingHabit else { return }
        name = habit.name
        selectedIcon = habit.icon
        selectedColorHex = habit.colorHex
        selectedDays = habit.frequency.scheduledDays
        hasReminder = habit.reminderTime != nil
        targetCompletionsPerDay = habit.targetCompletionsPerDay
        if let reminder = habit.reminderTime {
            reminderTime = reminder
        }
        let intervalMins = habit.reminderIntervalMinutes
        if intervalMins > 0 {
            if intervalMins % 60 == 0 {
                reminderIntervalValue = intervalMins / 60
                reminderIntervalUnit = .hours
            } else {
                reminderIntervalValue = intervalMins
                reminderIntervalUnit = .minutes
            }
        }
        healthKitSources = habit.healthKitSources
        minHealthKitDuration = habit.minHealthKitDurationMinutes
        healthKitStepGoal = habit.healthKitStepGoal
        showHealthSection = false  // "change" expander always starts collapsed
    }

    private func saveHabit() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let vm = HabitViewModel(modelContext: modelContext)
        let reminder = hasReminder ? reminderTime : nil
        let intervalMinutes = hasReminder && targetCompletionsPerDay > 1
            ? reminderIntervalValue * reminderIntervalUnit.multiplier
            : 0

        if let habit = editingHabit {
            vm.updateHabit(
                habit,
                name: trimmedName,
                icon: selectedIcon,
                colorHex: selectedColorHex,
                frequency: derivedFrequency,
                reminderTime: reminder,
                reminderIntervalMinutes: intervalMinutes,
                category: nil,
                targetCompletionsPerDay: targetCompletionsPerDay,
                healthKitSources: healthKitSources,
                minHealthKitDurationMinutes: minHealthKitDuration,
                healthKitStepGoal: healthKitStepGoal
            )
            if reminder != nil {
                NotificationManager.shared.scheduleReminder(for: habit)
            } else {
                NotificationManager.shared.removeReminder(for: habit)
            }
        } else {
            vm.createHabit(
                name: trimmedName,
                icon: selectedIcon,
                colorHex: selectedColorHex,
                frequency: derivedFrequency,
                reminderTime: reminder,
                reminderIntervalMinutes: intervalMinutes,
                category: nil,
                targetCompletionsPerDay: targetCompletionsPerDay,
                healthKitSources: healthKitSources,
                minHealthKitDurationMinutes: minHealthKitDuration,
                healthKitStepGoal: healthKitStepGoal
            )
            if reminder != nil {
                let allHabits = vm.fetchActiveHabits()
                if let newHabit = allHabits.first(where: { $0.name == trimmedName && $0.reminderTime != nil }) {
                    NotificationManager.shared.scheduleReminder(for: newHabit)
                }
            }
        }
        dismiss()
    }

    private func requestNotificationPermission() {
        Task {
            let granted = await NotificationManager.shared.requestPermission()
            if !granted { hasReminder = false }
        }
    }
}

// MARK: - Preview

#Preview {
    HabitFormView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self], inMemory: true)
}
