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

    private var startOfCurrentMonth: Date? {
        Date().adjust(for: .startOfMonth, calendar: calendar)
    }

    var body: some View {
        ExpandableRows(
            minimumRows: 2,
            increment: 1,
            header: { Header() },
            incRowsButton: { action in Button("show more", action: action) },
            decRowsButton: { action in Button("show less", action: action) }
        ) { rowIndex in
            Month(startOfMonth: (startOfCurrentMonth!).offset(.month, value: rowIndex * -1)!)
            // TODO: year divider
        }
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
                            .fontWeight(index < 5 ? .bold : .regular)
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
                        } else {
                            Spacer()
                        }
                    }
                }
            })
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
