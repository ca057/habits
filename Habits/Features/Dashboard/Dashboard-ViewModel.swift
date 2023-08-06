//
//  MainView-ViewModel.swift
//  Habits
//
//  Created by Christian Ost on 05.03.23.
//

import Combine
import Foundation
import CoreData

struct DashboardHabit {
    let id: UUID
    let name: String
    let colour: Colour
    let entries: [Entry]
}

extension Dashboard {
    @MainActor final class ViewModel: ObservableObject {
        private var habitsStorage = HabitsStorage.shared
        private var cancellables: Set<AnyCancellable> = []
        
        @Published var habits = [Habit]()
        @Published var showingAddHabit = false

        @Published var dashboardHabits = [DashboardHabit]()
        
        init() {
            habitsStorage.$habits
                .assign(to: \.habits, on: self)
                .store(in: &cancellables)
            
            let habitRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
            
            habitRequest.propertiesToFetch = ["name", "colour"]
            habitRequest.sortDescriptors = [
                NSSortDescriptor(key: "order", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]
            
            let fetchedHabits = try? DataController.shared.container.viewContext.fetch(habitRequest)
            
            guard let habitsWithoutEntries = fetchedHabits else { return }
            
            habitsWithoutEntries.forEach { habit in
                guard let id = habit.id, let name = habit.name else { return }
                        
                let entryRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
                entryRequest.predicate = NSPredicate(format: "habit == %@", habit)
                entryRequest.fetchLimit = 7 // TODO: make it a global setting?
                let entries = try? DataController.shared.container.viewContext.fetch(entryRequest)
                
                
                dashboardHabits.append(
                    DashboardHabit(
                        id: id,
                        name: name,
                        colour: Colour.fromRawValue(habit.colour),
                        entries: entries ?? []
                    )
                )
            }
        }
        
        func toggleEntry(for habit: Habit, on date: Date) {
            habitsStorage.toggleEntry(for: habit, date: date)
        }
                
        func reorderElements(source: IndexSet, destination: Int) -> Void {
            habitsStorage.move(from: source, to: destination)
        }
    }
}
