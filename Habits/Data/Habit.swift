//
//  Habit.swift
//  Habits
//
//  Created by Christian Ost on 07.12.23.
//
//

import Foundation
import SwiftData


@Model
class Habit {
    @Attribute(.unique) var id: UUID

    // TODO: rename
    var colour: String = "base"
    var createdAt: Date
    var name: String
    var order: Int16 = 0
    // TODO: rename
    @Relationship(deleteRule: .cascade, inverse: \Entry.habit) var entry = [Entry]()
    
    var asColour: Colour {
        get {
            Colour.fromRawValue(colour)
        }
        set {
            colour = newValue.toLabel()
        }
    }
    
    init(colour: String, createdAt: Date, id: UUID, name: String, order: Int16) {
        self.colour = colour
        self.createdAt = createdAt
        self.id = id
        self.name = name
        self.order = order
    }
}

extension Habit {
    func hasEntry(for date: Date) -> Bool {
        self.entry.contains(where: { entry in
            return CalendarUtils.shared.calendar.isDate(entry.date, inSameDayAs: date)
        })
    }
}
