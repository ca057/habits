//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI
import SwiftData

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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(\.dismiss) private var dismissView
    
    @Query private var queriedHabits: [Habit]
    private var habit: Habit? {
        queriedHabits.first
    }
    @Query private var entries: [Entry]
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        // TODO: make this a bit nicer
        if let habit = habit {
            VStack {
                Form {
                    Section("Timeline") {
                        TabTimelineContainer { positiveOffset in
                            HistoryMonthView(
                                startOfMonth: Date().adjust(for: .startOfMonth, calendar: calendar)!.offset(.month, value: positiveOffset * -1)!, // TODO: get rid of !
                                cell: { date in
                                    let isInTheFuture = date.compare(.isInTheFuture)
                                    let isWeekend = date.compare(.isWeekend)
                                    
                                    var fillColor: Color {
                                        let asColor = habit.asColour.toColor()
                                        if isWeekend {
                                            return asColor == Color.primary ? Color.gray : asColor
                                        }
                                        return asColor
                                    }
                                    
                                    Button(action: {
                                        toggleEntryFor(date)
                                    }, label: {
                                        VStack {
                                            Text(date.toString(format: .custom("d")) ?? "")
                                                .font(.footnote)
                                                .fontDesign(.rounded)
                                                .fontWeight(date.compare(.isToday) ? .bold : .regular)
                                                .background {
                                                    RoundedRectangle(cornerRadius: .infinity)
                                                        .fill(hasEntry(for: date) ? fillColor : .clear)
                                                        .grayscale(isWeekend ? 0.75 : 0)
                                                        .frame(width: 24, height: 32)
                                                }
                                                .frame(minHeight: 32)
                                        }
                                    })
                                    .disabled(isInTheFuture)
                                    .buttonStyle(.borderless)
                                    // make this work for all designs
                                    .foregroundStyle(isInTheFuture || isWeekend ? .secondary : .primary)
                                    .opacity(isInTheFuture ? 0.5 : isWeekend ? 0.75 : 1)
                                }
                            ).tag(habit.entry.count)
                        }
                    }
                    
                    Section("Settings") {
                        TextField("Name", text: Bindable(habit).name)
                        VStack(alignment: .leading) {
                            Text("Colour")
                            ColourPicker(colours: Colour.allCasesSorted, selection: Bindable(habit).asColour)
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
                    deleteHabit()
                    dismissView()
                }
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            EmptyView()
        }
    }
    
    init(id: UUID) {
        _queriedHabits = Query(filter: #Predicate { queriedHabit in
            queriedHabit.id == id
        })

        _entries = Query(
            filter: #Predicate<Entry> { $0.habit?.id == id },
            sort: [SortDescriptor(\Entry.date, order: .reverse)]
        )
    }
}

fileprivate extension HabitView {
    private func deleteHabit() {
        guard let habit = habit else { return }

        modelContext.delete(habit)
        try? modelContext.save()
    }
    
    private func toggleEntryFor(_ date: Date) {
        guard let habit = habit else { return }

        if let entry = habit.entry.first(where: { entry in calendar.isDate(entry.date, inSameDayAs: date) }) {
            modelContext.delete(entry)
        } else {
            let entry = Entry(date: date, habit: habit)
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }
    
    private func hasEntry(for date: Date) -> Bool {
        entries.contains { entry in CalendarUtils.shared.calendar.isDate(entry.date, inSameDayAs: date) }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    let habit = Habit(
        colour: Colour.green.toLabel(),
        createdAt: Date.now,
        id: UUID(),
        name: "preview",
        order: 0
    )
    
    container.mainContext.insert(habit)

    for i in 1..<10 {
        let entry = Entry(date: Date().adjust(day: i * Int.random(in: 1..<5)) ?? Date(), habit: habit)
        container.mainContext.insert(entry)
    }

    return HabitView(id: habit.id)
        .modelContainer(container)
}
