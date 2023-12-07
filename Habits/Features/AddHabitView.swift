//
//  AddHabitView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismissView
    
    @State private var isValid = false
    @State private var name = "" {
        didSet {
            isValid = !name.isEmpty
        }
    }
    @State private var bgColour = Colour.allCasesSorted[0]

    var body: some View {
        NavigationView {
            Form {
                TextField("I want to track...", text: $name)
                    .accessibilityLabel("Name of your new habit")
                Section {
                    VStack(alignment: .leading) {
                        Text("Pick a colour")
                        ColourPicker(
                            colours: Colour.allCasesSorted,
                            selection: $bgColour
                        )
                        .accessibilityLabel("Background colour")
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add habit")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: { dismissView() })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: handleSave)
                        .disabled(!isValid)
                }
            }
        }
    }
    
    func handleSave() {
        // TODO: save data
        // TODO: show error if saving wasn’t successful
        dismissView()
    }
}

#Preview {
    AddHabitView()
}
