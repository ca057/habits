//
//  DashboardItem.swift
//  habits
//
//  Created by Christian Ost on 24.03.22.
//

import SwiftUI

struct DashboardItem: View {
    var habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.name ?? "N/A")
                .font(.title)
                .bold()
                .padding(.top)
            Text("Started on \(habit.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                .font(.caption)
                .padding(.bottom)
        }
    }
}

// TODO: add preview again
