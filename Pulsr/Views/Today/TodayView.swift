//
//  TodayView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//  Phase 2 Week 3: Drag-to-reorder, milestone celebrations, habit notes, quick add
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.sortOrder)
    private var allHabits: [Habit]

    @State private var showingAddHabit = false
    @State private var showingTemplates = false
    @State private var editingHabit: Habit?
    @State private var showingLimitAlert = false
    @State private var showingPaywall = false
    @State private var isEditMode = false
    @State private var showingOtherHabits = false
    @AppStorage("smartSortEnabled") private var smartSortEnabled = false

    // Milestone celebration
    @State private var milestoneHabit: Habit?
    @State private var milestoneStreak: Int = 0
    @State private var showingMilestone = false

    // Habit notes
    @State private var noteHabit: Habit?
    @State private var noteCompletion: HabitCompletion?
    @State private var showingNoteSheet = false

    // AI coaching
    @State private var coachingMessage: CoachingMessage?

    // Badge celebration queue
    @State private var badgeQueue: [EarnedBadge] = []
    @State private var currentBadge: EarnedBadge?
    @State private var sharingBadge: EarnedBadge?
    @State private var badgePresentationID = UUID()
    @AppStorage("badgeSystemInitialized") private var badgeSystemInitialized = false

    // XP system
    @State private var currentXPGain: XPGain?
    @State private var xpHabitName: String = ""
    @State private var xpHabitStreak: Int = 0
    @State private var showingLevelUp = false
    @State private var newLevel: Int = 0

    // Quick tour
    @AppStorage("hasCompletedQuickTour") private var hasCompletedQuickTour = false
    @State private var showingQuickTour = false

    @Query(sort: \MoodEntry.date, order: .reverse)
    private var moodEntries: [MoodEntry]

    @Query(sort: \EarnedBadge.earnedAt, order: .reverse)
    private var earnedBadges: [EarnedBadge]

    private var todaysHabits: [Habit] {
        let scheduled = allHabits.filter { $0.frequency.isScheduled(for: Date()) }
        guard smartSortEnabled else { return scheduled }

        // AI smart sort: incomplete + at-risk first, then completed
        let incomplete = scheduled.filter { !$0.isCompleted(on: Date()) }
        let completed = scheduled.filter { $0.isCompleted(on: Date()) }

        // Sort incomplete by health score (lowest first = needs most attention)
        let scores = HabitHealthScorer.scoreAll(habits: incomplete)
        let sortedIncomplete = incomplete.sorted { a, b in
            let scoreA = scores.first(where: { $0.id == a.id })?.score ?? 50
            let scoreB = scores.first(where: { $0.id == b.id })?.score ?? 50
            return scoreA < scoreB
        }

        return sortedIncomplete + completed
    }

    private var notTodayHabits: [Habit] {
        allHabits.filter { !$0.frequency.isScheduled(for: Date()) }
    }

    private var completedCount: Int {
        todaysHabits.filter { $0.isCompleted(on: Date()) }.count
    }

    private var progress: Double {
        guard !todaysHabits.isEmpty else { return 0 }
        // For multi-completion habits, use fractional progress
        let total = todaysHabits.reduce(0.0) { sum, habit in
            sum + habit.completionProgress(on: Date())
        }
        return total / Double(todaysHabits.count)
    }

    var body: some View {
        NavigationStack {
            todayContent
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { todayToolbar }
                .sheet(isPresented: $showingAddHabit) {
                    HabitFormView()
                }
                .sheet(isPresented: $showingTemplates) {
                    HabitTemplatesView()
                }
                .sheet(item: $editingHabit) { habit in
                    HabitFormView(editingHabit: habit)
                }
                .sheet(isPresented: $showingNoteSheet) {
                    if let habit = noteHabit, let completion = noteCompletion {
                        HabitNoteSheet(habit: habit, completion: completion) {
                            showingNoteSheet = false
                        }
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                    }
                }
                .alert("Habit Limit Reached", isPresented: $showingLimitAlert) {
                    Button("Upgrade to Pro", role: .none) {
                        showingPaywall = true
                    }
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Free accounts can track up to \(HabitViewModel.freeHabitLimit) habits. Upgrade to Habitra Pro for unlimited habits.")
                }
                .onAppear {
                    refreshCoachingMessage()
                    if !hasCompletedQuickTour {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            showingQuickTour = true
                        }
                    }
                    // XP backfill for existing users
                    XPEngine.backfillIfNeeded(habits: allHabits, earnedBadges: earnedBadges)
                    // Ensure quests exist
                    if SubscriptionManager.canUseQuests {
                        QuestGenerator.ensureCurrentQuests(context: modelContext)
                    }
                    // Ensure collections exist
                    if SubscriptionManager.canUseCollections {
                        CollectionCatalog.ensureCollections(context: modelContext)
                    }
                }
                .overlay {
                    if showingMilestone, let habit = milestoneHabit {
                        MilestoneCelebrationView(
                            habitName: habit.name,
                            habitIcon: habit.icon,
                            habitColorHex: habit.colorHex,
                            streakCount: milestoneStreak,
                            completionRate: StreakCalculator.completionRate(for: habit, days: 7),
                            totalCompletions: StreakCalculator.totalCompletions(habit: habit),
                            longestStreak: habit.longestStreak,
                            onDismiss: { showingMilestone = false }
                        )
                        .transition(.opacity)
                        .zIndex(100)
                    }

                    // XP Popup
                    if let xpGain = currentXPGain {
                        XPPopupView(xpGain: xpGain, habitName: xpHabitName, currentStreak: xpHabitStreak) {
                            currentXPGain = nil
                        }
                        .transition(.opacity)
                        .zIndex(150)
                    }

                    // Level Up
                    if showingLevelUp {
                        LevelUpView(
                            newLevel: newLevel,
                            totalXP: XPEngine.lifetimeXP,
                            xpToNextLevel: XPEngine.xpForLevel(newLevel + 1) - XPEngine.lifetimeXP,
                            onDismiss: { showingLevelUp = false }
                        )
                        .transition(.opacity)
                        .zIndex(160)
                    }

                    if let badge = currentBadge {
                        BadgeCelebrationView(
                            badge: badge,
                            onDismiss: {
                                currentBadge = nil
                                showNextBadge()
                            },
                            onShare: {
                                sharingBadge = badge
                            }
                        )
                        .id(badgePresentationID) // forces fresh instance + onAppear per badge
                        .transition(.opacity)
                        .zIndex(200)
                    }

                    if showingQuickTour {
                        QuickTourView(isPresented: $showingQuickTour)
                            .transition(.opacity)
                            .zIndex(300)
                    }
                }
                .sheet(item: $sharingBadge) { badge in
                    BadgeShareSheet(earnedBadge: badge)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    // MARK: - Content

    private var todayContent: some View {
        ZStack {
            Color.habitraBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HabitraTheme.spacingLarge) {
                    DayProgressHeader(
                        progress: progress,
                        completedCount: completedCount,
                        totalCount: todaysHabits.count,
                        level: XPEngine.currentLevel,
                        xpProgress: XPEngine.xpProgressInLevel,
                        todayXP: XPEngine.todayXP
                    )

                    // AI coaching message
                    if let msg = coachingMessage {
                        coachingBanner(msg)
                            .padding(.horizontal, HabitraTheme.screenPadding)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    todayHabitsList

                    otherHabitsSection
                }
                .padding(.top, HabitraTheme.spacing)
                .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var todayToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                withHabitraAnimation { isEditMode.toggle() }
            } label: {
                Text(isEditMode ? "Done" : "Edit")
                    .foregroundStyle(Color.habitraAccent)
            }
        }
        ToolbarItem(placement: .principal) {
            HabitraWordmark(size: 18, style: .dark)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    handleAddHabit()
                } label: {
                    Label("New Habit", systemImage: "plus.circle")
                }

                Button {
                    showingTemplates = true
                } label: {
                    Label("Quick Add Template", systemImage: "square.grid.2x2")
                }

                Divider()

                Button {
                    withHabitraAnimation { smartSortEnabled.toggle() }
                } label: {
                    Label(
                        smartSortEnabled ? "Default Order" : "Smart Sort (AI)",
                        systemImage: smartSortEnabled ? "arrow.up.arrow.down" : "brain.head.profile"
                    )
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.habitraAccent)
            }
        }
    }

    // MARK: - Today's Habits

    @ViewBuilder
    private var todayHabitsList: some View {
        if allHabits.isEmpty {
            HabitraEmptyState(
                icon: "plus.circle.dashed",
                title: "No habits yet",
                message: "Create your first habit to start building your streak."
            )
            .padding(.top, 40)
        } else if todaysHabits.isEmpty {
            HabitraEmptyState(
                icon: "moon.stars.fill",
                title: "Nothing scheduled",
                message: "No habits are scheduled for today. Enjoy the break!"
            )
            .padding(.top, 40)
        } else {
            todayHabitsListContent
        }
    }

    private var todayHabitsListContent: some View {
        VStack(spacing: HabitraTheme.spacing) {
            ForEach(Array(todaysHabits.enumerated()), id: \.element.id) { index, habit in
                todayHabitRow(habit)
                    .staggeredAppearance(index: index, total: todaysHabits.count)
            }
        }
        .padding(.horizontal, HabitraTheme.screenPadding)
    }

    private func todayHabitRow(_ habit: Habit) -> some View {
        HabitRowView(
            habit: habit,
            onToggle: { toggleCompletion(for: habit) },
            onEdit: { editingHabit = habit }
        )
        .habitContextMenu(habit: habit, modelContext: modelContext, onEdit: { editingHabit = habit })
    }

    // MARK: - Other Habits

    @ViewBuilder
    private var otherHabitsSection: some View {
        if !notTodayHabits.isEmpty {
            VStack(alignment: .leading, spacing: HabitraTheme.spacing) {
                DisclosureGroup(isExpanded: $showingOtherHabits) {
                    VStack(spacing: HabitraTheme.spacing) {
                        ForEach(notTodayHabits) { habit in
                            otherHabitRow(habit)
                        }
                    }
                    .padding(.top, HabitraTheme.spacingSmall)
                } label: {
                    Text("OTHER HABITS (\(notTodayHabits.count))")
                        .habitraCaption()
                        .sectionHeaderAccessibility()
                }
                .tint(Color.habitraTextTertiary)
                .animation(.easeInOut(duration: 0.25), value: showingOtherHabits)
            }
            .padding(.horizontal, HabitraTheme.screenPadding)
        }
    }

    private func otherHabitRow(_ habit: Habit) -> some View {
        HabitRowCompact(habit: habit)
            .onTapGesture { editingHabit = habit }
            .accessibilityLabel("\(habit.name), \(habit.frequency.displayName)")
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Tap to edit this habit")
            .habitContextMenu(habit: habit, modelContext: modelContext, onEdit: { editingHabit = habit })
    }

    // MARK: - Actions

    // MARK: - AI Coaching Banner

    private func coachingBanner(_ message: CoachingMessage) -> some View {
        HStack(spacing: 10) {
            Image(systemName: message.icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: message.colorHex))

            Text(message.text)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextSecondary)
                .lineLimit(2)

            Spacer(minLength: 4)

            Button {
                withHabitraAnimation { coachingMessage = nil }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.habitraTextTertiary)
            }
        }
        .padding(12)
        .background(Color(hex: message.colorHex).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: HabitraTheme.cornerRadiusSmall)
                .stroke(Color(hex: message.colorHex).opacity(0.2), lineWidth: 1)
        )
    }

    private func refreshCoachingMessage() {
        coachingMessage = AICoachingMessages.generateMessage(
            habits: allHabits,
            moodEntries: moodEntries
        )
    }

    private func handleAddHabit() {
        let vm = HabitViewModel(modelContext: modelContext)
        if vm.canCreateHabit {
            showingAddHabit = true
        } else {
            showingLimitAlert = true
        }
    }

    private func toggleCompletion(for habit: Habit) {
        let wasCompleted = habit.isCompleted(on: Date())
        let wasPartial = habit.isPartiallyCompleted(on: Date())

        withHabitraAnimation(HabitraTheme.springAnimation) {
            let vm = HabitViewModel(modelContext: modelContext)
            vm.toggleCompletion(for: habit)
        }

        // Evaluate badges only when a habit transitions to fully completed
        let justCompleted = !wasCompleted && habit.isCompleted(on: Date())
        if justCompleted {
            // Award XP
            let levelBefore = XPEngine.currentLevel
            let xpGain = XPEngine.awardCompletion(habit: habit, habits: allHabits)
            HapticManager.xpGained()

            // Show XP popup
            xpHabitName = habit.name
            xpHabitStreak = habit.currentStreak
            currentXPGain = xpGain

            // Check for level up
            let levelAfter = XPEngine.currentLevel
            if levelAfter > levelBefore {
                newLevel = levelAfter
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    showingLevelUp = true
                }
            }

            evaluateBadges()

            // Evaluate quests
            if SubscriptionManager.canUseQuests {
                QuestEvaluator.evaluate(habits: allHabits, context: modelContext)
            }
        }

        if justCompleted || (!wasCompleted && !habit.isCompleted(on: Date()) && habit.isMultiCompletion) {
            let newStreak = habit.currentStreak

            // Accessibility announcement
            if habit.isMultiCompletion && !justCompleted {
                let count = habit.completionCount(on: Date())
                let target = habit.targetCompletionsPerDay
                UIAccessibility.post(notification: .announcement,
                    argument: "\(habit.name), \(count) of \(target)")
            } else if justCompleted {
                HabitraAccessibility.announceCompletion(habitName: habit.name, streak: newStreak)
            }

            // Invalidate streak cache
            StreakCache.shared.invalidate(habitID: habit.id)

            // Check milestone only when fully completed
            if justCompleted && MilestoneCelebrationView.isMilestone(newStreak) {
                milestoneHabit = habit
                milestoneStreak = newStreak
                HabitraAccessibility.announceMilestone(habitName: habit.name, streak: newStreak)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withHabitraAnimation { showingMilestone = true }
                }
            }

            // Offer note only when fully completed (not on each multi-completion tap)
            if justCompleted {
                let calendar = Calendar.current
                if let completion = habit.completions.last(where: {
                    calendar.isDate($0.completedDate, inSameDayAs: Date())
                }) {
                    noteHabit = habit
                    noteCompletion = completion
                    let delay: Double = MilestoneCelebrationView.isMilestone(newStreak) ? 4.5 : 0.6
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        showingNoteSheet = true
                    }
                }
            }
        }
    }

    // MARK: - Badge Helpers

    private func evaluateBadges() {
        // First run: silently backfill all historically earned badges without
        // showing any celebrations. Prevents a flood of overlays on first launch
        // for users who already have habit history.
        if !badgeSystemInitialized {
            let hasHistory = allHabits.contains { !$0.completions.isEmpty }
            BadgeEvaluator.evaluate(habits: allHabits, context: modelContext)
            badgeSystemInitialized = true
            // If they had no history this is their first-ever completion —
            // fall through so we don't skip their first real badge celebration.
            if hasHistory { return }
        }

        let newBadges = BadgeEvaluator.evaluate(habits: allHabits, context: modelContext)
        guard !newBadges.isEmpty else { return }

        // Award XP for each new badge
        for _ in newBadges {
            XPEngine.awardBadge()
        }

        // Cap pending celebrations at 3 to avoid overwhelming the user
        let slotsAvailable = max(0, 3 - badgeQueue.count)
        badgeQueue.append(contentsOf: newBadges.prefix(slotsAvailable))

        if currentBadge == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showNextBadge()
            }
        }
    }

    private func showNextBadge() {
        guard !badgeQueue.isEmpty else { return }
        badgePresentationID = UUID() // new identity → fresh view instance → onAppear fires
        currentBadge = badgeQueue.removeFirst()
    }

    private func moveHabits(from source: IndexSet, to destination: Int) {
        var habits = todaysHabits
        habits.move(fromOffsets: source, toOffset: destination)
        let vm = HabitViewModel(modelContext: modelContext)
        vm.reorderHabits(habits)
    }
}

// MARK: - Compact Row (for non-today habits)
struct HabitRowCompact: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: HabitraTheme.spacing) {
            Image(systemName: habit.icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: habit.colorHex).opacity(0.6))
                .frame(width: 32, height: 32)
                .background(Color(hex: habit.colorHex).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(habit.name)
                .font(HabitraFont.body())
                .foregroundStyle(Color.habitraTextTertiary)

            Spacer()

            Text(habit.frequency.displayName)
                .font(HabitraFont.footnote())
                .foregroundStyle(Color.habitraTextTertiary.opacity(0.6))
        }
        .habitraCard()
    }
}

// MARK: - Context Menu Modifier
struct HabitContextMenuModifier: ViewModifier {
    let habit: Habit
    let modelContext: ModelContext
    var onEdit: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button {
                    onEdit?()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    LiveActivityManager.shared.startTimer(for: habit, targetMinutes: 10)
                } label: {
                    Label("Start Timer", systemImage: "timer")
                }

                Button(role: .destructive) {
                    HapticManager.medium()
                    withHabitraAnimation {
                        let vm = HabitViewModel(modelContext: modelContext)
                        vm.archiveHabit(habit)
                    }
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }

                Divider()

                Button(role: .destructive) {
                    HapticManager.heavy()
                    withHabitraAnimation {
                        let vm = HabitViewModel(modelContext: modelContext)
                        vm.deleteHabit(habit)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

extension View {
    func habitContextMenu(habit: Habit, modelContext: ModelContext, onEdit: (() -> Void)? = nil) -> some View {
        modifier(HabitContextMenuModifier(habit: habit, modelContext: modelContext, onEdit: onEdit))
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self], inMemory: true)
}
