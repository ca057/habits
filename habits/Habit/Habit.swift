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
    var name: String
    
    // TODO
    // target rhythm

    init(name n: String) {
        self.name = n
        self.createdAt = Date.now
    }
}
