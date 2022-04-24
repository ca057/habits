//
//  HabitView.swift
//  habits
//
//  Created by Christian Ost on 19.02.22.
//

import SwiftUI

struct HabitView: View {
    var habit: Habit

    var body: some View {
        VStack {
            Text(habit.name ?? "")
        }
            .navigationTitle(habit.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
}

//struct HabitView_Previews: PreviewProvider {
//    static var previews: some View {
//        HabitView()
//    }
//}
