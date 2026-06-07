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
                    let targetDay = Entry.dayString(from: day)
                    let entriesForDay = habit.entry.filter({ $0.day == targetDay })
                    
                    EntryItemButton(
                        count: entriesForDay.count,
                        color: habit.asColour.toColor(),
                        secondaryColor: Color.secondary,
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
        }
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

struct HomeView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.navigation) private var navigation
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
        List {
            Section {
                ForEach(habits) { habit in
                    // TODO: move the navigation into the label / white space part
                    // Text + Spacer // .contentShape(.rect) + .onTapGesture
                    Button {
                        navigation.path.append(habit)
                    } label: {
                        OverViewItem(habit, range: days)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(.isLink)
                    .accessibilityLabel(habit.name)
                    .accessibilityHint("View details of habit")
                }
                .onMove(perform: reorderHabits)
                
                HStack {
                    Button("New habit", systemImage: "plus") {
                        showingAddHabit = true
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowSeparator(.hidden)
            } header: {
                DaysHeader(for: days)
            }
        }
        .listStyle(.inset)
        .scrollIndicators(.hidden)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gearshape") {
                    showingSettings = true
                }
            }
        }
        .toolbarRole(.browser)
        .sheet(isPresented: $showingSettings, content: { SettingsView() })
        .sheet(isPresented: $showingAddHabit, content: { AddHabitView() })

    }

    private func reorderHabits(from: IndexSet, to: Int) {
        var reordered = habits
        reordered.move(fromOffsets: from, toOffset: to)
        reordered.enumerated().forEach { index, habit in
            habit.order = Int16(index)
        }
    }
}

#Preview("default") {
    do {
        let previewer = try Previewer()

        return NavigationStack {
            HomeView(habits: previewer.habits, from: Date.now.offset(.day, value: -6) ?? Date.now, to: Date.now)
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
            HomeView(habits: [], from: Date.now.offset(.day, value: -6) ?? Date.now, to: Date.now)
                .modelContainer(previewer.container)
                .environment(\.calendar, CalendarUtils.shared.calendar)
        }.tint(.primary)
    } catch {
        return Text("error creating preview")
    }
}
