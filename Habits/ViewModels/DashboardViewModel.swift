//
//  DashboardViewModel.swift
//  Habits
//
//  Created by Christian Ost on 11.04.22.
//

import Combine
import Foundation

class DashboardViewModel: ObservableObject {
    private var habitsStorage = HabitsStorage.shared
    private var cancellables: Set<AnyCancellable> = []
    
    private var habitToDelete: Habit?
    
    @Published var habits = [Habit]()
    @Published var showingDeleteHabitConfirmation = false
    
    init() {
        HabitsStorage.shared.$habits
            .assign(to: \.habits, on: self)
            .store(in: &cancellables)
    }
    
    func toggleLatestEntry(for habit: Habit) {
        self.habitsStorage.toggleEntry(for: habit, date: Date.now)
    }
    
    func requestToDelete(_ habit: Habit) {
        habitToDelete = habit
        showingDeleteHabitConfirmation = true
    }
    
    func deleteHabit() {
        guard let habit = habitToDelete else {
            // TODO: this is an error, handle it?
            return
        }
        habitsStorage.deleteHabit(habit)
        showingDeleteHabitConfirmation = false
    }
    
    func reorderElements(source: IndexSet, destination: Int) {
        habitsStorage.move(from: source, to: destination)
    }
}
