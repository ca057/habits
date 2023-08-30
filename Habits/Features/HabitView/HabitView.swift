//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI

struct HabitView: View {
    var color : Color
    @StateObject var viewModel: ViewModel
    
    @Environment(\.dismiss) private var dismissView
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            Form {                
                Section("Overview") {
                    VStack {
                        ReversedCalendar(endDate: viewModel.currentEarliestScope) { date in
                            let isInWeekend = date?.compare(.isWeekend) ?? false
                            let dimForWeekend = isInWeekend ? 0.75 : 0
                            var fillColor: Color {
                                if isInWeekend {
                                    return color == Color.primary ? Color.gray : color
                                }
                                return color
                            }
                            var grayScale: Double { isInWeekend ? 0.75 : 0 }
                            
                            if viewModel.hasEntryForDate(date) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(fillColor)
                                    .grayscale(dimForWeekend)
                            } else if let date = date {
                                Text(CalendarUtils.shared.calendar.component(.day, from: date).description)
                                    .font(.footnote.monospacedDigit())
                                    .fontWeight(isInWeekend ? .light : .regular)
                                    .grayscale(dimForWeekend)
                            }
                        }

                        HStack {
                            Button("Show less") {
                                viewModel.decreaseCurrentVisibleScope()
                            }
                                .disabled(viewModel.cannotLoadLess)
                                .padding(.trailing)
                                .font(.subheadline)

                            Button("Show more") {
                                viewModel.increaseCurrentVisibleScope()
                            }
                                .disabled(viewModel.cannotLoadMore)
                                .font(.subheadline)
                        }
                    }
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
        let wrappedViewModel = ViewModel(habit)
        _viewModel = StateObject(wrappedValue: wrappedViewModel)
        self.color = wrappedViewModel.colour.toColor()
    }
}

struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
//        HabitView(Habit.preview)
        Text("preview missing")
    }
}
