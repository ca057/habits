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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
