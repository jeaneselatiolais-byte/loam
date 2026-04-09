//
//  HabitTimerActivity.swift
//  Habitra
//
//  Shared ActivityAttributes definition for Live Activity.
//  Must be accessible by both the main app and the widget extension.
//

import ActivityKit
import Foundation

struct HabitTimerAttributes: ActivityAttributes {
    /// Fixed context — set when the activity starts
    let habitName: String
    let habitIcon: String
    let habitColorHex: String
    let targetMinutes: Int

    /// Dynamic state — updated throughout the activity
    struct ContentState: Codable, Hashable {
        let startedAt: Date
        let elapsedSeconds: Int
        let isCompleted: Bool
    }
}
