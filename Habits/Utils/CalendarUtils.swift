//
//  CalendarUtils.swift
//  Habits
//
//  Created by Christian Ost on 27.03.23.
//

import Foundation
import DateHelper

fileprivate enum CalendarUtilsError: Error {
    case dateNotFound
}

class CalendarUtils {
    static var shared = CalendarUtils()
    
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.autoupdatingCurrent
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
    
    var months: [String] {
        var beginningOfMonth = Date().adjust(for: .startOfYear, calendar: calendar)
        var months = [String]()
        
        for _ in 0...12 {
            months.append(
                beginningOfMonth?.toString(
                    format: .custom("MMM"),
                    locale: Locale(identifier: Locale.current.language.languageCode?.identifier ?? "en")
                ) ?? ""
            )
            beginningOfMonth = beginningOfMonth?.offset(.month, value: 1)
        }
        
        return months
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
        throw CalendarUtilsError.dateNotFound
    }
    
    func findDateInWeek(year: Int, week: Int) throws -> Date {
        let firstWeek = try? findFirstWeekInYear(year)
        let dateForRequiredWeek = firstWeek?.offset(.week, value: week)
        
        if let dateForRequiredWeek = dateForRequiredWeek {
            return dateForRequiredWeek
        }
        
        throw CalendarUtilsError.dateNotFound
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
        throw CalendarUtilsError.dateNotFound
    }
}
