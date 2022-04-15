//
//  AddHabitViewModel.swift
//  Habits
//
//  Created by Christian Ost on 02.04.22.
//

import Foundation
import SwiftUI

class AddHabitViewModel: ObservableObject {
    private var habitsStorage: HabitsStorage

    @Published var isValid = false
    @Published var name = "" {
        didSet {
            isValid = !name.isEmpty
        }
    }
    
    func saveHabit() -> Bool {
        if !isValid {
            return false
        }
        self.habitsStorage.addHabit(name: name)
        return true
    }
    
    convenience init() {
        self.init(habitsStorage: .shared)
    }
    
    init(habitsStorage: HabitsStorage) {
        self.habitsStorage = habitsStorage
    }
}
