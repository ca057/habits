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
    private let dayChangedPublisher = NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
    
    @State private var today = Date.now
    @State private var navigation = Navigation()

    var body: some View {
        NavigationStack(path: $navigation.path) {
            Dashboard(showUntil: today)
                .navigationDestination(for: Habit.self) { habit in
                    SingleHabitView(id: habit.id) // TODO: pass in habit
                }
        }
        .tint(.primary)
        .environment(\.navigation, navigation)
        .environment(\.calendar, CalendarUtils.shared.calendar)
        .onReceive(dayChangedPublisher, perform: { _ in today = Date.now })
    }
}
