//
//  ContentView.swift
//  Pulsr
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: String = "today"

    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                // Today Tab
                TodayView()
                    .tag("today")
                    .tabItem {
                        Label("Today", systemImage: "checkmark.circle.fill")
                    }

                // Stats Tab
                StatsView()
                    .tag("stats")
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }

                // Coach Tab
                CoachView()
                    .tag("coach")
                    .tabItem {
                        Label("Coach", systemImage: "brain.head.profile")
                    }

                // Settings Tab
                SettingsView()
                    .tag("settings")
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .tint(Color(UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1.0)))
        }
    }
}

// MARK: - Placeholder Views
struct TodayView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Today's Habits")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)

                Spacer()

                Text("No habits yet")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Statistics")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)

                Spacer()

                Text("No data to display")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CoachView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("AI Coach")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)

                Spacer()

                Text("Complete habits to get coaching tips")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
