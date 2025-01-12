//
//  Overview.swift
//  Habits
//
//  Created by Christian Ost on 27.07.24.
//

import SwiftUI
import SwiftData

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
    
    private let cornerSize = CGSize(width: 4, height: 4)
    
    var body: some View {
        RoundedRectangle(cornerSize: cornerSize)
            .fill(color.opacity(hasEntry ? 1 : 0.1))
            .frame(height: 48)
            .onTapGesture(perform: { toggleEntry(day) })
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(color)
                    .frame(height: 2)
            }
            .overlay(alignment: .bottom) {
                Text(day.formatted(Date.FormatStyle().weekday(.short)))
                    .font(.footnote)
                    .monospaced()
                    .fontWeight(calendar.isDateInToday(day) ? .bold : .thin)
                    .foregroundStyle(hasEntry ? Color(UIColor.systemBackground) : Color.secondary)
                    .padding(.bottom, 4)
            }
            .clipShape(RoundedRectangle(cornerSize: cornerSize))
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

        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                .fill(.gray.tertiary.opacity(0.5))

            VStack(alignment: .leading, spacing: 8) {
                Text(habit.name)
                
                HStack(spacing: 16) {
                    ForEach(days, id: \.self) { day in
                        EntryButton(
                            day: day,
                            hasEntry: groupedEntriesByDate.index(forKey: day.formatted(.dateTime.year().month().day())) != nil,
                            color: habit.asColour.toColor(),
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
            predicate: #Predicate<Entry> { $0.habit?.persistentModelID == habitModelId && (days.first != nil ? $0.date >= days.first! : true) },
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

struct Overview: View {
    @Environment(\.calendar) private var calendar

    @State private var showingAddHabit = false
    @State private var showingSettings = false

    @Query(Habit.sortedWithEntries) var habits: [Habit]

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
                    // TODO: add numeric days as section to top
                    VStack(spacing: 8) {
                        ForEach(habits) { habit in
                            HabitOverviewItem(for: habit, days: days)
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
