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
        
        request.sortDescriptors = []
        
        return request
    }
}

class HabitsStorage: NSObject, ObservableObject {
    @Published var habits: [Habit] = []
    private let habitsController: NSFetchedResultsController<Habit>
    
    init(managedObjectContext: NSManagedObjectContext) {
        habitsController = NSFetchedResultsController(
            fetchRequest: Habit.habitsFetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        super.init()
        
        habitsController.delegate = self
        
        do {
            try habitsController.performFetch()
            self.habits = habitsController.fetchedObjects ?? []
        } catch {
            print("failed to fetch habits")
        }
    }
}

extension HabitsStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let habits = controller.fetchedObjects as? [Habit]
        else { return }
                
        self.habits = habits
    }
}
