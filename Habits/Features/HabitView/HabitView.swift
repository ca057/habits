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


struct HabitViewContent: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(\.dismiss) private var dismissView
    
    var habit: Habit
    var entries: [Entry]
    
    @State private var daysWithEntries: Set<String>
    @State private var showDeleteConfirmation = false
    
    private var selectedForegroundColor: Color {
        if habit.asColour.toColor() == Color.primary {
#if os(macOS)
            return Color(NSColor.windowBackgroundColor)
#else
            return Color(UIColor.systemBackground)
#endif
        }
        return Color.primary
    }
    
    var body: some View {
        // TODO: make this a bit nicer
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
//                                                .background {
//                                                    if hasEntry(for: date) {
//                                                        Pill(color: fillColor, filled: Binding.constant(true))
//                                                            .grayscale(isWeekend ? 0.75 : 0)
//                                                            .transition(.scale.animation(.easeIn(duration: 0.05)))
//                                                    }
//                                                }
                                                .frame(minHeight: 32)
                                        }
                                    })
                                    .disabled(isInTheFuture)
                                    .buttonStyle(.borderless)
                                    // make this work for all designs
                                    .foregroundStyle((isInTheFuture || isWeekend) && !hasEntry(for: date) ? .secondary : hasEntry(for: date) ? selectedForegroundColor : .primary)
                                    .opacity(isInTheFuture ? 0.5 : 1)
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
            .onChange(of: entries, computeDaysWithEntries)
    }
    
    init(habit: Habit, entries: [Entry]) {
        self._daysWithEntries = State(initialValue: Set(entries.map { $0.date.toString(format: .isoDate)! }))
        self.habit = habit
        self.entries = entries
    }

    
    private func computeDaysWithEntries() {
        // TODO: get rid of !
        daysWithEntries = Set(entries.map { $0.date.toString(format: .isoDate)! })
    }

    private func deleteHabit() {
        modelContext.delete(habit)
        try? modelContext.save()
    }
    
    private func toggleEntryFor(_ date: Date) {
        if let entry = habit.entry.first(where: { entry in calendar.isDate(entry.date, inSameDayAs: date) }) {
            modelContext.delete(entry)
        } else {
            let entry = Entry(date: date, habit: habit)
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }
    
    private func hasEntry(for date: Date) -> Bool {
        guard let isoDate = date.toString(format: .isoDate) else { return false }
        
        return daysWithEntries.contains(isoDate)
    }
}

struct HabitView: View {
    private var id: UUID

    @Query private var queriedHabits: [Habit]
    private var habit: Habit? {
        queriedHabits.first
    }
    @Query private var entries: [Entry]

    var body: some View {
        if let habit = habit {
            HabitViewContent(habit: habit, entries: entries)
        } else {
            EmptyView()
        }
    }
    
    init(id: UUID) {
        self.id = id
        
        _queriedHabits = Query(filter: #Predicate { $0.id == id })
        
        _entries = Query(
            filter: #Predicate<Entry> { $0.habit?.id == id },
            sort: [SortDescriptor(\Entry.date, order: .reverse)]
        )
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return HabitView(id: previewer.habit.id)
            .modelContainer(previewer.container)
    } catch {
        return Text("failed to create preview: \(error.localizedDescription)")
    }
}
