//
//  AddHabitView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismissView
    
    @ObservedObject var viewModel: AddHabitViewModel = AddHabitViewModel()

    var body: some View {
        NavigationView {
            Form {
                TextField("I want to track...", text: $viewModel.name)
                    .accessibilityLabel("Name of your new habit")
                Section {
                    VStack(alignment: .leading) {
                        Text("Pick a colour")
                        ColourPicker(
                            colours: Colour.allCasesSorted,
                            selection: $viewModel.bgColour
                        )
                        .accessibilityLabel("Background colour")
                    }
                    .padding(.vertical)
                }
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
