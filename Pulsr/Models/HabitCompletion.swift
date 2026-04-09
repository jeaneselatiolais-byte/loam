//
//  HabitCompletion.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation
import SwiftData

@Model
final class HabitCompletion {
    var id: UUID = UUID()
    var completedDate: Date = Date() // The day this completion counts for
    var completedAt: Date = Date()   // The exact timestamp of completion
    var note: String?                // Optional journal note

    // HealthKit auto-complete tracking
    var completionSource: String = "manual"   // "manual" or "healthKit"
    var healthKitWorkoutUUID: String?         // UUID string of the matching HKWorkout/session

    var habit: Habit?

    init(completedDate: Date = Date(), habit: Habit? = nil, note: String? = nil,
         completionSource: String = "manual", healthKitWorkoutUUID: String? = nil) {
        self.id = UUID()
        self.completedDate = Calendar.current.startOfDay(for: completedDate)
        self.completedAt = Date()
        self.note = note
        self.habit = habit
        self.completionSource = completionSource
        self.healthKitWorkoutUUID = healthKitWorkoutUUID
    }

    var isAutoCompleted: Bool { completionSource == "healthKit" }
}
