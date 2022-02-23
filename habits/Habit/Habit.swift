//
//  Habit.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import Foundation

struct Habit: Identifiable {
    let id = UUID()
    let createdAt: Date
    let type: HabitType
    var name: String
    
    // TODO
    // target rhythm

    init(name n: String, type t: HabitType) {
        name = n
        type = t
        createdAt = Date.now
    }
}
