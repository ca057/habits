//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI

fileprivate struct SectionHeader: View {
    private var text: String

    var body: some View {
        Text(text)
            .font(.headline)
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }
    
    init(_ text: String) {
        self.text = text
    }
}

struct HabitView: View {
    @StateObject var viewModel: ViewModel
    
    @Environment(\.dismiss) private var dismissView
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            Form {                
                Section {
                    VStack {
                        SectionHeader("Overview")

                        ReverseCalendarView(endDate: viewModel.latestEntry) { date in
                            if viewModel.hasEntryForDate(date) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(viewModel.colour.toColor())
                            } else if let date = date {
                                Text(CalendarHelper().calendar.component(.day, from: date).description)
                                    .font(.footnote.monospacedDigit())
                                    .fontWeight(date.compare(.isWeekend) ? .light : .regular)
                            }
                        }
                        // TODO: add load more button here
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Section {
                    VStack {
                        SectionHeader("Settings")
                        
                        TextField("Name", text: $viewModel.name)
                        
                        VStack(alignment: .leading) {
                            Text("Colour")
                            ColourPicker(colours: Colour.allCasesSorted, selection: $viewModel.colour)
                                .padding(.bottom, 4)
                        }
                    }
                }
                
                Section {
                    VStack {
                        SectionHeader("Danger Zone")
                        
                        Button("Delete habit", role: .destructive) {
                            showDeleteConfirmation = true
                        }
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
