//
//  DashboardView.swift
//  habits
//
//  Created by Christian Ost on 15.03.22.
//

import CoreData
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var habitsStorage: HabitsStorage

    var body: some View {
        VStack {
            List {
                if habitsStorage.habits.isEmpty {
                    Text("No habits yet - go and create one!")
                } else {
                    ForEach(habitsStorage.habits) { habit in
                        DashboardItem(habit: habit)
                    }
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
