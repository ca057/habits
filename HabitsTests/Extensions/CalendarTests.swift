//
//  CalendarTests.swift
//  HabitsTests
//
//  Created by Christian Ost on 18.09.24.
//

import SwiftUI
import Testing

struct CalendarTests {
    @MainActor private var calendar = CalendarUtils.shared.calendar

    @Test func oldestDate() {
        let oldestDate = calendar.date(byAdding: .day, value: -10, to: Date.now)!
        let now = Date.now
        
        #expect(calendar.oldestDate(oldestDate, now) == oldestDate)
        #expect(calendar.oldestDate(now, oldestDate) == oldestDate)
        #expect(calendar.oldestDate(now, now) == now)
    }

}
