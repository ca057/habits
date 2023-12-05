//
//  HistoryMonthView.swift
//  Habits
//
//  Created by Christian Ost on 04.12.23.
//

import SwiftUI

struct HistoryMonthView<Content>: View where Content: View {
    @Environment(\.calendar) var calendar
    
    var startOfMonth: Date
    @ViewBuilder var cell: (Date) -> Content
    
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
        Array(repeating: GridItem(spacing: 8), count: 7)
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("\(startOfMonth.toString(format: .custom("MMMM yyyy")) ?? "")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)

                LazyVGrid(columns: columns, content: { // TODO: consider non-lazy grid
                    ForEach(weeks, id: \.self) { week in
                        ForEach(getDaysInWeek(week), id: \.self) { day in
                            if (day.compare(.isSameMonth(as: startOfMonth))) {
                                cell(day)
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

#Preview {
    HistoryMonthView(
        startOfMonth: Date.now,
        cell: { date in
            Text(date.toString(format: .custom("d")) ?? "")
                .opacity(date.compare(.isInTheFuture) ? 0.5 : 1)
        }
    )
}
