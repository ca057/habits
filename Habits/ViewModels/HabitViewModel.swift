//
//  HabitViewModel.swift
//  Habits
//
//  Created by Christian Ost on 05.05.22.
//

import Foundation

class HabitViewModel {
    private var habitsStorage: HabitsStorage
    
    func deleteHabit(_ habit: Habit) {
        habitsStorage.deleteHabit(habit)
    }
    
    // MARK: -
    convenience init() {
        self.init(habitsStorage: .shared)
    }
    init(habitsStorage: HabitsStorage) {
        self.habitsStorage = habitsStorage
    }
}
