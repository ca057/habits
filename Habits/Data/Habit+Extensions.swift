//
//  Habit+Extensions.swift
//  Habits
//
//  Created by Christian Ost on 04.04.22.
//

import Foundation

extension Habit {
    func hasEntry(for date: Date) -> Bool {
        self.entry.contains(where: { entry in
            return Calendar.current.isDate(entry.date, equalTo: date, toGranularity: .day)
        })
    }
}
