//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

struct Dashboard: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.editMode) private var editMode

    var body: some View {
        NavigationView {
            Group {
                if viewModel.habits.isEmpty {
                    VStack {
                        Spacer()
                        EmptyState() {
                            viewModel.showingAddHabit = true
                        }
                        .padding()
                        Spacer()
                        Spacer()
                    }.padding(.horizontal)
                } else {
                    VStack {
                        List {
                            ForEach(viewModel.habits) { habit in
                                DashboardItem(habit: habit, toggleEntry: { viewModel.toggleEntry(for: $0, on: $1) } )
                                    .background(
                                        // TODO: add a lazy view here
                                        NavigationLink("", destination: HabitView(habit)).opacity(0)
                                    )
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button(habit.hasEntry(for: Date.now) ? "Untick" : "Tick") {
                                            viewModel.toggleEntry(for: habit, on: Date.now)
                                        }.tint(.blue)
                                    }
                            }
                            .onMove {  viewModel.reorderElements(source: $0, destination: $1) }
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.habits.isEmpty {
                        Button {
                            viewModel.showingAddHabit = true
                        } label: {
                            Label("Add new habit", systemImage: "plus")
                                .labelStyle(IconOnlyLabelStyle())
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddHabit) {
                AddHabitView()
            }
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}

