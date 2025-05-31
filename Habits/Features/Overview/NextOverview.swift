//
//  NextOverview.swift
//  Habits
//
//  Created by Christian Ost on 25.05.25.
//

import SwiftUI
import SwiftData

struct Headline: View {
    var body: some View {
        Text("Good morning!")
            .font(.title)
//            .fontDesign(.monospaced)
            .fontWidth(.condensed)
    }
}

struct DaysHeader: View {
    @Environment(\.calendar) private var calendar

    var from: Date
    var to: Date

    private var days: [Date] {
        return calendar.generateDates(
            inside: DateInterval(start: from, end: to),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            HStack {
                ForEach(days, id: \.self) { day in
                    Spacer()
                    Text(day.formatted(Date.FormatStyle().weekday(.narrow)))
                        .font(.footnote)
                        .monospaced()
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .containerRelativeFrame(.horizontal, count: 2, span: 1, spacing: 0)
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

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                Headline()
                    .padding(.bottom)

                Section(header: DaysHeader(from: from, to: to)) {
                    ForEach(habits, id: \.self) { habit in
                        Text(habit.name)
                            .monospaced()
                    }
                }
            }
        }
        .padding(.horizontal)
//        .scrollBounceBehavior(.basedOnSize)
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
