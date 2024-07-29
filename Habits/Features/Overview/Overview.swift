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

struct OverviewItem: View {
    var habit: Habit
    
    var days: [Date]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(habit.name)
                .font(.title3)
            
            HStack {
                ForEach(days, id: \.self) { day in
                    VStack {
                        Circle()
                            .strokeBorder(.green, lineWidth: 2)

                        Text(
                            day.toString(
                                format: .custom("dd"),
                                locale: Locale(identifier: Locale.current.language.languageCode?.identifier ?? "en")
                            ) ?? ""
                                .padding(leftTo: 2, withPad: " ") // TODO: test this
                        )
                        .font(.subheadline)
                        .monospaced()
                    }
                }.frame(maxWidth: .infinity)
            }
        }
//        .background(.red.opacity(0.5))
    }
    
    init(for habit: Habit, days: [Date]) {
        self.habit = habit
        self.days = days
    }
}

struct Overview: View {
    @Environment(\.calendar) private var calendar
//    @Environment(\.modelContext) private var modelContext
    
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
                    VStack(spacing: 16) {
                        ForEach(habits) { habit in
                            OverviewItem(for: habit, days: weekDays)
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
