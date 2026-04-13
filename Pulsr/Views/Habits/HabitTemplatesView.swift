//
//  HabitTemplatesView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import SwiftData

// MARK: - Template Data Model

private struct HabitTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let colorHex: String
    let frequency: HabitFrequency
}

private struct TemplateSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let templates: [HabitTemplate]
}

// MARK: - View

struct HabitTemplatesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var createdTemplateName: String?
    @State private var showCreatedConfirmation = false
    @State private var showingLimitAlert = false

    private var viewModel: HabitViewModel {
        HabitViewModel(modelContext: modelContext)
    }

    // MARK: - Template Data

    private let sections: [TemplateSection] = [
        TemplateSection(title: "Health", icon: "heart.fill", templates: [
            HabitTemplate(name: "Exercise", icon: "figure.run", colorHex: "4ADE80", frequency: .daily),
            HabitTemplate(name: "Drink Water", icon: "drop.fill", colorHex: "22D3EE", frequency: .daily),
            HabitTemplate(name: "Take Vitamins", icon: "pills.fill", colorHex: "FB923C", frequency: .daily),
            HabitTemplate(name: "Sleep 8 Hours", icon: "bed.double.fill", colorHex: "6C63FF", frequency: .daily),
        ]),
        TemplateSection(title: "Mindfulness", icon: "brain.head.profile", templates: [
            HabitTemplate(name: "Meditate", icon: "brain.head.profile", colorHex: "6C63FF", frequency: .daily),
            HabitTemplate(name: "Journal", icon: "pencil.and.outline", colorHex: "FBBF24", frequency: .daily),
            HabitTemplate(name: "Gratitude", icon: "heart.fill", colorHex: "F472B6", frequency: .daily),
            HabitTemplate(name: "Deep Breathing", icon: "wind", colorHex: "22D3EE", frequency: .daily),
        ]),
        TemplateSection(title: "Productivity", icon: "bolt.fill", templates: [
            HabitTemplate(name: "Read 30 min", icon: "book.fill", colorHex: "3B82F6", frequency: .daily),
            HabitTemplate(name: "No Phone Before Bed", icon: "phone.down.fill", colorHex: "F87171", frequency: .daily),
            HabitTemplate(name: "Plan Tomorrow", icon: "list.bullet", colorHex: "FB923C", frequency: .weekdays),
            HabitTemplate(name: "Learn Something New", icon: "lightbulb.fill", colorHex: "FBBF24", frequency: .weekdays),
        ]),
        TemplateSection(title: "Self-Care", icon: "sparkles", templates: [
            HabitTemplate(name: "Skincare Routine", icon: "sparkles", colorHex: "F472B6", frequency: .daily),
            HabitTemplate(name: "Walk Outside", icon: "figure.walk", colorHex: "4ADE80", frequency: .daily),
            HabitTemplate(name: "Screen Break", icon: "eye.fill", colorHex: "3B82F6", frequency: .weekdays),
            HabitTemplate(name: "Stretch", icon: "figure.yoga", colorHex: "FB923C", frequency: .daily),
        ]),
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.habitraBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HabitraTheme.spacingLarge) {
                        ForEach(sections) { section in
                            sectionView(section)
                        }
                    }
                    .padding(HabitraTheme.screenPadding)
                    .padding(.bottom, HabitraTheme.spacingLarge)
                }

                // MARK: - Created Confirmation Overlay
                if showCreatedConfirmation, let name = createdTemplateName {
                    VStack {
                        Spacer()

                        HStack(spacing: HabitraTheme.spacingSmall) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.habitraSuccess)
                            Text("Created!")
                                .font(HabitraFont.headline())
                                .foregroundStyle(Color.habitraTextPrimary)
                            Text(name)
                                .font(HabitraFont.body())
                                .foregroundStyle(Color.habitraTextSecondary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, HabitraTheme.spacingLarge)
                        .padding(.vertical, HabitraTheme.spacing)
                        .background(Color.habitraSurface)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
                        .padding(.bottom, HabitraTheme.spacingLarge)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.habitraTextSecondary)
                }
            }
            .alert("Habit Limit Reached", isPresented: $showingLimitAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You can track up to \(HabitViewModel.freeHabitLimit) habits in this release. Focused is better — pick the ones that matter most. More capacity is on the roadmap.")
            }
        }
    }

    // MARK: - Section View

    @ViewBuilder
    private func sectionView(_ section: TemplateSection) -> some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            HStack(spacing: HabitraTheme.spacingSmall) {
                Image(systemName: section.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.habitraTextTertiary)
                Text(section.title.uppercased())
                    .habitraCaption()
                    .sectionHeaderAccessibility()
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: HabitraTheme.spacing),
                    GridItem(.flexible(), spacing: HabitraTheme.spacing),
                ],
                spacing: HabitraTheme.spacing
            ) {
                ForEach(section.templates) { template in
                    templateCard(template)
                }
            }
        }
    }

    // MARK: - Template Card

    @ViewBuilder
    private func templateCard(_ template: HabitTemplate) -> some View {
        Button {
            createHabit(from: template)
        } label: {
            VStack(spacing: HabitraTheme.spacingSmall) {
                Image(systemName: template.icon)
                    .font(.system(size: 26))
                    .foregroundStyle(Color(hex: template.colorHex))
                    .frame(width: 48, height: 48)
                    .background(Color(hex: template.colorHex).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))

                Text(template.name)
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(template.frequency.displayName)
                    .font(HabitraFont.caption())
                    .foregroundStyle(Color.habitraTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HabitraTheme.spacing)
            .habitraCard(padding: HabitraTheme.spacingSmall)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func createHabit(from template: HabitTemplate) {
        let vm = viewModel

        guard vm.canCreateHabit else {
            showingLimitAlert = true
            return
        }

        vm.createHabit(
            name: template.name,
            icon: template.icon,
            colorHex: template.colorHex,
            frequency: template.frequency,
            reminderTime: nil,
            category: nil
        )

        HapticManager.success()

        createdTemplateName = template.name
        withHabitraAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showCreatedConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    HabitTemplatesView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self], inMemory: true)
}
