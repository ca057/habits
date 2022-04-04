//
//  Habit+Extensions.swift
//  Habits
//
//  Created by Christian Ost on 04.04.22.
//

import Foundation

extension Habit {
    func hasEntry(for date: Date) -> Bool {
        self.entry?.contains(where: {
            guard let entryDate = ($0 as? Entry)?.date else {
                return false
            }
            return Calendar.current.isDate(entryDate, equalTo: date, toGranularity: .day)
        }) ?? false
    }
}
