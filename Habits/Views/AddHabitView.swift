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
                Button(viewModel.isValid ? "Save" : "Cancel") {
                    if viewModel.isValid {
                        viewModel.saveHabit()
                    }
                    dismissView()
                }
//                .id("ahv_add")
            }
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
    }
}
