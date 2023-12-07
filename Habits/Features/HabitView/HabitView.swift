//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI


struct TimelineItem: Identifiable, Hashable {
    let id = UUID()
    var offset: Int
}

struct HabitView: View {
    var color : Color
    @StateObject var viewModel: ViewModel
    
    @Environment(\.dismiss) private var dismissView
    @State private var showDeleteConfirmation = false
    
    
    @State private var timelineItems = [
        TimelineItem(offset: 0),
    ]
    @State private var selectedOffset: Int = 0
    
    func insertTimelineItemIfRequiredFor(displayedOffset: Int) {
        let earliestOffset = timelineItems[0].offset

        if displayedOffset == earliestOffset {
            print("inserting item")
            timelineItems.insert(TimelineItem(offset: earliestOffset + 1), at: 0)
        }
    }

    var body: some View {
        VStack {
            Form {
                Section("Timeline") {
                    TabView(selection: $selectedOffset) {
                        ForEach(timelineItems, id: \.self) { item in
                            VStack{
                                Text("hello")
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
                            }
//                            .frame(maxWidth: .infinity)
                            .tag(item.offset)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onAppear { insertTimelineItemIfRequiredFor(displayedOffset: selectedOffset) }
                    .onChange(of: selectedOffset) { _, shownOffset in insertTimelineItemIfRequiredFor(displayedOffset: shownOffset) }
                }
            
//                Section("Timeline") {
//                    HistoryMonthView(
//                        startOfMonth: Date.now,
//                        cell: { date in
//                            let isInTheFuture = date.compare(.isInTheFuture)
//                            let isWeekend = date.compare(.isWeekend)
//                            
//                            var fillColor: Color {
//                                if isWeekend {
//                                    return color == Color.primary ? Color.gray : color
//                                }
//                                return color
//                            }
//
//                            Button(action: {
//                                viewModel.toggleEntryFor(date)
//                            }, label: {
//                                VStack {
//                                    RoundedRectangle(cornerRadius: .infinity)
//                                        .fill(viewModel.hasEntryForDate(date) ? fillColor : .clear)
//                                        .stroke(isInTheFuture ? .secondary : fillColor, lineWidth: 4)
//                                        .grayscale(isWeekend ? 0.75 : 0)
//                                        .frame(width: 16, height: 24)
//                                    
//                                    Text(date.toString(format: .custom("d")) ?? "")
//                                        .font(.footnote.monospacedDigit())
//                                        .fontWeight(date.compare(.isToday) ? .bold : .regular)
//                                        .fontDesign(.rounded)
//                                    
//                                }
//                            })
//                            .disabled(isInTheFuture)
//                            .buttonStyle(.borderless)
//                            .padding(.bottom, 4)
//                            .foregroundStyle(isInTheFuture || isWeekend ? .secondary : .primary)
//                            .opacity(isInTheFuture && isWeekend ? 0.75 : 1)
//                        }
//                    )
//                    Button("open full history") {
//                        viewModel.showHistorySheet = true
//                    }
//                }
//                
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
