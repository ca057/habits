//
//  SingleHabitAnalysis.swift
//  Habits
//
//  Created by Christian Ost on 16.09.24.
//

import Foundation

struct HabitDetailAnalysis {
    var achievedDays: Set<String>

    var achievedCompletion: Double
    var achievableDayCount: Int
    
    var firstRelevantDate: Date
    
    static func forYear(_ year: Date, calendar: Calendar, habit: Habit, entries: [Entry]) -> HabitDetailAnalysis {
        let startOfYear = year.adjust(for: .startOfYear)!
        let oldestEntryDate = entries.map { $0.day }.min().flatMap { Entry.date(from: $0) }
        let firstRelevantDate = calendar.oldestDate(habit.createdAt, oldestEntryDate ?? habit.createdAt)

        let yearPrefix = String(calendar.component(.year, from: year))
        let achievedDaysOfYear = entries.filter { $0.day.hasPrefix(yearPrefix) }.map { $0.day }

        var achievableDays: Int {
            guard let endOfToday = year.adjust(for: year.compare(.isThisYear) ? .endOfDay : .endOfYear)
            else { return 0 }

            let start = calendar.isDate(startOfYear, equalTo: firstRelevantDate, toGranularity: .year) ? firstRelevantDate : startOfYear

            return Int(ceil(Double(calendar.dateComponents([.hour], from: start, to: endOfToday).hour ?? 0) / 24))
        }

        return HabitDetailAnalysis(
            achievedDays: Set(achievedDaysOfYear),
            achievedCompletion: (Double(achievedDaysOfYear.count) / Double(achievableDays) * 100).rounded() / 100,
            achievableDayCount: achievableDays,
            firstRelevantDate: firstRelevantDate
        )
    }
}
