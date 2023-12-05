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
                Section("Timeline") {
                    HistoryMonthView(
                        startOfMonth: Date.now,
                        cell: { date in
                            let isInTheFuture = date.compare(.isInTheFuture)
                            let isWeekend = date.compare(.isWeekend)
                            
                            var fillColor: Color {
                                if isWeekend {
                                    return color == Color.primary ? Color.gray : color
                                }
                                return color
                            }

                            Button(action: {
                                viewModel.toggleEntryFor(date)
                            }, label: {
                                VStack {
                                    RoundedRectangle(cornerRadius: .infinity)
                                        .fill(viewModel.hasEntryForDate(date) ? fillColor : .clear)
                                        .stroke(isInTheFuture ? .secondary : fillColor, lineWidth: 4)
                                        .grayscale(isWeekend ? 0.75 : 0)
                                        .frame(width: 16, height: 24)
                                    
                                    Text(date.toString(format: .custom("d")) ?? "")
                                        .font(.footnote.monospacedDigit())
                                        .fontWeight(date.compare(.isToday) ? .bold : .regular)
                                        .fontDesign(.rounded)
                                    
                                }
                            })
                            .disabled(isInTheFuture)
                            .buttonStyle(.borderless)
                            .padding(.bottom, 4)
                            .foregroundStyle(isInTheFuture || isWeekend ? .secondary : .primary)
                            .opacity(isInTheFuture && isWeekend ? 0.75 : 1)
                        }
                    )
                    Button("open full history") {
                        viewModel.showHistorySheet = true
                    }
                }

                Section("Overview") {
                    ReversedCalendar(endDate: viewModel.earliestEntry) { date in
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
        .sheet(isPresented: $viewModel.showHistorySheet) {
            HabitHistoryView()
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

#Preview {
    let habit = Habit(context: DataController.shared.container.viewContext)

    habit.colour = Colour.green.toLabel()
    habit.entry = []
    
    return HabitView(habit)
}
