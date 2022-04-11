//
//  DashboardItemViewModel.swift
//  Habits
//
//  Created by Christian Ost on 04.04.22.
//

import Foundation
import SwiftUI

class DashboardItemViewModel {
    private var habitsStorage: HabitsStorage = .shared
    
    func toggleEntry(for habit: Habit, date: Date) {
        self.habitsStorage.toggleEntry(for: habit, date: date)
    }
}
