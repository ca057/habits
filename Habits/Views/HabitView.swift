//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI

struct HabitView: View {
    var habit: Habit
    let viewModel = HabitViewModel()
    
    @Environment(\.dismiss) private var dismissView
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            List {
                Text(habit.name ?? "")
                
                Section("Danger Zone") {
                    Button("Delete habit", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
        }
        .alert("Delete habit?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteHabit(habit)
                dismissView()
            }
        }
        .navigationTitle(habit.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct HabitView_Previews: PreviewProvider {
//    static var previews: some View {
//        HabitView()
//    }
//}
