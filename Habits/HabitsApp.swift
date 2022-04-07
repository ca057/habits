//
//  habitsApp.swift
//  habits
//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

@main
struct habitsApp: App {
    let dataController = DataController.shared
    
    @StateObject var habitsStorage: HabitsStorage

    init() {
        let managedObjectContext = dataController.container.viewContext

        self._habitsStorage = StateObject(wrappedValue: HabitsStorage(managedObjectContext: managedObjectContext))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(habitsStorage)
        }
    }
}
