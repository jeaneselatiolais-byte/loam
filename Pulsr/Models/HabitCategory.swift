//
//  HabitCategory.swift
//  Habitra
//
//  Created by Jeanese Raymond on 3/24/26.
//

import Foundation
import SwiftData

@Model
final class HabitCategory {
    var id: UUID = UUID()
    var name: String = ""
    var sortOrder: Int = 0

    @Relationship(deleteRule: .nullify, inverse: \Habit.category)
    var _habits: [Habit]? = []

    /// Non-optional accessor so call-sites stay unchanged
    @Transient
    var habits: [Habit] {
        get { _habits ?? [] }
        set { _habits = newValue }
    }

    init(name: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.sortOrder = sortOrder
        self._habits = []
    }
}
