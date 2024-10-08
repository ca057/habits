//
//  AddHabitView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismissView
    @Environment(\.modelContext) private var modelContext
    
    @State private var isValid = false
    @State private var name = ""
    @State private var bgColour = Colour.allCasesSorted[0]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        LabeledContent("Name") {
                            TextField("I want to track...", text: $name)
                                .accessibilityLabel("Name of your new habit")
                        }.labeledContentStyle(LTLabeledContentStyle())
                    }
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Pick a colour")
                        ColourPicker(
                            colours: Colour.allCasesSorted,
                            selection: $bgColour
                        )
                        .frame(minHeight: 32)
                        .accessibilityLabel("Background colour")
                    }
                    .padding(.bottom, 4)
                }
            }
            .navigationTitle("Add habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: { dismissView() })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: handleSave)
                        .disabled(!isValid)
                        .fontWeight(isValid ? .bold : .regular)
                }
            }
            .onChange(of: name) {
                isValid = !name.isEmpty
            }
        }
    }
    
    func handleSave() {
        modelContext.insert(Habit(name: name, colour: bgColour))
        // TODO: show error if it fails
        try? modelContext.save()
        dismissView()
    }
}

#Preview {
    NavigationStack {
        AddHabitView()
    }
}
