//
//  SingleHabitSettingsView.swift
//  Habits
//
//  Created by Christian Ost on 11.05.24.
//

import SwiftUI

struct SingleHabitSettingsView: View {
    @Environment(\.dismiss) private var dismissView
    var habit: Habit
    
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack {
            TextField("Name", text: Bindable(habit).name)
            VStack(alignment: .leading) {
                Text("Colour")
                ColourPicker(colours: Colour.allCasesSorted, selection: Bindable(habit).asColour)
                    .frame(minHeight: 32)
            }
            .padding(.bottom)
            Button("Delete habit", role: .destructive) {
                showingDeleteConfirmation = true
            }
        }
        .navigationTitle("Settings (\(habit.name))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismissView() })
                    .fontWeight(.bold)
                    .tint(.primary)
            }
        }
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
