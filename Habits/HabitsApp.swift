//
//  habitsApp.swift
//  habits
//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

@main
struct habitsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let dataController: DataController = .shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onChange(of: scenePhase, perform: handleSceneChange)
        }
    }
    
    private func handleSceneChange(phase: ScenePhase) {
        switch phase {
        case .active:
            updateData()
            break
        default: break
        }
    }
    
    private func updateData() {
        HabitsStorage.shared.loadData()
    }
}
