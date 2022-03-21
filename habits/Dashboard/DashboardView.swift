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
                    .onDelete(perform:removeItems)
                }
            }
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        for offset in offsets {
            // TODO: ask for confirmation
            moc.delete(habits[offset])
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
