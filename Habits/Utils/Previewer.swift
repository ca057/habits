//
//  Previewer.swift
//  Habits
//
//  Created by Christian Ost on 25.12.23.
//

import SwiftUI
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    let habit: Habit
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Habit.self, configurations: config)
        
        habit = Habit(
            colour: Colour.green.toLabel(),
            createdAt: Date.now,
            id: UUID(),
            name: "preview",
            order: 0
        )
        
        container.mainContext.insert(habit)
        
        for i in 1..<10 {
            let entry = Entry(date: Date().adjust(day: i * Int.random(in: 1..<5)) ?? Date(), habit: habit)
            container.mainContext.insert(entry)
        }
    }
}
