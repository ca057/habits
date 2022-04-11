//
//  DashboardViewModel.swift
//  Habits
//
//  Created by Christian Ost on 11.04.22.
//

import Combine
import Foundation

class DashboardViewModel: ObservableObject {
    @Published var habits = [Habit]()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        HabitsStorage.shared.$habits
            .assign(to: \.habits, on: self)
            .store(in: &cancellables)
    }
}
