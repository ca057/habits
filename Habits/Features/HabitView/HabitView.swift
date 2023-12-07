//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI

fileprivate struct TabTimelineContainer<Content: View>: View {
    @State private var timelineItems = [
        TimelineItem(offset: 0)
    ]
    @State private var timelineItemHeights: [CGFloat] = [0.0]
    @State private var selectedOffset = 0
    @State private var timelineHeight: CGFloat = 0.0
    
    @ViewBuilder var content: (_ offset: Int) -> Content

    var body: some View {
        TabView(selection: $selectedOffset) {
            ForEach(timelineItems, id: \.self) { item in
                VStack {
                    content(item.offset)
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                if let index = timelineItems.firstIndex(of: item) {
                                    timelineItemHeights[index] = geo.size.height
                                    updateCurrentHeightFor(selectedOffset)
                                }
                            }
                        })
                        .frame(alignment: .top)
                }
                .transition(.opacity)
                .tag(item.offset)
            }
        }
        .frame(minHeight: timelineHeight)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear { handleOffsetUpdate(offset: selectedOffset) }
        .onChange(of: selectedOffset) { _, displayedOffset in
            handleOffsetUpdate(offset: displayedOffset)
        }
    }
    
    private func handleOffsetUpdate(offset: Int) {
        insertTimelineItemIfRequiredFor(offset)
        updateCurrentHeightFor(offset)
    }
    
    private func updateCurrentHeightFor(_ displayedOffset: Int) {
        let visibleIndex = timelineItems.firstIndex(where: { item in
            item.offset == displayedOffset
        })
        
        if let visibleIndex = visibleIndex {
            let nextHeight = timelineItemHeights[visibleIndex]
            
            if timelineHeight != nextHeight {
                timelineHeight = nextHeight
            }
        }
    }
    
    private func insertTimelineItemIfRequiredFor(_ displayedOffset: Int) {
        let earliestOffset = timelineItems[0].offset
        
        if displayedOffset == earliestOffset {
            timelineItems.insert(TimelineItem(offset: earliestOffset + 1), at: 0)
            timelineItemHeights.insert(0.0, at: 0)
        }
    }
    
    private struct TimelineItem: Identifiable, Hashable {
        let id = UUID()
        var offset: Int
    }
}

struct HabitView: View {
    private var color : Color
    @StateObject private var viewModel: ViewModel
    
    @Environment(\.calendar) private var calendar
    @Environment(\.dismiss) private var dismissView
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            Form {
                Section("Timeline") {
                    TabTimelineContainer { positiveOffset in
                        HistoryMonthView(
                            startOfMonth: Date().adjust(for: .startOfMonth, calendar: calendar)!.offset(.month, value: positiveOffset * -1)!, // get rid of !
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
