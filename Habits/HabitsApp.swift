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
        }
        .modelContainer(container)
        .environment(\.calendar, CalendarUtils.shared.calendar)
    }
    
    init() {
        do {
            let url = URL.applicationSupportDirectory.appending(path: "Habit.sqlite")
            let config = ModelConfiguration(url: url)
            
            container = try ModelContainer(
                // TODO: are all entries here necessary?
                for: Habit.self, Entry.self,
                configurations: config
            )
        } catch {
            fatalError("failed to create model container")
        }
    }
}
