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

    var colour: String = "base"
    var createdAt: Date
    var name: String
    var order: Int16 = 0
    @Relationship(deleteRule: .cascade, inverse: \Entry.habit) var entry = [Entry]()
    
    init(colour: String, createdAt: Date, id: UUID, name: String, order: Int16) {
        self.colour = colour
        self.createdAt = createdAt
        self.id = id
        self.name = name
        self.order = order
    }
}
