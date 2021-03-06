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

    // TODO: make it a lazy var
    let container: NSPersistentContainer
        
    init() {
        // TODO: add option for in memory for tests
        container = NSPersistentContainer(name: "Habit")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("core data failed to load: \(error.localizedDescription)")
            }
            
            let persistentStoreDescriptions = NSPersistentStoreDescription()
            persistentStoreDescriptions.shouldMigrateStoreAutomatically = true
            persistentStoreDescriptions.shouldInferMappingModelAutomatically = true
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            self.container.persistentStoreDescriptions.append(persistentStoreDescriptions)
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
    
    func deleteObject(_ object: NSManagedObject) {
        self.container.viewContext.delete(object)
    }
}
