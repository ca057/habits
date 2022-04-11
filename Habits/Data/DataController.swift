//
//  DataController.swift
//  Habits
//
//  Created by Christian Ost on 02.04.22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    static let shared = DataController()

    let container: NSPersistentContainer
        
    init() {
        // TODO: add option for in memory for tests
        container = NSPersistentContainer(name: "Habit")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("core data failed to load: \(error.localizedDescription)")
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }

    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("saving changes failed: \(error.localizedDescription)")
            }
        }
    }
}
