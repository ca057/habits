//
//  ReversedCalendarGridElements.swift
//  Habits
//
//  Created by Christian Ost on 27.03.23.
//

import SwiftUI

extension ReversedCalendar {
    struct WeekRow<Content>: View where Content: View {
        var startFrom: Date
        var showYear = false // TODO: find better way of doing this
        var cell: (Date?) -> Content
        
        private let calendar = CalendarUtils.shared.calendar
        private var weekNumber: Int { calendar.component(.weekOfYear, from: startFrom) }
        
        private var month: String? {
            let isFirstDayOfMonth = calendar.component(.day, from: startFrom) == 1
            if isFirstDayOfMonth {
                return startFrom.toString(format: .custom("MMM"))?.description
            }
            
            let firstDayOfYear = startFrom.adjust(for: .startOfYear)
            if let firstDayOfYear = firstDayOfYear {
                let isFirstFullWeekOfYear = startFrom.compare(.isSameWeek(as: firstDayOfYear))
                if isFirstFullWeekOfYear {
                    return startFrom.toString(format: .custom("MMM"))?.description
                }
            }
            
            let endOfWeek = startFrom.adjust(for: .endOfWeek, calendar: calendar) ?? startFrom
            let weekIsStartOfNewMonth = !startFrom.compare(.isSameMonth(as: endOfWeek))
            let endOfWeekIsSameYear = startFrom.compare(.isSameYear(as: endOfWeek))
            
            if weekIsStartOfNewMonth && endOfWeekIsSameYear {
                return endOfWeek.toString(format: .custom("MMM"))?.description
            }
            
            return nil
        }
        
        var body: some View {
            GridRow {
                let wouldShowMonth = month != nil
                if wouldShowMonth || showYear {
                    if showYear {
                        Text(calendar.component(.year, from: startFrom).description)
                            .font(.footnote.bold().monospacedDigit())
                    } else if let month = month {
                        Text(month)
                            .font(.footnote)
                            .gridColumnAlignment(.leading)
                    }
                } else {
                    HStack { Spacer() }
                }
                
                ForEach(0..<7, id: \.self) { dayNumber in
                    let currentDay = startFrom.offset(.day, value: dayNumber)
                    if let currentDay = currentDay {
                        cell(currentDay)
                    } else {
                        EmptyView()
                    }
                    
                }
            }
        }
    }
    
    struct YearGridRows<Content>: View where Content: View {
        private var weeksToShow: Int
        private var latestMondayForYear: Date?
        private var cell: (Date?) -> Content
        
        var body: some View {
            if let lastMonday = latestMondayForYear {
                ForEach(0..<weeksToShow, id: \.self) { i in
                    let mondayOfWeek = lastMonday.offset(.week, value: i * -1)
                    
                    if let mondayOfWeek = mondayOfWeek {
                        WeekRow(startFrom: mondayOfWeek, showYear: mondayOfWeek.compare(.isSameDay(as: lastMonday)), cell: cell)
                    }
                }
            } else {
                EmptyView()
            }
        }
        
        init(_ year: Int, weeks: Int, @ViewBuilder cell: @escaping (Date?) -> Content) {
            self.weeksToShow = min(weeks, 52)
            self.cell = cell
            
            if CalendarUtils.shared.isCurrentYear(year) {
                let currentWeekNumber = CalendarUtils.shared.calendar.component(.weekOfYear, from: Date())

                self.latestMondayForYear = try? CalendarUtils.shared.findDateInWeek(year: year, week: currentWeekNumber)
            } else {
                self.latestMondayForYear = try? CalendarUtils.shared.findLastWeek(year: year)
            }
        }
    }

    struct WeekDaysGridHeader: View {
        var body: some View {
            GridRow {
                HStack { Spacer().frame(width: 0) }
                ForEach(0..<CalendarUtils.shared.weekDays.count, id: \.self) { index in
                    Text(CalendarUtils.shared.weekDays[index])
                        .font(.subheadline)
                        .fontWeight(index < 5 ? .regular : .light)
                }
            }
        }
    }

}
