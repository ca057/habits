//
//  NextOverview.swift
//  Habits
//
//  Created by Christian Ost on 25.05.25.
//

import SwiftUI
import SwiftData

fileprivate let itemWidth = CGFloat(24)

struct DaysHeader: View {
    private var days: [Date]
    
    var body: some View {
        HStack(spacing: 4) {
            Spacer()
            
            HStack(spacing: 2) {
                ForEach(days, id: \.self) { day in
                    Text(day.formatted(Date.FormatStyle().weekday(.narrow)))
                        .font(.system(size: 12))
                        .monospaced()
                        .foregroundStyle(.secondary)
                        .frame(width: itemWidth)
            }
            }
        }
        .padding(.vertical, 4)
    }
    
    init(for days: [Date]) {
        self.days = days
    }
}

fileprivate struct OverViewItem: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var modelContext
    
    var habit: Habit
    var days: [Date]

    var body: some View {
        HStack(spacing: 4) {
            Text(habit.name)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.bottom, 4)
                
            Spacer()

            HStack(spacing: 2) {
                ForEach(days, id: \.self) { day in
                    let entriesForDay = habit.entry.filter({ calendar.isDate(day, inSameDayAs: $0.date) })
                    
                    EntryItemButton(
                        count: entriesForDay.count,
                        color: habit.asColour.toColor(),
                        secondaryColor: Color.secondary.mix(with: .white, by: 0.75),
                        highlighted: false,
                        size: itemWidth,
                        perform: {
                            if let firstEntry = entriesForDay.first {
                                // TODO: fix me for multiple entries per day
                                removeEntry(entry: firstEntry)
                            } else {
                                addEntry(for: day)
                            }
                        }
                    )
                }
            }
        }.padding(.vertical, 4)
    }
    
    // TODO: make days a daysrange protocol to enforce that it has at least two dates
    init(_ habit: Habit, range days: [Date]) {
        self.habit = habit
        self.days = days
    }
    
    private func addEntry(for day: Date) {
        withAnimation(.easeOut(duration: 0.1)) {
            let entry = Entry(date: day, habit: habit)
            modelContext.insert(entry)
            try? modelContext.save()
        }
    }
    
    private func removeEntry(entry: Entry) {
        withAnimation(.easeIn(duration: 0.1)) {
            modelContext.delete(entry)
            try? modelContext.save()
        }
    }
}

struct NextOverview: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var modelContext

    var habits: [Habit]
    var from: Date
    var to: Date

    private var days: [Date] {
        return calendar.generateDates(
            inside: DateInterval(start: from, end: to),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    @State private var showingSettings = false
    @State private var showingAddHabit = false

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                    if !habits.isEmpty {
                        Section(header: DaysHeader(for: days)) {
                            ForEach(habits, id: \.self) { habit in
                                NavigationLink(value: habit) {
                                    OverViewItem(habit, range: days)
                                        .padding(.vertical, 4)
                                }
                                
                                if habit != habits.last {
                                    Divider()
                                }
                            }
                        }
                    }
                }

                HStack {
                    Button("New habit", systemImage: "plus") {
                        showingAddHabit = true
                    }.buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .background(Color.bg)
            .scrollIndicators(.hidden)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape") {
                        showingSettings = true
                    }
                }
            }
            .sheet(isPresented: $showingSettings, content: { Settings() })
            .sheet(isPresented: $showingAddHabit, content: { AddHabitView() })
        }
    }
}

#Preview("default") {
    do {
        let previewer = try Previewer()

        return NavigationStack {
            NextOverview(habits: previewer.habits, from: Date.now.offset(.day, value: -6) ?? Date.now, to: Date.now)
                .modelContainer(previewer.container)
                .environment(\.calendar, CalendarUtils.shared.calendar)
        }.tint(.primary)
    } catch {
        return Text("error creating preview")
    }
}

#Preview("empty") {
    do {
        let previewer = try Previewer()
        
        return NavigationStack {
            NextOverview(habits: [], from: Date.now.offset(.day, value: -6) ?? Date.now, to: Date.now)
                .modelContainer(previewer.container)
                .environment(\.calendar, CalendarUtils.shared.calendar)
        }.tint(.primary)
    } catch {
        return Text("error creating preview")
    }
}
