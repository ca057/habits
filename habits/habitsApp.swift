//
//  habitsApp.swift
//  habits
//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

@main
struct habitsApp: App {
    @StateObject private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
