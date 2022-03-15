//
// Created by Christian Ost on 13.03.22.
//

import Foundation

class HabitViewModel: ObservableObject {
    @Published public var habit: Habit
    
    init() {
        self.habit = Habit(name: "Test")
    }
}
