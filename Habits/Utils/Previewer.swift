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
    var habits: [Habit] = []
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Habit.self, configurations: config)
        
        habits.append(
            Habit(
                colour: Colour.green.toLabel(),
                createdAt: Date.now,
                id: UUID(),
                name: "preview",
                order: 0
            )
        )
        
        habits.append(
            Habit(
                colour: Colour.green.toLabel(),
                createdAt: Date.now,
                id: UUID(),
                name: "preview #1",
                order: 1
            )
        )
        
        habits.forEach({
            container.mainContext.insert($0)

            for i in 1..<10 {
                let entry = Entry(date: Date().adjust(day: i * Int.random(in: 1..<5)) ?? Date(), habit: $0)
                container.mainContext.insert(entry)
            }
        })
    }
}
