//
//  Overview.swift
//  Habits
//
//  Created by Christian Ost on 27.07.24.
//

import SwiftUI
import SwiftData

struct DropViewDelegate<T: Equatable> : DropDelegate {
    let destinationItem: T
    @Binding var items: [T]
    @Binding var draggedItem: T?
    var onSortFinished : (([T]) -> Void)
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem else { return }
        guard let fromIndex = items.firstIndex(of: draggedItem) else { return }
        guard let toIndex = items.firstIndex(of: destinationItem) else { return }
        
        if fromIndex != toIndex {
            withAnimation {
                items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        onSortFinished(items)
        return true
    }
}

struct EmptyOverview: View {
    var onAddHabit: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Button(action: onAddHabit, label: {
                Label("New habit", systemImage: "plus")
                    .font(.headline)
            })
            .buttonStyle(.bordered)
            
            Spacer()
            Spacer()
        }
    }
}

fileprivate struct EntryButton: View {
    @Environment(\.calendar) private var calendar

    var day: Date
    var hasEntry: Bool
    var color: Color
    var toggleEntry: (Date) -> Void
    
    var body: some View {
        Circle()
            .fill(color.opacity(hasEntry ? 1 : 0))
            .background {
                Circle()
                    .fill(color.opacity(0.25))
                    .padding(.horizontal, 4)
            }
            .onTapGesture(perform: { toggleEntry(day) })
            .overlay(alignment: .center) {
                Text(day.formatted(Date.FormatStyle().weekday(.short)))
                    .font(hasEntry ? .footnote : .caption2)
                    .monospaced()
                    .fontWeight(calendar.isDateInToday(day) ? .bold : .regular)
                    .foregroundStyle(hasEntry ? Color(UIColor.systemBackground) : Color.secondary)
            }
            .animation(.easeInOut(duration: 0.2), value: hasEntry)
    }
}

struct HabitOverviewItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(\.navigation) private var navigation

    var habit: Habit
    var days: [Date]
    
    @Query private var entries: [Entry]

    var body: some View {
        let groupedEntriesByDate = Dictionary(
            grouping: entries, by: { $0.date.formatted(.dateTime.year().month().day()) }
        )
        let color = habit.asColour.toColor()

        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8), style: .continuous)
                .fill(.gray.tertiary.opacity(0.5))

            VStack(spacing: 12) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
            
                HStack(spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        EntryButton(
                            day: day,
                            hasEntry: groupedEntriesByDate.index(forKey: day.formatted(.dateTime.year().month().day())) != nil,
                            color: color,
                            toggleEntry: toggleEntry
                        )
                    }.frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
        .background(.background)
        .onTapGesture {
            navigation.path.append(habit)
        }
    }
    
    init(for habit: Habit, days: [Date]) {
        self.habit = habit
        self.days = days
        
        let habitModelId = habit.persistentModelID
        
        
        var descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { $0.habit?.persistentModelID == habitModelId },
            sortBy: [SortDescriptor(\Entry.date, order: .reverse)]
        )
        descriptor.fetchLimit = days.count
                
        _entries = Query(descriptor)
    }

    private func toggleEntry(on date: Date) {
        if let entry = habit.entry.first(where: { entry in calendar.isDate(entry.date, inSameDayAs: date) }) {
            modelContext.delete(entry)
            try? modelContext.save()
        } else {
            let entry = Entry(date: date, habit: habit)
            modelContext.insert(entry)
        }
    }
}

struct OverviewDisplay: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddHabit = false
    @State private var showingSettings = false
    
    @State private var draggedHabit: Habit?

    @State var habits: [Habit]
    var from: Date
    var to: Date

    private var days: [Date] {
        return calendar.generateDates(
            inside: DateInterval(start: from, end: to),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }

    var body: some View {
        VStack() {
            if habits.isEmpty {
                EmptyOverview(onAddHabit: { showingAddHabit = true })
                    .padding(.horizontal)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(habits) { habit in
                            HabitOverviewItem(for: habit, days: days)
                                .contentShape(.dragPreview, RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
                                .onDrag {
                                    self.draggedHabit = habit
                                    return NSItemProvider()
                                }
                                .onDrop(
                                    of: [.text],
                                    delegate: DropViewDelegate(
                                        destinationItem: habit,
                                        items: $habits,
                                        draggedItem: $draggedHabit,
                                        onSortFinished: updateSortOrder
                                    )
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingAddHabit = true
                } label: {
                    Label("New habit", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) { AddHabitView() }
        .sheet(isPresented: $showingSettings) { Settings() }
    }
    
    private func updateSortOrder(_ orderedHabits: [Habit]) -> Void {
        orderedHabits.enumerated().forEach { $1.order = Int16($0) }
    }
}

struct Overview: View {
    var from: Date
    var to: Date
    @Query(Habit.sortedWithEntries) var habits: [Habit]

    var body: some View {
        OverviewDisplay(habits: habits, from: from, to: to)
    }
}

#Preview("default") {
    do {
        let previewer = try Previewer()
        
        return NavigationStack {
            Overview(from: Date.now.offset(.day, value: -6) ?? Date.now, to: Date.now)
                .modelContainer(previewer.container)
                .environment(\.calendar, CalendarUtils.shared.calendar)
        }
        .tint(.primary)
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
}

#Preview("empty") {
    NavigationStack {
        Overview(from: Date.now.offset(.day, value: -7) ?? Date.now, to: Date.now)
    }
    .tint(.primary)
}
