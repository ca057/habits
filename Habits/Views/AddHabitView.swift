//
//  AddHabitView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismissView
    
    @ObservedObject private var viewModel = AddHabitViewModel()

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $viewModel.name)
            }
            .navigationTitle("Add habit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: { dismissView() })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: handleSave)
                        .disabled(!viewModel.isValid)
                }
            }
        }
    }
    
    func handleSave() {
        _ = viewModel.saveHabit()
        // TODO: show error if saving wasn’t successful
        dismissView()
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
    }
}
