//
//  Habit.swift
//  Habits
//
//  Created by Christian Ost on 07.12.23.
//
//

import Foundation
import SwiftData

typealias Habit = HabitsSchemaV110.Habit

extension HabitsSchemaV110 {
    @Model
    class Habit {
        @Attribute(.unique) var id: UUID
        
        // TODO: rename
        var colour: String = "base"
        var name: String
        var order: Int16 = 0
        
        var createdAt: Date
        var archivedAt: Date?
        
        // TODO: rename
        @Relationship(deleteRule: .cascade, inverse: \Entry.habit) var entry = [Entry]()
        
        // TODO: resort the parameters
        init(colour: String, createdAt: Date, id: UUID, name: String, order: Int16) {
            self.colour = colour
            self.createdAt = createdAt
            self.id = id
            self.name = name
            self.order = order
        }
        
        convenience init(name: String, colour: Colour) {
            self.init(colour: colour.toLabel(), createdAt: Date.now, id: UUID(), name: name, order: 0)
        }
        
        static var sortedWithEntries: FetchDescriptor<Habit> {
            var fetchDescriptor = FetchDescriptor<Habit>(
                predicate: #Predicate { $0.archivedAt == nil },
                sortBy: [
                    SortDescriptor(\Habit.order),
                    SortDescriptor(\Habit.createdAt, order: .reverse)
                ]
            )
            fetchDescriptor.relationshipKeyPathsForPrefetching = [\.entry]
            
            return fetchDescriptor
        }
        
        static let archivedHabits = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.archivedAt != nil },
            sortBy: [
                SortDescriptor(\.archivedAt, order: .reverse),
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
    }
}

extension Habit {
    var asColour: Colour {
        get {
            Colour.fromRawValue(colour)
        }
        set {
            colour = newValue.toLabel()
        }
    }
}
