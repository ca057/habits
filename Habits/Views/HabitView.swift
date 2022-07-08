//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI

struct HabitView: View {
    @StateObject var viewModel: HabitViewModel
    
    @Environment(\.dismiss) private var dismissView
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            Form {
                Text("You’re working on this habit since \(viewModel.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "N/A") – nice job!")
                
                Section("Statistics") {
                    Ghraph(from: viewModel.earliestEntry, to: viewModel.latestEntry) { date in
                        Text(viewModel.hasEntryForDate(date) ? "X" : "")
                    }
                }
                
                Section("Settings") {
                    TextField("Name", text: $viewModel.name)
                    VStack(alignment: .leading) {
                        Text("Colour")
                        ColourPicker(colours: Colour.allCasesSorted, selection: $viewModel.colour)
                            .padding(.bottom, 4)
                    }
                }
                
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
                viewModel.deleteHabit()
                dismissView()
            }
        }
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: viewModel.saveChanges)
    }
    
    init(_ habit: Habit) {
        _viewModel = StateObject(wrappedValue: HabitViewModel(habit))
    }
}
