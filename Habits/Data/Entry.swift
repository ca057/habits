//
//  Entry.swift
//  Habits
//
//  Created by Christian Ost on 07.12.23.
//
//

import Foundation
import SwiftData


@Model
class Entry {
    var date: Date

    @Relationship var habit: Habit?
    
    init(date: Date, habit: Habit) {
        self.date = date
        self.habit = habit
    }
}
