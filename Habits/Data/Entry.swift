//
//  Entry.swift
//  Habits
//
//  Created by Christian Ost on 07.12.23.
//
//

import Foundation
import SwiftData

typealias Entry = HabitsSchemaV130.Entry

extension HabitsSchemaV110 {
    @Model
    class Entry {
        var date: Date

        @Relationship var habit: HabitsSchemaV110.Habit?

        init(date: Date, habit: HabitsSchemaV110.Habit) {
            self.date = date
            self.habit = habit
        }
    }
}

extension HabitsSchemaV120 {
    @Model
    class Entry {
        var date: Date
        var day: String?

        @Relationship var habit: HabitsSchemaV120.Habit?

        init(date: Date, habit: HabitsSchemaV120.Habit) {
            self.date = date
            self.day = Self.dayString(from: date)
            self.habit = habit
        }

        static func dayString(from date: Date) -> String {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f.string(from: date)
        }
    }
}

extension HabitsSchemaV130 {
    @Model
    class Entry {
        var day: String = ""

        @Relationship var habit: HabitsSchemaV130.Habit?

        init(date: Date, habit: HabitsSchemaV130.Habit) {
            self.day = Self.dayString(from: date)
            self.habit = habit
        }

        init(day: String, habit: HabitsSchemaV130.Habit) {
            self.day = day
            self.habit = habit
        }

        static func dayString(from date: Date) -> String {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f.string(from: date)
        }

        static func date(from dayString: String) -> Date? {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f.date(from: dayString)
        }
    }
}
