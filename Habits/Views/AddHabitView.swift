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

    private var isValid: Bool {
        !viewModel.name.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $viewModel.name)
            }
            .navigationTitle("Add habit")
            .toolbar {
                Button(isValid ? "Save" : "Cancel") {
                    if isValid {
                        viewModel.saveHabit()
                    }
                    dismissView()
                }
            }
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
    }
}
