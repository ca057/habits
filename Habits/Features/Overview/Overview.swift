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

    var habit: Habit
    var days: [Date]
    
    @State private var itemHeight = 48.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(habit.name)
            
            HStack(spacing: 16) {
                ForEach(days, id: \.self) { day in
                    VStack {
                        RoundedRectangle(cornerSize: CGSize(width: 12, height: 12))
                            .fill(habit.asColour.toColor().opacity(0.15))
                            .strokeBorder(
                                colorScheme == .dark ? habit.asColour.toColor().opacity(0.5) : .clear,
                                lineWidth: 1
                            )
                            .frame(height: 48)

                        Text(day.formatted(Date.FormatStyle().weekday(.abbreviated)))
                            .font(.footnote)
                            .foregroundStyle(.primary.secondary)
                            .monospaced()
                    }
                }.frame(maxWidth: .infinity)
            }
        }
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
                    // TODO: add numeric days as section to top
                    VStack(spacing: 16) {
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
