//
//  SingleHabitSettingsView.swift
//  Habits
//
//  Created by Christian Ost on 11.05.24.
//

import SwiftUI

struct SingleHabitSettingsView: View {
    @Environment(\.dismiss) private var dismissView
    @Environment(\.navigation) private var navigation
    @Environment(\.modelContext) private var modelContext
    var habit: Habit
    
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack {
            Form {
                Section("Name") {
                    TextField("Name", text: Bindable(habit).name)
                }

                Section("Colour") {
                    ColourPicker(colours: Colour.allCasesSorted, selection: Bindable(habit).asColour)
                        .frame(minHeight: 32)
                }
                
                Section("Danger Zone") {
                    Button("Delete habit", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
        }
        .navigationTitle("Settings (\(habit.name))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismissView() })
                    .fontWeight(.bold)
            }
        }
        .alert("Confirm deletion",
               isPresented: $showingDeleteConfirmation,
               actions: {
                    Group {
                        Button("Cancel", role: .cancel, action: {})
                        Button("Delete", role: .destructive, action: deleteHabit)
                    }
                },
               message: { Text("Do you really want to delete “\(habit.name)”?") }
        )
    }

    private func deleteHabit() {
        dismissView()
        navigation.path = NavigationPath()

        modelContext.delete(habit)
        try? modelContext.save()
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return NavigationStack {
            SingleHabitSettingsView(habit: previewer.habit)
        }
        .modelContainer(previewer.container)
    } catch {
        return Text("failed to create preview: \(error.localizedDescription)")
    }

}
