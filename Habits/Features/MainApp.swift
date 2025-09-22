//
//  App.swift
//  Habits
//
//  Created by Christian Ost on 29.03.23.
//

import SwiftUI
import SwiftData

@Observable final class Navigation {
    var path = NavigationPath()
    
    // TODO: expose method for pop to top
}

private struct NavigationPathEnvironment: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: Navigation = Navigation()
}

extension EnvironmentValues {
    var navigation: Navigation {
        get { self[NavigationPathEnvironment.self] }
        set { self[NavigationPathEnvironment.self] = newValue }
    }
}

struct MainApp: View {
    @Environment(\.calendar) private var calendar

    @State private var today = Date.now
    @State private var navigation = Navigation()
    @Query(Habit.sortedWithEntries) private var habits: [Habit]
    
    private var overviewDateInterval: (from: Date, to: Date) {
        (from: today.offset(.day, value: -6) ?? Date.now, to: today)
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            NextOverview(habits: habits, from: overviewDateInterval.from, to: overviewDateInterval.to)
                .navigationDestination(for: Habit.self) { habit in
                    SingleHabitView(id: habit.id) // TODO: pass in habit
                }

//            Overview(from: overviewDateInterval.from, to: overviewDateInterval.to)
//                .navigationDestination(for: Habit.self) { habit in
//                    SingleHabitView(id: habit.id) // TODO: pass in habit
//                }
        }
        .tint(.primary)
        .environment(\.navigation, navigation)
        .reactOnDayChange(perform: { today = $0 })
    }
}
