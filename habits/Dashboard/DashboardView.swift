//
//  DashboardView.swift
//  habits
//
//  Created by Christian Ost on 15.03.22.
//

import CoreData
import SwiftUI

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.createdAt, order: .reverse),
            SortDescriptor(\.name),
        ]
    ) var habits: FetchedResults<Habit>
    
    @State private var confirmDeletion = false
    @State private var habitIndexSetToDelete: IndexSet? = nil
    
    var body: some View {
        VStack {
            List {
                if habits.isEmpty {
                    Text("No habits yet - go and create one!")
                } else {
                    ForEach(habits) { habit in
                        // TODO: NavigationLinks to HabitViews
                        Text(habit.name ?? "N/A")
                    }
                    .onDelete { indexSet in
                        habitIndexSetToDelete = indexSet
                        confirmDeletion = true
                    }
                }
            }
        }
        .alert("Delete item?", isPresented: $confirmDeletion) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let indexSet = habitIndexSetToDelete {
                    removeItems(at: indexSet)
                    habitIndexSetToDelete = nil
                }
                confirmDeletion = false
            }
        } message: {
            Text("Do you want to delete the habit: \(getHabitNames(for: habitIndexSetToDelete))?")
        }
    }
    
    private func removeItems(at offsets: IndexSet) {
        for offset in offsets {
            // TODO: ask for confirmation
            moc.delete(habits[offset])
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }
    
    private func getHabitNames(for offsets: IndexSet?) -> String {
        guard let offsets = offsets else {
            return ""
        }
        guard !habits.isEmpty else {
            return ""
        }

        var habitList = ""
        for offset in offsets {
            let nextHabit = habits[offset].name ?? "N/A"
            habitList = habitList.count > 0 ? "\(habitList), \(nextHabit)" : nextHabit
        }

        return habitList
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
