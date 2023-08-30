//
//  ReversedCalendar.swift
//  Habits
//
//  Created by Christian Ost on 27.03.23.
//

import SwiftUI

struct ReversedCalendar<Content>: View where Content: View {
    var endDate: Date
    @ViewBuilder var cell: (Date?) -> Content
    
    private let calendar = CalendarUtils.shared.calendar
    
    private var startDate: Date {
        Date().adjust(for: .startOfWeek, calendar: calendar) ?? Date()
    }
    private var startWeekNumber: Int { calendar.component(.weekOfYear, from: startDate) }
    private var startYear: Int { calendar.component(.year, from: startDate) }
    
    private var weeksToDisplay: Int {
        var distanceInWeeks = Double(startDate.since(endDate, in: .day) ?? 0) / 7
        distanceInWeeks.round(.up)
        return min(Int(distanceInWeeks), 52)
    }
    private var yearsCount: Int {
        var yearsToDisplay = Double(startWeekNumber - weeksToDisplay) / Double(52)
        yearsToDisplay.round(.up)
        return Int(yearsToDisplay)
    }
    
    var body: some View {
        VStack {
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                WeekDaysGridHeader()
                
                Divider().padding(.vertical, 4)
                
                ForEach(0..<yearsCount, id: \.self) { i in
                    let currentYear = startYear - i
                    
                    YearGridRows(currentYear, weeks: min(weeksToDisplay, 52), cell: cell)
                    HStack {}.padding(.bottom)
                }
            }
        }
    }
}


struct ReversedCalendar_Previews: PreviewProvider {
    static var previews: some View {
        ReversedCalendar(endDate: Date.now.advanced(by: 60 * 60 * 24 * 120 * -1)) { date in
            if let date = date {
                Text("\(CalendarUtils.shared.calendar.component(.day, from: date).description)")
            } else {
                Text("N/A")
            }
        }
        .padding()
    }
}
