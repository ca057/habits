//
//  HistoryView.swift
//  Habits
//
//  Created by Christian Ost on 16.09.23.
//

import SwiftUI

fileprivate extension Calendar {
    // copied from https://gist.github.com/mecid/f8859ea4bdbd02cf5d440d58e936faec

    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}

struct HistoryView: View {
    @Environment(\.calendar) var calendar

    @State private var monthsToDisplay: Int = 6

    private let increment: Int = 6
    private var startOfCurrentMonth: Date? {
        Date().adjust(for: .startOfMonth, calendar: calendar)
    }

    var body: some View {
        VStack {
            Header()
            
            ScrollView {
                HStack {
                    Button("show more") {
                        monthsToDisplay = monthsToDisplay + increment
                    }
                    .buttonStyle(.bordered)
                    Button("show less") {
                        monthsToDisplay = max(monthsToDisplay - increment, 1)
                    }
                    .disabled(monthsToDisplay == 1)
                    .buttonStyle(.bordered)
                }
                LazyVStack(spacing: 12) {
                    ForEach((0..<monthsToDisplay).reversed(), id: \.self) { rowIndex in
                        Month(startOfMonth: (startOfCurrentMonth!).offset(.month, value: rowIndex * -1)!)
                    }
                }
                    .scrollTargetLayout()
                    .padding(.vertical, 4)
            }
            .scrollTargetBehavior(.viewAligned)
            .defaultScrollAnchor(.bottom)
        }
        .frame(maxWidth: .infinity)
    }
    

}

extension HistoryView {
    private struct Header: View {
        var body: some View {
            VStack {
                HStack(spacing: 0) {
                    ForEach(0..<CalendarUtils.shared.weekDays.count, id: \.self) { index in
                        Text(CalendarUtils.shared.weekDays[index])
                            .fontDesign(.rounded)
                            .foregroundStyle(index < 5 ? .primary : .secondary)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                Divider()
            }
        }
    }
}

fileprivate struct Month: View {
    @Environment(\.calendar) var calendar
    
    var startOfMonth: Date
    
    private var weeks: [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: startOfMonth)
        else { return [] }
        
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(weekday: calendar.firstWeekday)
        )
    }
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(spacing: 4), count: 7)
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(startOfMonth.toString(format: .custom("MMMM yyyy")) ?? "")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)

                LazyVGrid(columns: columns, content: {
                    ForEach(weeks, id: \.self) { week in
                        ForEach(getDaysInWeek(week), id: \.self) { day in
                            if (day.compare(.isSameMonth(as: startOfMonth))) {
                                // TODO: correct alignment
                                Text("\(day.toString(format: .custom("d")) ?? "")")
                                    .monospacedDigit()
                                    .foregroundStyle(day.compare(.isWeekend) ? .secondary : .primary)
                            } else {
                                Spacer()
                            }
                        }
                    }
                })
            }
            
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getDaysInWeek(_ week: Date) -> [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
        else { return [] }
        
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
            HistoryView()
                .padding()
    }
}
