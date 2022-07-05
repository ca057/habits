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
    var createdAt: Date?
    
    func saveChanges() {
        habitsStorage.update(habit, name: name, colour: colour)
    }
    
    func deleteHabit() {
        habitsStorage.delete(self.habit)
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
    }
}
