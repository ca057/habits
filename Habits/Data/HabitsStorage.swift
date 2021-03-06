//
//  HabitStorage.swift
//  Habits
//
//  Created by Christian Ost on 07.04.22.
//
// inspired by https://www.donnywals.com/fetching-objects-from-core-data-in-a-swiftui-project/
//

import CoreData
import Foundation

extension Habit {
    static var habitsFetchRequest: NSFetchRequest<Habit> {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "order", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        return request
    }
}

class HabitsStorage: NSObject, ObservableObject, Storage {
    static var shared = HabitsStorage()

    @Published var habits: [Habit] = []
    
    private let dataController: DataController
    private let habitsController: NSFetchedResultsController<Habit>
    
    override init() {
        let dataController = DataController.shared
        habitsController = NSFetchedResultsController(
            fetchRequest: Habit.habitsFetchRequest,
            managedObjectContext: dataController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.dataController = dataController

        super.init()
        habitsController.delegate = self
        
        self.loadData()
    }
    
    // MARK: - core
    
    func loadData() {
        // TODO: make async/await
        do {
            try habitsController.performFetch()
            self.habits = habitsController.fetchedObjects ?? []
        } catch {
            print("failed to fetch habits")
        }
    }
    
    // MARK: - create

    func addHabit(name: String, colour: Colour) {
        let habit = Habit(context: self.dataController.container.viewContext)
        habit.id = UUID()
        habit.name = name
        habit.createdAt = Date()
        habit.colour = colour.rawValue
        
        self.dataController.save()
    }
    
    // MARK: - update
    func update(_ habit: Habit, name: String, colour: Colour) {
        habit.name = name
        habit.colour = colour.rawValue
        
        self.dataController.save()
    }
    
    private func addEntryToHabit(for habit: Habit, date: Date) {
        let entry = Entry(context: self.dataController.container.viewContext)
        entry.date = date
        entry.habit = habit
        
        self.dataController.save()
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
            self.dataController.container.viewContext.delete(entry)
        })

        dataController.save()
    }
    
    func toggleEntry(for habit: Habit, date: Date) {
        if habit.hasEntry(for: date) {
            removeEntryFromHabit(from: habit, date: date)
        } else {
            addEntryToHabit(for: habit, date: date)
        }
    }
    
    func move(from: IndexSet, to: Int) {
        habits.move(fromOffsets: from, toOffset: to)
        for index in 0..<habits.count {
            let habit = habits[index]
            habit.order = Int16(index)
        }

        dataController.save()
    }

    // MARK: - delete
    func delete(_ habit: Habit) {
        dataController.deleteObject(habit)
        dataController.save()
    }
}

// MARK: - listener to changes
extension HabitsStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let habits = controller.fetchedObjects as? [Habit]
        else { return }
                
        self.habits = habits
    }
}
