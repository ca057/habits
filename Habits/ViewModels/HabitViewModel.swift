//
//  HabitViewModel.swift
//  Habits
//
//  Created by Christian Ost on 05.05.22.
//

import Foundation

class HabitViewModel: ObservableObject {
    private var habitsStorage: HabitsStorage
    private var habit: Habit
   
    @Published var name: String {
        didSet {
            self.saveChanges()
        }
    }
    @Published var colour: Colour {
        didSet {
            self.saveChanges()
        }
    }
    @Published var earliestEntry: Date = Date.now
    @Published var latestEntry: Date = Date.now
    var createdAt: Date?
    
    func saveChanges() {
        habitsStorage.update(habit, name: name, colour: colour)
    }
    
    func deleteHabit() {
        habitsStorage.delete(self.habit)
    }
    
    func hasEntryForDate(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return habit.hasEntry(for: date)
    }
    
    // MARK: -
    convenience init(_ habit: Habit) {
        self.init(habit: habit, habitsStorage: .shared)
    }
    init(habit: Habit, habitsStorage: HabitsStorage) {
        self.habitsStorage = habitsStorage
        self.habit = habit
        self.name = habit.name ?? ""
        self.createdAt = habit.createdAt
        self.colour = Colour.fromRawValue(habit.colour)
        
        guard let entries = habit.entry, entries.count > 0 else { return }

        entries.forEach({
            guard
                let entry = $0 as? Entry,
                let date = entry.date
            else { return }

            if date.compare(.isEarlier(than: earliestEntry)) {
                earliestEntry = date
            }
            if date.compare(.isLater(than: latestEntry)) {
                latestEntry = date
            }
        })
    }
}
