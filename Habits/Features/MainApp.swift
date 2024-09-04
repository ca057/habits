//
//  App.swift
//  Habits
//
//  Created by Christian Ost on 29.03.23.
//

import SwiftUI

@Observable final class Navigation {
    var path = NavigationPath()
    
    // TODO: expose method for pop to top
}

private struct NavigationPathEnvironment: EnvironmentKey {
    static let defaultValue: Navigation = Navigation()
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
    
    @AppStorage(SettingProperties.overviewDateRangeKey) private var overviewDateRange = SettingProperties.OverviewDateRange.pastSevenDays
    
    private var overviewDateInterval: (from: Date, to: Date) {
        if overviewDateRange == .pastSevenDays {
            return (from: today.offset(.day, value: -6) ?? Date.now, to: today)
        }
        return (
            from: today.adjust(for: .startOfWeek, calendar: calendar) ?? today,
            to: today.adjust(for: .endOfWeek, calendar: calendar) ?? today
        )
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            Overview(from: overviewDateInterval.from, to: overviewDateInterval.to)
                .navigationDestination(for: Habit.self) { habit in
                    SingleHabitView(id: habit.id) // TODO: pass in habit
                }
        }
        .tint(.primary)
        .environment(\.navigation, navigation)
        .reactOnDayChange(perform: { today = $0 })
    }
}
