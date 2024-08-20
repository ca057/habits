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

struct HabitOverviewItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(\.navigation) private var navigation

    var habit: Habit
    var days: [Date]
    
    @Query private var entries: [Entry]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(habit.name)
            
            HStack(spacing: 16) {
                ForEach(days, id: \.self) { day in
                    VStack {
                        RoundedRectangle(cornerSize: CGSize(width: 48, height: 48))
                            .fill(habit.asColour.toColor().opacity(hasEntry(for: day) ? 1 : 0.15))
                            .strokeBorder(habit.asColour.toColor().opacity(0.5), lineWidth: 0.5)
                            .frame(height: 48)
                            .onTapGesture(perform: { toggleEntry(on: day) })

                        Text(day.formatted(Date.FormatStyle().weekday(.abbreviated)))
                            .font(.footnote)
//                            .foregroundStyle(
//                                day.compare(.isWeekend) ? Color.secondary.opacity(0.5) : Color.secondary
//                            )
                            .monospaced()
                    }
                }.frame(maxWidth: .infinity)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.15))
        )
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
    
    private func hasEntry(for date: Date) -> Bool {
        entries.contains { entry in CalendarUtils.shared.calendar.isDate(entry.date, inSameDayAs: date) }
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

    private var weekOf: Date
    private var weekDays: [Date] {
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekOf)
        
        guard let weekInterval = weekInterval else { return [] }
        
        return calendar.generateDates(
            inside: weekInterval,
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
                            HabitOverviewItem(for: habit, days: weekDays)
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
    
    init(forWeekOf weekOf: Date) {
        self.weekOf = weekOf
    }
}

#Preview("default") {
    do {
        let previewer = try Previewer()
        
        return NavigationStack {
            Overview(forWeekOf: Date.now)
                .modelContainer(previewer.container)
                .environment(\.calendar, CalendarUtils.shared.calendar)
        }
        .tint(.primary)
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
}

#Preview("empty") {
    do {
        return NavigationStack {
            Overview(forWeekOf: Date.now)
        }
        .tint(.primary)
    } catch {
        return Text("error creating preview: \(error.localizedDescription)")
    }
}
