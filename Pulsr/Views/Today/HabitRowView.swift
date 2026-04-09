//
//  HabitRowView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//  Updated: Multi-completion progress indicator
//

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let onToggle: () -> Void
    var onEdit: (() -> Void)? = nil

    private var isCompleted: Bool {
        habit.isCompleted(on: Date())
    }

    private var isPartial: Bool {
        habit.isPartiallyCompleted(on: Date())
    }

    private var completionCount: Int {
        habit.completionCount(on: Date())
    }

    private var target: Int {
        habit.targetCompletionsPerDay
    }

    private var habitColor: Color {
        Color(hex: habit.colorHex)
    }

    /// True when today's completion was auto-logged by HealthKit.
    private var isAutoCompleted: Bool {
        let calendar = Calendar.current
        return habit.completions.contains {
            calendar.isDate($0.completedDate, inSameDayAs: Date()) && $0.isAutoCompleted
        }
    }

    @State private var showPulse = false
    @State private var rowScale: CGFloat = 1.0
    @State private var iconScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: HabitraTheme.spacing) {
            // Habit icon — tap to edit
            Button {
                onEdit?()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                        .fill(habitColor.opacity(isCompleted ? 0.2 : 0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: habit.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(habitColor.opacity(isCompleted ? 0.5 : 1.0))
                        .scaleEffect(iconScale)
                }
            }
            .buttonStyle(.plain)

            // Habit info — tap to edit
            Button {
                onEdit?()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(HabitraFont.headline())
                        .foregroundStyle(
                            isCompleted ? Color.habitraTextTertiary : Color.habitraTextPrimary
                        )
                        .strikethrough(isCompleted, color: .habitraTextTertiary)

                    HStack(spacing: 6) {
                        Text(habit.frequency.displayName)
                            .font(HabitraFont.footnote())
                            .foregroundStyle(Color.habitraTextTertiary)

                        // HealthKit linked indicator
                        if habit.hasHealthKitSource {
                            Image(systemName: habit.healthKitSources.count == 1
                                ? (habit.healthKitSources.first?.icon ?? "heart.fill")
                                : "figure.mixed.cardio")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.habitraHabitPink.opacity(0.6))
                        }

                        // Multi-completion counter
                        if habit.isMultiCompletion {
                            Text("\(completionCount) of \(target)")
                                .font(HabitraFont.footnote())
                                .foregroundStyle(
                                    isCompleted
                                        ? habitColor.opacity(0.7)
                                        : isPartial
                                            ? habitColor
                                            : Color.habitraTextTertiary
                                )
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Apple Health auto-complete badge
            if isAutoCompleted {
                Image(systemName: "heart.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.habitraHabitPink)
                    .padding(5)
                    .background(Color.habitraHabitPink.opacity(0.12))
                    .clipShape(Circle())
                    .help("Auto-completed from Apple Health")
            }

            // Streak badge
            StreakBadge(count: habit.currentStreak, color: habitColor)

            // Completion button
            Button(action: {
                triggerCompletion()
            }) {
                ZStack {
                    // Pulse ripple animation
                    if showPulse {
                        Circle()
                            .stroke(habitColor.opacity(0.4), lineWidth: 2)
                            .frame(width: 40, height: 40)
                            .scaleEffect(showPulse ? 1.5 : 1.0)
                            .opacity(showPulse ? 0.0 : 1.0)
                    }

                    if habit.isMultiCompletion {
                        // Multi-completion: ring progress + count
                        ZStack {
                            Circle()
                                .stroke(Color.habitraTextTertiary.opacity(0.15), lineWidth: 3)
                                .frame(width: 30, height: 30)

                            Circle()
                                .trim(from: 0, to: habit.completionProgress(on: Date()))
                                .stroke(
                                    isCompleted ? Color.habitraVital : habitColor,
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                .frame(width: 30, height: 30)
                                .rotationEffect(.degrees(-90))

                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.habitraVital)
                                    .transition(.scale)
                            } else {
                                Text("\(completionCount)")
                                    .font(HabitraFont.footnote())
                                    .foregroundStyle(completionCount > 0 ? habitColor : Color.habitraTextTertiary)
                            }
                        }
                        .animation(HabitraTheme.springAnimation, value: completionCount)
                    } else {
                        // Single completion: warm vital color when done
                        Circle()
                            .stroke(
                                isCompleted ? Color.habitraVital : Color.habitraTextTertiary.opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 28, height: 28)

                        if isCompleted {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.habitraVital, Color.habitraVital.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 28, height: 28)
                                .transition(.scale.combined(with: .opacity))

                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .transition(.scale)
                        }
                    }
                }
                .animation(HabitraTheme.springAnimation, value: isCompleted)
            }
            .buttonStyle(.plain)
        }
        .habitraCard(tintColor: habitColor)
        .scaleEffect(rowScale)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(accessibilityHintText)
        .accessibilityAddTraits(isCompleted ? .isSelected : [])
    }

    private var accessibilityLabelText: String {
        var label = "\(habit.name), \(habit.frequency.displayName)"
        if habit.isMultiCompletion {
            label += ", \(completionCount) of \(target) completed"
        } else {
            label += ", \(isCompleted ? "completed" : "not completed")"
        }
        if isAutoCompleted {
            label += ", auto-completed from Apple Health"
        }
        if habit.currentStreak > 0 {
            label += ", \(habit.currentStreak) day streak"
        }
        return label
    }

    private var accessibilityHintText: String {
        if habit.isMultiCompletion {
            if isCompleted {
                return "Double tap to reset all completions"
            } else {
                return "Double tap to add one completion"
            }
        }
        return isCompleted ? "Double tap to uncomplete" : "Double tap to mark as complete"
    }

    private func triggerCompletion() {
        if habit.isMultiCompletion {
            if isCompleted {
                HapticManager.habitUncompleted()
            } else {
                HapticManager.habitCompleted()
                animateCompletion()
            }
        } else {
            if !isCompleted {
                HapticManager.habitCompleted()
                animateCompletion()
            } else {
                HapticManager.habitUncompleted()
            }
        }
        onToggle()
    }

    private func animateCompletion() {
        // Pulse ripple
        withHabitraAnimation(.easeOut(duration: 0.6)) { showPulse = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showPulse = false }

        // Row spring compress → release
        withHabitraAnimation(.spring(response: 0.18, dampingFraction: 0.7)) { rowScale = 0.96 }
        withHabitraAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.1)) { rowScale = 1.0 }

        // Icon pop
        withHabitraAnimation(.spring(response: 0.15, dampingFraction: 0.5)) { iconScale = 1.22 }
        withHabitraAnimation(.spring(response: 0.35, dampingFraction: 0.55).delay(0.12)) { iconScale = 1.0 }
    }
}

#Preview {
    ZStack {
        Color.habitraBackground.ignoresSafeArea()

        VStack(spacing: 12) {
            HabitRowView(
                habit: {
                    let h = Habit(name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF")
                    return h
                }(),
                onToggle: {},
                onEdit: {}
            )

            HabitRowView(
                habit: {
                    let h = Habit(name: "Drink Water", icon: "drop.fill", colorHex: "22D3EE", targetCompletionsPerDay: 8)
                    return h
                }(),
                onToggle: {},
                onEdit: {}
            )

            HabitRowView(
                habit: {
                    let h = Habit(name: "Skincare", icon: "sparkles", colorHex: "F472B6", targetCompletionsPerDay: 2)
                    return h
                }(),
                onToggle: {},
                onEdit: {}
            )
        }
        .padding()
    }
}
