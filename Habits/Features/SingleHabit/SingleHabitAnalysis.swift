//
//  SingleHabitAnalysis.swift
//  Habits
//
//  Created by Christian Ost on 16.09.24.
//

import Foundation

struct SingleHabitAnalysis {
    var achievedDays: Set<String>

    var achievedCompletion: Double
    var achievableDayCount: Int
    
    var firstRelevantDate: Date
    
    static func forYear(_ year: Date, calendar: Calendar, habit: Habit, entries: [Entry]) -> SingleHabitAnalysis {
        let startOfYear = year.adjust(for: .startOfYear)!
        let firstRelevantDate = calendar.oldestDate(habit.createdAt, entries.sorted { a, b in a.date < b.date }.first?.date ?? habit.createdAt)

        let achievedOfYear = entries
            .reduce(into: [Date]()) { res, e in
                if e.date.compare(.isSameYear(as: year)) {
                    res.append(e.date)
                }
            }
        
        var achievableDays: Int {
            guard let endOfToday = year.adjust(for: year.compare(.isThisYear) ? .endOfDay : .endOfYear)
            else { return 0 }
            
            let start = calendar.isDate(startOfYear, equalTo: firstRelevantDate, toGranularity: .year) ? firstRelevantDate : startOfYear
            
            return Int(ceil(Double(calendar.dateComponents([.hour], from: start, to: endOfToday).hour ?? 0) / 24))
        }
        
        return SingleHabitAnalysis(
            achievedDays: Set(achievedOfYear.map { $0.toString(format: .isoDate) ?? "" }),
            achievedCompletion: (Double(achievedOfYear.count) / Double(achievableDays) * 100).rounded() / 100,
            achievableDayCount: achievableDays,
            firstRelevantDate: firstRelevantDate
        )
    }
}
