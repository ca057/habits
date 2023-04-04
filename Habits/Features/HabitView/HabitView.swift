//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI

struct HabitView: View {
    @StateObject var viewModel: ViewModel
    
    @Environment(\.dismiss) private var dismissView
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            Form {                
                Section("Overview") {
                    ReversedCalendar(endDate: viewModel.earliestEntry) { date in
                        let isOnWeekend = date?.compare(.isWeekend) ?? false
                        let dimForWeekend = isOnWeekend ? 0.75 : 0
                        
                        if viewModel.hasEntryForDate(date) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(viewModel.colour.toColor())
                                .grayscale(dimForWeekend)
                        } else if let date = date {
                            Text(CalendarUtils.shared.calendar.component(.day, from: date).description)
                                .font(.footnote.monospacedDigit())
                                .fontWeight(isOnWeekend ? .light : .regular)
                                .grayscale(dimForWeekend)
                        }
                    }
                    // TODO: add load more button here
                }
                .buttonStyle(BorderlessButtonStyle())
                
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
        .onDisappear(perform: { viewModel.saveChanges() }) // TODO: why?
    }
    
    init(_ habit: Habit) {
        _viewModel = StateObject(wrappedValue: ViewModel(habit))
    }
}
