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
                    .font(.system(size: 12))
                    .monospaced()
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
            }
        }
        .padding(.vertical, 4)
        .background(
            Gradient(
                stops: [
                    .init(color: Color.bg, location: 0),
                    .init(color: Color.bg.opacity(0.5), location: 0.75),
                    .init(color: Color.bg.opacity(0), location: 1)
                ]
            )
        )
    }
}

struct NextOverViewItem: View {
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

            ForEach(days, id: \.self) { day in
                EntryItem(
                    count: 1,
                    color: habit.asColour.toColor(),
                    secondaryColor: Color.secondary.mix(with: .white, by: 0.75),
                    highlighted: false,
                    size: CGFloat(24)
                )
            }
        }.padding(.vertical, 4)
    }
    
    init(_ habit: Habit, range days: [Date]) {
        self.habit = habit
        self.days = days
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
                    Section(header: DaysHeader(days: days)) {
                        ForEach(habits, id: \.self) { habit in
                            Divider()
                            NavigationLink(value: habit) {
                                NextOverViewItem(habit, range: days)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .background(Color.bg)
            .scrollBounceBehavior(.basedOnSize)
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
