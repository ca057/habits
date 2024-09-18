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
        
    let now = Date.now

    @Test func oldestDate() {
        let olderDate = calendar.date(byAdding: .day, value: -10, to: Date.now)!

        #expect(calendar.oldestDate(olderDate, now) == olderDate)
        #expect(calendar.oldestDate(now, olderDate) == olderDate)
        #expect(calendar.oldestDate(now, now) == now)
    }

    @Test func newestDate() {
        let olderDate = calendar.date(byAdding: .day, value: -10, to: Date.now)!

        #expect(calendar.newestDate(olderDate, now) == now)
        #expect(calendar.newestDate(now, olderDate) == now)
        #expect(calendar.newestDate(now, now) == now)
    }
}
