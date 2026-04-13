//
//  HabitraTabView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import SwiftData

struct HabitraTabView: View {
    @State private var selectedTab: Tab? = .today
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    enum Tab: String, CaseIterable, Identifiable {
        case today = "Today"
        case stats = "Stats"
        case coach = "Coach"
        case settings = "Settings"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .today: return "checkmark.circle.fill"
            case .stats: return "chart.bar.fill"
            case .coach: return "brain.head.profile"
            case .settings: return "gearshape.fill"
            }
        }

        /// Tabs visible in v1.0. Coach is hidden until AI features ship.
        /// v1.0: hidden via FeatureAvailability — see docs/RELEASE_STRATEGY.md
        static var visibleCases: [Tab] {
            allCases.filter { tab in
                switch tab {
                case .coach: return FeatureAvailability.aiInsights
                default: return true
                }
            }
        }
    }

    var body: some View {
        if horizontalSizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout (Tab Bar)

    private var iPhoneLayout: some View {
        TabView(selection: Binding(
            get: { selectedTab ?? .today },
            set: { selectedTab = $0 }
        )) {
            TodayView()
                .tabItem {
                    Label(Tab.today.rawValue, systemImage: Tab.today.icon)
                }
                .tag(Tab.today)

            StatsView()
                .tabItem {
                    Label(Tab.stats.rawValue, systemImage: Tab.stats.icon)
                }
                .tag(Tab.stats)

            // v1.0: hidden via FeatureAvailability — see docs/RELEASE_STRATEGY.md
            if FeatureAvailability.aiInsights {
                AIInsightsView()
                    .tabItem {
                        Label(Tab.coach.rawValue, systemImage: Tab.coach.icon)
                    }
                    .tag(Tab.coach)
            }

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(Color.habitraAccent)
        .onChange(of: selectedTab) { _, _ in
            HapticManager.selection()
        }
    }

    // MARK: - iPad Layout (Sidebar)

    private var iPadLayout: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(HabitraTabView.Tab.visibleCases) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .navigationTitle("Habitra")
            .tint(Color.habitraAccent)
            .listStyle(.sidebar)
        } detail: {
            detailView
        }
        .tint(Color.habitraAccent)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case .today, .none:
            TodayView()
        case .stats:
            StatsView()
        case .coach:
            // v1.0: hidden via FeatureAvailability — see docs/RELEASE_STRATEGY.md
            if FeatureAvailability.aiInsights {
                AIInsightsView()
            } else {
                TodayView()
            }
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    HabitraTabView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self], inMemory: true)
}
