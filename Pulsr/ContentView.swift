//
//  ContentView.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import SwiftUI
import SwiftData

/// Legacy entry point — redirects to HabitraTabView.
/// Kept for compatibility with any remaining references.
struct ContentView: View {
    var body: some View {
        HabitraTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self], inMemory: true)
}
