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
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var currentDate = Date().toString(format: .isoDate) ?? ""
    
    private let container: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            MainApp()
                .environment(\.calendar, CalendarUtils.shared.calendar)
                .tag(currentDate) // hacky workaround to make the app reload when opened on another day, might not be needed anymore when we track the app openings in a separate habit
        }
        .modelContainer(container)
        .onChange(of: scenePhase, handleScenePhaseChange)
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
    
    private func handleScenePhaseChange() -> Void {
        switch scenePhase {
        case .active:
            // TODO: make this work
            currentDate = Date().toString(format: .isoDate) ?? ""
            break
        default: break
        }
        
    }
}
