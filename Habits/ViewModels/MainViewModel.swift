//
//  DashboardViewModel.swift
//  Habits
//
//  Created by Christian Ost on 10.04.22.
//

import Foundation

class MainViewModel: ObservableObject {
    @Published var showingSettings = false
    @Published var showingAddHabit = false
}
