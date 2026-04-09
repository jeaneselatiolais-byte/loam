//
//  HabitraApp.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import SwiftData
import Combine

@main
struct HabitraApp: App {
    @AppStorage("prefersDarkMode") private var prefersDarkMode = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    /// Re-checks HealthKit every 5 minutes so workouts that sync after launch still auto-complete.
    private let healthAutoCompleteTimer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self, EarnedBadge.self, Quest.self, BadgeCollection.self])
        let useCloudSync = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        let modelConfiguration: ModelConfiguration = useCloudSync
            ? CloudSyncManager.cloudModelConfiguration(schema: schema)
            : CloudSyncManager.localModelConfiguration(schema: schema)

        do {
            return try ModelContainer(
                for: Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self, EarnedBadge.self, Quest.self, BadgeCollection.self,
                migrationPlan: HabitraMigrationPlan.self,
                configurations: modelConfiguration
            )
        } catch {
            print("⚠️ SwiftData store failed: \(error)")

            let localConfig = CloudSyncManager.localModelConfiguration(schema: schema)

            let fm = FileManager.default
            if let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let files = (try? fm.contentsOfDirectory(at: appSupport, includingPropertiesForKeys: nil)) ?? []
                for file in files where file.lastPathComponent.contains("default.store") {
                    try? fm.removeItem(at: file)
                }
            }

            do {
                return try ModelContainer(
                    for: Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self, EarnedBadge.self, Quest.self, BadgeCollection.self,
                    migrationPlan: HabitraMigrationPlan.self,
                    configurations: localConfig
                )
            } catch {
                print("⚠️ Retry failed, falling back to in-memory: \(error)")
                let inMemoryConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                do {
                    return try ModelContainer(
                        for: Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self, EarnedBadge.self, Quest.self, BadgeCollection.self,
                        configurations: inMemoryConfig
                    )
                } catch {
                    fatalError("Could not create ModelContainer even in-memory: \(error)")
                }
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            rootView
                .preferredColorScheme(prefersDarkMode ? .dark : .light)
                .onAppear {
                    // Populate demo data for App Store screenshots when launch arg is present
                    if ScreenshotDemoData.populateIfNeeded(context: sharedModelContainer.mainContext) {
                        hasCompletedOnboarding = true
                        return // Skip normal launch tasks during screenshot capture
                    }
                    rescheduleNotifications()
                    QuickActionsManager.updateShortcuts()
                    scheduleAINudges()
                    runHealthAutoComplete()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    runHealthAutoComplete()
                }
                .onReceive(healthAutoCompleteTimer) { _ in
                    runHealthAutoComplete()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    @ViewBuilder
    private var rootView: some View {
        if hasCompletedOnboarding {
            HabitraTabView()
        } else {
            OnboardingView()
        }
    }

    private func rescheduleNotifications() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived }
        )
        guard let habits = try? context.fetch(descriptor) else { return }
        NotificationManager.shared.rescheduleAll(habits: habits)
    }

    private func runHealthAutoComplete() {
        Task {
            await HealthAutoCompleteService.shared.run(context: sharedModelContainer.mainContext)
        }
    }

    private func scheduleAINudges() {
        let context = sharedModelContainer.mainContext
        let habitDescriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived }
        )
        let moodDescriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        guard let habits = try? context.fetch(habitDescriptor) else { return }
        let moods = (try? context.fetch(moodDescriptor)) ?? []
        AINudgeManager.shared.scheduleSmartNudges(habits: habits, moodEntries: moods)
        AINudgeManager.shared.scheduleWeeklyRecapReminder()

        // Train/retrain Core ML model if needed
        if CoreMLModelTrainer.shared.needsRetraining {
            _ = CoreMLModelTrainer.shared.trainModel(habits: habits, moodEntries: moods)
        }
    }
}
