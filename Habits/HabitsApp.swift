//
//  habitsApp.swift
//  habits
//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI
import SwiftData

@main
struct HabitsApp: App {
    private let container: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            MainApp()
                .environment(\.calendar, CalendarUtils.shared.calendar)
        }
        .modelContainer(container)
    }
    
    init() {
        do {
            let url = URL.applicationSupportDirectory.appending(path: "Habit.sqlite")
            let config = ModelConfiguration(url: url)
            
            container = try ModelContainer(for: Habit.self, configurations: config)
        } catch {
            fatalError("failed to create model container")
        }
    }
}
