//
//  AddHabitViewModel.swift
//  Habits
//
//  Created by Christian Ost on 02.04.22.
//

import Foundation

class AddHabitViewModel: ObservableObject {
    let dataController: DataController

    @Published var isValid = false
    @Published var name = "" {
        didSet {
            isValid = !name.isEmpty
        }
    }
    
    func saveHabit() {
        if !isValid {
            return
        }
        self.dataController.addHabit(name: name)
    }
    
    convenience init () {
        self.init(dataController: DataController.shared)
    }
    init (dataController: DataController) {
        self.dataController = dataController
    }
}
