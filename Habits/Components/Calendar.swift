//
//  Heatmap.swift
//  Habits
//
//  Created by Christian Ost on 14.03.23.
//

import SwiftUI
import DateHelper

enum CalendarError: Error {
    case dateNotFound
}

class CalendarHelper {
    static var shared = CalendarHelper()
    
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
        calendar.minimumDaysInFirstWeek = 4 // TODO: figure out why
        return calendar
    }
    
    var weekDays: [String] {
        var day = Date().adjust(for: .startOfWeek, calendar: calendar)
        var weekDays = [String]()
        
        for _ in 0...6 {
            weekDays.append(
                day?.toString(
                    format: .custom("EEE"),
                    locale: Locale(identifier: Locale.current.language.languageCode?.identifier ?? "en")
                ) ?? ""
            )
            day = day?.offset(.day, value: 1)
        }
        
        return weekDays
    }
    
    func isCurrentYear(_ year: Int) -> Bool {
        calendar.component(.year, from: Date()) == year
    }
    
    func findLastWeek(year: Int) throws -> Date {
        let lastWeekOfYear = Date(fromString: String(year), format: .isoYear)?
            .adjust(for: .endOfYear, calendar: calendar)?
            .adjust(for: .startOfWeek, calendar: calendar)
        
        if let lastWeekOfYear = lastWeekOfYear {
            return lastWeekOfYear
        }
        throw CalendarError.dateNotFound
    }
    
    func findDateInWeek(year: Int, week: Int) throws -> Date {
        let firstWeek = try? findFirstWeekInYear(year)
        let dateForRequiredWeek = firstWeek?.offset(.week, value: week)
        
        if let dateForRequiredWeek = dateForRequiredWeek {
            return dateForRequiredWeek
        }
        
        throw CalendarError.dateNotFound
    }
    
    private func findFirstWeekInYear(_ year: Int) throws -> Date {
        let firstDayOfYear = Date(fromString: String(year), format: .isoYear)?
            .adjust(for: .startOfYear, calendar: calendar)?
            .adjust(for: .startOfWeek, calendar: calendar)

        if let firstDayOfYear = firstDayOfYear, calendar.component(.weekOfYear, from: firstDayOfYear) == 1 {
            return firstDayOfYear
        }
        
        let oneWeekLater = firstDayOfYear?.offset(.week, value: 1)?.adjust(for: .startOfWeek, calendar: calendar)
        if let oneWeekLater = oneWeekLater {
            return oneWeekLater
        }
        throw CalendarError.dateNotFound
    }
}

fileprivate struct WeekRow<Content>: View where Content: View {
    var startFrom: Date
    var showYear = false // TODO: find better way of doing this
    var cell: (Date?) -> Content

    private var weekNumber: Int {
        CalendarHelper().calendar.component(.weekOfYear, from: startFrom)
    }
    var month: String? {
        let isFirstDayOfMonth = CalendarHelper().calendar.component(.day, from: startFrom) == 1
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
        
        let endOfWeek = startFrom.adjust(for: .endOfWeek, calendar: CalendarHelper().calendar) ?? startFrom
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
                    Text(CalendarHelper().calendar.component(.year, from: startFrom).description)
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

fileprivate struct YearGrid<Content>: View where Content: View {
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
    
    init(_ year: Int, weeks: Int, cell: @escaping (Date?) -> Content) {
        self.weeksToShow = min(weeks, 52)
        self.cell = cell
        
        if CalendarHelper().isCurrentYear(year) {
            self.latestMondayForYear = try? CalendarHelper().findDateInWeek(year: year, week: weeks - 1)
        } else {
            self.latestMondayForYear = try? CalendarHelper().findLastWeek(year: year)
        }
    }
}

//struct YearGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        Grid {
//            YearGrid(2023, weeks: 20) { date in
//                if let date = date {
//                    Text("\(CalendarHelper().calendar.component(.day, from: date).description)")
//                } else {
//                    Text("N/A")
//                }
//            }
//        }
//    }
//}

fileprivate struct WeekDaysGridHeader: View {
    var body: some View {
        GridRow {
            HStack { Spacer().frame(width: 0) }
            ForEach(0..<CalendarHelper().weekDays.count, id: \.self) { index in
                Text(CalendarHelper().weekDays[index])
                    .font(.subheadline)
                    .fontWeight(index < 5 ? .regular : .light)
            }
        }
    }
}

struct ReverseCalendarView<Content>: View where Content: View {
    var endDate: Date
    @ViewBuilder var cell: (Date?) -> Content
    
    private let calendar = CalendarHelper().calendar
    
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
        var yearsToDisplay = Double(weeksToDisplay - startWeekNumber) / Double(52)
        yearsToDisplay.round(.up)
        return Int(yearsToDisplay) + 1 // initial week
    }

    var body: some View {
        VStack {
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                WeekDaysGridHeader()
                
                Divider().padding(.vertical, 4)
                
                ForEach(0..<yearsCount, id: \.self) { i in
                    let currentYear = startYear - i
                    let weeks = currentYear == startYear ? startWeekNumber : min(weeksToDisplay - startWeekNumber - 52 * (i - 1), 52)
                    
                    YearGrid(currentYear, weeks: weeks, cell: cell)
                    HStack {}.padding(.bottom)
                }
            }
        }
    }
}

struct ReverseCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ReverseCalendarView(endDate: Date.now.advanced(by: 60 * 60 * 24 * 120 * -1)) { date in
            if let date = date {
                Text("\(CalendarHelper().calendar.component(.day, from: date).description)")
            } else {
                Text("N/A")
            }
        }
        .padding()
    }
}
