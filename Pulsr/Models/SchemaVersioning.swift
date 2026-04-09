//
//  SchemaVersioning.swift
//  Habitra
//
//  Versioned schema and migration plan for SwiftData.
//  Add new VersionedSchema enums here when the model changes,
//  then append a MigrationStage to HabitraMigrationPlan.stages.
//

import Foundation
import SwiftData

// MARK: - V1

/// The initial schema shipped with the first release.
enum HabitraSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self, EarnedBadge.self]
    }
}

// MARK: - V2 (Gamification Overhaul)

/// Adds Quest and BadgeCollection models for quests, challenges, and badge sets.
/// Lightweight migration — only new tables, no modifications to existing columns.
enum HabitraSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Habit.self, HabitCompletion.self, HabitCategory.self, MoodEntry.self, EarnedBadge.self,
         Quest.self, BadgeCollection.self]
    }
}

// MARK: - Migration Plan

enum HabitraMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HabitraSchemaV1.self, HabitraSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: HabitraSchemaV1.self, toVersion: HabitraSchemaV2.self)
        ]
    }
}
