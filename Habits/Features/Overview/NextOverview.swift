//
//  NextOverview.swift
//  Habits
//
//  Created by Christian Ost on 25.05.25.
//

import SwiftUI
import SwiftData

struct DaysHeader: View {
    private var days: [Date]
    
    var body: some View {
        HStack(spacing: 4) {
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(days, id: \.self) { day in
                    Text(day.formatted(Date.FormatStyle().weekday(.narrow)))
                        .font(.system(size: 12))
                        .monospaced()
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    init(for days: [Date]) {
        self.days = days
    }
}

struct NextOverViewItem: View {
    @Environment(\.calendar) private var calendar
    
    var habit: Habit
    var days: [Date]
    
    @Query(filter: Predicate<Entry>.false) private var entries: [Entry]

    var body: some View {
        HStack(spacing: 4) {
            Text(habit.name)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.bottom, 4)
                
            Spacer()

            ForEach(days, id: \.self) { day in
                let count = entries.count(where: { calendar.isDate(day, inSameDayAs: $0.date) })

                EntryItem(
                    count: count,
                    color: habit.asColour.toColor(),
                    secondaryColor: Color.secondary.mix(with: .white, by: 0.75),
                    highlighted: false,
                    size: CGFloat(24)
                )
            }
        }.padding(.vertical, 4)
    }
    
    // TODO: make days a daysrange protocol to enforce that it has at least two dates
    init(_ habit: Habit, range days: [Date]) {
        self.habit = habit
        self.days = days
        
        guard let firstDay = days.first else {
            // TODO: get rid of this when the daysrange protocol exists
            fatalError("No days provided")
        }

        let habitId = habit.persistentModelID
        let entriesFetchDescriptor = FetchDescriptor<Entry>(
            predicate: #Predicate {
                $0.habit?.persistentModelID == habitId && $0.date >= firstDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        _entries = Query(entriesFetchDescriptor)
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
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                    Section(header: DaysHeader(for: days)) {
                        ForEach(habits, id: \.self) { habit in
                            if habit != habits.first {
                                Divider()
                            }
                            NavigationLink(value: habit) {
                                NextOverViewItem(habit, range: days)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .background(Color.bg)
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
                VStack {}
                    .frame(maxWidth: .infinity)
                    .background(.bg)
            }
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
