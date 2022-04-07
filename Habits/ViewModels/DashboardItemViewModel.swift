//
//  DashboardItemViewModel.swift
//  Habits
//
//  Created by Christian Ost on 04.04.22.
//

import Foundation

class DashboardItemViewModel {
    let dataController: DataController
    
    convenience init() {
        self.init(dataController: DataController.shared)
    }
    init(dataController: DataController) {
        self.dataController = dataController
    }
    
    func toggleEntry(for habit: Habit, date: Date) {
        dataController.toggleEntry(for: habit, date: date)
    }
}
