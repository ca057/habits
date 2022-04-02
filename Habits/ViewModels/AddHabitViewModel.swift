//
//  AddHabitViewModel.swift
//  Habits
//
//  Created by Christian Ost on 02.04.22.
//

import Foundation

class AddHabitViewModel: ObservableObject {
    @Published var name = ""
    
    func saveHabit() {
        DataController.shared.addHabit(name: name)
    }
}
