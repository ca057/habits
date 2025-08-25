//
//  NextOverview.swift
//  Habits
//
//  Created by Christian Ost on 25.05.25.
//

import SwiftUI
import SwiftData

struct DaysHeader: View {
    var days: [Date]
    
    var body: some View {
        HStack(spacing: 4) {
            Spacer()
            
            ForEach(days, id: \.self) { day in
                Text(day.formatted(Date.FormatStyle().weekday(.narrow)))
                    .font(.footnote)
                    .monospaced()
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
            }
        }
    }
}

struct NextOverViewItem: View {
    var id: UUID
    var days: [Date]
    
    @Query private var queriedHabits: [Habit]
    private var habit: Habit? { queriedHabits.first }

    @Query private var entries: [Entry]

    var body: some View {
        if let habit = habit {
            VStack() {
                HStack(spacing: 4) {
                    Text(habit.name)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .monospaced()
                        .padding(.bottom, 4)
                        
                    Spacer()

                    ForEach(days, id: \.self) { day in
                        EntryItem(
                            count: 1,
                            color: habit.asColour.toColor(),
                            secondaryColor: Color.secondary.mix(with: .white, by: 0.75),
                            highlighted: false,
                            size: CGFloat(24)
                        )
                    }
                
                }
            }.padding(.vertical, 4)
        } else {
            Text("TODO")
        }
    }
    
    init(id: UUID, range days: [Date]) {
        self.id = id
        self.days = days
        
        _queriedHabits = Query(filter: #Predicate { $0.id == id })
        _entries = Query(
            filter: #Predicate<Entry> { $0.habit?.id == id },
            sort: [SortDescriptor(\Entry.date, order: .reverse)]
        )
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

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                Section(header: DaysHeader(days: days)) {
                    ForEach(habits, id: \.self) { habit in
                        Divider()
                        NextOverViewItem(id: habit.id, range: days)
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color.bg)
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
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
