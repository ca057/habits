//
//  DashboardView.swift
//  habits
//
//  Created by Christian Ost on 15.03.22.
//

import CoreData
import SwiftUI

struct DashboardView: View {
    @ObservedObject private var viewModel = DashboardViewModel()
    @Environment(\.editMode) private var editMode

    var body: some View {
        List {
            if viewModel.habits.isEmpty {
                Text("No habits yet - go and create one!")
            } else {
                ForEach(viewModel.habits) { habit in
                    DashboardItem(habit: habit)
                        .background(
                                NavigationLink("", destination: HabitView(habit)).opacity(0)
                        )
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(habit.hasEntry(for: Date.now) ? "Untick" : "Tick") {
                                viewModel.toggleLatestEntry(for: habit)
                            }.tint(.blue)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                viewModel.requestToDelete(habit)
                            }
                        }
                }
                .onMove(perform: viewModel.reorderElements)
                .onDelete { _ in }
            }
        }
        .alert("Delete habit?", isPresented: $viewModel.showingDeleteHabitConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteHabit()
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
