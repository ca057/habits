//
//  AddHabitView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismissView
    
    @StateObject var viewModel = ViewModel()

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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: { dismissView() })
                }
                ToolbarItem(placement: .topBarTrailing) {
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

extension AddHabitView {
    @MainActor final class ViewModel: ObservableObject {
        private var habitsStorage: HabitsStorage

        @Published var isValid = false
        @Published var name = "" {
            didSet {
                isValid = !name.isEmpty
            }
        }
        @Published var bgColour = Colour.allCasesSorted[0]
        
        func saveHabit() -> Bool {
            if !isValid {
                return false
            }
            self.habitsStorage.addHabit(name: name, colour: bgColour)
            return true
        }
        
        convenience init() {
            self.init(habitsStorage: .shared)
        }
        init(habitsStorage: HabitsStorage) {
            self.habitsStorage = habitsStorage
        }

    }
}
