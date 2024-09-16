//
//  SingleHabitAnalysis.swift
//  Habits
//
//  Created by Christian Ost on 16.09.24.
//

import Foundation

struct SingleHabitAnalysis {
    var achievedDays: Set<String>

    var achievedScore: Double
    var achievableDayCount: Int
    
    static func forYear(_ year: Date, calendar: Calendar, entries: [Entry]) -> SingleHabitAnalysis {
        var achievableDays: Int {
            guard let startOfYear = year.adjust(for: .startOfYear),
                  let endOfToday = year.adjust(for: year.compare(.isThisYear) ? .endOfDay : .endOfYear)
            else { return 0 }
            
            return Int(ceil(Double(calendar.dateComponents([.hour], from: startOfYear, to: endOfToday).hour ?? 0) / 24))
        }
        var achievedOfYear: [Date] {
            entries.reduce(into: [Date]()) { res, e in
                if e.date.compare(.isSameYear(as: year)) {
                    res.append(e.date)
                }
            }
        }
        
        return SingleHabitAnalysis(
            achievedDays: Set(achievedOfYear.map { $0.toString(format: .isoDate) ?? "" }),
            achievedScore: (Double(achievedOfYear.count) / Double(achievableDays) * 100).rounded() / 100,
            achievableDayCount: achievableDays
        )
    }
}
