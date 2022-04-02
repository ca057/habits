//
//  DashboardViewModel.swift
//  Habits
//
//  Created by Christian Ost on 02.04.22.
//

import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var habits = DataController.shared.loadAllHabits()
}
