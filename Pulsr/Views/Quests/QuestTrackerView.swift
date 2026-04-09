//
//  QuestTrackerView.swift
//  Habitra
//
//  Displays active and completed quests — monthly challenge + weekly quests.
//  Pro-only feature with lock overlay for free users.
//

import SwiftUI
import SwiftData

struct QuestTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quest.startDate, order: .reverse)
    private var quests: [Quest]

    private var monthlyQuest: Quest? {
        quests.first { $0.questType == "monthly" && !$0.isExpired }
            ?? quests.first { $0.questType == "monthly" }
    }

    private var weeklyQuests: [Quest] {
        quests.filter { $0.questType == "weekly" && !$0.isExpired }
    }

    private var completedQuests: [Quest] {
        quests.filter { $0.isCompleted }.prefix(5).map { $0 }
    }

    var body: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HabitraTheme.spacingLarge) {
                    // Monthly Challenge
                    if let monthly = monthlyQuest {
                        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
                            Text("MONTHLY CHALLENGE")
                                .habitraCaption()
                                .sectionHeaderAccessibility()

                            questCard(monthly, isMonthly: true)
                        }
                        .padding(.horizontal, HabitraTheme.screenPadding)
                    }

                    // Weekly Quests
                    if !weeklyQuests.isEmpty {
                        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
                            Text("THIS WEEK")
                                .habitraCaption()
                                .sectionHeaderAccessibility()

                            ForEach(weeklyQuests) { quest in
                                questCard(quest, isMonthly: false)
                            }
                        }
                        .padding(.horizontal, HabitraTheme.screenPadding)
                    }

                    // Completed
                    if !completedQuests.isEmpty {
                        VStack(alignment: .leading, spacing: HabitraTheme.spacingSmall) {
                            Text("COMPLETED")
                                .habitraCaption()
                                .sectionHeaderAccessibility()

                            ForEach(completedQuests) { quest in
                                completedQuestCard(quest)
                            }
                        }
                        .padding(.horizontal, HabitraTheme.screenPadding)
                    }

                    if quests.isEmpty {
                        HabitraEmptyState(
                            icon: "target",
                            title: "No quests yet",
                            message: "Quests will appear at the start of each week and month."
                        )
                        .padding(.top, 40)
                    }
                }
                .padding(.top, HabitraTheme.spacing)
                .padding(.bottom, 100)
            }

            // Pro lock overlay
            if !SubscriptionManager.canUseQuests {
                proLockOverlay
            }
        }
        .navigationTitle("Quests")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            QuestGenerator.ensureCurrentQuests(context: modelContext)
        }
    }

    // MARK: - Quest Card

    private func questCard(_ quest: Quest, isMonthly: Bool) -> some View {
        VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
            HStack {
                Image(systemName: quest.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: quest.colorHex))

                VStack(alignment: .leading, spacing: 2) {
                    Text(quest.title)
                        .font(HabitraFont.headline())
                        .foregroundStyle(Color.habitraTextPrimary)
                    Text(quest.descriptionText)
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextSecondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("+\(quest.xpReward) XP")
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraVital)
                    Text("\(quest.daysRemaining)d left")
                        .font(.system(.caption2))
                        .foregroundStyle(quest.daysRemaining <= 2 ? Color.habitraDanger : Color.habitraTextTertiary)
                }
            }

            // Progress bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.habitraSurfaceLight)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: isMonthly
                                        ? [Color.habitraVital, Color.habitraVitalGlow]
                                        : [Color.habitraAccent, Color.habitraAccentGlow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geo.size.width * quest.progressFraction), height: 6)
                            .animation(.easeOut(duration: 0.5), value: quest.progressFraction)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(quest.currentValue)/\(quest.targetValue)")
                        .font(.system(.caption2))
                        .foregroundStyle(Color.habitraTextTertiary)
                    Spacer()
                    Text("\(Int(quest.progressFraction * 100))%")
                        .font(.system(.caption2))
                        .foregroundStyle(Color(hex: quest.colorHex))
                }
            }
        }
        .habitraCard(tintColor: isMonthly ? Color.habitraVital : nil)
        .overlay(
            isMonthly
                ? RoundedRectangle(cornerRadius: HabitraTheme.cornerRadius)
                    .stroke(Color.habitraVital.opacity(0.2), lineWidth: 1)
                : nil
        )
    }

    private func completedQuestCard(_ quest: Quest) -> some View {
        HStack(spacing: HabitraTheme.spacing) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.habitraHabitGreen)

            VStack(alignment: .leading, spacing: 2) {
                Text(quest.title)
                    .font(HabitraFont.headline())
                    .foregroundStyle(Color.habitraTextSecondary)
                if let completedAt = quest.completedAt {
                    Text(shortDate(completedAt))
                        .font(HabitraFont.footnote())
                        .foregroundStyle(Color.habitraTextTertiary)
                }
            }

            Spacer()

            Text("+\(quest.xpReward) XP")
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraVital.opacity(0.6))
        }
        .habitraCard()
        .opacity(0.7)
    }

    // MARK: - Pro Lock Overlay

    private var proLockOverlay: some View {
        ZStack {
            Color.habitraBackground.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: HabitraTheme.spacing) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.habitraAccent)

                Text("Quests are Pro")
                    .font(HabitraFont.title())
                    .foregroundStyle(Color.habitraTextPrimary)

                Text("Upgrade to unlock weekly and monthly challenges with XP rewards.")
                    .font(HabitraFont.body())
                    .foregroundStyle(Color.habitraTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack {
        QuestTrackerView()
            .modelContainer(for: [Quest.self, Habit.self, HabitCompletion.self, EarnedBadge.self], inMemory: true)
    }
}
