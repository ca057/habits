//
//  MainView-ViewModel.swift
//  Habits
//
//  Created by Christian Ost on 05.03.23.
//

import Combine
import Foundation

extension Dashboard {
    @MainActor final class ViewModel: ObservableObject {
        private var habitsStorage = HabitsStorage.shared
        private var cancellables: Set<AnyCancellable> = []
        
        @Published var habits = [Habit]()
        @Published var showingAddHabit = false
        
        init() {
            habitsStorage.$habits
                .assign(to: \.habits, on: self)
                .store(in: &cancellables)
        }
        
        func toggleEntry(for habit: Habit, on date: Date) {
            habitsStorage.toggleEntry(for: habit, date: date)
        }
                
        func reorderElements(source: IndexSet, destination: Int) -> Void {
            habitsStorage.move(from: source, to: destination)
        }
    }
}
