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

    private func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("saving changes failed: \(error.localizedDescription)")
            }
        }
    }
    
    // TODO: move to HabitsStorage

    func addHabit(name: String) {
        let habit = Habit(context: self.container.viewContext)
        habit.id = UUID()
        habit.name = name
        habit.createdAt = Date()
        
        save()
    }
    
    private func addEntryToHabit(for habit: Habit, date: Date) {
        let entry = Entry(context: self.container.viewContext)
        entry.date = date
        entry.habit = habit
        
        save()
    }
    
    private func removeEntryFromHabit(from habit: Habit, date: Date) {
        guard let entries = habit.entry?.filter({
            // TODO: extract logic
            guard let entryDate = ($0 as? Entry)?.date else {
                return false
            }
            return Calendar.current.isDate(entryDate, equalTo: date, toGranularity: .day)
        }) else { return }
        
        if entries.count == 0 { return }
        
        entries.forEach({
            guard let entry = $0 as? Entry else { return }
            container.viewContext.delete(entry)
        })

        save()
    }
    
    func toggleEntry(for habit: Habit, date: Date) {
        if habit.hasEntry(for: date) {
            removeEntryFromHabit(from: habit, date: date)
        } else {
            addEntryToHabit(for: habit, date: date)
        }
    }
}

