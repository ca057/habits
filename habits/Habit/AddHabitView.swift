//
//  AddHabitView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismissView
    @Environment(\.managedObjectContext) private var moc

    @State private var name = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
            }
            .navigationTitle("Add habit")
            .toolbar {
                Button("Save") {
                    saveHabit()
                    dismissView()
                }
            }
        }
    }
    
    func saveHabit() {
        let habit = Habit(context: moc)
        habit.name = name
        habit.id = UUID()
        habit.createdAt = Date()
        
        if moc.hasChanges {
            try? moc.save()
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
    }
}
