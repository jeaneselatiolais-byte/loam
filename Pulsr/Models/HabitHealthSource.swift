//
//  HabitHealthSource.swift
//  Habitra
//
//  Defines the HealthKit activity type a habit can be auto-completed by.
//  Each case maps to one or more HKWorkoutActivityType values, or to a
//  non-workout HealthKit category (mindfulness, sleep, steps).
//

import Foundation
import HealthKit

enum HabitHealthSource: String, CaseIterable, Identifiable {
    case none             = ""
    // Workouts
    case running          = "running"
    case walking          = "walking"
    case cycling          = "cycling"
    case swimming         = "swimming"
    case yoga             = "yoga"
    case hiit             = "hiit"
    case strengthTraining = "strengthTraining"
    case dance            = "dance"
    case hiking           = "hiking"
    case pilates          = "pilates"
    case rowing           = "rowing"
    case elliptical       = "elliptical"
    case martialArts      = "martialArts"
    case anyWorkout       = "anyWorkout"
    // Non-workout
    case mindfulness      = "mindfulness"
    case sleep            = "sleep"
    case steps            = "steps"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:             return "None"
        case .running:          return "Running"
        case .walking:          return "Walking"
        case .cycling:          return "Cycling"
        case .swimming:         return "Swimming"
        case .yoga:             return "Yoga"
        case .hiit:             return "HIIT"
        case .strengthTraining: return "Strength Training"
        case .dance:            return "Dance"
        case .hiking:           return "Hiking"
        case .pilates:          return "Pilates"
        case .rowing:           return "Rowing"
        case .elliptical:       return "Elliptical"
        case .martialArts:      return "Martial Arts"
        case .anyWorkout:       return "Any Workout"
        case .mindfulness:      return "Mindfulness / Meditation"
        case .sleep:            return "Sleep"
        case .steps:            return "Step Goal"
        }
    }

    var icon: String {
        switch self {
        case .none:             return "xmark.circle"
        case .running:          return "figure.run"
        case .walking:          return "figure.walk"
        case .cycling:          return "figure.outdoor.cycle"
        case .swimming:         return "figure.pool.swim"
        case .yoga:             return "figure.yoga"
        case .hiit:             return "flame.fill"
        case .strengthTraining: return "dumbbell.fill"
        case .dance:            return "music.note"
        case .hiking:           return "figure.hiking"
        case .pilates:          return "figure.pilates"
        case .rowing:           return "figure.rowing"
        case .elliptical:       return "figure.elliptical"
        case .martialArts:      return "figure.martial.arts"
        case .anyWorkout:       return "figure.mixed.cardio"
        case .mindfulness:      return "brain.head.profile"
        case .sleep:            return "bed.double.fill"
        case .steps:            return "figure.walk"
        }
    }

    /// True when this source maps to an HKWorkout sample.
    var isWorkoutBased: Bool {
        switch self {
        case .none, .mindfulness, .sleep, .steps: return false
        default: return true
        }
    }

    /// True when a minimum-duration setting is meaningful for this source.
    var hasDurationSetting: Bool {
        switch self {
        case .none, .steps: return false
        default: return true
        }
    }

    /// HKWorkoutActivityTypes that match this source.
    /// Empty for non-workout sources; anyWorkout matches every type.
    var workoutActivityTypes: [HKWorkoutActivityType] {
        switch self {
        case .running:          return [.running]
        case .walking:          return [.walking]
        case .cycling:          return [.cycling]
        case .swimming:         return [.swimming, .swimBikeRun]
        case .yoga:             return [.yoga]
        case .hiit:             return [.highIntensityIntervalTraining]
        case .strengthTraining: return [.traditionalStrengthTraining, .functionalStrengthTraining, .coreTraining]
        case .dance:            return [.socialDance, .cardioDance]
        case .hiking:           return [.hiking]
        case .pilates:          return [.pilates]
        case .rowing:           return [.rowing]
        case .elliptical:       return [.elliptical]
        case .martialArts:      return [.martialArts, .kickboxing, .boxing]
        case .anyWorkout:       return []   // special: match any workout
        default:                return []
        }
    }
}
