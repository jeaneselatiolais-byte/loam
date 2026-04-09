//
//  HabitTimerAttributes.swift
//  HabitraWidget
//
//  Copy of ActivityAttributes for the widget extension target.
//

import ActivityKit
import Foundation

struct HabitTimerAttributes: ActivityAttributes {
    let habitName: String
    let habitIcon: String
    let habitColorHex: String
    let targetMinutes: Int

    struct ContentState: Codable, Hashable {
        let startedAt: Date
        let elapsedSeconds: Int
        let isCompleted: Bool
    }
}
