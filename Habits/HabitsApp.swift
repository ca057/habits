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
//    @Environment(\.scenePhase) private var scenePhase
    let container: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            MainApp()
                .environment(\.calendar, CalendarUtils.shared.calendar)
//                .environment(\.managedObjectContext, dataController.container.viewContext)
//                .onChange(of: scenePhase, initial: false, handleSceneChange)
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
    
//    private func handleSceneChange() {
//        switch scenePhase {
//        case .active:
//            updateData()
//            break
//        default: break
//        }
//    }
//    
//    private func updateData() {
//        HabitsStorage.shared.loadData()
//    }
}
